Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68B216B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:43:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so13810125wrb.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:43:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si5377440wrv.93.2017.08.14.04.43.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:43:28 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:43:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 02/15] x86/mm: setting fields in deferred pages
Message-ID: <20170814114326.GH19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-3-git-send-email-pasha.tatashin@oracle.com>
 <20170811090214.GD30811@dhcp22.suse.cz>
 <b0422e38-a6da-081a-71c5-82a36dd2a5bb@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0422e38-a6da-081a-71c5-82a36dd2a5bb@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 11:39:41, Pasha Tatashin wrote:
> >AFAIU register_page_bootmem_info_node is only about struct pages backing
> >pgdat, usemap and memmap. Those should be in reserved memblocks and we
> >do not initialize those at later times, they are not relevant to the
> >deferred initialization as your changelog suggests so the ordering with
> >get_page_bootmem shouldn't matter. Or am I missing something here?
> 
> The pages for pgdata, usemap, and memmap are part of reserved, and thus
> getting initialized when free_all_bootmem() is called.
> 
> So, we have something like this in mem_init()
> 
> register_page_bootmem_info
>  register_page_bootmem_info_node
>   get_page_bootmem
>    .. setting fields here ..
>    such as: page->freelist = (void *)type;
> 
> free_all_bootmem()
>  free_low_memory_core_early()
>   for_each_reserved_mem_region()
>    reserve_bootmem_region()
>     init_reserved_page() <- Only if this is deferred reserved page
>      __init_single_pfn()
>       __init_single_page()
>           memset(0) <-- Loose the set fields here!

OK, I have missed that part. Please make it explicit in the changelog.
It is quite easy to get lost in the deep call chains.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
