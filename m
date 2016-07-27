Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0116B0005
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 12:04:14 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so177625pad.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:04:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fc2si7028283pac.103.2016.07.27.09.04.13
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 09:04:13 -0700 (PDT)
Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5798DB49.7030803@intel.com>
Date: Wed, 27 Jul 2016 09:03:21 -0700
MIME-Version: 1.0
In-Reply-To: <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On 07/26/2016 06:23 PM, Liang Li wrote:
> +	vb->pfn_limit = VIRTIO_BALLOON_PFNS_LIMIT;
> +	vb->pfn_limit = min(vb->pfn_limit, get_max_pfn());
> +	vb->bmap_len = ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> +	hdr_len = sizeof(struct balloon_bmap_hdr);
> +	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);

This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.  How
big was the pfn buffer before?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
