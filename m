Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F6E8C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:39:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3481A2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3481A2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD86B6B000E; Thu,  8 Aug 2019 12:39:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88E26B0266; Thu,  8 Aug 2019 12:39:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A517B6B0269; Thu,  8 Aug 2019 12:39:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 844A56B000E
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:39:09 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id m25so85783797qtn.18
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:39:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FAQsoWa+YjeSw28UKnYMTaDlYJFNmo+0V7yCGyNpCOU=;
        b=kx2n70QFpWR0N+5ExCBi6TTdC0AT6oIyAGI3KL/ltBwQoulpGkxn57Klq/mATdNp7M
         HgZ2Ys/0hkM4ZIKRnZFJgGQiEhgtRFkCvDKfaOdZZ5vdIVHAjhdJ029QMcXlFE8ZOVvg
         wUjyaJSuHcOxRV2c3nTr/3qIx3owkBlRLlejt+dtIYtExdv3/BwfyoG4uv/dpTn8DjO6
         OVlKjPzoS1GN7kOYiNb+X7GYAufT30c8+DFAWFCbbuhR6NHnwcOYcnaQdsDRdL1bOmEI
         dajB0xt0kwy6hXQUX5w8IFxUii0GD94ABiRdAtx4735KJv919E2+Z29Lv4zRmMgRF3Hn
         avqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjocRxeP0FlEzSpHeyegsuk1CcqOo2XBP8To63cGuYbAcu4JVf
	VtuOID5NLVMuKXa/redTEi6YXJW22xYA7XRgpiY7Lo8As5Uki3coqbLACYyB/kKCktqThLkZhG8
	VuY/RMoOkcRVHGo47M7lCUeOzUmhzBs9Y5nUW5rtZyt69kGJ8/qYP3Q/SVpVB+3h/iw==
X-Received: by 2002:aed:2063:: with SMTP id 90mr14058820qta.307.1565282349282;
        Thu, 08 Aug 2019 09:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA2HpoKU4W0g/uMTt1xiHNRj7b8r1DdGiPBrYWbh9oTQBMlv1y81Sxj7FuLL9eQ+7oj201
X-Received: by 2002:aed:2063:: with SMTP id 90mr14058762qta.307.1565282348415;
        Thu, 08 Aug 2019 09:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565282348; cv=none;
        d=google.com; s=arc-20160816;
        b=NzJZxnocl8HkN/y1yjQtsKHRXuouMplZMAfJKgYnMyjHw7cCjdmrBFolFq2Kt7nndP
         /MCU2eTCNHlwBDRDkIiJeBwU2V+SmlgA3n0FfoKDKxJyWNUWZgAQUgBrBqBjWRgDxljg
         CjZ2f0E2jhvS/x5P8OByAsPqokqX9l/SYpP3vEvZLdsLKQWFA8H/MJzqa2SVKx77t+0O
         CbLduZ2EJBS313XzKlwGqoCSEslxpm5xTZbZ0NaKZCvTJB1XFaMD31i+wWbNG1bYiCc4
         JIJY2LCzlqPf3herUSJjGgB+T8om35j7xVWMesRhXuwosL7Oal38XSCkRS4J6OEJ5lHD
         I7hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FAQsoWa+YjeSw28UKnYMTaDlYJFNmo+0V7yCGyNpCOU=;
        b=JPc0ch2rDKuI9Dz4MuqXhgcfpXrCezjCzWdOir2/yK1yenjf5WTS0Nw4ELgIEqPwR0
         TZKjekJWdlAc8Mi5jg6IbeRGwrAhIgCveFyK9+g5gyj2hHFQ5NaF6XCCb0y2Nv5NICXX
         9JAMIMnD8otNYo2qLGnw0zkYSxb0OIx57EsbXDx9HdGEM1jWXPZhHCWoTQdCejgTzmsC
         CFq0ZohrieK+5mJSuWOf5X4mh149pXqWTI6HtyZZRQBxZWwq5wxPf+BPsBET/9uJwWYJ
         Cs+9/7JEAwq/E8b4Kgchr2wf6fIdc/R1nm7y/HOm4IbvtnQppey13WHd6Zl1tAE7czHw
         AvGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7si3806469qkc.19.2019.08.08.09.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9FAF83091DC4;
	Thu,  8 Aug 2019 16:39:07 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 20B0860BE1;
	Thu,  8 Aug 2019 16:39:07 +0000 (UTC)
Date: Thu, 8 Aug 2019 12:39:05 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 23/24] xfs: reclaim inodes from the LRU
Message-ID: <20190808163905.GC24551@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-24-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-24-david@fromorbit.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 08 Aug 2019 16:39:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:51PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Replace the AG radix tree walking reclaim code with a list_lru
> walker, giving us both node-aware and memcg-aware inode reclaim
> at the XFS level. This requires adding an inode isolation function to
> determine if the inode can be reclaim, and a list walker to
> dispose of the inodes that were isolated.
> 
> We want the isolation function to be non-blocking. If we can't
> grab an inode then we either skip it or rotate it. If it's clean
> then we skip it, if it's dirty then we rotate to give it time to be

Do you mean we remove it if it's clean?

> cleaned before it is scanned again.
> 
> This congregates the dirty inodes at the tail of the LRU, which
> means that if we start hitting a majority of dirty inodes either
> there are lots of unlinked inodes in the reclaim list or we've
> reclaimed all the clean inodes and we're looped back on the dirty
> inodes. Either way, this is an indication we should tell kswapd to
> back off.
> 
> The non-blocking isolation function introduces a complexity for the
> filesystem shutdown case. When the filesystem is shut down, we want
> to free the inode even if it is dirty, and this may require
> blocking. We already hold the locks needed to do this blocking, so
> what we do is that we leave inodes locked - both the ILOCK and the
> flush lock - while they are sitting on the dispose list to be freed
> after the LRU walk completes.  This allows us to process the
> shutdown state outside the LRU walk where we can block safely.
> 
> Keep in mind we don't have to care about inode lock order or
> blocking with inode locks held here because a) we are using
> trylocks, and b) once marked with XFS_IRECLAIM they can't be found
> via the LRU and inode cache lookups will abort and retry. Hence
> nobody will try to lock them in any other context that might also be
> holding other inode locks.
> 
> Also convert xfs_reclaim_inodes() to use a LRU walk to free all
> the reclaimable inodes in the filesystem.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_icache.c | 199 ++++++++++++++++++++++++++++++++++++++------
>  fs/xfs/xfs_icache.h |  10 ++-
>  fs/xfs/xfs_inode.h  |   8 ++
>  fs/xfs/xfs_super.c  |  50 +++++++++--
>  4 files changed, 232 insertions(+), 35 deletions(-)
> 
...
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index b5c4c1b6fd19..e3e898a2896c 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
...
> @@ -1810,23 +1811,58 @@ xfs_fs_mount(
>  }
>  
>  static long
> -xfs_fs_nr_cached_objects(
> +xfs_fs_free_cached_objects(
>  	struct super_block	*sb,
>  	struct shrink_control	*sc)
>  {
> -	/* Paranoia: catch incorrect calls during mount setup or teardown */
> -	if (WARN_ON_ONCE(!sb->s_fs_info))
> -		return 0;
> +	struct xfs_mount	*mp = XFS_M(sb);
> +        struct xfs_ireclaim_args ra;

^ whitespace damage

> +	long freed;
>  
> -	return list_lru_shrink_count(&XFS_M(sb)->m_inode_lru, sc);
> +	INIT_LIST_HEAD(&ra.freeable);
> +	ra.lowest_lsn = NULLCOMMITLSN;
> +	ra.dirty_skipped = 0;
> +
> +	freed = list_lru_shrink_walk(&mp->m_inode_lru, sc,
> +					xfs_inode_reclaim_isolate, &ra);

This is more related to the locking discussion on the earlier patch, but
this looks like it has more similar serialization to the example patch I
posted than the one without locking at all. IIUC, this walk has an
internal lock per node lru that is held across the walk and passed into
the callback. We never cycle it, so for any given node we only allow one
reclaimer through here at a time.

That seems to be Ok given we don't do much in the isolation handler, the
lock isn't held across the dispose sequence and we're still batching in
the shrinker core on top of that. We're still serialized over the lru
fixups such that concurrent reclaimers aren't processing the same
inodes, however.

BTW I got a lockdep splat[1] for some reason on a straight mount/unmount
cycle with this patch.

Brian

[1] dmesg output:

[   39.011867] ============================================
[   39.012643] WARNING: possible recursive locking detected
[   39.013422] 5.3.0-rc2+ #205 Not tainted
[   39.014623] --------------------------------------------
[   39.015636] umount/871 is trying to acquire lock:
[   39.016122] 00000000ea09de26 (&xfs_nondir_ilock_class){+.+.}, at: xfs_ilock+0xd2/0x280 [xfs]
[   39.017072] 
[   39.017072] but task is already holding lock:
[   39.017832] 000000001a5b5707 (&xfs_nondir_ilock_class){+.+.}, at: xfs_ilock_nowait+0xcb/0x320 [xfs]
[   39.018909] 
[   39.018909] other info that might help us debug this:
[   39.019570]  Possible unsafe locking scenario:
[   39.019570] 
[   39.020248]        CPU0
[   39.020512]        ----
[   39.020778]   lock(&xfs_nondir_ilock_class);
[   39.021246]   lock(&xfs_nondir_ilock_class);
[   39.021705] 
[   39.021705]  *** DEADLOCK ***
[   39.021705] 
[   39.022338]  May be due to missing lock nesting notation
[   39.022338] 
[   39.023070] 3 locks held by umount/871:
[   39.023481]  #0: 000000004d39d244 (&type->s_umount_key#61){+.+.}, at: deactivate_super+0x43/0x50
[   39.024462]  #1: 0000000011270366 (&xfs_dir_ilock_class){++++}, at: xfs_ilock_nowait+0xcb/0x320 [xfs]
[   39.025488]  #2: 000000001a5b5707 (&xfs_nondir_ilock_class){+.+.}, at: xfs_ilock_nowait+0xcb/0x320 [xfs]
[   39.027163] 
[   39.027163] stack backtrace:
[   39.027681] CPU: 3 PID: 871 Comm: umount Not tainted 5.3.0-rc2+ #205
[   39.028534] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   39.029152] Call Trace:
[   39.029428]  dump_stack+0x67/0x90
[   39.029889]  __lock_acquire.cold.67+0x121/0x1f9
[   39.030519]  lock_acquire+0x90/0x170
[   39.031170]  ? xfs_ilock+0xd2/0x280 [xfs]
[   39.031603]  down_write_nested+0x4f/0xb0
[   39.032064]  ? xfs_ilock+0xd2/0x280 [xfs]
[   39.032684]  ? xfs_dispose_inodes+0x124/0x320 [xfs]
[   39.033575]  xfs_ilock+0xd2/0x280 [xfs]
[   39.034058]  xfs_dispose_inodes+0x124/0x320 [xfs]
[   39.034656]  xfs_reclaim_inodes+0x149/0x190 [xfs]
[   39.035381]  ? finish_wait+0x80/0x80
[   39.035855]  xfs_unmountfs+0x81/0x190 [xfs]
[   39.036443]  xfs_fs_put_super+0x35/0x90 [xfs]
[   39.037016]  generic_shutdown_super+0x6c/0x100
[   39.037554]  kill_block_super+0x21/0x50
[   39.037986]  deactivate_locked_super+0x34/0x70
[   39.038477]  cleanup_mnt+0xb8/0x140
[   39.038879]  task_work_run+0x9e/0xd0
[   39.039302]  exit_to_usermode_loop+0xb3/0xc0
[   39.039774]  do_syscall_64+0x206/0x210
[   39.040591]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   39.041771] RIP: 0033:0x7fcd4ec0536b
[   39.042627] Code: 0b 0c 00 f7 d8 64 89 01 48 83 c8 ff c3 66 90 f3 0f 1e fa 31 f6 e9 05 00 00 00 0f 1f 44 00 00 f3 0f 1e fa b8 a6 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d ed 0a 0c 00 f7 d8 64 89 01 48
[   39.045336] RSP: 002b:00007ffdedf686c8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a6
[   39.046119] RAX: 0000000000000000 RBX: 00007fcd4ed2f1e4 RCX: 00007fcd4ec0536b
[   39.047506] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 000055ad23f2ad90
[   39.048295] RBP: 000055ad23f2ab80 R08: 0000000000000000 R09: 00007ffdedf67440
[   39.049062] R10: 000055ad23f2adb0 R11: 0000000000000246 R12: 000055ad23f2ad90
[   39.049869] R13: 0000000000000000 R14: 000055ad23f2ac78 R15: 0000000000000000

