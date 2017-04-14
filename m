Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB3926B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 10:22:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y38so22938964qtb.23
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 07:22:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e34si1947641qtb.135.2017.04.14.07.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 07:22:51 -0700 (PDT)
Date: Fri, 14 Apr 2017 17:22:43 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
Message-ID: <20170414171452-mutt-send-email-mst@kernel.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <20170413204411.GJ784@bombadil.infradead.org>
 <20170414044515-mutt-send-email-mst@kernel.org>
 <20170414094740.GN784@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170414094740.GN784@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Apr 14, 2017 at 02:47:40AM -0700, Matthew Wilcox wrote:
> On Fri, Apr 14, 2017 at 04:50:48AM +0300, Michael S. Tsirkin wrote:
> > On Thu, Apr 13, 2017 at 01:44:11PM -0700, Matthew Wilcox wrote:
> > > On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
> > > > 2) transfer the guest unused pages to the host so that they
> > > > can be skipped to migrate in live migration.
> > > 
> > > I don't understand this second bit.  You leave the pages on the free list,
> > > and tell the host they're free.  What's preventing somebody else from
> > > allocating them and using them for something?  Is the guest semi-frozen
> > > at this point with just enough of it running to ask the balloon driver
> > > to do things?
> > 
> > There's missing documentation here.
> > 
> > The way things actually work is host sends to guest
> > a request for unused pages and then write-protects all memory.
> 
> ... hopefully you mean "write protects all memory, then sends a request
> for unused pages", otherwise there's a race condition.

Exactly.

> And I see the utility of this, but does this functionality belong in
> the balloon driver?

We have historically put all kind of memory-related functionality in the
balloon device. Consider for example memory statistics - seems related
conceptually. See patches 1-2: the new mechanism for reporting lists of
pages seems to be benefitial for both which seems to indicate using the
balloon for this is a good idea.

> It seems like it's something you might want even if you don't have the
> balloon driver loaded.  Or something you might not want if you do have
> the balloon driver loaded.

Most of balloon functionality is kind of loosely coupled.  Yes we could
split it up but I'm not sure what would this buy us. What do you have
in mind?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
