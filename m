Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 186606B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 12:45:39 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p46Gj2lS023842
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 6 May 2011 09:45:04 -0700
Received: by ewy9 with SMTP id 9so1472513ewy.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 09:45:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 6 May 2011 09:44:40 -0700
Message-ID: <BANLkTi=kxGkRS-VamLBnZCoHC7TpMsJ90w@mail.gmail.com>
Subject: Re: Batch locking for rmap fork/exit processing
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, lwoodman@redhat.com, mel@csn.ul.ie

Hmm. Andrew wasn't cc'd on this series, and usually things like this
go through the -mm tree.

Maybe Andrew saw it by virtue of the linux-mm list, but maybe he
didn't. So here he is cc'd directly.

The series looks reasonable to me,

                         Linus

On Thu, May 5, 2011 at 12:32 PM, Andi Kleen <andi@firstfloor.org> wrote:
> 012f18004da33ba67 in 2.6.36 caused a significant performance regression in
> fork/exit intensive workloads with a lot of sharing. The problem is that
> fork/exit now contend heavily on the lock of the root anon_vma.
>
> This patchkit attempts to lower this a bit by batching the lock acquisions.
> Right now the lock is taken for every shared vma individually. This
> patchkit batches this and only reaquires the lock when actually needed.
>
> When multiple processes are doing this in parallel, they will now
> spend much less time bouncing the lock cache line around. In addition
> there should be also lower overhead in the uncontended case because
> locks are relatively slow (not measured)
>
> This doesn't completely fix the regression on a 4S system, but cuts
> it down somewhat. One particular workload suffering from this gets
> about 5% faster.
>
> This is essentially a micro optimization that just tries to mitigate
> the problem a bit.
>
> Better would be to switch back to more local locking like .35 had, but I
> guess then we would be back with the old deadlocks? I was thinking also of
> adding some deadlock avoidance as an alternative.
>
> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
