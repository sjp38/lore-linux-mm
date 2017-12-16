Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 732786B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 00:58:16 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v137so4943191oia.21
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:58:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r2si2470830oib.254.2017.12.15.21.58.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 21:58:15 -0800 (PST)
Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171214181219.GA26124@bombadil.infradead.org>
	<201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
	<20171215202238-mutt-send-email-mst@kernel.org>
	<201712161331.ABI26579.OtOMFSOLHVFFQJ@I-love.SAKURA.ne.jp>
	<20171216050536.GA18920@bombadil.infradead.org>
In-Reply-To: <20171216050536.GA18920@bombadil.infradead.org>
Message-Id: <201712161457.FAJ56216.OSQFFLFMVOtHJO@I-love.SAKURA.ne.jp>
Date: Sat, 16 Dec 2017 14:57:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: mst@redhat.com, wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Matthew Wilcox wrote:
> On Sat, Dec 16, 2017 at 01:31:24PM +0900, Tetsuo Handa wrote:
> > Michael S. Tsirkin wrote:
> > > On Sat, Dec 16, 2017 at 01:21:52AM +0900, Tetsuo Handa wrote:
> > > > My understanding is that virtio-balloon wants to handle sparsely spreaded
> > > > unsigned long values (which is PATCH 4/7) and wants to find all chunks of
> > > > consecutive "1" bits efficiently. Therefore, I guess that holding the values
> > > > in ascending order at store time is faster than sorting the values at read
> > > > time.
> 
> What makes you think that the radix tree (also xbitmap, also idr) doesn't
> sort the values at store time?

I don't care whether the radix tree sorts the values at store time.
What I care is how to read stored values in ascending order with less overhead.

Existing users are too much optimized and difficult to understand for new
comers. I appreciate if there are simple sample codes which explain how to
use library functions and which can be compiled/tested in userspace.
Your "- look at ->head, see it is NULL, return false." answer did not
give me any useful information.

> 
> > I'm asking whether we really need to invent a new library module (i.e.
> > PATCH 1/7 + PATCH 2/7 + PATCH 3/7) for virtio-balloon compared to mine.
> > 
> > What virtio-balloon needs is ability to
> > 
> >   (1) record any integer value in [0, ULONG_MAX] range
> > 
> >   (2) fetch all recorded values, with consecutive values combined in
> >       min,max (or start,count) form for efficiently
> > 
> > and I wonder whether we need to invent complete API set which
> > Matthew Wilcox and Wei Wang are planning for generic purpose.
> 
> The xbitmap absolutely has that ability.

Current patches are too tricky to review.
When will all corner cases be closed?

>                                           And making it generic code
> means more people see it, use it, debug it, optimise it.

I'm not objecting against generic code. But trying to optimize it can
enbug it, like using exception path keeps me difficult to review whether
the implementation is correct. I'm suggesting to start xbitmap without
exception path, and I haven't seen a version without exception path.

>                                                           I originally
> wrote the implementation for bcache, when Kent was complaining we didn't
> have such a thing.  His needs weren't as complex as Wei's, which is why
> I hadn't implemented everything that Wei needed.
> 

Unless current xbitmap patches become clear, virtio-balloon changes won't
be able to be get merged. We are repeating this series without closing
many bugs. We can start virtio-balloon changes with a stub code which
provides (1) and (2), and that's my version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
