Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 707B46B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 06:09:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so1829294lfh.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 03:09:54 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id d87si1276859wmh.76.2016.06.08.03.09.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 03:09:53 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id B87079887C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 10:09:52 +0000 (UTC)
Date: Wed, 8 Jun 2016 11:09:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [BUG] Page allocation failures with newest kernels
Message-ID: <20160608100950.GH2527@techsingularity.net>
References: <CAPv3WKdYdwpi3k5eY86qibfprMFwkYOkDwHOsNydp=0sTV3mgg@mail.gmail.com>
 <60e8df74202e40b28a4d53dbc7fd0b22@IL-EXCH02.marvell.com>
 <20160531131520.GI24936@arm.com>
 <CAPv3WKftqsEXbdU-geAcUKXBSskhA0V72N61a1a+5DfahLK_Dg@mail.gmail.com>
 <20160602135226.GX2527@techsingularity.net>
 <CAPv3WKd8Zdcv5nhr2euN7L4W5JYLex_Hmn+9AVd6reyD-Vw4kg@mail.gmail.com>
 <20160603095344.GZ2527@techsingularity.net>
 <CAPv3WKfrgNg00M4oE3VKLYimYqN6NO6ziR7LWYXQ1d_M-bo67A@mail.gmail.com>
 <20160603123655.GA2527@techsingularity.net>
 <CAPv3WKfEQCeR++uqaUVhhsNe0WFsKq1Sn9uo==9NxtQe=GV7zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAPv3WKfEQCeR++uqaUVhhsNe0WFsKq1Sn9uo==9NxtQe=GV7zw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Wojtas <mw@semihalf.com>
Cc: Will Deacon <will.deacon@arm.com>, Yehuda Yitschak <yehuday@marvell.com>, Robin Murphy <robin.murphy@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Grzegorz Jaszczyk <jaz@semihalf.com>, Nadav Haklai <nadavh@marvell.com>, Tomasz Nowicki <tn@semihalf.com>, Gregory =?iso-8859-15?Q?Cl=E9ment?= <gregory.clement@free-electrons.com>

On Tue, Jun 07, 2016 at 07:36:57PM +0200, Marcin Wojtas wrote:
> Hi Mel,
> 
> 
> 
> 2016-06-03 14:36 GMT+02:00 Mel Gorman <mgorman@techsingularity.net>:
> > On Fri, Jun 03, 2016 at 01:57:06PM +0200, Marcin Wojtas wrote:
> >> >> For the record: the newest kernel I was able to reproduce the dumps
> >> >> was v4.6: http://pastebin.com/ekDdACn5. I've just checked v4.7-rc1,
> >> >> which comprise a lot (mainly yours) changes in mm, and I'm wondering
> >> >> if there may be a spot fix or rather a series of improvements. I'm
> >> >> looking forward to your opinion and would be grateful for any advice.
> >> >>
> >> >
> >> > I don't believe we want to reintroduce the reserve to cope with CMA. One
> >> > option would be to widen the gap between low and min watermark by the
> >> > size of the CMA region. The effect would be to wake kswapd earlier which
> >> > matters considering the context of the failing allocation was
> >> > GFP_ATOMIC.
> >>
> >> Of course my intention is not reintroducing anything that's gone
> >> forever, but just to find out way to overcome current issues. Do you
> >> mean increasing CMA size?
> >
> > No. There is a gap between the low and min watermarks. At the low point,
> > kswapd is woken up and at the min point allocation requests either
> > either direct reclaim or fail if they are atomic. What I'm suggesting
> > is that you adjust the low watermark and add the size of the CMA area
> > to it so that kswapd is woken earlier. The watermarks are calculated in
> > __setup_per_zone_wmarks
> >
> 
> I printed all zones' settings, whose watermarks are configured within
> __setup_per_zone_wmarks(). There are three DMA, Normal and Movable -
> only first one's watermarks have non-zero values. Increasing DMA min
> watermark didn't help. I also played with increasing

Patch?

Did you establish why GFP_ATOMIC (assuming that's the failing site) had
not specified __GFP_ATOMIC at the time of the allocation failure?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
