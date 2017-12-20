Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 078476B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:26:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id t65so16380448pfe.22
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:26:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e62si12985489pfa.154.2017.12.20.04.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 04:25:59 -0800 (PST)
Date: Wed, 20 Dec 2017 04:25:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 0/7] Virtio-balloon Enhancement
Message-ID: <20171220122547.GA1654@bombadil.infradead.org>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
 <5A3A3CBC.4030202@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A3A3CBC.4030202@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Wed, Dec 20, 2017 at 06:34:36PM +0800, Wei Wang wrote:
> On 12/19/2017 10:05 PM, Tetsuo Handa wrote:
> > I think xb_find_set() has a bug in !node path.
> 
> I think we can probably remove the "!node" path for now. It would be good to
> get the fundamental part in first, and leave optimization to come as
> separate patches with corresponding test cases in the future.

You can't remove the !node path.  You'll see !node when the highest set
bit is less than 1024.  So do something like this:

	unsigned long bit;
	xb_preload(GFP_KERNEL);
	xb_set_bit(xb, 700);
	xb_preload_end();
	bit = xb_find_set(xb, ULONG_MAX, 0);
	assert(bit == 700);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
