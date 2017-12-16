Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDC26B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 05:12:10 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id i12so1980309plk.5
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:12:10 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d8si5865203pgf.419.2017.12.16.02.12.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 02:12:09 -0800 (PST)
Message-ID: <5A34F1F4.6010900@intel.com>
Date: Sat, 16 Dec 2017 18:14:12 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
References: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>	<201712122220.IFH05261.LtJOFFSFHVMQOO@I-love.SAKURA.ne.jp>	<5A311C5E.7000304@intel.com>	<201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>	<5A31F445.6070504@intel.com> <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
In-Reply-To: <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On 12/15/2017 12:29 AM, Tetsuo Handa wrote:
> Wei Wang wrote:
>> I used the example of xb_clear_bit_range(), and xb_find_next_bit() is
>> the same fundamentally. Please let me know if anywhere still looks fuzzy.
> I don't think it is the same for xb_find_next_bit() with set == 0.
>
> +		if (radix_tree_exception(bmap)) {
> +			unsigned long tmp = (unsigned long)bmap;
> +			unsigned long ebit = bit + 2;
> +
> +			if (ebit >= BITS_PER_LONG)
> +				continue;
> +			if (set)
> +				ret = find_next_bit(&tmp, BITS_PER_LONG, ebit);
> +			else
> +				ret = find_next_zero_bit(&tmp, BITS_PER_LONG,
> +							 ebit);
> +			if (ret < BITS_PER_LONG)
> +				return ret - 2 + IDA_BITMAP_BITS * index;
>
> What I'm saying is that find_next_zero_bit() will not be called if you do
> "if (ebit >= BITS_PER_LONG) continue;" before calling find_next_zero_bit().
>
> When scanning "0000000000000000000000000000000000000000000000000000000000000001",
> "bit < BITS_PER_LONG - 2" case finds "0" in this word but
> "bit >= BITS_PER_LONG - 2" case finds "0" in next word or segment.
>
> I can't understand why this is correct behavior. It is too much puzzling.
>

OK, I'll post out a version without the exceptional path.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
