Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AD9106B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:24:43 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0Ofhe013298
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:24:41 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A6A45DE4E
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:24:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 729DB45DE51
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:24:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C27D1DB805A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:24:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F1A121DB8038
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:24:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
In-Reply-To: <20101123143427.GA30941@redhat.com>
References: <20101025122914.9173.A69D9226@jp.fujitsu.com> <20101123143427.GA30941@redhat.com>
Message-Id: <20101124085022.7BDF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Nov 2010 09:24:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> On 10/25, KOSAKI Motohiro wrote:
> >
> > Because execve() makes new mm struct and setup stack and
> > copy argv. It mean the task have two mm while execve() temporary.
> > Unfortunately this nascent mm is not pointed any tasks, then
> > OOM-killer can't detect this memory usage. therefore OOM-killer
> > may kill incorrect task.
> >
> > Thus, this patch added signal->in_exec_mm member and track
> > nascent mm usage.
> 
> Stupid question.
> 
> Can't we just account these allocations in the old -mm temporary?
> 
> IOW. Please look at the "patch" below. It is of course incomplete
> and wrong (to the point inc_mm_counter() is not safe without
> SPLIT_RSS_COUNTING), and copy_strings/flush_old_exec are not the
> best places to play with mm-counters, just to explain what I mean.
> 
> It is very simple. copy_strings() increments MM_ANONPAGES every
> time we add a new page into bprm->vma. This makes this memory
> visible to select_bad_process().
> 
> When exec changes ->mm (or if it fails), we change MM_ANONPAGES
> counter back.
> 
> Most probably I missed something, but what do you think?

Because, If the pages of argv is swapping out when processing execve,
This accouing doesn't work.

Of cource, changing swapping-out logic is one of way. But I did hope
no VM core logic change. taking implict mlocking argv area during execve
is also one of option. But I did think implicit mlocking is more risky.

Is this enough explanation? Please don't hesitate say "no". If people
don't like my approach, I don't hesitate change my thinking.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
