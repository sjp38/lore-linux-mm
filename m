Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 982846B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 05:24:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a7-v6so438442wmg.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 02:24:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n45-v6si3495400edd.236.2018.05.31.02.24.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 May 2018 02:24:26 -0700 (PDT)
Date: Thu, 31 May 2018 11:24:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
Message-ID: <20180531092425.GM15278@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-3-mhocko@kernel.org>
 <93ce964b-e352-1905-c2b6-deedf2ea06f8@oracle.com>
 <c0e447b3-4ba7-239e-6550-64de7721ad28@oracle.com>
 <20180530080212.GA27180@dhcp22.suse.cz>
 <e7705544-04fe-c382-f6d0-48d0680b46f2@oracle.com>
 <20180530162501.GB15278@dhcp22.suse.cz>
 <1f6be96b-12ac-9a03-df90-386dab02369d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f6be96b-12ac-9a03-df90-386dab02369d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, libhugetlbfs@googlegroups.com

On Wed 30-05-18 17:51:15, Mike Kravetz wrote:
[...]
> [   38.931497] load_elf_binary: skipping index 0 p_vaddr = 8048034
> [   38.932321] load_elf_binary: skipping index 1 p_vaddr = 8048154
> [   38.933165] load_elf_binary: calling elf_map() index 2 bias 0 vaddr 8048000
> [   38.934087]     map_addr ELF_PAGESTART(addr) 8048000 total_size 0 ELF_PAGEALIGN(size) 2000
> [   38.935101]     eppnt->p_offset = 0
> [   38.935561]     eppnt->p_vaddr  = 8048000
> [   38.936073]     eppnt->p_paddr  = 8048000
> [   38.936897]     eppnt->p_filesz = 169c
> [   38.937493]     eppnt->p_memsz  = 169c
> [   38.938042] load_elf_binary: calling elf_map() index 3 bias 0 vaddr 804969c
> [   38.939002]     map_addr ELF_PAGESTART(addr) 8049000 total_size 0 ELF_PAGEALIGN(size) 2000
> [   38.939959]     eppnt->p_offset = 169c
> [   38.940410]     eppnt->p_vaddr  = 804969c
> [   38.940897]     eppnt->p_paddr  = 804969c
> [   38.941507]     eppnt->p_filesz = 1878
> [   38.942019]     eppnt->p_memsz  = 1878
> [   38.942516] 1123 (xB.linkhuge_nof): Uhuuh, elf segment at 8049000 requested but the memory is mapped already
> 
> It is pretty easy to see the mmap conflict.  I'm still trying to determine if
> the executable file is 'valid'.  It did not throw an error previously as
> MAP_FIXED unmapped the overlapping page.  However, this does not seem right.

Yes, it looks suspicious to say the least. How come the original content
is not needed anymore? Maybe the first section should be 0x1000 rather
than 0x169c?

I am not an expert on the load linkers myself so I cannot really answer
this question. Please note that ppc had something similar. See
ad55eac74f20 ("elf: enforce MAP_FIXED on overlaying elf segments").
Maybe we need to sprinkle more of those at other places?
-- 
Michal Hocko
SUSE Labs
