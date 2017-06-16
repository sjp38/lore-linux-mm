Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E64F36B02C3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:05:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 12so2727778wmn.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:05:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p73si401981wmf.62.2017.06.16.01.05.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 01:05:06 -0700 (PDT)
Date: Fri, 16 Jun 2017 10:05:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 11/14] mm, memory_hotplug: do not associate hotadded
 memory to zones until online
Message-ID: <20170616080502.GA30580@dhcp22.suse.cz>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-12-mhocko@kernel.org>
 <20170616042058.GA3976@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616042058.GA3976@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

[Please try to trim the context you are replying to]

On Fri 16-06-17 12:20:58, Wei Yang wrote:
> On Mon, May 15, 2017 at 10:58:24AM +0200, Michal Hocko wrote:
[...]
> > /*
> >+ * Return true if [start_pfn, start_pfn + nr_pages) range has a non-empty
> >+ * intersection with the given zone
> >+ */
> >+static inline bool zone_intersects(struct zone *zone,
> >+		unsigned long start_pfn, unsigned long nr_pages)
> >+{
> >+	if (zone_is_empty(zone))
> >+		return false;
> >+	if (start_pfn >= zone_end_pfn(zone))
> >+		return false;
> >+
> >+	if (zone->zone_start_pfn <= start_pfn)
> >+		return true;
> >+	if (start_pfn + nr_pages > zone->zone_start_pfn)
> >+		return true;
> >+
> >+	return false;
> >+}
> 
> I think this could be simplified as:
> 
> static inline bool zone_intersects(struct zone *zone,
> 		unsigned long start_pfn, unsigned long nr_pages)
> {
> 	if (zone_is_empty(zone))
> 		return false;
> 
> 	if (start_pfn >= zone_end_pfn(zone) ||
> 	    start_pfn + nr_pages <= zone->zone_start_pfn)
> 		return false;
> 
> 	return true;
> }

Feel free to send a patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
