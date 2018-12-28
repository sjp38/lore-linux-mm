Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED5E88E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:39:50 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id j125so25290800qke.12
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:39:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c127si4913674qkd.153.2018.12.27.19.39.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 19:39:50 -0800 (PST)
Date: Fri, 28 Dec 2018 11:39:40 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv3 0/2] mm/memblock: reuse memblock bottom-up allocation
 style
Message-ID: <20181228033940.GB1990@MiWiFi-R3L-srv>
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On 12/28/18 at 11:00am, Pingfan Liu wrote:
> The bottom-up allocation style is introduced to cope with movable_node,
> where the limit inferior of allocation starts from kernel's end, due to
> lack of knowledge of memory hotplug info at this early time.
> Beside this original aim, 'kexec -c' prefers to reuse this style to alloc mem

Wondering what is 'kexec -c'.

> at lower address, since if the reserved region is beyond 4G, then it requires
> extra mem (default is 16M) for swiotlb. But at this time hotplug info has been

The default is 256M, not sure if we are talking about the same thing.

low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);

> got, the limit inferior can be extend to 0, which is done by this series
> 
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Len Brown <lenb@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Daniel Vacek <neelx@redhat.com>
> Cc: Mathieu Malaterre <malat@debian.org>
> Cc: Stefan Agner <stefan@agner.ch>
> Cc: Dave Young <dyoung@redhat.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: yinghai@kernel.org,
> Cc: vgoyal@redhat.com
> Cc: linux-kernel@vger.kernel.org
> 
> Pingfan Liu (2):
>   mm/memblock: extend the limit inferior of bottom-up after parsing
>     hotplug attr
>   x86/kdump: bugfix, make the behavior of crashkernel=X consistent with
>     kaslr
> 
>  arch/x86/kernel/setup.c  |  9 +++++---
>  drivers/acpi/numa.c      |  4 ++++
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 58 +++++++++++++++++++++++++++++-------------------
>  4 files changed, 46 insertions(+), 26 deletions(-)
> 
> -- 
> 2.7.4
> 
