Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB32F6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:38:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y187so27848267wmy.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:38:25 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id r38si25980384wrb.121.2017.03.06.02.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:38:24 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id u108so17182481wrb.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:38:24 -0800 (PST)
Date: Mon, 6 Mar 2017 11:38:20 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170306103820.ixuvs7fd6s4tvfzy@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303100433.lm5t4hqxj6friyp6@phenom.ffwll.local>
 <10344634.XsotFaGzfj@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <10344634.XsotFaGzfj@avalon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: dri-devel@lists.freedesktop.org, Daniel Vetter <daniel@ffwll.ch>, Laura Abbott <labbott@redhat.com>, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Fri, Mar 03, 2017 at 06:45:40PM +0200, Laurent Pinchart wrote:
> - I haven't seen any proposal how a heap-based solution could be used in a 
> generic distribution. This needs to be figured out before committing to any 
> API/ABI.

Two replies from my side:

- Just because a patch doesn't solve world hunger isn't really a good
  reason to reject it.

- Heap doesn't mean its not resizeable (but I'm not sure that's really
  your concern).

- Imo ION is very much part of the picture here to solve this for real. We
  need to bits:

  * Be able to allocate memory from specific pools, not going through a
    specific driver. ION gives us that interface. This is e.g. also needed
    for "special" memory, like SMA tries to expose.

  * Some way to figure out how&where to allocate the buffer object. This
    is purely a userspace problem, and this is the part the unix memory
    allocator tries to solve. There's no plans in there for big kernel
    changes, instead userspace does a dance to reconcile all the
    constraints, and one of the constraints might be "you have to allocate
    this from this special ION heap". The only thing the kernel needs to
    expose is which devices use which ION heaps (we kinda do that
    already), and maybe some hints of how they can be generalized (but I
    guess stuff like "minimal pagesize of x KB" is also fulfilled by any
    CMA heap is knowledge userspace needs).

Again I think waiting for this to be fully implemented before we merge any
part is going to just kill any upstreaming efforts. ION in itself, without
the full buffer negotiation dance seems clearly useful (also for stuff
like SMA), and having it merged will help with moving the buffer
allocation dance forward.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
