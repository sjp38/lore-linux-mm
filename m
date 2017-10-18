Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF386B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 08:34:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e64so3452997pfk.0
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 05:34:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b81si7441221pfm.54.2017.10.18.05.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 05:34:30 -0700 (PDT)
Date: Wed, 18 Oct 2017 05:34:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-ID: <20171018123427.GA7271@bombadil.infradead.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srividya Desireddy <srividya.dr@samsung.com>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Oct 18, 2017 at 10:48:32AM +0000, Srividya Desireddy wrote:
> +static void zswap_fill_page(void *ptr, unsigned long value)
> +{
> +	unsigned int pos;
> +	unsigned long *page;
> +
> +	page = (unsigned long *)ptr;
> +	if (value == 0)
> +		memset(page, 0, PAGE_SIZE);
> +	else {
> +		for (pos = 0; pos < PAGE_SIZE / sizeof(*page); pos++)
> +			page[pos] = value;
> +	}
> +}

I think you meant:

static void zswap_fill_page(void *ptr, unsigned long value)
{
	memset_l(ptr, value, PAGE_SIZE / sizeof(unsigned long));
}

(and you should see significantly better numbers at least on x86;
I don't know if anyone's done an arm64 version of memset_l yet).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
