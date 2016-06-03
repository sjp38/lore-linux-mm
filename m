Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 277D76B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:36:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so36810656lfd.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:36:59 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id fa10si7396198wjd.171.2016.06.03.05.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:36:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 60D2C1C2FBA
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 13:36:57 +0100 (IST)
Date: Fri, 3 Jun 2016 13:36:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [BUG] Page allocation failures with newest kernels
Message-ID: <20160603123655.GA2527@techsingularity.net>
References: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
 <574D64A0.2070207@arm.com>
 <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
 <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
 <20160531131520.GI24936@arm.com>
 <CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
 <20160602135226.GX2527@techsingularity.net>
 <CAPv3WKd8Zdcv5nhr2euN7L4W5JYLex_Hmn+9AVd6reyD-Vw4kg@mail.gmail.com>
 <20160603095344.GZ2527@techsingularity.net>
 <CAPv3WKfrgNg00M4oE3VKLYimYqN6NO6ziR7LWYXQ1d_M-bo67A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPv3WKfrgNg00M4oE3VKLYimYqN6NO6ziR7LWYXQ1d_M-bo67A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Wojtas <mw@semihalf.com>
Cc: Will Deacon <will.deacon@arm.com>, Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, Gregory =?iso-8859-15?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>

On Fri, Jun 03, 2016 at 01:57:06PM +0200, Marcin Wojtas wrote:
> >> For the record: the newest kernel I was able to reproduce the dumps
> >> was v4.6: http://pastebin.com/ekDdACn5. I've just checked v4.7-rc1,
> >> which comprise a lot (mainly yours) changes in mm, and I'm wondering
> >> if there may be a spot fix or rather a series of improvements. I'm
> >> looking forward to your opinion and would be grateful for any advice.
> >>
> >
> > I don't believe we want to reintroduce the reserve to cope with CMA. One
> > option would be to widen the gap between low and min watermark by the
> > size of the CMA region. The effect would be to wake kswapd earlier which
> > matters considering the context of the failing allocation was
> > GFP_ATOMIC.
> 
> Of course my intention is not reintroducing anything that's gone
> forever, but just to find out way to overcome current issues. Do you
> mean increasing CMA size?

No. There is a gap between the low and min watermarks. At the low point,
kswapd is woken up and at the min point allocation requests either
either direct reclaim or fail if they are atomic. What I'm suggesting
is that you adjust the low watermark and add the size of the CMA area
to it so that kswapd is woken earlier. The watermarks are calculated in
__setup_per_zone_wmarks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
