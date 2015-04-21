Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2531B900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 10:42:09 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so77098879qcy.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 07:42:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d7si1990317qka.121.2015.04.21.07.42.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 07:42:08 -0700 (PDT)
Date: Tue, 21 Apr 2015 16:41:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: mempolicy ref-counting question
Message-ID: <20150421144155.GA1116@redhat.com>
References: <87pp6y31bj.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pp6y31bj.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I can't answer, so let me add cc's. I never understood mempolicy.c and
I forgot everything I learned when I added vma_dup_policy ;) and that
patch didn't change this logic as you can see.

All I can say is that it _seems_ to me you are right, split_vma() could
use mpol_get()...

At least mbind_range() lools suboptimal. split_vma() creates a copy, and
right after that vma_replace_policy() does another mpol_dup().

On 04/21, Rasmus Villemoes wrote:
>
> I'm trying to understand why "git grep mpol_get" doesn't give more hits
> than it does. Two of the users (kernel/sched/debug.c and
> fs/proc/task_mmu.c) seem to only hold the extra reference while writing
> to a seq_file. That leaves just three actual users.
>
> In particular, I'm wondering why __split_vma (and copy_vma) use
> vma_dup_policy instead of simply getting an extra reference on the
> old. I see there's some cpuset_being_rebound dance in mpol_dup, but I
> don't understand why that's needed: In __split_vma, we're holding
> mmap_sem, so either update_tasks_nodemask has already visited this mm
> via mpol_rebind_mm (which also takes the mmap_sem), so the old vma is
> already rebound, or the mpol_rebind_mm call will come later and rebind
> the mempolicy of both the old and new vma - why would it matter that the
> new vma's policy is rebound immediately?
>
> I'd appreciate it if someone could enlighten me (I'm probably
> missing something obvious).
>
> Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
