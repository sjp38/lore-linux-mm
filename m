Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A25D6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 22:03:51 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g125-v6so1398432ita.0
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:03:51 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 136-v6si2437083itv.62.2018.06.20.19.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 19:03:50 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5L1xbhq032873
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:03:49 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2jmtgwxu2c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:03:49 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5L23mR7019308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:03:48 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5L23lPA024676
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:03:47 GMT
Received: by mail-ot0-f173.google.com with SMTP id 101-v6so1779145oth.4
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:03:47 -0700 (PDT)
MIME-Version: 1.0
References: <20180601125321.30652-1-osalvador@techadventures.net> <20180601125321.30652-3-osalvador@techadventures.net>
In-Reply-To: <20180601125321.30652-3-osalvador@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 20 Jun 2018 22:03:11 -0400
Message-ID: <CAGM2rebO04-AqvZNFLtZ=JVOieY_qr=e=k9G3yS4g+-cO96wrA@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/memory_hotplug: Call register_mem_sect_under_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Fri, Jun 1, 2018 at 8:54 AM <osalvador@techadventures.net> wrote:
>
> From: Oscar Salvador <osalvador@suse.de>
>
> When hotpluging memory, it is possible that two calls are being made
> to register_mem_sect_under_node().
> One comes from __add_section()->hotplug_memory_register()
> and the other from add_memory_resource()->link_mem_sections() if
> we had to register a new node.
>
> In case we had to register a new node, hotplug_memory_register()
> will only handle/allocate the memory_block's since
> register_mem_sect_under_node() will return right away because the
> node it is not online yet.

Indeed.

>
> I think it is better if we leave hotplug_memory_register() to
> handle/allocate only memory_block's and make link_mem_sections()
> to call register_mem_sect_under_node().

Agree, this makes the code simpler.

Please remove:
> +register_fail:
> +       /*
> +        * If sysfs file of new node can't create, cpu on the node
> +        * can't be hot-added. There is no rollback way now.
> +        * So, check by BUG_ON() to catch it reluctantly..
> +        */
> +       BUG_ON(ret);

Merge the above comment with:
> +               /* we online node here. we can't roll back from here. */

And replace all:
> +       if (ret)
> +               goto register_fail;

With:
BUG_ON(ret);

With the above addressed:

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
