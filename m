Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8676B03A7
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:31:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h15so3141270wmd.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:31:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si21753704wrg.61.2017.04.10.08.31.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 08:31:43 -0700 (PDT)
Date: Mon, 10 Apr 2017 17:31:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410153139.GG4618@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410162749.7d7f31c1@nial.brq.redhat.com>
 <20170410145639.GE4618@dhcp22.suse.cz>
 <20170410152228.GF4618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410152228.GF4618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon 10-04-17 17:22:28, Michal Hocko wrote:
[...]
> Heh, this one is embarrassing
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 1c6fdacbccd3..9677b6b711b0 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -402,7 +402,7 @@ static ssize_t show_valid_zones(struct device *dev,
>  		return sprintf(buf, "none\n");
>  
>  	start_pfn = valid_start_pfn;
> -	nr_pages = valid_end_pfn - valid_end_pfn;
> +	nr_pages = valid_end_pfn - start_pfn;
>  
>  	/*
>  	 * Check the existing zone. Make sure that we do that only on the

Btw. while starting into the code I think that allow_online_pfn_range is
also wrong and we need the following
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 94e96ca790f6..035165ceefef 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -858,7 +858,7 @@ bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
 	 * TODO make sure we do not overlap with ZONE_DEVICE
 	 */
 	if (online_type == MMOP_ONLINE_KERNEL) {
-		if (!populated_zone(movable_zone))
+		if (!movable_zone->spanned_pages)
 			return true;
 		return movable_zone->zone_start_pfn >= pfn + nr_pages;
 	} else if (online_type == MMOP_ONLINE_MOVABLE) {

because we would allow ZONE_NORMAL after the full movable zone has been
offlined.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
