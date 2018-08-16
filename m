Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0FCD6B0005
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:47:39 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id o4-v6so3066771wrn.19
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:47:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201-v6sor192549wmf.4.2018.08.16.03.47.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 03:47:38 -0700 (PDT)
Date: Thu, 16 Aug 2018 12:47:36 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v1 3/5] mm/memory_hotplug: check if sections are already
 online/offline
Message-ID: <20180816104736.GA16861@techadventures.net>
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180816100628.26428-4-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 16, 2018 at 12:06:26PM +0200, David Hildenbrand wrote:

> +
> +/* check if all mem sections are offline */
> +bool mem_sections_offline(unsigned long pfn, unsigned long end_pfn)
> +{
> +	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +
> +		if (WARN_ON(!valid_section_nr(section_nr)))
> +			continue;
> +		if (online_section_nr(section_nr))
> +			return false;
> +	}
> +	return true;
> +}

AFAICS pages_correctly_probed will catch this first.
pages_correctly_probed checks for the section to be:

- present
- valid
- !online

Maybe it makes sense to rename it, and write another pages_correctly_probed routine
for the offline case.

So all checks would stay in memory_block_action level, and we would not need
the mem_sections_offline/online stuff.

Thanks
-- 
Oscar Salvador
SUSE L3
