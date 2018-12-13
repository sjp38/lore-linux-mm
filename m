Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7126B8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 02:28:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w2so730434edc.13
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 23:28:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6-v6sor349386ejq.44.2018.12.12.23.28.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 23:28:30 -0800 (PST)
Date: Thu, 13 Dec 2018 07:28:28 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
Message-ID: <20181213072828.zzfl3guhtc3mbdfa@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <201812080950.q5whdIbk%fengguang.wu@intel.com>
 <20181209120323.lotz4v2ahywtk3hk@master>
 <f3e59ee6-9f1e-8677-e779-e3cc13151b18@intel.com>
 <20181213030832.whutggpzdy336u6y@master>
 <b036dab0-6822-3a8f-b2ce-4a979506172d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b036dab0-6822-3a8f-b2ce-4a979506172d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rong Chen <rong.a.chen@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, mgorman@techsingularity.net, akpm@linux-foundation.org

On Thu, Dec 13, 2018 at 01:02:21PM +0800, Rong Chen wrote:
>
>
>On 12/13/2018 11:08 AM, Wei Yang wrote:
>> On Thu, Dec 13, 2018 at 10:26:41AM +0800, Rong Chen wrote:
>> > 
>> > On 12/09/2018 08:03 PM, Wei Yang wrote:
>> > > On Sat, Dec 08, 2018 at 09:42:29AM +0800, kbuild test robot wrote:
>> > > > Hi Wei,
>> > > > 
>> > > > Thank you for the patch! Perhaps something to improve:
>> > > > 
>> > > > [auto build test WARNING on linus/master]
>> > > > [also build test WARNING on v4.20-rc5 next-20181207]
>> > > > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>> > > > 
>> > > > url:    https://github.com/0day-ci/linux/commits/Wei-Yang/mm-pageblock-make-sure-pageblock-won-t-exceed-mem_sectioin/20181207-030601
>> > > > config: powerpc-allmodconfig (attached as .config)
>> > > > compiler: powerpc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
>> > > > reproduce:
>> > > >          wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>> > > >          chmod +x ~/bin/make.cross
>> > > >          # save the attached .config to linux build tree
>> > > >          GCC_VERSION=7.2.0 make.cross ARCH=powerpc
>> > > > 
>> > > > All warnings (new ones prefixed by >>):
>> > > > 
>> > > >     In file included from include/linux/gfp.h:6:0,
>> > > >                      from include/linux/xarray.h:14,
>> > > >                      from include/linux/radix-tree.h:31,
>> > > >                      from include/linux/fs.h:15,
>> > > >                      from include/linux/compat.h:17,
>> > > >                      from arch/powerpc/kernel/asm-offsets.c:16:
>> > > > > > include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>> > > >      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>> > > >           ^~~~~~~~~~~~~~~
>> > > > --
>> > > >     In file included from include/linux/gfp.h:6:0,
>> > > >                      from include/linux/mm.h:10,
>> > > >                      from mm//swap.c:16:
>> > > > > > include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>> > > >      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>> > > >           ^~~~~~~~~~~~~~~
>> > > >     In file included from include/linux/gfp.h:6:0,
>> > > >                      from include/linux/mm.h:10,
>> > > >                      from mm//swap.c:16:
>> > > > > > include/linux/mmzone.h:1088:6: warning: "pageblock_order" is not defined, evaluates to 0 [-Wundef]
>> > > >      #if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>> > > >           ^~~~~~~~~~~~~~~
>> > > > 
>> > > > vim +/pageblock_order +1088 include/linux/mmzone.h
>> > > > 
>> > > >    1087	
>> > > > > 1088	#if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
>> > > >    1089	#error Allocator pageblock_order exceeds SECTION_SIZE
>> > > >    1090	#endif
>> > > >    1091	
>> > > > 
>> > > I took a look at the latest code, at line 1082 of the same file uses
>> > > pageblock_order. And I apply this patch on top of v4.20-rc5, the build
>> > > looks good to me.
>> > > 
>> > > Confused why this introduce an compile error.
>> > Hi Wei,
>> > 
>> > we could reproduce the warnings with using make.cross.
>> > 
>> That's interesting.
>> 
>> Do you see this file already use pageblock_order in line 1081?
>> 
>> Is this one report warning?
>> 
>
>both questions is yes.
>

Sounds interesting :-)

I don't have a power machine and we may drop this patch as discussed, so
I won't look into this now.

Thanks for your effort.

>Best Regards,
>Rong Chen
>
>

-- 
Wei Yang
Help you, Help me
