Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7146B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 13:12:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k1so4717717pgq.2
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:12:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g71si3569114pfd.400.2017.12.14.10.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 10:12:25 -0800 (PST)
Date: Thu, 14 Dec 2017 10:12:19 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
Message-ID: <20171214181219.GA26124@bombadil.infradead.org>
References: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
 <201712122220.IFH05261.LtJOFFSFHVMQOO@I-love.SAKURA.ne.jp>
 <5A311C5E.7000304@intel.com>
 <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
 <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Fri, Dec 15, 2017 at 01:29:45AM +0900, Tetsuo Handa wrote:
> > > Also, one more thing you need to check. Have you checked how long does
> > > xb_find_next_set_bit(xb, 0, ULONG_MAX) on an empty xbitmap takes?
> > > If it causes soft lockup warning, should we add cond_resched() ?
> > > If yes, you have to document that this API might sleep. If no, you
> > > have to document that the caller of this API is responsible for
> > > not to pass such a large value range.
> > 
> > Yes, that will take too long time. Probably we can document some 
> > comments as a reminder for the callers.
> 
> Then, I feel that API is poorly implemented. There is no need to brute-force
> when scanning [0, ULONG_MAX] range. If you eliminate exception path and
> redesign the data structure, xbitmap will become as simple as a sample
> implementation shown below. Not tested yet, but I think that this will be
> sufficient for what virtio-baloon wants to do; i.e. find consecutive "1" bits
> quickly. I didn't test whether finding "struct ulong_list_data" using radix
> tree can improve performance.

find_next_set_bit() is just badly implemented.  There is no need to
redesign the data structure.  It should be a simple matter of:

 - look at ->head, see it is NULL, return false.

If bit 100 is set and you call find_next_set_bit(101, ULONG_MAX), it
should look at block 0, see there is a pointer to it, scan the block,
see there are no bits set above 100, then realise we're at the end of
the tree and stop.

If bit 2000 is set, and you call find_next_set_bit(2001, ULONG_MAX)
tit should look at block 1, see there's no bit set after bit 2001, then
look at the other blocks in the node, see that all the pointers are NULL
and stop.

This isn't rocket science, we already do something like this in the radix
tree and it'll be even easier to do in the XArray.  Which I'm going back
to working on now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
