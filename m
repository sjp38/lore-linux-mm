Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2746E6B0062
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 06:52:00 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2UAqkGU009183
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Mar 2009 19:52:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2FCA45DE59
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:52:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7608F45DE4E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:52:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FCE31DB8047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:52:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7F451DB803A
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:52:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903250043.18069.nickpiggin@yahoo.com.au>
References: <20090322205249.6801.A69D9226@jp.fujitsu.com> <200903250043.18069.nickpiggin@yahoo.com.au>
Message-Id: <20090330191830.6924.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Mar 2009 19:52:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

> > Am I missing any thing?
> 
> I still don't understand why this way is so much better than
> my last proposal. I just wanted to let that simmer down for a 
> few days :) But I'm honestly really just interested in a good
> discussion and I don't mind being sworn at if I'm being stupid,
> but I really want to hear opinions of why I'm wrong too.
> 
> Yes my patch has downsides I'm quite happy to admit. But I just
> don't see that copy-on-fork rather than wrprotect-on-fork is
> the showstopper. To me it seemed nice because it is practically
> just reusing code straight from do_wp_page, and pretty well
> isolated out of the fastpath.

Firstly, I'm very sorry for very long delay responce. This month, I'm
very busy and I don't have enough developing time ;)

Secondly, I have strongly obsession to bugfix. (I guess you alread know it)
but I don't have obsession to bugfix _way_. my patch was made for
creating good discussion, not NAK your patch.

I think your patch is good. but it have few disadvantage.
(yeah, I agree mine have lot disadvantage)

1. using page->flags
   nowadays, page->flags is one of most prime estate in linux.
   as far as possible, we can avoid to use it.
2. don't have GUP_FLAGS_PINNING_PAGE flag
   then, access_process_vm() can decow a page unnecessary.
   it isn't good feature, I think.

   IOW, I don't think "caller transparent" is important.
   minimal side effect is important more. my side-effect mean non direct-io
   effection. I don't mind direct-io path side effection. it is only used DB or
   similar software. then, we can assume a lot of userland usage.


and I was playing your patch in last week. but I conclude I can't shrink
it more.
As far as I understand, Linus don't refuse copy-on-fork itself. he only
refuse messy bugfix patch.
In general, bugfix patch should be backportable to stable tree.

Then, I think step-by-step development is better.

1. at first, merge wrprotect-on-fork.
2. improve speed.

What do you think?


btw,
Linus give me good inspiration. if page pinning happend, the patch
is guranteed to grabbed only one process.
then, we can put pinning-count and some additional information
into anon_vma. it can avoid to use page->flags although we implement 
copy-on-fork. maybe.


HOWEVER, if you really hate my approach, please don't hesitate to tell it.
I don't hope submit your disliked patch. I respect linus, but I respect you too.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
