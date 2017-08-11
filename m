Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D91506B02B4
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:40:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e2so19141912qta.13
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:40:20 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m65si1016012qki.91.2017.08.11.08.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 08:40:20 -0700 (PDT)
Subject: Re: [v6 02/15] x86/mm: setting fields in deferred pages
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-3-git-send-email-pasha.tatashin@oracle.com>
 <20170811090214.GD30811@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <b0422e38-a6da-081a-71c5-82a36dd2a5bb@oracle.com>
Date: Fri, 11 Aug 2017 11:39:41 -0400
MIME-Version: 1.0
In-Reply-To: <20170811090214.GD30811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

> AFAIU register_page_bootmem_info_node is only about struct pages backing
> pgdat, usemap and memmap. Those should be in reserved memblocks and we
> do not initialize those at later times, they are not relevant to the
> deferred initialization as your changelog suggests so the ordering with
> get_page_bootmem shouldn't matter. Or am I missing something here?

The pages for pgdata, usemap, and memmap are part of reserved, and thus 
getting initialized when free_all_bootmem() is called.

So, we have something like this in mem_init()

register_page_bootmem_info
  register_page_bootmem_info_node
   get_page_bootmem
    .. setting fields here ..
    such as: page->freelist = (void *)type;

free_all_bootmem()
  free_low_memory_core_early()
   for_each_reserved_mem_region()
    reserve_bootmem_region()
     init_reserved_page() <- Only if this is deferred reserved page
      __init_single_pfn()
       __init_single_page()
           memset(0) <-- Loose the set fields here!

memblock does not know about deferred pages, and can be requested to 
allocate physical pages anywhere. So, the reserved pages in memblock can 
be both in non-deferred and deferred part of the memory.

Without deferred pages enabled, by the time register_page_bootmem_info() 
is called every page went through __init_single_page(), but with 
deferred pages enabled, there is scenario where fields can be set before 
pages go through __init_single_page(). This patch fixes it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
