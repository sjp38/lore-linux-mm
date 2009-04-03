Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 084E76B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 23:49:18 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Fri, 3 Apr 2009 14:49:48 +1100
References: <20090322205249.6801.A69D9226@jp.fujitsu.com> <20090330191830.6924.A69D9226@jp.fujitsu.com> <200904022307.12043.nickpiggin@yahoo.com.au>
In-Reply-To: <200904022307.12043.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904031449.49594.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[sorry, resending because my mail client started sending HTML and
this didn't get through spam filters]

On Thursday 02 April 2009 23:07:11 Nick Piggin wrote:
Hi!

On Monday 30 March 2009 21:52:44 KOSAKI Motohiro wrote:
> > Hi Nick,
>
> > > Am I missing any thing?
> >
> > I still don't understand why this way is so much better than
> > my last proposal. I just wanted to let that simmer down for a
> > few days :) But I'm honestly really just interested in a good
> > discussion and I don't mind being sworn at if I'm being stupid,
> > but I really want to hear opinions of why I'm wrong too.
> >
> > Yes my patch has downsides I'm quite happy to admit. But I just
> > don't see that copy-on-fork rather than wrprotect-on-fork is
> > the showstopper. To me it seemed nice because it is practically
> > just reusing code straight from do_wp_page, and pretty well
> > isolated out of the fastpath.
>
> Firstly, I'm very sorry for very long delay responce. This month, I'm
> very busy and I don't have enough developing time ;)

No problem.


> Secondly, I have strongly obsession to bugfix. (I guess you alread know 
it)
> but I don't have obsession to bugfix _way_. my patch was made for
> creating good discussion, not NAK your patch.

Definitely. I like more discussion and alternative approaches.


> I think your patch is good. but it have few disadvantage.
> (yeah, I agree mine have lot disadvantage)
>
> 1. using page->flags
>    nowadays, page->flags is one of most prime estate in linux.
>    as far as possible, we can avoid to use it.

Well... I'm not sure if it is that bad. It uses an anonymous
page flag, which are not so congested as pagecache page flags.
I can't think of anything preventing anonymous pages from
using PG_owner_priv_1, PG_private, or PG_mappedtodisk, so a
"final" solution that uses a page flag would use one of those
I guess.


> 2. don't have GUP_FLAGS_PINNING_PAGE flag
>    then, access_process_vm() can decow a page unnecessary.
>    it isn't good feature, I think.

access_process_vm I think can just avoid COWing because it
holds mmap_sem for the duration of the operation. I just didn't
fix that because I didn't really think of it.


>    IOW, I don't think "caller transparent" is important.

Well I don't know about that. I don't know that O_DIRECT is particularly
more important to fix the problem than vmsplice, or any of the numerous
other zero-copy methods open coded in drivers.


>    minimal side effect is important more. my side-effect mean non direct-
io
>    effection. I don't mind direct-io path side effection. it is only used
> DB or similar software. then, we can assume a lot of userland usage.

I agree my patch should not be de-cowing for access_process_vm for read.
I think that can be fixed.
 
But I disagree that O_DIRECT is unimportant. I think the big database users
don't like more cost in this path, and they obviously have the capacity to
use it carefully so I'm sure they would prefer not to add anything. Intel
definitely counts cycles in the O_DIRECT path.


> and I was playing your patch in last week. but I conclude I can't shrink
> it more.
> As far as I understand, Linus don't refuse copy-on-fork itself. he only
> refuse messy bugfix patch.
> In general, bugfix patch should be backportable to stable tree.

I think assessing this type of patch based of diffstat is a bit
ridiculous ;) But I think it can be shrunk a bit if it shares a
bit of code with do_wp_page.


> Then, I think step-by-step development is better.
>
> 1. at first, merge wrprotect-on-fork.
> 2. improve speed.
>
> What do you think?
>
>
> btw,
> Linus give me good inspiration. if page pinning happend, the patch
> is guranteed to grabbed only one process.
> then, we can put pinning-count and some additional information
> into anon_vma. it can avoid to use page->flags although we implement
> copy-on-fork. maybe.

Hmm, I might try playing with that in my patch. Not so much because the
extra flag is important (as I explain above), but keeping a count will
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
