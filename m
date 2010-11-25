Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8538B6B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 06:06:55 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAPB6qf1005477
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Nov 2010 20:06:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ACC845DE5C
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 20:06:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B18E45DE56
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 20:06:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D276E38006
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 20:06:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 36D0AE38001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 20:06:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
In-Reply-To: <20101124110915.GA20452@redhat.com>
References: <20101124085022.7BDF.A69D9226@jp.fujitsu.com> <20101124110915.GA20452@redhat.com>
Message-Id: <20101125092237.F43A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Nov 2010 20:06:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

> > > Stupid question.
> > >
> > > Can't we just account these allocations in the old -mm temporary?
> > >
> > > IOW. Please look at the "patch" below. It is of course incomplete
> > > and wrong (to the point inc_mm_counter() is not safe without
> > > SPLIT_RSS_COUNTING), and copy_strings/flush_old_exec are not the
> > > best places to play with mm-counters, just to explain what I mean.
> > >
> > > It is very simple. copy_strings() increments MM_ANONPAGES every
> > > time we add a new page into bprm->vma. This makes this memory
> > > visible to select_bad_process().
> > >
> > > When exec changes ->mm (or if it fails), we change MM_ANONPAGES
> > > counter back.
> > >
> > > Most probably I missed something, but what do you think?
> >
> > Because, If the pages of argv is swapping out when processing execve,
> > This accouing doesn't work.
> 
> Why?
> 
> If copy_strings() inserts the new page into bprm->vma and then
> this page is swapped out, inc_mm_counter(current->mm, MM_ANONPAGES)
> becomes incorrect, yes. And we can't turn it into MM_SWAPENTS.
> 
> But does this really matter? oom_badness() counts MM_ANONPAGES +
> MM_SWAPENTS, and result is the same.

Ah, I got it. I did too strongly get stucked correct accounting. but
you mean it's not must.

Okey, I'll tackle this one at this weekend hopefully.



> > Is this enough explanation? Please don't hesitate say "no". If people
> > don't like my approach, I don't hesitate change my thinking.
> 
> Well, certainly I can't say no ;)
> 
> But it would be nice to find a more simple fix (if it can work,
> of course).
> 
> 
> And. I need a simple solution for the older kernels.

Alright. It is certinally considerable one.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
