Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 308EFC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:28:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D94CE20675
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:28:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D94CE20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85DD36B0008; Mon, 20 May 2019 05:28:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8327A6B000A; Mon, 20 May 2019 05:28:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FC6C6B000C; Mon, 20 May 2019 05:28:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 202576B0008
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:28:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so24277305edm.16
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:28:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=t9cv1AUiJKCCP3DYy8uCGs4/+4Y7AXuA8cAoZoxQltA=;
        b=liNUoe3wxjlRsXFML7ZR69ycNr0A0l5605Copx1hX2ETvC1HvxzX+NwewqYpwqfvwF
         WBRg59PaXaG/+iqjD4NpkLd0z8wDXueCcigA0Sggthq1plyDhw3lseWD86Zh1e4SQY9D
         g97KSK5zAV7BU/56XdcNvt9CtuyjmvDMCJncn8JC49OcySI29sb3BK3UiEjo4MGDSda8
         tuQejg49b23cEIKmIwSKypIhEjSJuBFwxbU3FIdfeJ3j1hBNFEI7oZxAOPt2JEtzuOJM
         DDVcelA2Z1ExTd4wDVbWzC9Acg3UpWKYy+E2bbfgQVR3GOYmqadsnuOWiJ85JM7zQ3cy
         /0mA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUSXpsmH7peNAVrLDMOC4fVNVt8TBzbP+Tt8kEGQwpKscwNjtIE
	HqfmVsalj0hLfAqSQeWylN5j73lF2FOk2sDn6Axi9jkEsZiJFPQQjHvjz2WEQu9D195xt3HXAtx
	41078I4S/Ib0iQ+ONb+TSk33nPfaRbpTvRHN5RyOaEjfGomcRn1c4FZQRy204kbM=
X-Received: by 2002:a50:89b7:: with SMTP id g52mr74353536edg.291.1558344536659;
        Mon, 20 May 2019 02:28:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxP5pVUSTl3s2DIMjWqZpYW4U5jYIwZGKYZHMeJ+QcBNrwLLSgKDaTwh03D01Mnueui6aoX
X-Received: by 2002:a50:89b7:: with SMTP id g52mr74353470edg.291.1558344535601;
        Mon, 20 May 2019 02:28:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558344535; cv=none;
        d=google.com; s=arc-20160816;
        b=FS2sHlvomR2BAHxeDTyiFo4fmOJ8eKyZMmVbbxQdCEWYf81JRPb3mJNM6+SQqAipRb
         dShfZqEVIOhrMMBW/ZDd49uBAPdsB5cPW47z7/qqG+Gh4+QenoXDV2CqVY9m8AzRHGS7
         TlkLGvsKaTaamgoAgemxo17JIbNpsftooFF/FOfIQmWGoSQIACo7r8KQ1RNsTvQtZ8yF
         dJ4nwYTPnm498P1X1TQePkv39yemNCiXOVmmXBGjKVvMCUtrWqg4ZNZwvmOByVSOqAwv
         PvaCaRqbH6+XXJaP8m1HHCAGKNNOx1IwPp11Rp//jjotiIhAMYsd9pR1M0Qt17vSqACJ
         MU1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=t9cv1AUiJKCCP3DYy8uCGs4/+4Y7AXuA8cAoZoxQltA=;
        b=KMTbWWnbvkQ6bN2LoS2G4ZobQlzwWuEWjkkO8s5Hfs4PqggrY/iujf6+mzqsGL9tJC
         pgp9S5ljwh5SBuf+rZnNGmxY5ulo0QWBMLdRvDU6u/5JmIgLLqZrR0q1888evWGg7ICB
         YM07V21oKXgWwHQbufDYFu+Rmmu8k1KHL06EX4yGwjnXCzdHZFbVSn6psJuEv/1iYfoO
         JFIle0A+of9z5rt9vjUakA3dFnn9eg62iU5IuYXt7w4MlonSM8GCocSCHhmkpI7xEALh
         HPHk4VcBTZDUXVHM40x+j55Yawca6QI+Gr0O+omr6o5I2jksCioGLEoCtmQsBOOzHuUJ
         wZlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z54si2002499edc.429.2019.05.20.02.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:28:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 169B6ABD7;
	Mon, 20 May 2019 09:28:55 +0000 (UTC)
Date: Mon, 20 May 2019 11:28:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190520092854.GB6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api]

On Mon 20-05-19 12:52:47, Minchan Kim wrote:
> - Background
> 
> The Android terminology used for forking a new process and starting an app
> from scratch is a cold start, while resuming an existing app is a hot start.
> While we continually try to improve the performance of cold starts, hot
> starts will always be significantly less power hungry as well as faster so
> we are trying to make hot start more likely than cold start.
> 
> To increase hot start, Android userspace manages the order that apps should
> be killed in a process called ActivityManagerService. ActivityManagerService
> tracks every Android app or service that the user could be interacting with
> at any time and translates that into a ranked list for lmkd(low memory
> killer daemon). They are likely to be killed by lmkd if the system has to
> reclaim memory. In that sense they are similar to entries in any other cache.
> Those apps are kept alive for opportunistic performance improvements but
> those performance improvements will vary based on the memory requirements of
> individual workloads.
> 
> - Problem
> 
> Naturally, cached apps were dominant consumers of memory on the system.
> However, they were not significant consumers of swap even though they are
> good candidate for swap. Under investigation, swapping out only begins
> once the low zone watermark is hit and kswapd wakes up, but the overall
> allocation rate in the system might trip lmkd thresholds and cause a cached
> process to be killed(we measured performance swapping out vs. zapping the
> memory by killing a process. Unsurprisingly, zapping is 10x times faster
> even though we use zram which is much faster than real storage) so kill
> from lmkd will often satisfy the high zone watermark, resulting in very
> few pages actually being moved to swap.
> 
> - Approach
> 
> The approach we chose was to use a new interface to allow userspace to
> proactively reclaim entire processes by leveraging platform information.
> This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> that are known to be cold from userspace and to avoid races with lmkd
> by reclaiming apps as soon as they entered the cached state. Additionally,
> it could provide many chances for platform to use much information to
> optimize memory efficiency.
> 
> IMHO we should spell it out that this patchset complements MADV_WONTNEED
> and MADV_FREE by adding non-destructive ways to gain some free memory
> space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> when memory pressure rises.
> 
> To achieve the goal, the patchset introduce two new options for madvise.
> One is MADV_COOL which will deactive activated pages and the other is
> MADV_COLD which will reclaim private pages instantly. These new options
> complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> that it hints the kernel that memory region is not currently needed and
> should be reclaimed when memory pressure rises.
> 
> This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> information required to make the reclaim decision is not known to the app.
> Instead, it is known to a centralized userspace daemon, and that daemon
> must be able to initiate reclaim on its own without any app involvement.
> To solve the concern, this patch introduces new syscall -
> 
> 	struct pr_madvise_param {
> 		int size;
> 		const struct iovec *vec;
> 	}
> 
> 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> 				struct pr_madvise_param *restuls,
> 				struct pr_madvise_param *ranges,
> 				unsigned long flags);
> 
> The syscall get pidfd to give hints to external process and provides
> pair of result/ranges vector arguments so that it could give several
> hints to each address range all at once.
> 
> I guess others have different ideas about the naming of syscall and options
> so feel free to suggest better naming.
> 
> - Experiment
> 
> We did bunch of testing with several hundreds of real users, not artificial
> benchmark on android. We saw about 17% cold start decreasement without any
> significant battery/app startup latency issues. And with artificial benchmark
> which launches and switching apps, we saw average 7% app launching improvement,
> 18% less lmkd kill and good stat from vmstat.
> 
> A is vanilla and B is process_madvise.
> 
> 
>                                        A          B      delta   ratio(%)
>                allocstall_dma          0          0          0       0.00
>            allocstall_movable       1464        457      -1007     -69.00
>             allocstall_normal     263210     190763     -72447     -28.00
>              allocstall_total     264674     191220     -73454     -28.00
>           compact_daemon_wake      26912      25294      -1618      -7.00
>                  compact_fail      17885      14151      -3734     -21.00
>          compact_free_scanned 4204766409 3835994922 -368771487      -9.00
>              compact_isolated    3446484    2967618    -478866     -14.00
>       compact_migrate_scanned 1621336411 1324695710 -296640701     -19.00
>                 compact_stall      19387      15343      -4044     -21.00
>               compact_success       1502       1192       -310     -21.00
> kswapd_high_wmark_hit_quickly        234        184        -50     -22.00
>             kswapd_inodesteal     221635     233093      11458       5.00
>  kswapd_low_wmark_hit_quickly      66065      54009     -12056     -19.00
>                    nr_dirtied     259934     296476      36542      14.00
>   nr_vmscan_immediate_reclaim       2587       2356       -231      -9.00
>               nr_vmscan_write    1274232    2661733    1387501     108.00
>                    nr_written    1514060    2937560    1423500      94.00
>                    pageoutrun      67561      55133     -12428     -19.00
>                    pgactivate    2335060    1984882    -350178     -15.00
>                   pgalloc_dma   13743011   14096463     353452       2.00
>               pgalloc_movable          0          0          0       0.00
>                pgalloc_normal   18742440   16802065   -1940375     -11.00
>                 pgalloc_total   32485451   30898528   -1586923      -5.00
>                  pgdeactivate    4262210    2930670   -1331540     -32.00
>                       pgfault   30812334   31085065     272731       0.00
>                        pgfree   33553970   31765164   -1788806      -6.00
>                  pginodesteal      33411      15084     -18327     -55.00
>                   pglazyfreed          0          0          0       0.00
>                    pgmajfault     551312    1508299     956987     173.00
>                pgmigrate_fail      43927      29330     -14597     -34.00
>             pgmigrate_success    1399851    1203922    -195929     -14.00
>                        pgpgin   24141776   19032156   -5109620     -22.00
>                       pgpgout     959344    1103316     143972      15.00
>                  pgpgoutclean    4639732    3765868    -873864     -19.00
>                      pgrefill    4884560    3006938   -1877622     -39.00
>                     pgrotated      37828      25897     -11931     -32.00
>                 pgscan_direct    1456037     957567    -498470     -35.00
>        pgscan_direct_throttle          0          0          0       0.00
>                 pgscan_kswapd    6667767    5047360   -1620407     -25.00
>                  pgscan_total    8123804    6004927   -2118877     -27.00
>                    pgskip_dma          0          0          0       0.00
>                pgskip_movable          0          0          0       0.00
>                 pgskip_normal      14907      25382      10475      70.00
>                  pgskip_total      14907      25382      10475      70.00
>                pgsteal_direct    1118986     690215    -428771     -39.00
>                pgsteal_kswapd    4750223    3657107   -1093116     -24.00
>                 pgsteal_total    5869209    4347322   -1521887     -26.00
>                        pswpin     417613    1392647     975034     233.00
>                       pswpout    1274224    2661731    1387507     108.00
>                 slabs_scanned   13686905   10807200   -2879705     -22.00
>           workingset_activate     668966     569444     -99522     -15.00
>        workingset_nodereclaim      38957      32621      -6336     -17.00
>            workingset_refault    2816795    2179782    -637013     -23.00
>            workingset_restore     294320     168601    -125719     -43.00
> 
> pgmajfault is increased by 173% because swapin is increased by 200% by
> process_madvise hint. However, swap read based on zram is much cheaper
> than file IO in performance point of view and app hot start by swapin is
> also cheaper than cold start from the beginning of app which needs many IO
> from storage and initialization steps.
> 
> This patchset is against on next-20190517.
> 
> Minchan Kim (7):
>   mm: introduce MADV_COOL
>   mm: change PAGEREF_RECLAIM_CLEAN with PAGE_REFRECLAIM
>   mm: introduce MADV_COLD
>   mm: factor out madvise's core functionality
>   mm: introduce external memory hinting API
>   mm: extend process_madvise syscall to support vector arrary
>   mm: madvise support MADV_ANONYMOUS_FILTER and MADV_FILE_FILTER
> 
>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>  include/linux/page-flags.h             |   1 +
>  include/linux/page_idle.h              |  15 +
>  include/linux/proc_fs.h                |   1 +
>  include/linux/swap.h                   |   2 +
>  include/linux/syscalls.h               |   2 +
>  include/uapi/asm-generic/mman-common.h |  12 +
>  include/uapi/asm-generic/unistd.h      |   2 +
>  kernel/signal.c                        |   2 +-
>  kernel/sys_ni.c                        |   1 +
>  mm/madvise.c                           | 600 +++++++++++++++++++++----
>  mm/swap.c                              |  43 ++
>  mm/vmscan.c                            |  80 +++-
>  14 files changed, 680 insertions(+), 83 deletions(-)
> 
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

-- 
Michal Hocko
SUSE Labs

