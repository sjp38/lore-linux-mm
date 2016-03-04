Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1BF6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 10:59:49 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id r187so40411294oih.3
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:59:49 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id o3si3215499obm.21.2016.03.04.07.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 07:59:48 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id fz5so53924486obc.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 07:59:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D997A6.7070200@suse.cz>
References: <20160302002829.38211.89593.stgit@dwillia2-desk3.amr.corp.intel.com>
	<56D997A6.7070200@suse.cz>
Date: Fri, 4 Mar 2016 07:59:48 -0800
Message-ID: <CAPcyv4jaqGA9dmAzXU1recsox6UxY0RzPey+Gc+9hePeJ=4P5Q@mail.gmail.com>
Subject: Re: [PATCH v2] mm: exclude ZONE_DEVICE from GFP_ZONE_TABLE
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Fri, Mar 4, 2016 at 6:11 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 03/02/2016 01:32 AM, Dan Williams wrote:
>> ZONE_DEVICE (merged in 4.3) and ZONE_CMA (proposed) are examples of new
>> mm zones that are bumping up against the current maximum limit of 4
>> zones, i.e. 2 bits in page->flags for the GFP_ZONE_TABLE.
>>
>> The GFP_ZONE_TABLE poses an interesting constraint since
>> include/linux/gfp.h gets included by the 32-bit portion of a 64-bit
>> build.  We need to be careful to only build the table for zones that
>> have a corresponding gfp_t flag.  GFP_ZONES_SHIFT is introduced for this
>> purpose.  This patch does not attempt to solve the problem of adding a
>> new zone that also has a corresponding GFP_ flag.
>>
>> Vlastimil points out that ZONE_DEVICE, by depending on x86_64 and
>> SPARSEMEM_VMEMMAP implies that SECTIONS_WIDTH is zero.  In other words
>
>                                                        ^ by default
>
> Because CONFIG_SPARSEMEM_VMEMMAP can still be disabled by the user.
>
>> even though ZONE_DEVICE does not fit in GFP_ZONE_TABLE it is free to
>> consume another bit in page->flags (expand ZONES_WIDTH) with room to
>> spare.
>
> So it's still possible to configure the x86_64 kernel such that you get
> "#warning Unfortunate NUMA and NUMA Balancing config". But it requires
> some effort to override the defaults, and it's not breaking build or
> runtime. BTW I was able to get that warning even with your previous
> patch that limited NODES_WIDTH, so that wasn't a solution for this
> anyway. This patch is simpler and better.

All this suggests that ZONE_DEVICE depend on SPARSEMEM_VMEMMAP.  I'll
fix that up.

>> Link: https://bugzilla.kernel.org/show_bug.cgi?id=110931
>> Fixes: 033fbae988fc ("mm: ZONE_DEVICE for "device memory"")
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
>> Reported-by: Mark <markk@clara.co.uk>
>> Reported-by: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
