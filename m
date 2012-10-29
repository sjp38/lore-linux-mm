Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 028836B0072
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 12:14:14 -0400 (EDT)
Date: Mon, 29 Oct 2012 12:14:12 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and naive
	hashtable
Message-ID: <20121029161412.GB18944@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <20121029112907.GA9115@Krystal> <CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On Mon, Oct 29, 2012 at 7:29 AM, Mathieu Desnoyers
> <mathieu.desnoyers@efficios.com> wrote:
> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> +
> >> +     for (i = 0; i < sz; i++)
> >> +             INIT_HLIST_HEAD(&ht[sz]);
> >
> > ouch. How did this work ? Has it been tested at all ?
> >
> > sz -> i
> 
> Funny enough, it works perfectly. Generally as a test I boot the
> kernel in a VM and let it fuzz with trinity for a bit, doing that with
> the code above worked flawlessly.
> 
> While it works, it's obviously wrong. Why does it work though? Usually
> there's a list op happening pretty soon after that which brings the
> list into proper state.
> 
> I've been playing with a patch that adds a magic value into list_head
> if CONFIG_DEBUG_LIST is set, and checks that magic in the list debug
> code in lib/list_debug.c.
> 
> Does it sound like something useful? If so I'll send that patch out.

Most of the calls to this initialization function apply it on zeroed
memory (static/kzalloc'd...), which makes it useless. I'd actually be in
favor of removing those redundant calls (as I pointed out in another
email), and document that zeroed memory don't need to be explicitly
initialized.

Those sites that need to really reinitialize memory, or initialize it
(if located on the stack or in non-zeroed dynamically allocated memory)
could use a memset to 0, which will likely be faster than setting to
NULL on many architectures.

About testing, I'd recommend taking the few sites that still need the
initialization function, and just initialize the array with garbage
before calling the initialization function. Things should blow up quite
quickly. Doing it as a one-off thing might be enough to catch any issue.
I don't think we need extra magic numbers to catch issues in this rather
obvious init function.

Thanks,

Mathieu

> 
> 
> Thanks,
> Sasha

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
