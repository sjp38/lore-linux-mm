Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE956B038E
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 04:46:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so2450770wmg.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 01:46:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e69si2305033wmc.70.2017.03.17.01.46.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 01:46:55 -0700 (PDT)
Date: Fri, 17 Mar 2017 09:46:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: DOM Worker: page allocation stalls (4.9.13)
Message-ID: <20170317084652.GD26298@dhcp22.suse.cz>
References: <20170316100409.GR802@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316100409.GR802@shells.gnugeneration.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Philip J. Freeman" <elektron@halo.nu>
Cc: linux-mm@kvack.org

On Thu 16-03-17 03:04:09, Philip J. Freeman wrote:
> My laptop became almost totally un responsive today. I was able to
> switch VTs but not log in and had to power cycle to regain control. I
> don't understand what this means. Any ideas?
>
> Mar 14 14:31:20 x61s-44a5 kernel: [168382.032039] DOM Worker: page allocation stalls for 10646ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[...]
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032181] Mem-Info:
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192] active_anon:308454 inactive_anon:154809 isolated_anon:224
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  active_file:869 inactive_file:978 isolated_file:0
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  unevictable:0 dirty:0 writeback:0 unstable:0
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  slab_reclaimable:6099 slab_unreclaimable:8555
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  mapped:1999 shmem:156254 pagetables:2929 bounce:0
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032192]  free:13192 free_pcp:0 free_cma:0

OK, so the allocation couldn't make a forward progress for more than
10s. You do not seem to have many file pages on the LRU lists left
and so you only have anonymous memory as reclaimable. Slab doesn't
have many pages either. Everything together makes it 1886MB out of 2GB.
~50MB is free so this means ~70MB is in unaccounted memory (50MB is
reserved) which looks reasonably and I wouldn't suspect any kernel
memory leak

[..]
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032343] 159096 total pagecache pages
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032348] 955 pages in swap cache
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032352] Swap cache stats: add 267105, delete 266150, find 100036/132538
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032355] Free swap  = 1836400kB
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032358] Total swap = 1949692kB
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032360] 513612 pages RAM
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032363] 0 pages HighMem/MovableOnly
> Mar 14 14:31:22 x61s-44a5 kernel: [168382.032365] 12989 pages reserved

> Mar 14 14:35:41 x61s-44a5 kernel: [168644.685090] DOM Worker: page allocation stalls for 11024ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
[...]
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685239] Mem-Info:
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251] active_anon:308078 inactive_anon:154761 isolated_anon:256
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  active_file:1046 inactive_file:1061 isolated_file:0
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  unevictable:0 dirty:0 writeback:0 unstable:0
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  slab_reclaimable:6098 slab_unreclaimable:8554
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  mapped:2252 shmem:156234 pagetables:2929 bounce:0
> Mar 14 14:35:42 x61s-44a5 kernel: [168644.685251]  free:13191 free_pcp:116 free_cma:0

pretty much the same picture. Both inactive and active anonymous LRU
lists have grown a bit which means that the anonymous memory pressure
continues. This is the same process stalling but it is a different
alloation request.
[...]
> Mar 14 14:37:32 x61s-44a5 kernel: [168756.031364] firefox-esr: page allocation stalls for 12753ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[...]
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031540] Mem-Info:
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552] active_anon:308635 inactive_anon:154041 isolated_anon:224
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  active_file:1195 inactive_file:1218 isolated_file:0
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  unevictable:0 dirty:0 writeback:0 unstable:0
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  slab_reclaimable:6095 slab_unreclaimable:8550
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  mapped:2380 shmem:155496 pagetables:2929 bounce:0
> Mar 14 14:37:34 x61s-44a5 kernel: [168756.031552]  free:13192 free_pcp:0 free_cma:0

and again the picture is similar. inactive anonymous list shrunk by ~700
pages but the active list has grown by ~600 pages. This suggests we are
seeing activated pages on the inactive list and promote them so the
anonymous memory is actively used.
[...]
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164143] DOM Worker: page allocation stalls for 14239ms, order:0, mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
[...]
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164300] Mem-Info:
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313] active_anon:308681 inactive_anon:154714 isolated_anon:320
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  active_file:759 inactive_file:749 isolated_file:0
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  unevictable:0 dirty:0 writeback:0 unstable:0
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  slab_reclaimable:6095 slab_unreclaimable:8550
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  mapped:1762 shmem:156270 pagetables:2929 bounce:0
> Mar 14 14:38:52 x61s-44a5 kernel: [168835.164313]  free:13193 free_pcp:93 free_cma:0

And again the anonymous memory pressure grows. So I would suspect some
userspace application went off the hook and started consuming a lot of
anonymous memory which gets you to a trashing stage when basically
nothing can move on much without swap out. The page cache is at its
minimum and I suspect that most binaries would have to be read from disk
and you reached the point of trashing. I am afraid we are not really
great at handling these situations from the kernel well. Killing the
memory hog would be probably the most sane thing to do.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
