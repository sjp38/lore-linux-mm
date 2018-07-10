Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2886B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 08:32:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d30-v6so3248251edd.0
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:32:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11-v6si2016753edo.400.2018.07.10.05.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 05:32:23 -0700 (PDT)
Date: Tue, 10 Jul 2018 14:32:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: post linux 4.4 vm oom kill, lockup and thrashing woes
Message-ID: <20180710123222.GK14284@dhcp22.suse.cz>
References: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710120755.3gmin4rogheqb3u5@schmorp.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Lehmann <schmorp@schmorp.de>
Cc: linux-mm@kvack.org

On Tue 10-07-18 14:07:56, Marc Lehmann wrote:
> (I am not subscribed)
> 
> Hi!
> 
> While reporting another (not strictly related) kernel bug
> (https://bugzilla.kernel.org/show_bug.cgi?id=199931) I was encouraged to
> report my problem here, even though, in my opinion, I don't have enough
> hard data for a good bug report, so bear with me, please.
> 
> Basically, the post 4.4 VM system (I think my troubles started around 4.6
> or 4.7) is nearly unusable on all of my (very different) systems that
> actually do some work, with symptoms being frequent OOM kills with many
> gigabytes of available memory, extended periods of semi-freezing with
> thrashing, and apparent hard lockups, almost certainly related to memory
> usage.

JFTR, we have discussed that off-list and Marc has provided on example
oom report:
[48190.574505] nvidia-modeset invoked oom-killer: gfp_mask=0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null),  order=3, oom_score_adj=0
[48190.574508] nvidia-modeset cpuset=/ mems_allowed=0
[...]
[48190.574769] active_anon:960260 inactive_anon:175381 isolated_anon:0
                active_file:1061865 inactive_file:177006 isolated_file:0
                unevictable:0 dirty:273 writeback:0 unstable:0
                slab_reclaimable:1519864 slab_unreclaimable:61079
                mapped:31182 shmem:11064 pagetables:23135 bounce:0
                free:53178 free_pcp:68 free_cma:0
[...]
[48190.574783] Node 0 DMA: 0*4kB 2*8kB (U) 3*16kB (U) 2*32kB (U) 2*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15872kB
[48190.574787] Node 0 DMA32: 2015*4kB (UME) 4517*8kB (UME) 5301*16kB (UE) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 129012kB
[48190.574791] Node 0 Normal: 6379*4kB (UME) 2915*8kB (UE) 1266*16kB (UE) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 69092kB

We are out of order-3+ oroders in all eligible zones (please note that
DMA zone is not really usable for this request). Different kernel
versions have slightly different implementation of the compaction so
they might behave differently but once it cannot make any progress
then we are out of luck. It is quite unfortunate that nvidia really
insists on having order-3 allocation. Maybe it can use kvmalloc or use
__GFP_RETRY_MAYFAIL in current kernels.

It is quite surprising we have so mach memory yet we are not able to
find order-3 contiguous block. This smells suspicious. You have
previously mentioned that dropping cache helped. So I assume that fs
metadata are fragmenting the memory.

Anyway, I will go over your whole report later. I am quite busy right now.

Thanks for the report!
-- 
Michal Hocko
SUSE Labs
