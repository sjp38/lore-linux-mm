Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 34EB96B0254
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 03:20:14 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so19973387wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 00:20:13 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id hs1si3516864wib.37.2015.07.31.00.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 00:20:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id D5B2098C51
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 07:20:11 +0000 (UTC)
Date: Fri, 31 Jul 2015 08:20:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 00/10] Remove zonelist cache and high-order watermark
 checking
Message-ID: <20150731072009.GC5840@techsingularity.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <20150731061403.GC15912@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150731061403.GC15912@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 31, 2015 at 03:14:03PM +0900, Joonsoo Kim wrote:
> On Mon, Jul 20, 2015 at 09:00:09AM +0100, Mel Gorman wrote:
> > From: Mel Gorman <mgorman@suse.de>
> > 
> > This series started with the idea to move LRU lists to pgdat but this
> > part was more important to start with. It was written against 4.2-rc1 but
> > applies to 4.2-rc3.
> > 
> > The zonelist cache has been around for a long time but it is of dubious merit
> > with a lot of complexity. There are a few reasons why it needs help that
> > are explained in the first patch but the most important is that a failed
> > THP allocation can cause a zone to be treated as "full". This potentially
> > causes unnecessary stalls, reclaim activity or remote fallbacks. Maybe the
> > issues could be fixed but it's not worth it.  The series places a small
> > number of other micro-optimisations on top before examining watermarks.
> > 
> > High-order watermarks are something that can cause high-order allocations to
> > fail even though pages are free. This was originally to protect high-order
> > atomic allocations but there is a much better way that can be handled using
> > migrate types. This series uses page grouping by mobility to preserve some
> > pageblocks for high-order allocations with the size of the reservation
> > depending on demand. kswapd awareness is maintained by examining the free
> > lists. By patch 10 in this series, there are no high-order watermark checks
> > while preserving the properties that motivated the introduction of the
> > watermark checks.
> 
> I guess that removal of zonelist cache and high-order watermarks has
> different purpose and different set of reader. It is better to
> separate this two kinds of patches next time to help reviewer to see
> what they want to see.
> 

One of the reasons zonelist existed was to avoid watermark checks in some
case. The series also intends to reduce the cost of watermark checks in some
cases which is why they are part of the same series. I'm not comfortable
doing one without the other.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
