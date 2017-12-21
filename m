Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE566B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:57:38 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 3so5485298ioz.9
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 04:57:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h5si13549453ioe.20.2017.12.21.04.57.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Dec 2017 04:57:37 -0800 (PST)
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <5A3A3CBC.4030202@intel.com>
	<20171220122547.GA1654@bombadil.infradead.org>
	<286AC319A985734F985F78AFA26841F73938CC3E@shsmsx102.ccr.corp.intel.com>
	<20171220171019.GA12236@bombadil.infradead.org>
	<5A3B2148.8050306@intel.com>
In-Reply-To: <5A3B2148.8050306@intel.com>
Message-Id: <201712212156.AGC09823.OVFtFMJHOSFOLQ@I-love.SAKURA.ne.jp>
Date: Thu, 21 Dec 2017 21:56:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, willy@infradead.org
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> Thanks for the effort. That's actually caused by the previous "!node" 
> path, which incorrectly changed "index = (index | RADIX_TREE_MAP_MASK) + 
> 1". With the change below, it will run pretty well with the test cases.
> 
> if (!node && !bitmap)
>      return size;
> 
> Would you mind to have a try with the v20 RESEND patch that was just 
> shared?

No. Please explain what "!node" situation indicates. Why did you try
"index = (index | RADIX_TREE_MAP_MASK) + 1; continue;" in the previous patch?

+unsigned long xb_find_set(struct xb *xb, unsigned long size,
+			  unsigned long offset)
+{
+	struct radix_tree_root *root = &xb->xbrt;
+	struct radix_tree_node *node;
+	void __rcu **slot;
+	struct ida_bitmap *bitmap;
+	unsigned long index = offset / IDA_BITMAP_BITS;
+	unsigned long index_end = size / IDA_BITMAP_BITS;
+	unsigned long bit = offset % IDA_BITMAP_BITS;
+
+	if (unlikely(offset >= size))
+		return size;
+
+	while (index <= index_end) {
+		unsigned long ret;
+		unsigned int nbits = size - index * IDA_BITMAP_BITS;
+
+		bitmap = __radix_tree_lookup(root, index, &node, &slot);
+
+		if (!node && !bitmap)
+			return size;
+
+		if (bitmap) {
+			if (nbits > IDA_BITMAP_BITS)
+				nbits = IDA_BITMAP_BITS;
+
+			ret = find_next_bit(bitmap->bitmap, nbits, bit);
+			if (ret != nbits)
+				return ret + index * IDA_BITMAP_BITS;
+		}
+		bit = 0;
+		index++;
+	}
+
+	return size;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
