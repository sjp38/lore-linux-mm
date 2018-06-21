Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 882196B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 22:35:59 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 12-v6so1312846qtq.8
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:35:59 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l7-v6si2570224qvo.196.2018.06.20.19.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 19:35:57 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5L2YOYv052973
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:35:57 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jmtgwxvqn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:35:57 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5L2ZtFw018401
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:35:56 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5L2ZtDI007412
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:35:55 GMT
Received: by mail-ot0-f179.google.com with SMTP id h6-v6so1858181otj.0
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:35:54 -0700 (PDT)
MIME-Version: 1.0
References: <20180601125321.30652-1-osalvador@techadventures.net> <20180601125321.30652-4-osalvador@techadventures.net>
In-Reply-To: <20180601125321.30652-4-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 20 Jun 2018 22:35:18 -0400
Message-ID: <CAGM2reb6p-ffZ6-JDc5vqMkyDNDn9siWjEy9LnVJ1BtTKYhegA@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/memory_hotplug: Get rid of link_mem_sections
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Fri, Jun 1, 2018 at 8:54 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> link_mem_sections() and walk_memory_range() share most of the code,
> so we can use walk_memory_range() with a callback to register_mem_sect_under_node()
> instead of using link_mem_sections().

Yes, their logic is indeed identical, so it is good to replace some
code with walk_memory_range().

>
> To control whether the node id must be check, two new functions has been added:
>
> register_mem_sect_under_node_nocheck_node()
> and
> register_mem_sect_under_node_check_node()

I do not like this, please see if my suggestion is better:

1. Revert all the changes outside of  link_mem_sections()
2. Remove check_nid argument from register_mem_sect_under_node
and link_mem_sections.
3. In register_mem_sect_under_node
Replace:

if (check_nid) {
}

With:
if (system_state == SYSTEM_BOOTING) {
}

4. Change register_mem_sect_under_node() prototype to match callback
of walk_memory_range()
5. Call walk_memory_range(... register_mem_sect_under_node ...) from
link_mem_sections

Thank you,
Pavel
