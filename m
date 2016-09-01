Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B03E6B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 01:47:36 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c67so40740196ywe.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 22:47:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q66si3024233qkb.116.2016.08.31.22.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 22:47:35 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u815gt4H143869
	for <linux-mm@kvack.org>; Thu, 1 Sep 2016 01:47:35 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 256bce0usx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Sep 2016 01:47:34 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 23:47:34 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 0/6] Introduce ZONE_CMA
In-Reply-To: <20160831080300.GB22757@js1304-P5Q-DELUXE>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com> <8737lnudq6.fsf@linux.vnet.ibm.com> <CAAmzW4MZdwn2-Pd_58B+vXKOyPybdfx4FPRvxNaADnDCryo7Ng@mail.gmail.com> <87shtmsfpy.fsf@linux.vnet.ibm.com> <20160831080300.GB22757@js1304-P5Q-DELUXE>
Date: Thu, 01 Sep 2016 11:17:23 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87eg54rx1w.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Tue, Aug 30, 2016 at 04:09:37PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <js1304@gmail.com> writes:
>> 
>> > 2016-08-29 18:27 GMT+09:00 Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>:
>> >> js1304@gmail.com writes:
>> >>
>> >>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> >>>
>> >>> Hello,
>> >>>
>> >>> Changes from v4
>> >>> o Rebase on next-20160825
>> >>> o Add general fix patch for lowmem reserve
>> >>> o Fix lowmem reserve ratio
>> >>> o Fix zone span optimizaion per Vlastimil
>> >>> o Fix pageset initialization
>> >>> o Change invocation timing on cma_init_reserved_areas()
>> >>
>> >> I don't see much information regarding how we interleave between
>> >> ZONE_CMA and other zones for movable allocation. Is that explained in
>> >> any of the patch ? The fair zone allocator got removed by
>> >> e6cbd7f2efb433d717af72aa8510a9db6f7a7e05
>> >
>> > Interleaving would not work since the fair zone allocator policy is removed.
>> > I don't think that it's a big problem because it is just matter of
>> > timing to fill
>> > up the memory. Eventually, memory on ZONE_CMA will be fully used in
>> > any case.
>> 
>> Does that mean a CMA allocation will now be slower because in most case we
>> will need to reclaim ? The zone list will now have ZONE_CMA in the
>> beginning right ?
>
> ZONE_CMA will be used first but I don't think that CMA allocation will
> be slower. In most case, memory would be fully used (usually
> by page cache). So, we need reclaim or migration in any case.

Considering that the upstream kernel doesn't allow migration of THP
pages, this would mean that migrate will fail in most case if we have
THP enabled and the THP allocation request got satisfied via ZONE_CMA.
Isn't that going to be a problem ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
