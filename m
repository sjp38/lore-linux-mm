Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 844596B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:59:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 79so1012267wmr.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 13:59:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i13si527425wmd.88.2017.07.19.13.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 13:59:30 -0700 (PDT)
Date: Wed, 19 Jul 2017 13:59:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 05/10] mm: thp: enable thp migration in generic path
Message-Id: <20170719135927.d553f5afe893ca43d70cbdc5@linux-foundation.org>
In-Reply-To: <A5D98DDB-2295-467D-8368-D0A037CC2DC7@cs.rutgers.edu>
References: <201707191504.G4xCE7El%fengguang.wu@intel.com>
	<A5D98DDB-2295-467D-8368-D0A037CC2DC7@cs.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

On Wed, 19 Jul 2017 14:39:43 -0400 "Zi Yan" <zi.yan@cs.rutgers.edu> wrote:

> On 19 Jul 2017, at 4:04, kbuild test robot wrote:
> 
> > Hi Zi,
> >
> > [auto build test WARNING on mmotm/master]
> > [also build test WARNING on v4.13-rc1 next-20170718]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> >
> > url:    https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fgithub.com%2F0day-ci%2Flinux%2Fcommits%2FZi-Yan%2Fmm-page-migration-enhancement-for-thp%2F20170718-095519&data=02%7C01%7Czi.yan%40cs.rutgers.edu%7Ca711ac47d4c0436ef66f08d4ce7cf30c%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636360483431631457&sdata=NpxRpWbxe6o56xDJYpw1K6wgQo11IPCAbG2tE8l%2BU6E%3D&reserved=0
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: xtensa-common_defconfig (attached as .config)
> > compiler: xtensa-linux-gcc (GCC) 4.9.0
> > reproduce:
> >         wget https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fraw.githubusercontent.com%2F01org%2Flkp-tests%2Fmaster%2Fsbin%2Fmake.cross&data=02%7C01%7Czi.yan%40cs.rutgers.edu%7Ca711ac47d4c0436ef66f08d4ce7cf30c%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636360483431631457&sdata=rBCfu0xUg3v%2B8r%2Be2tsiqRcqw%2FEZSTa4OtF0hU%2FqMbc%3D&reserved=0 -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=xtensa
> >
> > All warnings (new ones prefixed by >>):
> >
> >    In file included from mm/vmscan.c:55:0:
> >    include/linux/swapops.h: In function 'swp_entry_to_pmd':
> >>> include/linux/swapops.h:220:2: warning: missing braces around initializer [-Wmissing-braces]
> >      return (pmd_t){ 0 };
> >      ^
> >    include/linux/swapops.h:220:2: warning: (near initialization for '(anonymous).pud') [-Wmissing-braces]
> >
> > vim +220 include/linux/swapops.h
> >
> >    217	
> >    218	static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> >    219	{
> >> 220		return (pmd_t){ 0 };
> >    221	}
> >    222	
> 
> It is a GCC 4.9.0 bug: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53119
> 
> Upgrading GCC can get rid of this warning.

I think there was a workaround for this, but I don't recall what it
was.

This suppressed the warning:

--- a/include/linux/swapops.h~a
+++ a/include/linux/swapops.h
@@ -217,7 +217,7 @@ static inline swp_entry_t pmd_to_swp_ent
 
 static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
 {
-	return (pmd_t){ 0 };
+	return (pmd_t){};
 }
 
 static inline int is_pmd_migration_entry(pmd_t pmd)

But I don't know if this is the approved workaround and I don't know
what it will do at runtime!

But we should fix this.  Expecting zillions of people to update their
compiler version isn't nice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
