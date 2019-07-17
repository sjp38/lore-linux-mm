Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 529D7C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:00:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C71621849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:00:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="Pvi91OeA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C71621849
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01BB86B000C; Wed, 17 Jul 2019 18:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE6EE6B000D; Wed, 17 Jul 2019 18:00:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D238E0001; Wed, 17 Jul 2019 18:00:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5413C6B000C
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 18:00:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so18742952edw.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 15:00:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=Da3xj+lbqJZYssT8H4D5qYhqhKgCVFCCNArrdj/bqeA=;
        b=kokwTqtuvyeRUwK1CmBxuqxM+VBPxLmOMD5N6E9M5sVS9oVCdN7z4h22BxSOTKuEcm
         eFLZssfZz/gghVKdB3QCIXpmANHKaUdXzRy0nQb7BUDzLYgGs5k56DTGxELyl6X4qRwZ
         j3WYiMNqgLuSRKZYOOMxf8WRbeE24IAmoPMEFMwnYQUQPAeW6W9WP5UH+DtZHVkNYKY7
         CLd8qhaO8jAfyyW9M0MYBfznF0yk6qZ5ebMW5fLScsng86r/icG9wpHlwB00KFQvBooP
         JOQe0lNgIMLjvSpgxGZBQUxhyVPto9BLmC1r1HKkq9Xz2CbR7A6UX8myR1ru5CKcIn8K
         HqdQ==
X-Gm-Message-State: APjAAAUm+/Dhwsply75tjSxXcj4GqMqHIadVAzPJinAtmMTDlrmdLRgd
	gPC5pawsMjYN8+EsoRjJ3JuWLcofey/xivfoVgHsOy0RjMBxH03BohdGPjE/QNGQGPC5xGzfdbY
	TUvP+krR/ew/+h4EQIP6zfYWGvIDUIe1vdJDPIHYOGMappqGSW8rcriGTB6GMubMoag==
X-Received: by 2002:aa7:da03:: with SMTP id r3mr37095776eds.130.1563400832712;
        Wed, 17 Jul 2019 15:00:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd2hE4CM6a8e93O+vp9ug9VEDdcoM02eYn5GFPodAg2V4hUP7LkE0mF3bm5cptM+nBtbFi
X-Received: by 2002:aa7:da03:: with SMTP id r3mr37095435eds.130.1563400828885;
        Wed, 17 Jul 2019 15:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400828; cv=none;
        d=google.com; s=arc-20160816;
        b=spYLwHW0qLG6wujOTczt6dDOPiQB7OJGfqjrDcbUW+ENc+HlXsMBPBOdK1OpFjkqMe
         LkfKND10ctvL0WJfAI0f1qTA/jCoPUYiykKvUqf0+K8JaC7DyO3rwE9q8jj4N8LZoWLJ
         3fHjhj5zm9BvqLISdMoU2wINiml3qT3WOk1ZXmqt8AmOeEwzp48VTwqUDPW7mTR7fzpQ
         1YyEV86T7eOrtJi/fbttflLv+3ZjfDu2FHMR9yS8cUltqvKGYBDZ1IYx+Q92RCtJoJMx
         74lAW1nB9Np6MxJAfzn8CAVVou7xoKp2dnHjKzuRFgoG3XsemI4+5m4QkxT6si76MmQ3
         RLrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=Da3xj+lbqJZYssT8H4D5qYhqhKgCVFCCNArrdj/bqeA=;
        b=YrHDBosWuDNdOeGnOAOXPvbWMTp5bWZWOxNPHGUhbyMqnBCvRyQq5Y/ySh/VRIRU/4
         C4VsJijbk0YF4DZWfXkGflI6aViF8AGzfEY+QzZ7oJtEosRmxi3I0nsuwvYz1WUPBymR
         Mi7JhTIyKt8zTPJNd339XPFCgNFuc+XZ51F9M2GKMiGpCXSEEkmFBjFGZFLjH78nXXjD
         ifZZIFIrl831RnVPfWudZ8e1KT9MebXWnKWhoa7RoUyX094cJC1V1kWikJZTe+n3an6g
         wCh+GTrPvfm8gZGiauhmAXAErRQpWj+T0lONWvHw7smvl3XvSan2ZvMMk6LpLhWK2KnM
         Bong==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=Pvi91OeA;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40136.protonmail.ch (mail-40136.protonmail.ch. [185.70.40.136])
        by mx.google.com with ESMTPS id f14si136541ejt.144.2019.07.17.15.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 15:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) client-ip=185.70.40.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=Pvi91OeA;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Wed, 17 Jul 2019 22:00:18 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563400825;
	bh=Da3xj+lbqJZYssT8H4D5qYhqhKgCVFCCNArrdj/bqeA=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=Pvi91OeAxMkrpJAhR2FC/saD5zJOeL+zL2uJcS/vL2oVm9qzziRH9gEkn80YOq5zN
	 eFBr+eqAz57JUwj80NPhJZLsxz4Kj945f3lDPxrHTG9uenV7iNc9vdEUvoEcrKkJ4w
	 nhzSh1TnOdHwesoHw00UfQAFl/pa+yDJQl2TyyVw=
To: Mel Gorman <mgorman@techsingularity.net>
From: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <8pZH2SJj3Wvi88hZae_hXIB29mCb8Pg9e5evGNd1xXYc9QlriA9xct5PgeQThRHe3Bll356k226z_VaEqosaSJUVydus09dsljaBtIpT7Bw=@protonmail.com>
In-Reply-To: <20190717175332.GC24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
 <20190716071121.GA24383@techsingularity.net>
 <xZGQeie9gbbIEm7ZciNh3PrdV8kTu-SE7KtUYV3cloMCUEdzB7taS5BcTzSUSaThu5_ftcRjr3sYcQB1c9dVPX3i1kQ2eP-xjKvFIpT7wZs=@protonmail.com>
 <20190717175332.GC24383@techsingularity.net>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tl;dr: patch seems to work, thank you very much!

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Wednesday, July 17, 2019 7:53 PM, Mel Gorman <mgorman@techsingularity.ne=
t> wrote:

> Ok, great. From the trace, it was obvious that the scanner is making no
> progress. I don't think zswap is involved as such but it may be making
> it easier to trigger due to altering timing. At least, I see no reason
> why zswap would materially affect the termination conditions.
I don't know if it matters in this context, but I've been using the term `z=
swap`(somewhere else I think) to (wrongly)refer to swap in zram (and even s=
ometimes called it ext4(in this bug report too) without realizing at the ti=
me that ext4 is only for /tmp and /var/tmp instead! they are ext4 in zram) =
but in fact this isn't zswap that I have been using (even though I have CON=
FIG_ZSWAP=3Dy in .config) but it's just CONFIG_ZRAM=3Dy with CONFIG_SWAP=3D=
y (and probably a bunch of others being needed too).

>
> From the path and your trace, I think what might be happening is that
> a fatal signal is pending which does not advance the scanner or look like
> a proper abort. I think it ends up looping in compaction instead of dying
> without either aborting or progressing the scanner. It might explain why
> stress-ng is hitting is as it is probably sending fatal signals on timeou=
t
> (I didn't check the source).
Ah I didn't know there are multiple `stress` versions, here's what I used:

/usr/bin/stress is owned by stress 1.0.4-5

$ pacman -Qs stress
local/stress 1.0.4-5
    A tool that stress tests your system (CPU, memory, I/O, disks)

$ pacman -Qi stress
Name            : stress
Version         : 1.0.4-5
Description     : A tool that stress tests your system (CPU, memory, I/O, d=
isks)
Architecture    : x86_64
URL             : http://people.seas.harvard.edu/~apw/stress/
Licenses        : GPL
Groups          : None
Provides        : None
Depends On      : None
Optional Deps   : None
Required By     : None
Optional For    : None
Conflicts With  : None
Replaces        : None
Installed Size  : 25.00 KiB
Packager        : Florian Pritz <bluewind@xinu.at>
Build Date      : Thu 31 May 2018 01:46:16 PM CEST
Install Date    : Mon 10 Jun 2019 02:44:14 AM CEST
Install Reason  : Explicitly installed
Install Script  : No
Validated By    : Signature

Note: not:
$ yaourt -Ss stress-ng
aur/stress-ng 0.09.59-1 (11) (0.10)
    stress-ng will stress test a computer system in various selectable ways

(it probably doesn't matter anyway :) as I didn't look at the source either=
)


>
> Can you try this (compile tested only) patch please? Note that the stress
> test might still take time to exit normally if it's stuck in a swap
> storm of some sort but I'm hoping the 100% compaction CPU usage goes away
> at least.
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..952dc2fb24e5 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -842,13 +842,15 @@ isolate_migratepages_block(struct compact_control c=
c, unsigned long low_pfn,
> /* Periodically drop the lock (if held) regardless of its
>
> -          * contention, to give chance to IRQs. Abort async compaction
>
>
> -          * if contended.
>
>
>
> -          * contention, to give chance to IRQs. Abort completely if
>
>
> -          * a fatal signal is pending.
>            */
>           if (!(low_pfn % SWAP_CLUSTER_MAX)
>               && compact_unlock_should_abort(&pgdat->lru_lock,
>
>
>
> -         =09=09=09    flags, &locked, cc))
>
>
> -         =09break;
>
>
>
> -         =09=09=09    flags, &locked, cc)) {
>
>
> -         =09low_pfn =3D 0;
>
>
> -         =09goto fatal_pending;
>
>
> -         }
>
>
>
> if (!pfn_valid_within(low_pfn))
> goto isolate_fail;
> @@ -1060,6 +1062,7 @@ isolate_migratepages_block(struct compact_control *=
cc, unsigned long low_pfn,
> trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
> nr_scanned, nr_isolated);
>
> +fatal_pending:
> cc->total_migrate_scanned +=3D nr_scanned;
>
>     if (nr_isolated)
>     =09count_compact_events(COMPACTISOLATED, nr_isolated);
>
>
> --
>
> Mel Gorman
> SUSE Labs



Now the "problem" is I can't tell if it would get stuck :D but it usually e=
nds in no more than 17 sec:
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [7981] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: FAIL: [7981] (415) <-- worker 8202 got signal 9
stress: WARN: [7981] (417) now reaping child worker processes
stress: FAIL: [7981] (415) <-- worker 8199 got signal 9
stress: WARN: [7981] (417) now reaping child worker processes
stress: FAIL: [7981] (451) failed run completed in 18s

real=090m17.397s
user=090m1.069s
sys=092m42.774s

sometimes it's 14,15 or 16, but usually it's between 17 and 18(exclusive) s=
econds.



Interestingly sometimes (rarely) it succeeds:
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [12629] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [12629] successful run completed in 15s

real=090m14.571s
user=090m1.122s
sys=092m18.623s

But it succeedes 100% of the time if I limit CPU max to 800Mhz (lowest):
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [8434] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [8434] successful run completed in 23s

real=090m22.639s
user=090m1.653s
sys=093m18.693s
sometimes it's in 7 sec less that the usual 22sec:
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [8689] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [8689] successful run completed in 15s

real=090m15.585s
user=090m1.576s
sys=092m26.495s


(probably irrelevant)Sometimes Xorg says it can't allocate any more memory =
but stacktrace looks like it's inside some zram i915 kernel stuff:

[ 1416.842931] [drm] Atomic update on pipe (A) took 188 us, max time under =
evasion is 100 us
[ 1425.416979] Xorg: page allocation failure: order:0, mode:0x400d0(__GFP_I=
O|__GFP_FS|__GFP_COMP|__GFP_RECLAIMABLE), nodemask=3D(null),cpuset=3D/,mems=
_allowed=3D0
[ 1425.416984] CPU: 1 PID: 1024 Comm: Xorg Kdump: loaded Tainted: G     U  =
          5.2.1-g527a3db363a3 #74
[ 1425.416985] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 2201 05/27/2019
[ 1425.416986] Call Trace:
[ 1425.416991]  dump_stack+0x46/0x60
[ 1425.416993]  warn_alloc.cold+0x7b/0xfb
[ 1425.416996]  __alloc_pages_slowpath+0xbe2/0xc20
[ 1425.416997]  __alloc_pages_nodemask+0x268/0x2b0
[ 1425.416999]  new_slab+0x3ff/0x610
[ 1425.417001]  ? xas_alloc+0x9c/0xc0
[ 1425.417002]  ___slab_alloc+0x33b/0x540
[ 1425.417003]  ? xas_nomem+0x49/0x70
[ 1425.417005]  ? xas_alloc+0x9c/0xc0
[ 1425.417006]  ? xas_nomem+0x49/0x70
[ 1425.417007]  __slab_alloc+0x9/0x10
[ 1425.417008]  kmem_cache_alloc+0x118/0x150
[ 1425.417010]  xas_nomem+0x49/0x70
[ 1425.417011]  add_to_swap_cache+0x25c/0x310
[ 1425.417013]  __read_swap_cache_async+0xef/0x1e0
[ 1425.417014]  swap_cluster_readahead+0x1ac/0x2a0
[ 1425.417015]  shmem_swapin+0x55/0xa0
[ 1425.417018]  ? call_function_single_interrupt+0xa/0x20
[ 1425.417019]  ? xas_init_marks+0x19/0x40
[ 1425.417020]  ? xas_store+0x3e4/0x640
[ 1425.417022]  shmem_swapin_page+0x418/0x590
[ 1425.417023]  ? xas_load+0x5/0x70
[ 1425.417025]  ? find_get_entry+0x55/0x120
[ 1425.417026]  shmem_getpage_gfp.isra.0+0x37f/0x820
[ 1425.417028]  shmem_read_mapping_page_gfp+0x3b/0x70
[ 1425.417051]  i915_gem_object_get_pages_gtt+0x1f9/0x550 [i915]
[ 1425.417070]  ? gen8_ppgtt_alloc_4lvl+0x5a/0x150 [i915]
[ 1425.417086]  __i915_gem_object_get_pages+0x4e/0x60 [i915]
[ 1425.417104]  __i915_vma_do_pin+0x4bf/0x540 [i915]
[ 1425.417120]  eb_lookup_vmas+0x68b/0xb90 [i915]
[ 1425.417136]  ? i915_gem_do_execbuffer+0x351/0x1040 [i915]
[ 1425.417152]  ? i915_gem_execbuffer2_ioctl+0x1b7/0x380 [i915]
[ 1425.417154]  ? krealloc+0x21/0xa0
[ 1425.417169]  i915_gem_do_execbuffer+0x502/0x1040 [i915]
[ 1425.417172]  ? ZSTD_decompressMultiFrame+0x329/0x370
[ 1425.417174]  ? ZSTD_decompressDCtx+0xc/0x10
[ 1425.417175]  ? ktime_get_with_offset+0x5c/0x130
[ 1425.417177]  ? zram_bvec_rw.isra.0+0x154/0x6a0
[ 1425.417179]  ? _cond_resched+0x10/0x20
[ 1425.417194]  i915_gem_execbuffer2_ioctl+0x1b7/0x380 [i915]
[ 1425.417196]  ? zram_rw_page+0xba/0xe0
[ 1425.417211]  ? i915_gem_execbuffer_ioctl+0x2a0/0x2a0 [i915]
[ 1425.417220]  drm_ioctl_kernel+0xa5/0xf0 [drm]
[ 1425.417228]  drm_ioctl+0x201/0x380 [drm]
[ 1425.417243]  ? i915_gem_execbuffer_ioctl+0x2a0/0x2a0 [i915]
[ 1425.417245]  do_vfs_ioctl+0x3f4/0x660
[ 1425.417246]  ? handle_mm_fault+0xa9/0x1d0
[ 1425.417248]  ksys_ioctl+0x59/0x90
[ 1425.417249]  __x64_sys_ioctl+0x11/0x20
[ 1425.417251]  do_syscall_64+0x50/0x170
[ 1425.417253]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1425.417255] RIP: 0033:0x78521f1b1c2b
[ 1425.417256] Code: 0f 1e fa 48 8b 05 65 d2 0c 00 64 c7 00 26 00 00 00 48 =
c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 35 d2 0c 00 f7 d8 64 89 01 48
[ 1425.417258] RSP: 002b:00007ffcf8fd0d08 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000010
[ 1425.417259] RAX: ffffffffffffffda RBX: 000000000000000a RCX: 000078521f1=
b1c2b
[ 1425.417260] RDX: 00007ffcf8fd0d40 RSI: 0000000040406469 RDI: 00000000000=
0000a
[ 1425.417261] RBP: 00005a6a541acad0 R08: 0000000000000000 R09: 00007852196=
c2a60
[ 1425.417262] R10: 0000785213f3e000 R11: 0000000000000246 R12: 00000000000=
02000
[ 1425.417263] R13: 000078521af98000 R14: 00007ffcf8fd0d40 R15: 00007ffcf8f=
d0d40
[ 1425.417264] Mem-Info:
[ 1425.417267] active_anon:6998108 inactive_anon:442511 isolated_anon:9465
                active_file:2251 inactive_file:2329 isolated_file:259
                unevictable:16735 dirty:20 writeback:0 unstable:0
                slab_reclaimable:28873 slab_unreclaimable:37272
                mapped:3501 shmem:39527 pagetables:32186 bounce:0
                free:87238 free_pcp:2904 free_cma:0
[ 1425.417269] Node 0 active_anon:27992432kB inactive_anon:1770044kB active=
_file:9004kB inactive_file:9316kB unevictable:66940kB isolated(anon):37860k=
B isolated(file):1036kB mapped:14004kB dirty:80kB writeback:0kB shmem:15810=
8kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 22118400kB writeback_tmp:=
0kB unstable:0kB all_unreclaimable? no
[ 1425.417271] Node 0 DMA free:15892kB min:100kB low:124kB high:148kB activ=
e_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:=
0kB writepending:0kB present:15980kB managed:15892kB mlocked:0kB kernel_sta=
ck:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1425.417273] lowmem_reserve[]: 0 2346 31714 31714
[ 1425.417275] Node 0 DMA32 free:132920kB min:15608kB low:19508kB high:2340=
8kB active_anon:2259000kB inactive_anon:1412kB active_file:0kB inactive_fil=
e:0kB unevictable:1296kB writepending:0kB present:2744176kB managed:2416496=
kB mlocked:0kB kernel_stack:16kB pagetables:3420kB bounce:0kB free_pcp:4kB =
local_pcp:0kB free_cma:0kB
[ 1425.417277] lowmem_reserve[]: 0 0 29368 29368
[ 1425.417279] Node 0 Normal free:200140kB min:198384kB low:246956kB high:2=
95528kB active_anon:25733140kB inactive_anon:1769340kB active_file:10288kB =
inactive_file:10456kB unevictable:65560kB writepending:80kB present:3065446=
4kB managed:30077908kB mlocked:32kB kernel_stack:9408kB pagetables:125324kB=
 bounce:0kB free_pcp:11740kB local_pcp:1420kB free_cma:0kB
[ 1425.417281] lowmem_reserve[]: 0 0 0 0
[ 1425.417282] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 0*32kB 2*64kB (U) 1*1=
28kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 158=
92kB
[ 1425.417287] Node 0 DMA32: 248*4kB (UME) 256*8kB (UME) 172*16kB (UME) 138=
*32kB (UME) 87*64kB (UME) 68*128kB (UME) 38*256kB (UE) 22*512kB (UME) 11*10=
24kB (E) 0*2048kB 19*4096kB (M) =3D 134560kB
[ 1425.417292] Node 0 Normal: 17*4kB (UM) 20*8kB (UM) 16*16kB (UM) 1721*32k=
B (UM) 733*64kB (UME) 140*128kB (UM) 1*256kB (E) 1*512kB (M) 2*1024kB (ME) =
37*2048kB (M) 0*4096kB =3D 198980kB
[ 1425.417297] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D1048576kB
[ 1425.417298] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D2048kB
[ 1425.417299] 50365 total pagecache pages
[ 1425.417306] 6377 pages in swap cache
[ 1425.417307] Swap cache stats: add 728656996, delete 728204250, find 6351=
630/8862186
[ 1425.417308] Free swap  =3D 35959128kB
[ 1425.417308] Total swap =3D 67108860kB
[ 1425.417309] 8353655 pages RAM
[ 1425.417310] 0 pages HighMem/MovableOnly
[ 1425.417310] 226081 pages reserved
[ 1425.417311] 0 pages cma reserved
[ 1425.417312] SLUB: Unable to allocate memory on node -1, gfp=3D0xc0(__GFP=
_IO|__GFP_FS)
[ 1425.417313]   cache: radix_tree_node, object size: 576, buffer size: 584=
, default order: 2, min order: 0
[ 1425.417314]   node 0: slabs: 5357, objs: 149702, free: 0
[ 1426.236297] Xorg: page allocation failure: order:0, mode:0x400d0(__GFP_I=
O|__GFP_FS|__GFP_COMP|__GFP_RECLAIMABLE), nodemask=3D(null),cpuset=3D/,mems=
_allowed=3D0
[ 1426.236306] CPU: 9 PID: 1024 Comm: Xorg Kdump: loaded Tainted: G     U  =
          5.2.1-g527a3db363a3 #74
[ 1426.236307] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 2201 05/27/2019
[ 1426.236308] Call Trace:
[ 1426.236318]  dump_stack+0x46/0x60
[ 1426.236322]  warn_alloc.cold+0x7b/0xfb
[ 1426.236326]  __alloc_pages_slowpath+0xbe2/0xc20
[ 1426.236328]  __alloc_pages_nodemask+0x268/0x2b0
[ 1426.236331]  new_slab+0x3ff/0x610
[ 1426.236335]  ? xas_alloc+0x9c/0xc0
[ 1426.236337]  ___slab_alloc+0x33b/0x540
[ 1426.236339]  ? xas_nomem+0x49/0x70
[ 1426.236340]  ? xas_alloc+0x9c/0xc0
[ 1426.236341]  ? xas_nomem+0x49/0x70
[ 1426.236342]  __slab_alloc+0x9/0x10
[ 1426.236343]  kmem_cache_alloc+0x118/0x150
[ 1426.236345]  xas_nomem+0x49/0x70
[ 1426.236347]  add_to_swap_cache+0x25c/0x310
[ 1426.236349]  __read_swap_cache_async+0xef/0x1e0
[ 1426.236351]  read_swap_cache_async+0x24/0x60
[ 1426.236352]  swap_cluster_readahead+0x237/0x2a0
[ 1426.236354]  ? get_page_from_freelist+0xe88/0x1330
[ 1426.236356]  ? ktime_get+0x49/0x110
[ 1426.236358]  shmem_swapin+0x55/0xa0
[ 1426.236361]  shmem_swapin_page+0x418/0x590
[ 1426.236362]  ? xas_load+0x5/0x70
[ 1426.236366]  ? find_get_entry+0x55/0x120
[ 1426.236367]  shmem_getpage_gfp.isra.0+0x37f/0x820
[ 1426.236368]  shmem_read_mapping_page_gfp+0x3b/0x70
[ 1426.236438]  i915_gem_object_get_pages_gtt+0x1f9/0x550 [i915]
[ 1426.236445]  ? set_next_entity+0x89/0x150
[ 1426.236447]  ? pick_next_task_fair+0x590/0x760
[ 1426.236482]  __i915_gem_object_get_pages+0x4e/0x60 [i915]
[ 1426.236501]  __i915_vma_do_pin+0x4bf/0x540 [i915]
[ 1426.236518]  eb_lookup_vmas+0x68b/0xb90 [i915]
[ 1426.236534]  i915_gem_do_execbuffer+0x502/0x1040 [i915]
[ 1426.236537]  ? xas_init_marks+0x19/0x40
[ 1426.236538]  ? xas_store+0x3e4/0x640
[ 1426.236540]  ? __delete_from_swap_cache+0x15a/0x190
[ 1426.236541]  ? _swap_info_get+0xa/0x30
[ 1426.236543]  ? free_swap_slot+0x43/0xc0
[ 1426.236544]  ? __swap_entry_free.constprop.0+0x92/0xa0
[ 1426.236545]  ? shmem_swapin_page+0x4fe/0x590
[ 1426.236547]  ? xas_load+0x5/0x70
[ 1426.236549]  ? find_get_entry+0x55/0x120
[ 1426.236550]  ? _cond_resched+0x10/0x20
[ 1426.236566]  i915_gem_execbuffer2_ioctl+0x1b7/0x380 [i915]
[ 1426.236577]  ? __mod_lruvec_state+0x3a/0xe0
[ 1426.236593]  ? i915_gem_execbuffer_ioctl+0x2a0/0x2a0 [i915]
[ 1426.236618]  drm_ioctl_kernel+0xa5/0xf0 [drm]
[ 1426.236627]  drm_ioctl+0x201/0x380 [drm]
[ 1426.236645]  ? i915_gem_execbuffer_ioctl+0x2a0/0x2a0 [i915]
[ 1426.236649]  ? __set_current_blocked+0x38/0x50
[ 1426.236650]  ? signal_setup_done+0x8b/0xa0
[ 1426.236654]  do_vfs_ioctl+0x3f4/0x660
[ 1426.236656]  ? recalc_sigpending+0xe/0x40
[ 1426.236659]  ? _copy_from_user+0x37/0x60
[ 1426.236661]  ksys_ioctl+0x59/0x90
[ 1426.236662]  __x64_sys_ioctl+0x11/0x20
[ 1426.236664]  do_syscall_64+0x50/0x170
[ 1426.236669]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1426.236671] RIP: 0033:0x78521f1b1c2b
[ 1426.236673] Code: 0f 1e fa 48 8b 05 65 d2 0c 00 64 c7 00 26 00 00 00 48 =
c7 c0 ff ff ff ff c3 66 0f 1f 44 00 00 f3 0f 1e fa b8 10 00 00 00 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 35 d2 0c 00 f7 d8 64 89 01 48
[ 1426.236674] RSP: 002b:00007ffcf8fcee18 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000010
[ 1426.236676] RAX: ffffffffffffffda RBX: 000078521dd60d40 RCX: 000078521f1=
b1c2b
[ 1426.236677] RDX: 00007ffcf8fcee80 RSI: 0000000040406469 RDI: 00000000000=
0000a
[ 1426.236677] RBP: 00007ffcf8fcee80 R08: 0000000000000000 R09: 00007852196=
c3d60
[ 1426.236678] R10: 00007852184ea000 R11: 0000000000000246 R12: 00000000404=
06469
[ 1426.236679] R13: 000000000000000a R14: 00007ffcf8fcee80 R15: 00007ffcf8f=
cee80
[ 1426.236682] SLUB: Unable to allocate memory on node -1, gfp=3D0xc0(__GFP=
_IO|__GFP_FS)
[ 1426.236683]   cache: radix_tree_node, object size: 576, buffer size: 584=
, default order: 2, min order: 0
[ 1426.236684]   node 0: slabs: 1195, objs: 33082, free: 0
[ 1466.913788] stress invoked oom-killer: gfp_mask=3D0x100dca(GFP_HIGHUSER_=
MOVABLE|__GFP_ZERO), order=3D0, oom_score_adj=3D0
[ 1466.913792] CPU: 3 PID: 15698 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #74
[ 1466.913793] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 2201 05/27/2019
[ 1466.913794] Call Trace:
[ 1466.913798]  dump_stack+0x46/0x60
[ 1466.913800]  dump_header+0x4f/0x2fd
[ 1466.913801]  ? oom_unkillable_task+0x95/0xc0
[ 1466.913802]  ? find_lock_task_mm+0x2e/0x70
[ 1466.913803]  oom_kill_process.cold+0xb/0x10
[ 1466.913805]  out_of_memory+0x1bc/0x460
[ 1466.913806]  __alloc_pages_slowpath+0xb19/0xc20
[ 1466.913808]  __alloc_pages_nodemask+0x268/0x2b0
[ 1466.913810]  alloc_pages_vma+0x74/0x1c0
[ 1466.913812]  __handle_mm_fault+0xe1f/0x1310
[ 1466.913814]  handle_mm_fault+0xa9/0x1d0
[ 1466.913816]  __do_page_fault+0x237/0x480
[ 1466.913817]  do_page_fault+0x1d/0x67
[ 1466.913819]  ? page_fault+0x8/0x30
[ 1466.913821]  page_fault+0x1e/0x30
[ 1466.913822] RIP: 0033:0x56f413018c10
[ 1466.913824] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1466.913825] RSP: 002b:00007ffd17a85910 EFLAGS: 00010206
[ 1466.913827] RAX: 00000000187e3000 RBX: 00007a864406e010 RCX: 00007a88982=
523db
[ 1466.913827] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 00007a86440=
6e000
[ 1466.913828] RBP: 000056f413019a54 R08: 00007a864406e010 R09: 00000000000=
00000
[ 1466.913829] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 1466.913830] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 1466.913831] Mem-Info:
[ 1466.913834] active_anon:6889086 inactive_anon:437196 isolated_anon:44189
                active_file:210 inactive_file:248 isolated_file:32
                unevictable:16068 dirty:0 writeback:0 unstable:0
                slab_reclaimable:10669 slab_unreclaimable:55287
                mapped:492 shmem:16679 pagetables:49030 bounce:0
                free:85711 free_pcp:1702 free_cma:0
[ 1466.913837] Node 0 active_anon:27556344kB inactive_anon:1748784kB active=
_file:840kB inactive_file:992kB unevictable:64272kB isolated(anon):176756kB=
 isolated(file):128kB mapped:1968kB dirty:0kB writeback:0kB shmem:66716kB s=
hmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 18806784kB writeback_tmp:0kB u=
nstable:0kB all_unreclaimable? no
[ 1466.913838] Node 0 DMA free:15892kB min:100kB low:124kB high:148kB activ=
e_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:=
0kB writepending:0kB present:15980kB managed:15892kB mlocked:0kB kernel_sta=
ck:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1466.913841] lowmem_reserve[]: 0 2346 31714 31714
[ 1466.913842] Node 0 DMA32 free:133064kB min:15608kB low:19508kB high:2340=
8kB active_anon:2246984kB inactive_anon:516kB active_file:32kB inactive_fil=
e:20kB unevictable:56kB writepending:0kB present:2744176kB managed:2416496k=
B mlocked:0kB kernel_stack:16kB pagetables:6120kB bounce:0kB free_pcp:4kB l=
ocal_pcp:0kB free_cma:0kB
[ 1466.913845] lowmem_reserve[]: 0 0 29368 29368
[ 1466.913847] Node 0 Normal free:193888kB min:194288kB low:242860kB high:2=
91432kB active_anon:25307420kB inactive_anon:1748072kB active_file:2148kB i=
nactive_file:2432kB unevictable:62728kB writepending:0kB present:30654464kB=
 managed:30077908kB mlocked:32kB kernel_stack:9392kB pagetables:190000kB bo=
unce:0kB free_pcp:6804kB local_pcp:344kB free_cma:0kB
[ 1466.913849] lowmem_reserve[]: 0 0 0 0
[ 1466.913851] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (U) 0*32kB 2*64kB (U) 1*1=
28kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 158=
92kB
[ 1466.913856] Node 0 DMA32: 117*4kB (UME) 133*8kB (UME) 95*16kB (UME) 98*3=
2kB (UME) 127*64kB (UME) 80*128kB (UME) 40*256kB (UME) 27*512kB (UME) 18*10=
24kB (ME) 2*2048kB (ME) 15*4096kB (ME) =3D 132588kB
[ 1466.913861] Node 0 Normal: 482*4kB (UME) 478*8kB (UME) 648*16kB (ME) 849=
*32kB (E) 661*64kB (UME) 345*128kB (UE) 132*256kB (UE) 49*512kB (UME) 4*102=
4kB (ME) 0*2048kB 0*4096kB =3D 192728kB
[ 1466.913867] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D1048576kB
[ 1466.913868] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_surp=
=3D0 hugepages_size=3D2048kB
[ 1466.913869] 64205 total pagecache pages
[ 1466.913875] 47161 pages in swap cache
[ 1466.913876] Swap cache stats: add 776634640, delete 776102875, find 6734=
206/9399597
[ 1466.913877] Free swap  =3D 0kB
[ 1466.913877] Total swap =3D 67108860kB
[ 1466.913878] 8353655 pages RAM
[ 1466.913879] 0 pages HighMem/MovableOnly
[ 1466.913879] 226081 pages reserved
[ 1466.913880] 0 pages cma reserved
[ 1466.913880] Tasks state (memory values in pages):
[ 1466.913881] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swape=
nts oom_score_adj name
[ 1466.913888] [    399]     0   399    21409        0   212992      330   =
          0 systemd-journal
[ 1466.913889] [    413]     0   413     9265        0    94208      420   =
      -1000 systemd-udevd
[ 1466.913891] [    604]    81   604     2773        0    65536      225   =
       -900 dbus-daemon
[ 1466.913893] [    609]     0   609      649        0    45056       45   =
          0 gpm
[ 1466.913894] [    610]     0   610     6600        0    90112      269   =
          0 systemd-logind
[ 1466.913896] [    695]     0   695    11319        0   131072      157   =
          0 login
[ 1466.913898] [    799]  1000   799     7472        1   102400      377   =
          0 systemd
[ 1466.913899] [    800]  1000   800    16164      131   159744      463   =
          0 (sd-pam)
[ 1466.913900] [    812]  1000   812     3407        1    69632     1626   =
          0 bash
[ 1466.913902] [   1001]  1000  1001     1895        1    57344      143   =
          0 startx
[ 1466.913903] [   1023]  1000  1023     1006        0    49152       51   =
          0 xinit
[ 1466.913905] [   1024]  1000  1024   179163      512   634880     3292   =
          0 Xorg
[ 1466.913906] [   1033]  1000  1033    92987        0   217088     1934   =
          0 xfce4-session
[ 1466.913908] [   1037]  1000  1037     2758        0    61440      241   =
          0 dbus-daemon
[ 1466.913909] [   1040]  1000  1040    76635        1    98304      232   =
          0 at-spi-bus-laun
[ 1466.913911] [   1044]  1000  1044    57827        0    81920      290   =
          0 xfconfd
[ 1466.913912] [   1051]  1000  1051     2716        1    65536      165   =
          0 dbus-daemon
[ 1466.913914] [   1054]  1000  1054    40960        1    81920      256   =
          0 at-spi2-registr
[ 1466.913915] [   1057]   102  1057   483104        0   233472     1331   =
          0 polkitd
[ 1466.913916] [   1075]  1000  1075     1498        0    49152      120   =
          0 ssh-agent
[ 1466.913918] [   1080]  1000  1080    39233       18    69632       57   =
          0 gpg-agent
[ 1466.913919] [   1082]  1000  1082    90685      109   274432     4696   =
          0 xfwm4
[ 1466.913921] [   1088]  1000  1088    58565        1   176128     1375   =
          0 xfsettingsd
[ 1466.913922] [   1089]  1000  1089    69802        0   184320     1784   =
          0 xfce4-panel
[ 1466.913924] [   1092]     0  1092    65176        0   126976      419   =
          0 upowerd
[ 1466.913925] [   1097]  1000  1097    87154        0   184320     1268   =
          0 Thunar
[ 1466.913926] [   1118]  1000  1118    78926        0   258048    10182   =
          0 xfdesktop
[ 1466.913928] [   1123]  1000  1123    69044        0   167936     1478   =
          0 panel-16-whiske
[ 1466.913929] [   1126]  1000  1126    60071        0   196608     1436   =
          0 panel-22-screen
[ 1466.913931] [   1127]  1000  1127    49794        0   163840     1227   =
          0 panel-12-system
[ 1466.913932] [   1128]  1000  1128    49428        0   159744     1239   =
          0 panel-24-cpugra
[ 1466.913933] [   1129]  1000  1129    50483        0   167936     1603   =
          0 panel-20-cpufre
[ 1466.913935] [   1130]  1000  1130    49795        0   155648     1230   =
          0 panel-13-netloa
[ 1466.913936] [   1131]  1000  1131    49794        0   159744     1267   =
          0 panel-10-diskpe
[ 1466.913938] [   1132]  1000  1132    49795        0   163840     1225   =
          0 panel-4-diskper
[ 1466.913939] [   1133]  1000  1133    49928        0   159744     1242   =
          0 panel-8-xfce4-s
[ 1466.913940] [   1134]  1000  1134    59673        0   192512     1491   =
          0 panel-3-power-m
[ 1466.913942] [   1137]  1000  1137    49443        0   159744     1225   =
          0 panel-6-systray
[ 1466.913943] [   1140]  1000  1140    59653        0   192512     1497   =
          0 panel-11-notifi
[ 1466.913944] [   1141]  1000  1141    58452        4   176128      695   =
          0 panel-17-xfce4-
[ 1466.913946] [   1142]  1000  1142    49851        0   159744     1243   =
          0 panel-2-actions
[ 1466.913947] [   1145]  1000  1145    48311      160   143360      350   =
          0 panel-25-xfce4-
[ 1466.913949] [   1174]  1000  1174    95427        0   212992     2255   =
          0 xfce4-terminal
[ 1466.913950] [   1176]  1000  1176   116553        0   258048     4697   =
          0 xfce4-terminal
[ 1466.913951] [   1189]  1000  1189    48086        0   139264      467   =
          0 polkit-gnome-au
[ 1466.913953] [   1197]  1000  1197    50286        0   159744     1402   =
          0 xfce4-power-man
[ 1466.913954] [   1200]  1000  1200    42772        1   114688      874   =
          0 pulseaudio
[ 1466.913956] [   1206]  1000  1206    67174        0   155648      541   =
          0 xfce4-notifyd
[ 1466.913957] [   1216]  1000  1216     1895        1    53248      121   =
          0 showdns
[ 1466.913958] [   1223]  1000  1223     1862        0    57344      107   =
          0 logw
[ 1466.913960] [   1224]  1000  1224     1895        0    53248      124   =
          0 showdns
[ 1466.913961] [   1225]  1000  1225     1895        1    53248      121   =
          0 showdns_success
[ 1466.913963] [   1226]  1000  1226     1895        1    57344      120   =
          0 showdns_fails
[ 1466.913964] [   1227]  1000  1227     1862        1    53248      120   =
          0 showdns_from_fi
[ 1466.913965] [   1228]  1000  1228     1862        1    57344      120   =
          0 showdns_from_ch
[ 1466.913967] [   1231]  1000  1231     1528        0    53248       82   =
          0 dmesg
[ 1466.913968] [   1254]  1000  1254     1528        0    53248       77   =
          0 dmesg
[ 1466.913970] [   1255]  1000  1255     1862        0    53248      108   =
          0 stripcolors
[ 1466.913971] [   1256]  1000  1256     1625        0    53248      121   =
          0 grep
[ 1466.913972] [   1257]  1000  1257     2479        1    53248       78   =
          0 sed
[ 1466.913974] [   1260]  1000  1260     1528        0    53248       74   =
          0 dmesg
[ 1466.913975] [   1261]  1000  1261     1862        0    57344      107   =
          0 stripcolors
[ 1466.913977] [   1262]  1000  1262     1528        0    53248       87   =
          0 dmesg
[ 1466.913978] [   1263]  1000  1263     1625        0    53248      119   =
          0 grep
[ 1466.913979] [   1264]  1000  1264     1862        0    53248      108   =
          0 stripcolors
[ 1466.913981] [   1265]  1000  1265     1635        0    53248      108   =
          0 grep
[ 1466.913982] [   1266]  1000  1266     1624        0    53248      169   =
          0 grep
[ 1466.913984] [   1267]  1000  1267     2545        0    61440      213   =
          0 sed
[ 1466.913985] [   1268]  1000  1268     1623        0    53248      103   =
          0 grep
[ 1466.913986] [   1269]  1000  1269     1528        0    53248       93   =
          0 dmesg
[ 1466.913988] [   1270]  1000  1270     1862        0    49152      106   =
          0 stripcolors
[ 1466.913989] [   1271]  1000  1271     1627        0    53248      143   =
          0 grep
[ 1466.913991] [   1272]  1000  1272     2512        0    61440      154   =
          0 sed
[ 1466.913992] [   1273]  1000  1273     2479        0    57344      101   =
          0 sed
[ 1466.913993] [   1274]  1000  1274     2479        0    61440       94   =
          0 sed
[ 1466.913995] [   1275]  1000  1275     2479        0    57344       82   =
          0 sed
[ 1466.913996] [   1276]  1000  1276     2479        0    57344      114   =
          0 sed
[ 1466.913998] [   1325]   133  1325    38725        0    73728      106   =
          0 rtkit-daemon
[ 1466.913999] [   1336]  1000  1336     2649        0    69632       99   =
          0 dbus-daemon
[ 1466.914000] [   1364]  1000  1364    61444        0   106496      288   =
          0 gsettings-helpe
[ 1466.914002] [   1369]  1000  1369    57721        0    81920      137   =
          0 xfconfd
[ 1466.914003] [   1765]  1000  1765    39295        0    69632      188   =
          0 dconf-service
[ 1466.914005] [   3405]  1000  3405     3410        1    69632     1632   =
          0 bash
[ 1466.914007] [   3472]  1000  3472     3487        0    61440      277   =
          0 top
[ 1466.914008] [   3824]  1000  3824     3411        1    69632     1656   =
          0 bash
[ 1466.914010] [   5947]  1000  5947     3410        1    73728     1633   =
          0 bash
[ 1466.914012] [  11271]  1000 11271     3410        1    73728     1669   =
          0 bash
[ 1466.914014] [  11355]  1000 11355     1862        1    53248      113   =
          0 v
[ 1466.914015] [  11363]  1000 11363    16261        0   167936     1709   =
          0 vim
[ 1466.914017] [  14553]  1000 14553     3501        1    73728     1714   =
          0 bash
[ 1466.914019] [  14624]  1000 14624     1646      131    65536       82   =
          0 watch
[ 1466.914020] [  15658]  1000 15658      947        1    49152       26   =
          0 stress
[ 1466.914022] [  15659]  1000 15659  2442354    35472   733184    49380   =
          0 stress
[ 1466.914023] [  15660]  1000 15660  2442354    17461   712704    64448   =
          0 stress
[ 1466.914025] [  15661]  1000 15661  2442354    31447  1048576    92880   =
          0 stress
[ 1466.914026] [  15662]  1000 15662  2442354    24856   692224    54878   =
          0 stress
[ 1466.914027] [  15663]  1000 15663  2442354    78517  1007616    40479   =
          0 stress
[ 1466.914029] [  15664]  1000 15664  2442354    28535   946176    82962   =
          0 stress
[ 1466.914030] [  15665]  1000 15665  2442354      763   458752    49668   =
          0 stress
[ 1466.914032] [  15666]  1000 15666  2442354    33217   905216    73150   =
          0 stress
[ 1466.914033] [  15667]  1000 15667  2442354    27000  1216512   118297   =
          0 stress
[ 1466.914034] [  15668]  1000 15668  2442354    30129   868352    71648   =
          0 stress
[ 1466.914036] [  15669]  1000 15669  2442354    58911  1298432    96600   =
          0 stress
[ 1466.914037] [  15670]  1000 15670  2442354    34067  1028096    87659   =
          0 stress
[ 1466.914038] [  15671]  1000 15671  2442354    37665  1290240   116863   =
          0 stress
[ 1466.914040] [  15672]  1000 15672  2442354    27605  1064960    98712   =
          0 stress
[ 1466.914041] [  15673]  1000 15673  2442354    72245  1294336    82778   =
          0 stress
[ 1466.914042] [  15674]  1000 15674  2442354    32309  1101824    98646   =
          0 stress
[ 1466.914044] [  15675]  1000 15675  2442354    16205   659456    59473   =
          0 stress
[ 1466.914045] [  15676]  1000 15676  2442354    75163  1179648    65513   =
          0 stress
[ 1466.914047] [  15677]  1000 15677  2442354        1   577536    65327   =
          0 stress
[ 1466.914048] [  15678]  1000 15678  2442354       87   643072    73506   =
          0 stress
[ 1466.914050] [  15679]  1000 15679  2442354    21381   598016    46576   =
          0 stress
[ 1466.914051] [  15680]  1000 15680  2442354    27317   925696    81287   =
          0 stress
[ 1466.914052] [  15681]  1000 15681  2442354    53527  1007616    65673   =
          0 stress
[ 1466.914054] [  15682]  1000 15682  2442354    33620   790528    58401   =
          0 stress
[ 1466.914055] [  15683]  1000 15683  2442354    22478   688128    56765   =
          0 stress
[ 1466.914056] [  15684]  1000 15684  2442354    45031   774144    44974   =
          0 stress
[ 1466.914058] [  15685]  1000 15685  2442354      167   466944    51456   =
          0 stress
[ 1466.914059] [  15686]  1000 15686  2442354    30506   684032    48204   =
          0 stress
[ 1466.914060] [  15687]  1000 15687  2442354       76   360448    38174   =
          0 stress
[ 1466.914062] [  15688]  1000 15688  2442354    27924   716800    54795   =
          0 stress
[ 1466.914063] [  15689]  1000 15689  2442354    24105   823296    72068   =
          0 stress
[ 1466.914064] [  15690]  1000 15690  2442354    13187   651264    60993   =
          0 stress
[ 1466.914066] [  15691]  1000 15691  2442354    20202   675840    57520   =
          0 stress
[ 1466.914067] [  15692]  1000 15692  2442354    37068  1036288    85690   =
          0 stress
[ 1466.914069] [  15693]  1000 15693  2442354    34960   753664    52047   =
          0 stress
[ 1466.914070] [  15694]  1000 15694  2442354    33364  1003520    85280   =
          0 stress
[ 1466.914071] [  15695]  1000 15695  2442354    37500  1122304    95993   =
          0 stress
[ 1466.914073] [  15696]  1000 15696  2442354    40010   774144    49648   =
          0 stress
[ 1466.914074] [  15697]  1000 15697  2442354    25200   733184    59669   =
          0 stress
[ 1466.914075] [  15698]  1000 15698  2442354    33928   860160    66367   =
          0 stress
[ 1466.914077] [  15699]  1000 15699  2442354    28883   696320    51372   =
          0 stress
[ 1466.914078] [  15700]  1000 15700  2442354    63688  1032192    58535   =
          0 stress
[ 1466.914079] [  15701]  1000 15701  2442354      206   462848    50676   =
          0 stress
[ 1466.914081] [  15702]  1000 15702  2442354    37586   978944    78007   =
          0 stress
[ 1466.914082] [  15703]  1000 15703  2442354    57038   950272    54697   =
          0 stress
[ 1466.914083] [  15704]  1000 15704  2442354    23691   688128    55570   =
          0 stress
[ 1466.914085] [  15705]  1000 15705  2442354    24519   704512    56769   =
          0 stress
[ 1466.914086] [  15706]  1000 15706  2442354    41070   831488    56065   =
          0 stress
[ 1466.914087] [  15707]  1000 15707  2442354    16687   950272    95308   =
          0 stress
[ 1466.914089] [  15708]  1000 15708  2442354    72969  1179648    67689   =
          0 stress
[ 1466.914090] [  15709]  1000 15709  2442354    46107   962560    67440   =
          0 stress
[ 1466.914091] [  15710]  1000 15710  2442354    30480   733184    54368   =
          0 stress
[ 1466.914093] [  15711]  1000 15711  2442354    28799   757760    58943   =
          0 stress
[ 1466.914094] [  15712]  1000 15712  2442354    24325   806912    69759   =
          0 stress
[ 1466.914095] [  15713]  1000 15713  2442354    17610   737280    67758   =
          0 stress
[ 1466.914097] [  15714]  1000 15714  2442354    26403   917504    81508   =
          0 stress
[ 1466.914098] [  15715]  1000 15715  2442354     1099   577536    64016   =
          0 stress
[ 1466.914099] [  15716]  1000 15716  2442354    36219   880640    67074   =
          0 stress
[ 1466.914101] [  15717]  1000 15717  2442354    47198  1003520    71486   =
          0 stress
[ 1466.914102] [  15718]  1000 15718  2442354    22209   798720    70805   =
          0 stress
[ 1466.914103] [  15719]  1000 15719  2442354    36188   729088    48179   =
          0 stress
[ 1466.914105] [  15720]  1000 15720  2442354    48222  1081344    80144   =
          0 stress
[ 1466.914106] [  15721]  1000 15721  2442354   114843  1372160    49891   =
          0 stress
[ 1466.914108] [  15722]  1000 15722  2442354      162   557056    62352   =
          0 stress
[ 1466.914109] [  15723]  1000 15723  2442354    34078   843776    64635   =
          0 stress
[ 1466.914110] [  15724]  1000 15724  2442354        1   516096    57478   =
          0 stress
[ 1466.914112] [  15725]  1000 15725  2442354    33713   684032    45031   =
          0 stress
[ 1466.914113] [  15726]  1000 15726  2442354    70880  1007616    48303   =
          0 stress
[ 1466.914114] [  15727]  1000 15727  2442354    33070   794624    59294   =
          0 stress
[ 1466.914116] [  15728]  1000 15728  2442354    49921   884736    53910   =
          0 stress
[ 1466.914117] [  15729]  1000 15729  2442354    37100   786432    54438   =
          0 stress
[ 1466.914118] [  15730]  1000 15730  2442354      772   745472    85673   =
          0 stress
[ 1466.914120] [  15731]  1000 15731  2442354    20798   647168    53336   =
          0 stress
[ 1466.914121] [  15732]  1000 15732  2442354    66860  1286144    87132   =
          0 stress
[ 1466.914122] [  15733]  1000 15733  2442354    58022  1003520    60648   =
          0 stress
[ 1466.914124] [  15734]  1000 15734  2442354    40229   794624    52337   =
          0 stress
[ 1466.914125] [  15735]  1000 15735  2442354    52416   831488    44743   =
          0 stress
[ 1466.914127] [  15736]  1000 15736  2442354    22784  1220608   123039   =
          0 stress
[ 1466.914128] [  15737]  1000 15737  2442354    47752  1228800    99082   =
          0 stress
[ 1466.914130] [  15738]  1000 15738  2442354     5388   598016    62219   =
          0 stress
[ 1466.914131] [  15739]  1000 15739  2442354    42512   991232    74612   =
          0 stress
[ 1466.914132] [  15740]  1000 15740  2442354    30409   843776    68268   =
          0 stress
[ 1466.914134] [  15741]  1000 15741  2442354       61   385024    41076   =
          0 stress
[ 1466.914135] [  15742]  1000 15742  2442354    22049   688128    57225   =
          0 stress
[ 1466.914136] [  15743]  1000 15743  2442354    11593  1163264   127053   =
          0 stress
[ 1466.914138] [  15744]  1000 15744  2442354    12709   700416    68066   =
          0 stress
[ 1466.914139] [  15745]  1000 15745  2442354    58506   966656    55522   =
          0 stress
[ 1466.914140] [  15746]  1000 15746  2442354    37704   978944    77912   =
          0 stress
[ 1466.914142] [  15747]  1000 15747  2442354      557   430080    46244   =
          0 stress
[ 1466.914143] [  15748]  1000 15748  2442354    47961   929792    61466   =
          0 stress
[ 1466.914144] [  15749]  1000 15749  2442354    35600   880640    67733   =
          0 stress
[ 1466.914146] [  15750]  1000 15750  2442354    36018   897024    69355   =
          0 stress
[ 1466.914147] [  15751]  1000 15751  2442354      397   552960    61659   =
          0 stress
[ 1466.914149] [  15752]  1000 15752  2442354     9336   745472    77088   =
          0 stress
[ 1466.914150] [  15753]  1000 15753  2442354    57814  1249280    91607   =
          0 stress
[ 1466.914151] [  15754]  1000 15754  2442354    46202  1044480    77582   =
          0 stress
[ 1466.914153] [  15755]  1000 15755  2442354    63801  1069056    63083   =
          0 stress
[ 1466.914154] [  15756]  1000 15756  2442354    21609   765952    67300   =
          0 stress
[ 1466.914155] [  15757]  1000 15757  2442354    59274   892928    45599   =
          0 stress
[ 1466.914157] [  15758]  1000 15758  2442354        1   479232    52862   =
          0 stress
[ 1466.914158] [  15759]  1000 15759  2442354    76444  1163264    62175   =
          0 stress
[ 1466.914160] [  15760]  1000 15760  2442354    31653   933888    78283   =
          0 stress
[ 1466.914161] [  15761]  1000 15761  2442354    30021   790528    62026   =
          0 stress
[ 1466.914163] [  15762]  1000 15762  2442354    45007   901120    60875   =
          0 stress
[ 1466.914164] [  15763]  1000 15763  2442354    21275   659456    54316   =
          0 stress
[ 1466.914165] [  15764]  1000 15764  2442354    29773   778240    60715   =
          0 stress
[ 1466.914167] [  15765]  1000 15765  2442354    34685   815104    60423   =
          0 stress
[ 1466.914168] [  15766]  1000 15766  2442354    19320   741376    66595   =
          0 stress
[ 1466.914169] [  15767]  1000 15767  2442354    26619   630784    45137   =
          0 stress
[ 1466.914171] [  15768]  1000 15768  2442354    65238  1044480    58545   =
          0 stress
[ 1466.914172] [  15769]  1000 15769  2442354    34694   851968    65018   =
          0 stress
[ 1466.914174] [  15770]  1000 15770  2442354     7212   589824    59319   =
          0 stress
[ 1466.914175] [  15771]  1000 15771  2442354    35594   729088    48796   =
          0 stress
[ 1466.914177] [  15772]  1000 15772  2442354    17326   811008    77258   =
          0 stress
[ 1466.914178] [  15773]  1000 15773  2442354    32841  1118208   100160   =
          0 stress
[ 1466.914180] [  15774]  1000 15774  2442354      202   847872    98614   =
          0 stress
[ 1466.914181] [  15775]  1000 15775  2442354       31   651264    74185   =
          0 stress
[ 1466.914182] [  15776]  1000 15776  2442354    44425  1032192    77815   =
          0 stress
[ 1466.914184] [  15777]  1000 15777  2442354    23280   675840    54459   =
          0 stress
[ 1466.914185] [  15778]  1000 15778  2442354    20222   839680    77633   =
          0 stress
[ 1466.914187] [  15779]  1000 15779  2442354    34766  1187840   106667   =
          0 stress
[ 1466.914188] [  15780]  1000 15780  2442354    18561   540672    42251   =
          0 stress
[ 1466.914189] [  15781]  1000 15781  2442354      157   360448    37959   =
          0 stress
[ 1466.914191] [  15782]  1000 15782  2442354    31124   733184    53724   =
          0 stress
[ 1466.914209] [  15783]  1000 15783  2442354    25112   638976    48009   =
          0 stress
[ 1466.914210] [  15784]  1000 15784  2442354     9932   495616    45085   =
          0 stress
[ 1466.914212] [  15785]  1000 15785  2442354    33793   724992    50071   =
          0 stress
[ 1466.914213] [  15786]  1000 15786  2442354    20149   860160    80493   =
          0 stress
[ 1466.914214] [  15787]  1000 15787  2442354    49386  1040384    73876   =
          0 stress
[ 1466.914216] [  15788]  1000 15788  2442354    26792   794624    65738   =
          0 stress
[ 1466.914217] [  15789]  1000 15789  2442354      463   647168    73278   =
          0 stress
[ 1466.914219] [  15790]  1000 15790  2442354    27350   651264    47280   =
          0 stress
[ 1466.914220] [  15791]  1000 15791  2442354    27893   974848    87221   =
          0 stress
[ 1466.914221] [  15792]  1000 15792  2442354    51549   917504    56361   =
          0 stress
[ 1466.914223] [  15793]  1000 15793  2442354    31852   860160    68872   =
          0 stress
[ 1466.914224] [  15794]  1000 15794  2442354    28996   827392    67626   =
          0 stress
[ 1466.914226] [  15795]  1000 15795  2442354    49525   806912    44556   =
          0 stress
[ 1466.914227] [  15796]  1000 15796  2442354    59806   819200    35827   =
          0 stress
[ 1466.914228] [  15797]  1000 15797  2442354    42778   966656    71305   =
          0 stress
[ 1466.914230] [  15798]  1000 15798  2442354    29384   745472    57056   =
          0 stress
[ 1466.914231] [  15799]  1000 15799  2442354    29609   655360    45554   =
          0 stress
[ 1466.914232] [  15800]  1000 15800  2442354    19677   602112    48838   =
          0 stress
[ 1466.914234] [  15801]  1000 15801  2442354    91631  1261568    59202   =
          0 stress
[ 1466.914235] [  15802]  1000 15802  2442354    37784   708608    44013   =
          0 stress
[ 1466.914236] [  15803]  1000 15803  2442354    38862   843776    59834   =
          0 stress
[ 1466.914238] [  15804]  1000 15804  2442354    53364  1110016    78641   =
          0 stress
[ 1466.914239] [  15805]  1000 15805  2442354       93   380928    40778   =
          0 stress
[ 1466.914241] [  15806]  1000 15806  2442354    38511  1003520    80159   =
          0 stress
[ 1466.914242] [  15807]  1000 15807  2442354    73352  1150976    63780   =
          0 stress
[ 1466.914243] [  15808]  1000 15808  2442354    41336   745472    45096   =
          0 stress
[ 1466.914245] [  15809]  1000 15809  2442354    22708   831488    74460   =
          0 stress
[ 1466.914246] [  15810]  1000 15810  2442354    30775   716800    52072   =
          0 stress
[ 1466.914247] [  15811]  1000 15811  2442354    28548  1024000    92686   =
          0 stress
[ 1466.914249] [  15812]  1000 15812  2442354    45063  1224704   101243   =
          0 stress
[ 1466.914250] [  15813]  1000 15813  2442354    41298   786432    50210   =
          0 stress
[ 1466.914252] [  15814]  1000 15814  2442354    16514   557056    45980   =
          0 stress
[ 1466.914253] [  15815]  1000 15815  2442354    38228   950272    73777   =
          0 stress
[ 1466.914255] [  15816]  1000 15816  2442354     3546  1073152   123763   =
          0 stress
[ 1466.914256] [  15817]  1000 15817  2442354      228   774144    89437   =
          0 stress
[ 1466.914258] [  15818]  1000 15818  2442354   147848  2117632   109587   =
          0 stress
[ 1466.914259] [  15819]  1000 15819  2442354    30535  1105920   100966   =
          0 stress
[ 1466.914260] [  15820]  1000 15820  2442354    35952  1097728    94515   =
          0 stress
[ 1466.914262] [  15821]  1000 15821  2442354        1   716800    82464   =
          0 stress
[ 1466.914263] [  15822]  1000 15822  2442354    24288  1056768   101008   =
          0 stress
[ 1466.914265] [  15823]  1000 15823  2442354       82   753664    87027   =
          0 stress
[ 1466.914266] [  15824]  1000 15824  2442354    46572  1122304    86919   =
          0 stress
[ 1466.914268] [  15825]  1000 15825  2442354    27250  1073152   100103   =
          0 stress
[ 1466.914269] [  15826]  1000 15826  2442354    16521   851968    83211   =
          0 stress
[ 1466.914270] [  15827]  1000 15827  2442354    65108  1241088    83270   =
          0 stress
[ 1466.914272] [  15828]  1000 15828  2442354    42946   995328    74688   =
          0 stress
[ 1466.914273] [  15829]  1000 15829  2442354    29091  1073152    97972   =
          0 stress
[ 1466.914275] [  15830]  1000 15830  2442354    43149  1134592    91934   =
          0 stress
[ 1466.914276] [  15831]  1000 15831  2442354    20040   962560    93516   =
          0 stress
[ 1466.914277] [  15832]  1000 15832  2442354    39625  1032192    82643   =
          0 stress
[ 1466.914279] [  15833]  1000 15833  2442354    28676   802816    64882   =
          0 stress
[ 1466.914280] [  15834]  1000 15834  2442354    32089  1122304   101453   =
          0 stress
[ 1466.914281] [  15835]  1000 15835  2442354    53649  1032192    68572   =
          0 stress
[ 1466.914283] [  15836]  1000 15836  2442354      176   585728    66213   =
          0 stress
[ 1466.914284] [  15837]  1000 15837  2442354       16   487424    53694   =
          0 stress
[ 1466.914286] [  15838]  1000 15838  2442354    34092   753664    53328   =
          0 stress
[ 1466.914287] [  15839]  1000 15839  2442354    24923   733184    59956   =
          0 stress
[ 1466.914288] [  15840]  1000 15840  2442354    75766  1343488    85385   =
          0 stress
[ 1466.914290] [  15841]  1000 15841  2442354    24663   819200    70933   =
          0 stress
[ 1466.914291] [  15842]  1000 15842  2442354    53107   966656    60930   =
          0 stress
[ 1466.914292] [  15843]  1000 15843  2442354    38419   925696    70548   =
          0 stress
[ 1466.914294] [  15844]  1000 15844  2442354    34410   823296    61763   =
          0 stress
[ 1466.914295] [  15845]  1000 15845  2442354    18088   724992    65749   =
          0 stress
[ 1466.914297] [  15846]  1000 15846  2442354    48202  1228800    98646   =
          0 stress
[ 1466.914298] [  15847]  1000 15847  2442354    82782  1212416    61974   =
          0 stress
[ 1466.914299] [  15848]  1000 15848  2442354    19695   872448    82357   =
          0 stress
[ 1466.914301] [  15849]  1000 15849  2442354    34530   860160    66229   =
          0 stress
[ 1466.914302] [  15850]  1000 15850  2442354    40215   819200    55441   =
          0 stress
[ 1466.914303] [  15851]  1000 15851  2442354    33624   716800    49227   =
          0 stress
[ 1466.914305] [  15852]  1000 15852  2442354    55436   995328    62192   =
          0 stress
[ 1466.914306] [  15853]  1000 15853  2442354    21205   929792    88066   =
          0 stress
[ 1466.914308] [  15854]  1000 15854  2442354    52815  1171456    86823   =
          0 stress
[ 1466.914309] [  15855]  1000 15855  2442354    16708   667648    59546   =
          0 stress
[ 1466.914310] [  15856]  1000 15856  2442354    33506   925696    75409   =
          0 stress
[ 1466.914312] [  15857]  1000 15857  2442354     4436   417792    41037   =
          0 stress
[ 1466.914313] [  15858]  1000 15858  2442354    41905   839680    56283   =
          0 stress
[ 1466.914314] [  15859]  1000 15859  2442354    16448   802816    77136   =
          0 stress
[ 1466.914316] [  15860]  1000 15860  2442354    48905   950272    63128   =
          0 stress
[ 1466.914317] [  15861]  1000 15861  2442354    14641   704512    66276   =
          0 stress
[ 1466.914319] [  15862]  1000 15862  2442354      244   638976    72828   =
          0 stress
[ 1466.914320] [  15863]  1000 15863  2442354    37726   978944    77901   =
          0 stress
[ 1466.914321] [  15864]  1000 15864  2442354    69044  1224704    77302   =
          0 stress
[ 1466.914323] [  15865]  1000 15865  2442354    50818   892928    54057   =
          0 stress
[ 1466.914324] [  15866]  1000 15866  2442354      149   815104    94511   =
          0 stress
[ 1466.914326] [  15867]  1000 15867  2442354    21797   753664    65579   =
          0 stress
[ 1466.914327] [  15868]  1000 15868  2442354    86029  3780608   379238   =
          0 stress
[ 1466.914329] [  15869]  1000 15869  2442354    35631  1433600   136771   =
          0 stress
[ 1466.914330] [  15870]  1000 15870  2442354    73646  1695744   131540   =
          0 stress
[ 1466.914332] [  15871]  1000 15871  2442354    70948  1466368   105576   =
          0 stress
[ 1466.914333] [  15872]  1000 15872  2442354      627  2543616   309624   =
          0 stress
[ 1466.914335] [  15873]  1000 15873  2442354      592   802816    93005   =
          0 stress
[ 1466.914336] [  15874]  1000 15874  2442354    50241  3207168   343395   =
          0 stress
[ 1466.914337] [  15875]  1000 15875  2442354    33324  1392640   133978   =
          0 stress
[ 1466.914339] [  15876]  1000 15876  2442354    75920  1761280   137479   =
          0 stress
[ 1466.914340] [  15877]  1000 15877  2442354    36961  3280896   365416   =
          0 stress
[ 1466.914341] [  15878]  1000 15878  2442354    33187  1441792   140260   =
          0 stress
[ 1466.914342] oom-kill:constraint=3DCONSTRAINT_NONE,nodemask=3D(null),cpus=
et=3D/,mems_allowed=3D0,global_oom,task_memcg=3D/user.slice/user-1000.slice=
/session-1.scope,task=3Dstress,pid=3D15868,uid=3D1000
[ 1466.914349] Out of memory: Killed process 15868 (stress) total-vm:976941=
6kB, anon-rss:344112kB, file-rss:4kB, shmem-rss:0kB
[ 1467.129760] oom_reaper: reaped process 15868 (stress), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:0kB



I got one at 19.2sec
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [21374] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: FAIL: [21374] (415) <-- worker 21585 got signal 9
stress: WARN: [21374] (417) now reaping child worker processes
stress: FAIL: [21374] (451) failed run completed in 19s

real=090m19.223s
user=090m1.077s
sys=092m53.496s

I did 45 tries without tracers.
Recompiled kernel just like the last time(when I was able to trigger it on =
the third try) aka with tracers:
I did 15 tries and they were all successfull(at full CPU speed) with durati=
ons between 17-22 sec.
I guess all that tracing code in kernel introduced some minor lag which is =
enough for this to never trigger OOM-killer, just like when I limit cpu max=
 to 800Mhz.

I even tried running two in parallel, no OOM-killer.
Or this:
$ time stress -m 220 --vm-bytes 10000000000 --timeout 30
stress: info: [12381] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [12381] successful run completed in 56s

real=090m55.957s
user=090m1.908s
sys=099m20.969s
Longer timeout I could see 65000MiB of swap were used at some point! (in 't=
op')
still nothing triggered OOM-killer :D
ok, a timeout of 60 did it(triggered OOM):
$ time stress -m 220 --vm-bytes 10000000000 --timeout 60
stress: info: [13225] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: FAIL: [13225] (415) <-- worker 13445 got signal 9
stress: WARN: [13225] (417) now reaping child worker processes
stress: FAIL: [13225] (451) failed run completed in 59s

real=090m58.812s
user=090m2.312s
sys=099m53.327s

But anyway, since last time I was able to trigger it with the normal(timeou=
t 10) command on the third try, I've decided to keep trying that:
after 170 more tries via `$ while true; do time stress -m 220 --vm-bytes 10=
000000000 --timeout 10; done`
I saw no hangs or any runs taking more time than the usual 16-26 sec.
So the patch must be working as intended. Thanks very much. Let me know if =
you want me to do anything else.

Cheers!

