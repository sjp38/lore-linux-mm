Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A75046B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:46:20 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id l1so19356875wja.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:46:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e22si4811398wrc.236.2017.01.11.08.46.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 08:46:19 -0800 (PST)
Date: Wed, 11 Jan 2017 17:46:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Message-ID: <20170111164616.GJ16365@dhcp22.suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 11-01-17 21:52:29, Ganapatrao Kulkarni wrote:
[...]
> [ 2397.331098] cpuset01 invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1, order=0, oom_score_adj=0
> [ 2397.331100] cpuset01 cpuset=1 mems_allowed=1
[...]
> [ 2397.331206] Node 1 active_anon:5160kB inactive_anon:4968kB
> active_file:260kB inactive_file:0kB unevictable:4kB isolated(anon):0kB
> isolated(file):0kB mapped:1636kB dirty:0kB writeback:5164kB shmem:0kB
> shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1624kB writeback_tmp:0kB
> unstable:0kB pages_scanned:17440 all_unreclaimable? yes

Hmm, so we consider the whole not unreclaimable...

> [ 2397.331208] Node 1 Normal free:12046572kB min:45532kB low:62044kB

while there is 12G of free memory. That sounds fishy...

> high:78556kB active_anon:5160kB inactive_anon:4968kB active_file:260kB
> inactive_file:0kB unevictable:4kB writepending:5164kB
> present:16777216kB managed:16512808kB mlocked:4kB
> slab_reclaimable:37876kB slab_unreclaimable:42904kB
> kernel_stack:4264kB pagetables:27612kB bounce:0kB free_pcp:1968kB
> local_pcp:0kB free_cma:0kB
[...]
> [ 2397.331236] Free swap  = 15892444kB
> [ 2397.331236] Total swap = 16383996kB

There is a lot of swap space free as well.

[...]
> [ 2398.146123] cpuset01 invoked oom-killer:  gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=1, order=0, oom_score_adj=0
> [ 2398.146124] cpuset01 cpuset=1 mems_allowed=1
[...]
> [ 2398.146217] Node 1 active_anon:3948kB inactive_anon:4736kB
> active_file:528kB inactive_file:204kB unevictable:4kB
> isolated(anon):0kB isolated(file):0kB mapped:1548kB dirty:0kB
> writeback:5100kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
> anon_thp: 1724kB writeback_tmp:0kB unstable:0kB pages_scanned:16433
> all_unreclaimable? yes
> [ 2398.146220] Node 1 Normal free:12047352kB min:45532kB low:62044kB
> high:78556kB active_anon:3948kB inactive_anon:4736kB active_file:528kB
> inactive_file:204kB unevictable:4kB writepending:5100kB
> present:16777216kB managed:16512808kB mlocked:4kB
> slab_reclaimable:37876kB slab_unreclaimable:42856kB
> kernel_stack:4248kB pagetables:26644kB bounce:0kB free_pcp:1900kB
> local_pcp:120kB free_cma:0kB

Hmm, so there is another very similar oom report 1s later with similar
numbers. This doesn't look like a race when somehting else would free a
lot of memory at once. This smells like something different. Maybe we
cannot use any of the available pages for the allocation?

> [ 2398.169391] Node 1 Normal: 951*4kB (UME) 1308*8kB (UME) 1034*16kB (UME) 742*32kB (UME) 581*64kB (UME) 450*128kB (UME) 362*256kB (UME) 275*512kB (ME) 189*1024kB (UM) 117*2048kB (ME) 2742*4096kB (M) = 12047196kB

Most of the memblocks are marked Unmovable (except for the 4MB bloks)
which shouldn't matter because we can fallback to unmovable blocks for
movable allocation AFAIR so we shouldn't really fail the request. I
really fail to see what is going on there but it smells really
suspicious.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
