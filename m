Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA5C76B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 21:33:43 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id z1so12905050iob.17
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:33:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p71si2340861itc.117.2017.12.19.18.33.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 18:33:42 -0800 (PST)
Message-Id: <201712200233.vBK2X7oX028845@www262.sakura.ne.jp>
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 20 Dec 2017 11:33:07 +0900
References: <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp> <20171219144020.GA30842@bombadil.infradead.org>
In-Reply-To: <20171219144020.GA30842@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> > I think xb_find_set() has a bug in !node path.
> 
> Don't think.  Write a test-case.  Please.  If it shows a bug, then great,

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
+		if (!node) {
+			index = (index | RADIX_TREE_MAP_MASK) + 1;

Why we don't need to reset "bit" to 0 here?
We will continue with wrong offset if "bit != 0", won't we?

+			continue;
+		}
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
