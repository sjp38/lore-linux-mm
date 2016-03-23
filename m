Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D60B46B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 07:12:11 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so23133653pfd.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 04:12:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ut6si3671859pac.241.2016.03.23.04.12.10
        for <linux-mm@kvack.org>;
        Wed, 23 Mar 2016 04:12:10 -0700 (PDT)
Date: Wed, 23 Mar 2016 11:11:55 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Delete flush cache all in arm64 platform.
Message-ID: <20160323111155.GB2057@leverpostej>
References: <56EFABD3.7060700@hisilicon.com>
 <20160321100818.GA17326@leverpostej>
 <56F01A0A.3030208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56F01A0A.3030208@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Chen Feng <puck.chen@hisilicon.com>, catalin.marinas@arm.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xuyiping@hisilicon.com, suzhuangluan@hisilicon.com, saberlily.xia@hisilicon.com, dan.zhao@hisilicon.com, linux-arm-kernel@lists.infradead.org

On Mon, Mar 21, 2016 at 08:58:02AM -0700, Laura Abbott wrote:
> On 03/21/2016 03:08 AM, Mark Rutland wrote:
> >On Mon, Mar 21, 2016 at 04:07:47PM +0800, Chen Feng wrote:
> >>But if we use VA to flush cache to do cache-coherency with other
> >>master(eg:gpu)
> >>
> >>We must iterate over the sg-list to flush by va to pa.
> >>
> >>In this way, the iterate of sg-list may cost too much time(sg-table to
> >>sg-list) if the sglist is too long. Take a look at the
> >>ion_pages_sync_for_device in ion.
> >>
> >>The driver(eg: ION) need to use this interface(flush cache all) to
> >>*improve the efficiency*.

> >I'm not sure what to suggest regarding improving efficiency.
> >
> >Is walking the sglist the expensive portion, or is the problem the cost
> >of multiple page-size operations (each with their own barriers)?
> 
> Last time I looked at this, it was mostly the multiple page-size operations.

We may be able to amortize some of that cost if we had non-synchronised
cache maintenance operations for each page, then followed that up with a
single final DSB SY.

There are several places in arch/arm64/mm/dma-mapping.c (practically
every use of for_each_sg) that could potentially benefit. I'm not sure
how much that's likely to gain as it will depend heavily on the
microarchitecture.

Regardless, it looks like that would require ion_pages_sync_for_device
and friends to be reworked, as it seems to only hand single pages down
to the architecture backend rather than a more complete sglist.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
