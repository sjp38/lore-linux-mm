Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB00C6B0069
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 14:22:51 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p9VIMlIY027212
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 11:22:48 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq12.eem.corp.google.com with ESMTP id p9VHt3HR003544
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 11:22:46 -0700
Received: by pzk2 with SMTP id 2so22982391pzk.8
        for <linux-mm@kvack.org>; Mon, 31 Oct 2011 11:22:44 -0700 (PDT)
Date: Mon, 31 Oct 2011 11:22:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] oom: fix integer overflow of points in oom_badness
In-Reply-To: <1320076569-23872-1-git-send-email-fhrbata@redhat.com>
Message-ID: <alpine.DEB.2.00.1110311120280.7271@chino.kir.corp.google.com>
References: <1320048865-13175-1-git-send-email-fhrbata@redhat.com> <1320076569-23872-1-git-send-email-fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, stable@kernel.org, eteo@redhat.com, pmatouse@redhat.com

On Mon, 31 Oct 2011, Frantisek Hrbata wrote:

> An integer overflow will happen on 64bit archs if task's sum of rss, swapents
> and nr_ptes exceeds (2^31)/1000 value. This was introduced by commit
> 
> f755a04 oom: use pte pages in OOM score
> 

This commit was introduced in 2.6.39 but also backported to stable since 
2.6.36, so presumably we'd need to mark this for stable as well going back 
that far.

> where the oom score computation was divided into several steps and it's no
> longer computed as one expression in unsigned long(rss, swapents, nr_pte are
> unsigned long), where the result value assigned to points(int) is in
> range(1..1000). So there could be an int overflow while computing
> 
> 176          points *= 1000;
> 
> and points may have negative value. Meaning the oom score for a mem hog task
> will be one.
> 
> 196          if (points <= 0)
> 197                  return 1;
> 
> For example:
> [ 3366]     0  3366 35390480 24303939   5       0             0 oom01
> Out of memory: Kill process 3366 (oom01) score 1 or sacrifice child
> 
> Here the oom1 process consumes more than 24303939(rss)*4096~=92GB physical
> memory, but it's oom score is one.
> 
> In this situation the mem hog task is skipped and oom killer kills another and
> most probably innocent task with oom score greater than one.
> 
> The points variable should be of type long instead of int to prevent the int
> overflow.
> 
> Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>
Cc: stable@kernel.org [2.6.36+]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
