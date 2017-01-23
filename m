Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 19BCD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:49:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so213817742pgg.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:49:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 63si16807879pgi.211.2017.01.23.13.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 13:48:59 -0800 (PST)
Date: Mon, 23 Jan 2017 13:48:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 159/293] mm/page_alloc.c:3546:15: warning:
 'alloc_flags' may be used uninitialized in this function
Message-Id: <20170123134858.b9c9728c87e3f030575d5406@linux-foundation.org>
In-Reply-To: <201701211215.dD0CaO6m%fengguang.wu@intel.com>
References: <201701211215.dD0CaO6m%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 21 Jan 2017 12:01:26 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   fa78008f505569e7988ed3eb737ca7d43d87eac3
> commit: 6f387b30fdba17b62b7c13d67d3caebbcc3bef0c [159/293] mm: consolidate GFP_NOFAIL checks in the allocator slowpath
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 6f387b30fdba17b62b7c13d67d3caebbcc3bef0c
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/page_alloc.c: In function '__alloc_pages_slowpath':
> >> mm/page_alloc.c:3546:15: warning: 'alloc_flags' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      unsigned int alloc_flags;
>                   ^~~~~~~~~~~

Yup.  I guess we initialize alloc_flags before the `goto nopage'.

--- a/mm/page_alloc.c~mm-consolidate-gfp_nofail-checks-in-the-allocator-slowpath-fix
+++ a/mm/page_alloc.c
@@ -3577,6 +3577,14 @@ retry_cpuset:
 	no_progress_loops = 0;
 	compact_priority = DEF_COMPACT_PRIORITY;
 	cpuset_mems_cookie = read_mems_allowed_begin();
+
+	/*
+	 * The fast path uses conservative alloc_flags to succeed only until
+	 * kswapd needs to be woken up, and to avoid the cost of setting up
+	 * alloc_flags precisely. So we do that now.
+	 */
+	alloc_flags = gfp_to_alloc_flags(gfp_mask);
+
 	/*
 	 * We need to recalculate the starting point for the zonelist iterator
 	 * because we might have used different nodemask in the fast path, or
@@ -3588,14 +3596,6 @@ retry_cpuset:
 	if (!ac->preferred_zoneref->zone)
 		goto nopage;
 
-
-	/*
-	 * The fast path uses conservative alloc_flags to succeed only until
-	 * kswapd needs to be woken up, and to avoid the cost of setting up
-	 * alloc_flags precisely. So we do that now.
-	 */
-	alloc_flags = gfp_to_alloc_flags(gfp_mask);
-
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
