Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5766B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 16:43:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b85so4141117pfj.22
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:43:12 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z81si7999266pfl.235.2017.10.18.13.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 13:43:11 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	<20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
Date: Wed, 18 Oct 2017 13:43:10 -0700
In-Reply-To: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	(Srividya Desireddy's message of "Wed, 18 Oct 2017 10:48:32 +0000")
Message-ID: <8760bci3vl.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srividya Desireddy <srividya.dr@samsung.com>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

Srividya Desireddy <srividya.dr@samsung.com> writes:
>
> On a ARM Quad Core 32-bit device with 1.5GB RAM by launching and
> relaunching different applications, out of ~64000 pages stored in
> zswap, ~11000 pages were same-value filled pages (including zero-filled
> pages) and ~9000 pages were zero-filled pages.

What are the values for the non zero cases?

> +static int zswap_is_page_same_filled(void *ptr, unsigned long *value)
> +{
> +	unsigned int pos;
> +	unsigned long *page;
> +
> +	page = (unsigned long *)ptr;
> +	for (pos = 1; pos < PAGE_SIZE / sizeof(*page); pos++) {
> +		if (page[pos] != page[0])
> +			return 0;
> +	}

So on 32bit it checks for 32bit repeating values and on 64bit
for 64bit repeating values. Does that make sense?

Did you test the patch on a 64bit system?

Overall I would expect this extra pass to be fairly expensive. It may
be better to add some special check to the compressor, and let
it abort if it sees a string of same values, and only do the check
then.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
