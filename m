Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 753ED6B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:46:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d65so38008981ith.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:46:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 139si9848015ioc.119.2016.07.27.18.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 18:45:59 -0700 (PDT)
Date: Thu, 28 Jul 2016 04:45:52 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20160728044000-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Thu, Jul 28, 2016 at 01:13:35AM +0000, Li, Liang Z wrote:
> > Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
> > process
> > 
> > On 07/26/2016 06:23 PM, Liang Li wrote:
> > > +	vb->pfn_limit = VIRTIO_BALLOON_PFNS_LIMIT;
> > > +	vb->pfn_limit = min(vb->pfn_limit, get_max_pfn());
> > > +	vb->bmap_len = ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > > +	hdr_len = sizeof(struct balloon_bmap_hdr);
> > > +	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
> > 
> > This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.  How big
> > was the pfn buffer before?
> 
> Yes, it is if the max pfn is more than 32GB.
> The size of the pfn buffer use before is 256*4 = 1024 Bytes, it's too small, 
> and it's the main reason for bad performance.
> Use the max 1MB kmalloc is a balance between performance and flexibility,
> a large page bitmap covers the range of all the memory is no good for a system
> with huge amount of memory. If the bitmap is too small, it means we have
> to traverse a long list for many times, and it's bad for performance.
> 
> Thanks!
> Liang   

There are all your implementation decisions though.

If guest memory is so fragmented that you only have order 0 4k pages,
then allocating a huge 1M contigious chunk is very problematic
in and of itself.

Most people rarely migrate and do not care how fast that happens.
Wasting a large chunk of memory (and it's zeroed for no good reason, so you
actually request host memory for it) for everyone to speed it up
when it does happen is not really an option.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
