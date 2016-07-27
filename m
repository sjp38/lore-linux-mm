Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0D46B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 17:39:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q62so18521700oih.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:39:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x28si28710023ita.90.2016.07.27.14.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 14:39:20 -0700 (PDT)
Date: Thu, 28 Jul 2016 00:39:14 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20160728003644-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5798DB49.7030803@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Wed, Jul 27, 2016 at 09:03:21AM -0700, Dave Hansen wrote:
> On 07/26/2016 06:23 PM, Liang Li wrote:
> > +	vb->pfn_limit = VIRTIO_BALLOON_PFNS_LIMIT;
> > +	vb->pfn_limit = min(vb->pfn_limit, get_max_pfn());
> > +	vb->bmap_len = ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > +	hdr_len = sizeof(struct balloon_bmap_hdr);
> > +	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
> 
> This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.  How
> big was the pfn buffer before?


Yes I would limit this to 1G memory in a go, will result
in a 32KByte bitmap.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
