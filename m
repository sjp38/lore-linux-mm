Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 357E06B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 09:52:30 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so24516096lbc.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 06:52:30 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id a195si1531891wma.36.2016.06.02.06.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 06:52:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 3864D1C148B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 14:52:28 +0100 (IST)
Date: Thu, 2 Jun 2016 14:52:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [BUG] Page allocation failures with newest kernels
Message-ID: <20160602135226.GX2527@techsingularity.net>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
 <574D64A0.2070207@arm.com>
 <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
 <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
 <20160531131520.GI24936@arm.com>
 <CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Wojtas <mw@semihalf.com>
Cc: Will Deacon <will.deacon@arm.com>, Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, Gregory =?iso-8859-15?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>

On Thu, Jun 02, 2016 at 07:48:38AM +0200, Marcin Wojtas wrote:
> Hi Will,
> 
> I think I found a right trace. Following one-liner fixes the issue
> beginning from v4.2-rc1 up to v4.4 included:
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -294,7 +294,7 @@ static inline bool
> early_page_uninitialised(unsigned long pfn)
> 
>  static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
>  {
> -       return false;
> +       return true;
>  }
> 

How does that make a difference in v4.4 since commit
974a786e63c96a2401a78ddba926f34c128474f1 removed the only
early_page_nid_uninitialised() ? It further doesn't make sense if deferred
memory initialisation is not enabled as the pages will always be
initialised.

> From what I understood, now order-0 allocation keep no reserve at all.

Watermarks should still be preserved. zone_watermark_ok is still there.
What might change is the size of reserves for high-order atomic
allocations only. Fragmentation shouldn't be a factor. I'm missing some
major part of the picture.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
