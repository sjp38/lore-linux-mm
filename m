Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C73966B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 21:10:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b192so5350990pga.14
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 18:10:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j5si5495070pgc.544.2017.10.18.18.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 18:10:58 -0700 (PDT)
Date: Wed, 18 Oct 2017 18:10:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-ID: <20171019011056.GB17308@bombadil.infradead.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <8760bci3vl.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8760bci3vl.fsf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Oct 18, 2017 at 01:43:10PM -0700, Andi Kleen wrote:
> > +static int zswap_is_page_same_filled(void *ptr, unsigned long *value)
> > +{
> > +	unsigned int pos;
> > +	unsigned long *page;
> > +
> > +	page = (unsigned long *)ptr;
> > +	for (pos = 1; pos < PAGE_SIZE / sizeof(*page); pos++) {
> > +		if (page[pos] != page[0])
> > +			return 0;
> > +	}
> 
> So on 32bit it checks for 32bit repeating values and on 64bit
> for 64bit repeating values. Does that make sense?

Yes.  Every 64-bit repeating pattern is also a 32-bit repeating pattern.
Supporting a 64-bit pattern on a 32-bit kernel is painful, but it makes
no sense to *not* support a 64-bit pattern on a 64-bit kernel.  This is
the same approach used in zram, fwiw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
