Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5DD86B0008
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 09:33:39 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 3so9023053oix.12
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 06:33:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si8253141ott.161.2018.02.01.06.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 06:33:38 -0800 (PST)
Date: Thu, 1 Feb 2018 22:33:33 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 2/2] mm/sparse.c: Add nr_present_sections to change the
 mem_map allocation
Message-ID: <20180201143333.GD1770@localhost.localdomain>
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-3-bhe@redhat.com>
 <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
 <6def8374-2de2-a30c-69ff-2a49fb57dc9a@linux.intel.com>
 <20180201141934.GC1770@localhost.localdomain>
 <7494fba4-a769-67d4-4121-508bd26da4ba@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7494fba4-a769-67d4-4121-508bd26da4ba@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On 02/01/18 at 06:23am, Dave Hansen wrote:
> On 02/01/2018 06:19 AM, Baoquan He wrote:
> > 
> > I suppose these functions changed here are only called during system
> > bootup, namely in paging_init(). Hot-add memory goes in a different
> > path, __add_section() -> sparse_add_one_section(), different called
> > functions.
> 
> But does this keep those sections that were not present on boot from
> being added later?

I think it won't. As you can see, the referred functions are only called
during init stage. If anyone try to use any of them for later hot-add memory,
that will cause problem, lucky there isn't. And this is only used to
store the allocated usemap and mem_map for each present section on boot.
After that, the usemap_map and map_map pointer array will be freed, they
are temporary here. I forget mentioning this in patch log, sorry for bringing
confusion.

void __init sparse_memory_present_with_active_regions(int nid)
void __init memory_present(int nid, unsigned long start, unsigned long end)
void __init sparse_init(void) 
static void __init alloc_usemap_and_memmap(...)
static void __init sparse_early_usemaps_alloc_node(...)
static void __init sparse_early_mem_maps_alloc_node(...)
void __init sparse_mem_maps_populate_node(...)
void __init sparse_mem_maps_populate_node(...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
