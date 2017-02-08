Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0BBF6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 03:16:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so29519040wmg.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 00:16:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u133si1580841wmu.53.2017.02.08.00.16.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 00:16:54 -0800 (PST)
Date: Wed, 8 Feb 2017 09:16:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH]
 mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages-fix
Message-ID: <20170208081652.GB5686@dhcp22.suse.cz>
References: <20170207202755.24571-1-mhocko@kernel.org>
 <201702080524.R4RBmup3%fengguang.wu@intel.com>
 <20170207141420.ab4de727ed05ddd41602f73f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207141420.ab4de727ed05ddd41602f73f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <htejun@gmail.com>

On Tue 07-02-17 14:14:20, Andrew Morton wrote:
> On Wed, 8 Feb 2017 05:54:56 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
> > Hi Michal,
> > 
> > [auto build test ERROR on mmotm/master]
> > [also build test ERROR on v4.10-rc7 next-20170207]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages-fix/20170208-050036
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: i386-randconfig-x001-201706 (attached as .config)
> > compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> > reproduce:
> >         # save the attached .config to linux build tree
> >         make ARCH=i386 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    In file included from include/asm-generic/percpu.h:6:0,
> >                     from arch/x86/include/asm/percpu.h:542,
> >                     from arch/x86/include/asm/preempt.h:5,
> >                     from include/linux/preempt.h:59,
> >                     from include/linux/spinlock.h:50,
> >                     from include/linux/mmzone.h:7,
> >                     from include/linux/gfp.h:5,
> >                     from include/linux/mm.h:9,
> >                     from mm/page_alloc.c:18:
> >    mm/page_alloc.c: In function 'drain_all_pages':
> > >> include/linux/percpu-defs.h:91:33: error: section attribute cannot be specified for local variables
> >      extern __PCPU_DUMMY_ATTRS char __pcpu_unique_##name;  \
> >                                     ^
> 
> huh, yes.  The DEFINE_PER_CPU() macro is broken.
> 
> If you do
> 
> foo()
> {
> 	static DEFINE_PER_CPU(int, bar);
> }
> 
> then it won't compile, as described here.  It should.
> 
> And if you do
> 
> static DEFINE_PER_CPU(int, bar);
> 
> then you still get global symbols (__pcpu_unique_bar).
> 
> The kernel does the above thing in, umm, 466 places and afaict they're
> all broken.  If two code sites ever use the same identifier, they'll
> get linkage errors.
> 
> huh.  Seems hard to fix.

Nasty! Unfortunately, I am not familiar with the static pcp code magic
to come up with a fix.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
