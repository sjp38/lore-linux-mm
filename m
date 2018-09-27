Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0D08E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 14:32:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t24-v6so1598473eds.12
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:32:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h25-v6si3111534edw.256.2018.09.27.11.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 11:32:39 -0700 (PDT)
Date: Thu, 27 Sep 2018 20:32:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce new function vm_insert_kmem_page
Message-ID: <20180927183236.GJ6278@dhcp22.suse.cz>
References: <20180927175123.GA16367@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927175123.GA16367@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, pasha.tatashin@oracle.com, riel@redhat.com, willy@infradead.org, minchan@kernel.org, peterz@infradead.org, ying.huang@intel.com, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, arnd@arndb.de, mcgrof@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-09-18 23:21:23, Souptick Joarder wrote:
> vm_insert_kmem_page is similar to vm_insert_page and will
> be used by drivers to map kernel (kmalloc/vmalloc/pages)
> allocated memory to user vma.
> 
> Previously vm_insert_page is used for both page fault
> handlers and outside page fault handlers context. When
> vm_insert_page is used in page fault handlers context,
> each driver have to map errno to VM_FAULT_CODE in their
> own way. But as part of vm_fault_t migration all the
> page fault handlers are cleaned up by using new vmf_insert_page.
> Going forward, vm_insert_page will be removed by converting
> it to vmf_insert_page.
>  
> But their are places where vm_insert_page is used outside
> page fault handlers context and converting those to
> vmf_insert_page is not a good approach as drivers will end
> up with new VM_FAULT_CODE to errno conversion code and it will
> make each user more complex.
> 
> So this new vm_insert_kmem_page can be used to map kernel
> memory to user vma outside page fault handler context.
> 
> In short, vmf_insert_page will be used in page fault handlers
> context and vm_insert_kmem_page will be used to map kernel
> memory to user vma outside page fault handlers context.
> 
> We will slowly convert all the user of vm_insert_page to
> vm_insert_kmem_page after this API be available in linus tree.

In general I do not like patches adding a new exports/functionality
without any user added at the same time. I am not going to look at the
implementation right now but the above opens more questions than it
gives answers. Why do we have to distinguish #PF from other paths?
-- 
Michal Hocko
SUSE Labs
