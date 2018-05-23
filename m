Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D47E6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:17:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bd7-v6so13825377plb.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:17:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5-v6si18601322pfi.88.2018.05.23.01.17.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 01:17:56 -0700 (PDT)
Date: Wed, 23 May 2018 10:17:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: save two stranding bit in gfp_mask
Message-ID: <20180523081753.GH20441@dhcp22.suse.cz>
References: <20180516202023.167627-1-shakeelb@google.com>
 <201805231335.RIR9HxYj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805231335.RIR9HxYj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Shakeel Butt <shakeelb@google.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 23-05-18 16:08:28, kbuild test robot wrote:
> Hi Shakeel,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.17-rc6]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Shakeel-Butt/mm-save-two-stranding-bit-in-gfp_mask/20180518-202316
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> 

What is the warning? Btw. this smells like a failure in the script of
some sort. The patch you are referring doesn't really change any code
except using different valuues for gfp constants which shouldn't make
any difference to any code.

> vim +/jl +2585 fs/reiserfs/journal.c
> 
> ^1da177e Linus Torvalds 2005-04-16  2573  
> ^1da177e Linus Torvalds 2005-04-16  2574  static struct reiserfs_journal_list *alloc_journal_list(struct super_block *s)
> ^1da177e Linus Torvalds 2005-04-16  2575  {
> ^1da177e Linus Torvalds 2005-04-16  2576  	struct reiserfs_journal_list *jl;
> 8c777cc4 Pekka Enberg   2006-02-01  2577  	jl = kzalloc(sizeof(struct reiserfs_journal_list),
> 8c777cc4 Pekka Enberg   2006-02-01  2578  		     GFP_NOFS | __GFP_NOFAIL);
> ^1da177e Linus Torvalds 2005-04-16  2579  	INIT_LIST_HEAD(&jl->j_list);
> ^1da177e Linus Torvalds 2005-04-16  2580  	INIT_LIST_HEAD(&jl->j_working_list);
> ^1da177e Linus Torvalds 2005-04-16  2581  	INIT_LIST_HEAD(&jl->j_tail_bh_list);
> ^1da177e Linus Torvalds 2005-04-16  2582  	INIT_LIST_HEAD(&jl->j_bh_list);
> 90415dea Jeff Mahoney   2008-07-25  2583  	mutex_init(&jl->j_commit_mutex);
> ^1da177e Linus Torvalds 2005-04-16  2584  	SB_JOURNAL(s)->j_num_lists++;
> ^1da177e Linus Torvalds 2005-04-16 @2585  	get_journal_list(jl);
> ^1da177e Linus Torvalds 2005-04-16  2586  	return jl;
> ^1da177e Linus Torvalds 2005-04-16  2587  }
> ^1da177e Linus Torvalds 2005-04-16  2588  
> 
> :::::: The code at line 2585 was first introduced by commit
> :::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
> 
> :::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
> :::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

-- 
Michal Hocko
SUSE Labs
