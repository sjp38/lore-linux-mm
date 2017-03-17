Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5876B0390
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:21:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n21so52533317qta.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:21:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f50si5267945qtc.47.2017.03.16.18.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 18:21:29 -0700 (PDT)
Date: Fri, 17 Mar 2017 03:21:21 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel v8 3/4] mm: add inerface to offer info about
 unused pages
Message-ID: <20170317023556-mutt-send-email-mst@kernel.org>
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
 <1489648127-37282-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489648127-37282-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Thu, Mar 16, 2017 at 03:08:46PM +0800, Wei Wang wrote:
> +/*
> + * The record_unused_pages() function is used to record the system unused
> + * pages. The unused pages can be skipped to transfer during live migration.
> + * Though the unused pages are dynamically changing, dirty page logging
> + * mechanisms are able to capture the newly used pages though they were
> + * recorded as unused pages via this function.

You will keep confusing people as long as you keep using
this terminology which only makes sense in a very specific
use and a very specific implementation.

How does guest developer know this does the right thing wrt locking etc?
Look at hypervisor spec and try to figure it all out together?

So stop saying what caller should do, describe what does the *API* does.

You want something like this:

	Get a list of pages in the system that are unused at some point between
	record_unused_pages is called and before it returns, implying that any
	data that was present in these pages before record_unused_pages was
	called is safe to discard. Pages can be used immediately after
	this point and any data written after this point is not safe to discard,
	it is caller's responsibility to either prevent the use or
	detect such pages.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
