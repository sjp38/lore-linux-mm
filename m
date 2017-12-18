Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E28D6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 21:59:39 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f2so4555609plj.15
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 18:59:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j6si7863700pgq.184.2017.12.17.18.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Dec 2017 18:59:37 -0800 (PST)
Date: Sun, 17 Dec 2017 18:59:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171218025927.GB6683@bombadil.infradead.org>
References: <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
 <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
 <20171214181219.GA26124@bombadil.infradead.org>
 <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
 <20171215184915.GB27160@bombadil.infradead.org>
 <20171215192203.GC27160@bombadil.infradead.org>
 <286AC319A985734F985F78AFA26841F739387C1D@shsmsx102.ccr.corp.intel.com>
 <20171217221842.GA6683@bombadil.infradead.org>
 <5A3728DC.3060509@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A3728DC.3060509@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Mon, Dec 18, 2017 at 10:33:00AM +0800, Wei Wang wrote:
> > My only qualm is that I've been considering optimising the memory
> > consumption when an entire 1024-bit chunk is full; instead of keeping a
> > pointer to a 128-byte entry full of ones, store a special value in the
> > radix tree which means "every bit is set".
> > 
> > The downside is that we then have to pass GFP flags to xbit_clear() and
> > xbit_zero(), and they can fail.  It's not clear to me whether that's a
> > good tradeoff.
> 
> Yes, this will sacrifice performance. In many usages, users may set bits one
> by one, and each time when a bit is set, it needs to scan the whole
> ida_bitmap to see if all other bits are set, if so, it can free the
> ida_bitmap. I think this extra scanning of the ida_bitmap would add a lot
> overhead.

Not a huge amount of overhead.  An ida_bitmap is only two cachelines,
and the loop is simply 'check each word against ~0ul', so up to 16
load/test/loop instructions.  Plus we have to do that anyway to maintain
the free tag for IDAs.

> > But I need to get the XArray (which replaces the radix tree) finished first.
> 
> OK. It seems the new implementation wouldn't be done shortly.
> Other parts of this patch series are close to the end of review, and we hope
> to make some progress soon. Would it be acceptable that we continue with the
> basic xb_ implementation (e.g. as xbitmap 1.0) for this patch series? and
> xbit_ implementation can come as xbitmap 2.0 in the future?

Yes, absolutely, I don't want to hold you up behind the XArray.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
