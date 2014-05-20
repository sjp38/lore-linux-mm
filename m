Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC496B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 07:18:04 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp16so234156pbb.6
        for <linux-mm@kvack.org>; Tue, 20 May 2014 04:18:03 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id pp3si1321508pbb.207.2014.05.20.04.18.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 May 2014 04:18:03 -0700 (PDT)
Date: Tue, 20 May 2014 14:17:53 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: page_alloc: calculate classzone_idx once from the zonelist
 ref
Message-ID: <20140520111753.GA22262@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org

Hello Mel Gorman,

The patch a486e00b8283: "mm: page_alloc: calculate classzone_idx once
from the zonelist ref" from May 17, 2014, leads to the following
static checker warning:

	mm/page_alloc.c:2543 __alloc_pages_slowpath()
	warn: we tested 'nodemask' before and it was 'false'

mm/page_alloc.c
  2537           * Find the true preferred zone if the allocation is unconstrained by
  2538           * cpusets.
  2539           */
  2540          if (!(alloc_flags & ALLOC_CPUSET) && !nodemask) {
                                                     ^^^^^^^^^
Patch introduces this test.

  2541                  struct zoneref *preferred_zoneref;
  2542                  preferred_zoneref = first_zones_zonelist(zonelist, high_zoneidx,
  2543                                  nodemask ? : &cpuset_current_mems_allowed,
                                        ^^^^^^^^
Patch introduces this test as well.

  2544                                  &preferred_zone);
  2545                  classzone_idx = zonelist_zone_idx(preferred_zoneref);
  2546          }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
