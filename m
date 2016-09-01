Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79E2D6B025E
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 13:16:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i138so15042617wmf.1
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 10:16:58 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id qg1si6873356wjb.100.2016.09.01.10.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 10:16:56 -0700 (PDT)
Date: Thu, 1 Sep 2016 18:16:38 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
Message-ID: <20160901171637.GO2356@ZenIV.linux.org.uk>
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
 <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
 <20160804135712.GK2356@ZenIV.linux.org.uk>
 <f20e389d-2269-9aca-0fd5-019b7a042f9e@sandeen.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f20e389d-2269-9aca-0fd5-019b7a042f9e@sandeen.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Sandeen <sandeen@sandeen.net>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 01, 2016 at 08:10:44AM -0500, Eric Sandeen wrote:
> On 8/4/16 8:57 AM, Al Viro wrote:
> 
> > Don't feed the troll.  On all paths leading to that place we have
> >         result->name = kname;
> >         len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
> > or
> >                 result->name = kname;
> >                 len = strncpy_from_user(kname, filename, PATH_MAX);
> > with failure exits taken if strncpy_from_user() returns an error, which means
> > that the damn thing has already been copied into.
> > 
> > FWIW, it looks a lot like buggered kmemcheck; as usual, he can't be bothered
> > to mention which kernel version would it be (let alone how to reproduce it
> > on the kernel in question), but IIRC davej had run into some instrumentation
> > breakage lately.
> 
> The original report is in https://bugzilla.kernel.org/show_bug.cgi?id=120651
> if anyone is interested in it.

	What the hell does that one have to getname_flags(), other than having
attracted the same... something on the edge of failing the Turing Test?

	FWIW, looking at the netfilter one...  That's nf_register_net_hook()
hitting
        entry->ops      = *reg;
with reg pointing to something uninitialized (according to kmemcheck, that is,
and presuming that it's not an instrumentation bug).  With the callchain
in report, it came (all in the same assumptions) from
	nf_register_net_hooks(net, ops, hweight32(table->valid_hooks))
with hweight32(table->valid_hooks) being greater than the amount of
initialized entries in ops[] (call site in ipt_register_table()).

	This "ops" ought to be net/ipv4/netfilter/iptable_filter.c:filter_ops,
allocated by
        filter_ops = xt_hook_ops_alloc(&packet_filter, iptable_filter_hook);
in iptable_filter_init().  "table" is &packet_filter and its contents ought
to be unchanged, so ->valid_hooks in there is FILTER_VALID_HOOKS, i.e.
((1 << NF_INET_LOCAL_IN) | (1 << NF_INET_FORWARD) | (1 << NF_INET_LOCAL_OUT)).

	Which is to say, filter_ops[] had fewer than 3 initialized elements
when it got to the call of iptable_filter_table_init()...  Since filter_ops
hadn't been NULL, the xt_hook_ops_alloc() call above must've already been
done.  Said xt_hook_ops_alloc() should've allocated a 3-element array and
hooked through all of it, so it's not a wholesale uninitialized element, it's
uninitialized parts of one...

	What gets initialized is ->hook, ->pf, ->hooknum and ->priority.
Let's figure out the offsets:
	0: list (two pointers, i.e. 16 bytes)
	0x10: hook (8)
	0x18: dev (8)
	0x20: priv (8)
	0x28: pf (1)
	0x29: padding (3)
	0x2c: hooknum (4)
	0x30: priority (4)
	0x34: padding (8)
	
OK...  The address of the damn thing is apparently ffff880037b4bd80 and
we see complaint about the accesses at offsets 0, 0x18, 8, 0x20 and then
the same pattern with 0x38 and 0x70 added (i.e. the same fields in the next
two elements of the same array).  Then there are similar complaints, but
with a different call chain (iptable_mangle instead of iptable_filter).

These offsets are ->list, ->dev and ->priv, and those are exactly the ones
not initialized by xt_hook_ops_alloc().  Looking at the nf_register_net_hook(),
we have
        list_add_rcu(&entry->ops.list, elem->list.prev);
a bit further down the road.  ->dev and ->priv are left uninitialized (and
very likely - unused).

I would say it's a false positive.  struct nf_hook_ops is embedded into a
bunch of different objects, with different subsets of fields getting used.
IMO it's a bad idea (in particular, I really wonder if ->list would've
been better off moved into (some of) the containing suckers), but it's
not a bug per se, just a design choice asking for trouble.  One way of
getting kmemcheck off your back would be to switch xt_hook_ops_alloc() from
	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
to
	ops = kcalloc(num_hooks, sizeof(*ops), GFP_KERNEL);
which might have some merits beyond making kmemcheck STFU...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
