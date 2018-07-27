Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07F116B000A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:24:56 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o24-v6so3827597iob.20
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:24:56 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 19-v6si3216389itk.86.2018.07.27.08.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 08:24:54 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6RFNk5I164204
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:24:54 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2kbv8tfqpk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:24:53 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6RFOqUG017393
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:24:52 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6RFOqp6001759
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:24:52 GMT
Received: by mail-oi0-f42.google.com with SMTP id l10-v6so9723396oii.0
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:24:51 -0700 (PDT)
MIME-Version: 1.0
References: <20180727140325.11881-1-osalvador@techadventures.net> <20180727140325.11881-5-osalvador@techadventures.net>
In-Reply-To: <20180727140325.11881-5-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 27 Jul 2018 11:24:15 -0400
Message-ID: <CAGM2reY-uUTBYUY9XhhQqm6CRWjFsH0fxJ1H7D3+-0Lbyy8HTg@mail.gmail.com>
Subject: Re: [PATCH v4 4/4] mm/page_alloc: Introduce free_area_init_core_hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

Hi Oscar,

>  static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)

Remove __ref from this function and add it to
free_area_init_core_hotplug() instead, as that is the only function
from a different section. This will reduce the scope of ref, and no
need to place reset_node_managed_pages() into a different section as
it is compiled only when CONFIG_MEMORY_HOTPLUG=y

> +#ifdef CONFIG_MEMORY_HOTPLUG
> +void __paginginit free_area_init_core_hotplug(int nid)
> +{
> +       enum zone_type j;
> +       pg_data_t *pgdat = NODE_DATA(nid);
> +
> +       pgdat_init_internals(pgdat);
> +       for (j = 0; j < MAX_NR_ZONES; j++) {
> +               struct zone *zone = pgdat->node_zones + j;
> +               zone_init_internals(zone, j, nid, 0);
> +       }
> +}

Style: I would write the for() loop above like this:

        for (i = 0; i < MAX_NR_ZONES; i++)
                zone_init_internals(&pgdat->node_zones[i], i, nid, 0);

Other than this all good:
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Thank you,
Pavel
