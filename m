Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1ADC6B0341
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 09:20:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j16so11323256pga.6
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 06:20:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f3si4398447plf.562.2017.09.12.06.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 06:20:54 -0700 (PDT)
Message-ID: <59B7DFED.6060502@intel.com>
Date: Tue, 12 Sep 2017 21:23:57 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v15 1/5] lib/xbitmap: Introduce xbitmap
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com> <1503914913-28893-2-git-send-email-wei.w.wang@intel.com> <20170911125455.GA32538@bombadil.infradead.org>
In-Reply-To: <20170911125455.GA32538@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On 09/11/2017 08:54 PM, Matthew Wilcox wrote:
> On Mon, Aug 28, 2017 at 06:08:29PM +0800, Wei Wang wrote:
>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> The eXtensible Bitmap is a sparse bitmap representation which is
>> efficient for set bits which tend to cluster.  It supports up to
>> 'unsigned long' worth of bits, and this commit adds the bare bones --
>> xb_set_bit(), xb_clear_bit() and xb_test_bit().
>>
>> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
> This is quite naughty of you.  You've modified the xbitmap implementation
> without any indication in the changelog that you did so.

This was changed in the previous version and included in that
v13->v14 ChangeLog: https://lkml.org/lkml/2017/8/16/923


> I don't
> think the modifications you made are an improvement, but without any
> argumentation from you I don't know why you think they're an improvement.

Probably it shouldn't be modified when the discussion is incomplete:
https://lkml.org/lkml/2017/8/10/36
Sorry about that. Hope we could get more feedback from you on the
changes later.

If you want, we can continue this part from the the v13 patch, which might
be closer to the implementation that you like: 
https://lkml.org/lkml/2017/8/3/60

>> diff --git a/lib/xbitmap.c b/lib/xbitmap.c
>> new file mode 100644
>> index 0000000..8c55296
>> --- /dev/null
>> +++ b/lib/xbitmap.c
>> @@ -0,0 +1,176 @@
>> +#include <linux/slab.h>
>> +#include <linux/xbitmap.h>
>> +
>> +/*
>> + * The xbitmap implementation supports up to ULONG_MAX bits, and it is
>> + * implemented based on ida bitmaps. So, given an unsigned long index,
>> + * the high order XB_INDEX_BITS bits of the index is used to find the
>> + * corresponding item (i.e. ida bitmap) from the radix tree, and the low
>> + * order (i.e. ilog2(IDA_BITMAP_BITS)) bits of the index are indexed into
>> + * the ida bitmap to find the bit.
>> + */
>> +#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
>> +#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
>> +					      RADIX_TREE_MAP_SHIFT))
>> +#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
> I don't understand why you moved the xb_preload code here from the
> radix tree.  I want all the code which touches the preload implementation
> together in one place, which is the radix tree.

Based on the previous comments (put all the code to lib/xbitmap.c) and your
comment here, I will move xb_preload() and the above Macro to radix-tree.c,
while leaving the rest in xbitmap.c.

Would this be something you expected? Or would you like to move all back
to radix-tree.c like that in v13?


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
