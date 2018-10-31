Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF2E6B000E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:19:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb3-v6so12395758plb.20
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:19:24 -0700 (PDT)
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181031081945.207709-1-vovoy@chromium.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
Date: Wed, 31 Oct 2018 07:19:21 -0700
MIME-Version: 1.0
In-Reply-To: <20181031081945.207709-1-vovoy@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: owner-linux-mm@kvack.org, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.orglinux-mm@kvack.org
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 10/31/18 1:19 AM, owner-linux-mm@kvack.org wrote:
> -These are currently used in two places in the kernel:
> +These are currently used in three places in the kernel:
>  
>   (1) By ramfs to mark the address spaces of its inodes when they are created,
>       and this mark remains for the life of the inode.
> @@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
>       swapped out; the application must touch the pages manually if it wants to
>       ensure they're in memory.
>  
> + (3) By the i915 driver to mark pinned address space until it's unpinned.

mlock() and ramfs usage are pretty easy to track down.  /proc/$pid/smaps
or /proc/meminfo can show us mlock() and good ol' 'df' and friends can
show us ramfs the extent of pinned memory.

With these, if we see "Unevictable" in meminfo bump up, we at least have
a starting point to find the cause.

Do we have an equivalent for i915?
