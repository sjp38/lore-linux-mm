Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B984440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:01:02 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 4so4541189wrt.8
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:01:02 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b9si7526343wrh.303.2017.11.10.01.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 01:01:00 -0800 (PST)
Date: Fri, 10 Nov 2017 10:01:00 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] mm: introduce get_user_pages_longterm
Message-ID: <20171110090100.GA4895@lst.de>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com> <151001623591.16354.4902423177617232098.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151001623591.16354.4902423177617232098.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, stable@vger.kernel.org, linux-kernel@vger.kernel.org

> +long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
> +		unsigned int gup_flags, struct page **pages,
> +		struct vm_area_struct **vmas)
> +{
> +	struct vm_area_struct **__vmas = vmas;

How about calling the vma argument vma_arg, and the one used vma to
make thigns a little more readable?

> +	struct vm_area_struct *vma_prev = NULL;
> +	long rc, i;
> +
> +	if (!pages)
> +		return -EINVAL;
> +
> +	if (!vmas && IS_ENABLED(CONFIG_FS_DAX)) {
> +		__vmas = kzalloc(sizeof(struct vm_area_struct *) * nr_pages,
> +				GFP_KERNEL);
> +		if (!__vmas)
> +			return -ENOMEM;
> +	}
> +
> +	rc = get_user_pages(start, nr_pages, gup_flags, pages, __vmas);
> +
> +	/* skip scan for fs-dax vmas if they are compile time disabled */
> +	if (!IS_ENABLED(CONFIG_FS_DAX))
> +		goto out;

Instead of all this IS_ENABLED magic I'd recomment to just conditionally
compile this function and define it to get_user_pages in the header
if FS_DAX is disabled.

Else this looks fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
