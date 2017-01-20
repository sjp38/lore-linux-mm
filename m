Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15D486B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 06:48:17 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id o65so105946600yba.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 03:48:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 12si4703987qkw.311.2017.01.20.03.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 03:48:16 -0800 (PST)
Date: Fri, 20 Jan 2017 11:48:09 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20170120114809.GH2658@work-vm>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, david@redhat.com, aarcange@redhat.com, quintela@redhat.com

* Liang Li (liang.z.li@intel.com) wrote:

<snip>

> +static void free_extended_page_bitmap(struct virtio_balloon *vb)
> +{
> +	int i, bmap_count = vb->nr_page_bmap;
> +
> +	for (i = 1; i < bmap_count; i++) {
> +		kfree(vb->page_bitmap[i]);
> +		vb->page_bitmap[i] = NULL;
> +		vb->nr_page_bmap--;
> +	}
> +}
> +
> +static void kfree_page_bitmap(struct virtio_balloon *vb)
> +{
> +	int i;
> +
> +	for (i = 0; i < vb->nr_page_bmap; i++)
> +		kfree(vb->page_bitmap[i]);
> +}

It might be worth commenting that pair of functions to make it clear
why they are so different; I guess the kfree_page_bitmap
is used just before you free the structure above it so you
don't need to keep the count/pointers updated?

Dave
--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
