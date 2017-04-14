Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38B046B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 05:47:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g23so17075975pfj.10
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 02:47:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a5si1364730plt.253.2017.04.14.02.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 02:47:52 -0700 (PDT)
Date: Fri, 14 Apr 2017 02:47:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating &
 fast live migration
Message-ID: <20170414094740.GN784@bombadil.infradead.org>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
 <20170413204411.GJ784@bombadil.infradead.org>
 <20170414044515-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170414044515-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Apr 14, 2017 at 04:50:48AM +0300, Michael S. Tsirkin wrote:
> On Thu, Apr 13, 2017 at 01:44:11PM -0700, Matthew Wilcox wrote:
> > On Thu, Apr 13, 2017 at 05:35:03PM +0800, Wei Wang wrote:
> > > 2) transfer the guest unused pages to the host so that they
> > > can be skipped to migrate in live migration.
> > 
> > I don't understand this second bit.  You leave the pages on the free list,
> > and tell the host they're free.  What's preventing somebody else from
> > allocating them and using them for something?  Is the guest semi-frozen
> > at this point with just enough of it running to ask the balloon driver
> > to do things?
> 
> There's missing documentation here.
> 
> The way things actually work is host sends to guest
> a request for unused pages and then write-protects all memory.

... hopefully you mean "write protects all memory, then sends a request
for unused pages", otherwise there's a race condition.

And I see the utility of this, but does this functionality belong in
the balloon driver?  It seems like it's something you might want even
if you don't have the balloon driver loaded.  Or something you might
not want if you do have the balloon driver loaded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
