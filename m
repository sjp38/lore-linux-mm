Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A99C36B0007
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:53:04 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x188so2737000qkc.12
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:53:04 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o188si2918451qkb.328.2018.03.14.11.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 11:53:03 -0700 (PDT)
Subject: Re: [mmotm:master 8/285] fs//hugetlbfs/inode.c:142:22: note: in
 expansion of macro 'PGOFF_LOFFT_MAX'
References: <201803141423.WZYJTFEz%fengguang.wu@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0d54df0b-1e53-58a0-81ff-e496ae2f7cd8@oracle.com>
Date: Wed, 14 Mar 2018 11:52:51 -0700
MIME-Version: 1.0
In-Reply-To: <201803141423.WZYJTFEz%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On 03/13/2018 11:15 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   ead058c4ec49752a4e0323368f1d695385c66020
> commit: af7abfba1161d2814301844fe11adac16910ea80 [8/285] hugetlbfs-check-for-pgoff-value-overflow-v3
> config: sh-defconfig (attached as .config)
> compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout af7abfba1161d2814301844fe11adac16910ea80
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All warnings (new ones prefixed by >>):
> 
>    fs//hugetlbfs/inode.c: In function 'hugetlbfs_file_mmap':
>>> fs//hugetlbfs/inode.c:118:36: warning: left shift count is negative [-Wshift-count-negative]
>     #define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
>                                        ^

BITS_PER_LONG = 32 (32bit config)
PAGE_SHIFT = 16 (64K pages)
This results in the negative shift value.

I had proposed another (not so pretty way) to create the mask.

#define PGOFF_LOFFT_MAX \
	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))

This works for the above config, and should work for any.

Andrew, how would you like me to update the patch?  I can send a new
version but know you have also made some changes for VM_WARN.  Would
you simply like a delta on top of the current patch?

-- 
Mike Kravetz
