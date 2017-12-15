Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7656B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:05:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e69so6736481pgc.15
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 03:05:47 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i8si4931809pfk.151.2017.12.15.03.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 03:05:41 -0800 (PST)
Date: Fri, 15 Dec 2017 19:05:07 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v19 1/7] xbitmap: Introduce xbitmap
Message-ID: <201712151837.MQq7hdgk%fengguang.wu@intel.com>
References: <1513079759-14169-2-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513079759-14169-2-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: kbuild-all@01.org, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Hi Matthew,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.15-rc3]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Wei-Wang/Virtio-balloon-Enhancement/20171215-100525
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +29 lib/xbitmap.c

     5	
     6	/**
     7	 *  xb_set_bit - set a bit in the xbitmap
     8	 *  @xb: the xbitmap tree used to record the bit
     9	 *  @bit: index of the bit to set
    10	 *
    11	 * This function is used to set a bit in the xbitmap. If the bitmap that @bit
    12	 * resides in is not there, the per-cpu ida_bitmap will be taken.
    13	 *
    14	 * Returns: 0 on success. %-EAGAIN indicates that @bit was not set.
    15	 */
    16	int xb_set_bit(struct xb *xb, unsigned long bit)
    17	{
    18		int err;
    19		unsigned long index = bit / IDA_BITMAP_BITS;
    20		struct radix_tree_root *root = &xb->xbrt;
    21		struct radix_tree_node *node;
    22		void **slot;
    23		struct ida_bitmap *bitmap;
    24		unsigned long ebit;
    25	
    26		bit %= IDA_BITMAP_BITS;
    27		ebit = bit + 2;
    28	
  > 29		err = __radix_tree_create(root, index, 0, &node, &slot);
    30		if (err)
    31			return err;
    32		bitmap = rcu_dereference_raw(*slot);
    33		if (radix_tree_exception(bitmap)) {
    34			unsigned long tmp = (unsigned long)bitmap;
    35	
    36			if (ebit < BITS_PER_LONG) {
    37				tmp |= 1UL << ebit;
    38				rcu_assign_pointer(*slot, (void *)tmp);
    39				return 0;
    40			}
    41			bitmap = this_cpu_xchg(ida_bitmap, NULL);
    42			if (!bitmap)
    43				return -EAGAIN;
    44			memset(bitmap, 0, sizeof(*bitmap));
    45			bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
    46			rcu_assign_pointer(*slot, bitmap);
    47		}
    48	
    49		if (!bitmap) {
    50			if (ebit < BITS_PER_LONG) {
    51				bitmap = (void *)((1UL << ebit) |
    52						RADIX_TREE_EXCEPTIONAL_ENTRY);
  > 53				__radix_tree_replace(root, node, slot, bitmap, NULL);
    54				return 0;
    55			}
    56			bitmap = this_cpu_xchg(ida_bitmap, NULL);
    57			if (!bitmap)
    58				return -EAGAIN;
    59			memset(bitmap, 0, sizeof(*bitmap));
    60			__radix_tree_replace(root, node, slot, bitmap, NULL);
    61		}
    62	
    63		__set_bit(bit, bitmap->bitmap);
    64		return 0;
    65	}
    66	EXPORT_SYMBOL(xb_set_bit);
    67	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
