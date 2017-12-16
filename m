Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 163586B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:32:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id t73so3735668iof.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:32:28 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o1si5706184iof.134.2017.12.15.20.32.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 20:32:26 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <5A31F445.6070504@intel.com>
	<201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
	<20171214181219.GA26124@bombadil.infradead.org>
	<201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
	<20171215202238-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171215202238-mutt-send-email-mst@kernel.org>
Message-Id: <201712161331.ABI26579.OtOMFSOLHVFFQJ@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 13:31:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: willy@infradead.org, wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Michael S. Tsirkin wrote:
> On Sat, Dec 16, 2017 at 01:21:52AM +0900, Tetsuo Handa wrote:
> > My understanding is that virtio-balloon wants to handle sparsely spreaded
> > unsigned long values (which is PATCH 4/7) and wants to find all chunks of
> > consecutive "1" bits efficiently. Therefore, I guess that holding the values
> > in ascending order at store time is faster than sorting the values at read
> > time.
> 
> Are you asking why is a bitmap used here, as opposed to a tree?

No. I'm OK with "segments using trees" + "offsets using bitmaps".

>                                                                  It's
> not just store versus read. There's also the issue that memory can get
> highly fragmented, if it is, the number of 1s is potentially very high.
> A bitmap can use as little as 1 bit per value, it is hard to beat in
> this respect.
> 

I'm asking whether we really need to invent a new library module (i.e.
PATCH 1/7 + PATCH 2/7 + PATCH 3/7) for virtio-balloon compared to mine.

What virtio-balloon needs is ability to

  (1) record any integer value in [0, ULONG_MAX] range

  (2) fetch all recorded values, with consecutive values combined in
      min,max (or start,count) form for efficiently

and I wonder whether we need to invent complete API set which
Matthew Wilcox and Wei Wang are planning for generic purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
