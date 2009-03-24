Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D9D966B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 09:32:45 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Wed, 25 Mar 2009 00:43:16 +1100
References: <200903170323.45917.nickpiggin@yahoo.com.au> <20090318105735.BD17.A69D9226@jp.fujitsu.com> <20090322205249.6801.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090322205249.6801.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903250043.18069.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 22 March 2009 23:23:56 KOSAKI Motohiro wrote:
> Hi
>
> following patch is my v2 approach.
> it survive Andrea's three dio test-case.
>
> Linus suggested to change add_to_swap() and shrink_page_list() stuff
> for avoid false cow in do_wp_page() when page become to swapcache.
>
> I think it's good idea. but it's a bit radical. so I think it's for
> development tree tackle.
>
> Then, I decide to use Nick's early decow in
> get_user_pages() and RO mapped page don't use gup_fast.

You probably should be testing for PageAnon pages in gup_fast.
Also, using a bit in page->flags you could potentially get
anonymous, readonly mappings working again (I thought I had
them working in my patch, but on second thoughts perhaps I
had a bug in tagging them, I'll try to fix that).


> yeah, my approach is extream brutal way and big hammer. but I think
> it don't have performance issue in real world.
>
> why?
>
> Practically, we can assume following two thing.
>
> (1) the buffer of passed write(2) syscall argument is RW mapped
>     page or COWed RO page.
>
> if anybody write following code, my path cause performance degression.
>
>    buf = mmap()
>    memset(buf, 0x11, len);
>    mprotect(buf, len, PROT_READ)
>    fd = open(O_DIRECT)
>    write(fd, buf, len)
>
> but it's very artifactical code. nobody want this.
> ok, we can ignore this.

The more interesting uses of gup (and perhaps somewhat
improved or enabled with fast-gup) I think are things like
vmsplice, and syslets/threadlets/aio kind of things. And I
don't exactly know what the users are going to look like.


> (2) DirectIO user process isn't short lived process.
>
> early decow only decrease short lived process performaqnce.
> because long lived process do decowing anyway before exec(2).
>
> and, All DB application is definitely long lived process.
> then early decow don't cause degression.

Right, most databases won't care *at all* because they won't
do any decowing. But if there are cases that do care, then we
can perhaps take the policy of having them use MADV_DONTFORK
or somesuch.


> TODO
>   - implement down_write_killable().
>     (but it isn't important thing because this is rare case issue.)
>   - implement non x86 portion.
>
>
> Am I missing any thing?

I still don't understand why this way is so much better than
my last proposal. I just wanted to let that simmer down for a 
few days :) But I'm honestly really just interested in a good
discussion and I don't mind being sworn at if I'm being stupid,
but I really want to hear opinions of why I'm wrong too.

Yes my patch has downsides I'm quite happy to admit. But I just
don't see that copy-on-fork rather than wrprotect-on-fork is
the showstopper. To me it seemed nice because it is practically
just reusing code straight from do_wp_page, and pretty well
isolated out of the fastpath.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
