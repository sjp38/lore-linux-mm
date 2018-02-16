Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE52C6B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 04:19:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a6so608144wme.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 01:19:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s130sor3735445wms.82.2018.02.16.01.19.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 01:19:22 -0800 (PST)
Date: Fri, 16 Feb 2018 10:19:18 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v4 5/6] mm/memory_hotplug: don't read nid from struct page
 during hotplug
Message-ID: <20180216091918.axu57tfsezzybeoa@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-6-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-6-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> During memory hotplugging the probe routine will leave struct pages
> uninitialized, the same as it is currently done during boot. Therefore, we
> do not want to access the inside of struct pages before
> __init_single_page() is called during onlining.
> 
> Because during hotplug we know that pages in one memory block belong to
> the same numa node, we can skip the checking. We should keep checking for
> the boot case.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  drivers/base/memory.c |  2 +-
>  drivers/base/node.c   | 22 +++++++++++++++-------
>  include/linux/node.h  |  4 ++--
>  3 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index deb3f029b451..a14fb0cd424a 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -731,7 +731,7 @@ int register_new_memory(int nid, struct mem_section *section)
>  	}
>  
>  	if (mem->section_count == sections_per_block)
> -		ret = register_mem_sect_under_node(mem, nid);
> +		ret = register_mem_sect_under_node(mem, nid, false);
>  out:

The namespace of all these memory range handling functions is horribly random,
and I think now it got worse: we add an assumption that register_new_memory() is 
implicitly called as part of hotplugged memory (where things are pre-cleared) - 
but nothing in its naming suggests so.

How about renaming it to hotplug_memory_register() or so?

With that change you can add:

  Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
