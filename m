Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 954426B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:30:10 -0400 (EDT)
Received: by pacan13 with SMTP id an13so3726456pac.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:30:10 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id kt9si8635214pab.169.2015.07.29.03.30.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 03:30:09 -0700 (PDT)
Received: by pacan13 with SMTP id an13so3726192pac.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:30:09 -0700 (PDT)
Date: Wed, 29 Jul 2015 19:30:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
Message-ID: <20150729102849.GA19352@bgram>
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
 <55B88FF1.7050502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B88FF1.7050502@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

Hi Jerome,

On Wed, Jul 29, 2015 at 10:33:53AM +0200, Jerome Marchand wrote:
> On 06/15/2015 03:06 PM, Minchan Kim wrote:
> > We want to know per-process workingset size for smart memory management
> > on userland and we use swap(ex, zram) heavily to maximize memory efficiency
> > so workingset includes swap as well as RSS.
> > 
> > On such system, if there are lots of shared anonymous pages, it's
> > really hard to figure out exactly how many each process consumes
> > memory(ie, rss + wap) if the system has lots of shared anonymous
> > memory(e.g, android).
> > 
> > This patch introduces SwapPss field on /proc/<pid>/smaps so we can get
> > more exact workingset size per process.
> > 
> > Bongkyu tested it. Result is below.
> > 
> > 1. 50M used swap
> > SwapTotal: 461976 kB
> > SwapFree: 411192 kB
> > 
> > $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum += $2} END {print sum}';
> > 48236
> > $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum += $2} END {print sum}';
> > 141184
> 
> Hi Minchan,
> 
> I just found out about this patch. What kind of shared memory is that?
> Since it's android, I'm inclined to think something specific like
> ashmem. I'm asking because this patch won't help for more common type of
> shared memory. See my comment below.

It's normal heap of parent(IOW, MAP_ANON|MAP_PRIVATE memory which is share
 by child processes).

> 
> > 
> > 2. 240M used swap
> > SwapTotal: 461976 kB
> > SwapFree: 216808 kB
> > 
> > $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum += $2} END {print sum}';
> > 230315
> > $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum += $2} END {print sum}';
> > 1387744
> > 
> snip
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 6dee68d013ff..d537899f4b25 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -446,6 +446,7 @@ struct mem_size_stats {
> >  	unsigned long anonymous_thp;
> >  	unsigned long swap;
> >  	u64 pss;
> > +	u64 swap_pss;
> >  };
> >  
> >  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> > @@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
> >  	} else if (is_swap_pte(*pte)) {
> 
> This won't work for sysV shm, tmpfs and MAP_SHARED | MAP_ANONYMOUS
> mapping pages which are pte_none when paged out. They're currently not
> accounted at all when in swap.

This patch doesn't handle those pages because we don't have supported
thoses pages. IMHO, if someone need it, it should be another patch and
he can contribute it in future.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
