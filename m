Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B256B6B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 12:24:19 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id d142so3415646oih.4
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 09:24:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor1536527oif.262.2018.03.01.09.24.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 09:24:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180301152729.GM15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz> <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
 <20180301152729.GM15057@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 1 Mar 2018 18:24:17 +0100
Message-ID: <CACjP9X9E4d-ew9ZaHzhy2+R6DumYSny2_sRqoQa-n6cOZU3Y1w@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu, Mar 1, 2018 at 4:27 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 01-03-18 16:09:35, Daniel Vacek wrote:
>> From registers and stack I digged start_page points to
>> ffffe31d01ed8000 (note that this is
>> page ffffe31d01edffc0 aligned to pageblock) and I can see this in memory dump:
>>
>> crash> kmem -p 77fff000 78000000 7b5ff000 7b600000 7b7fe000 7b7ff000
>> 7b800000 7ffff000 80000000
>>       PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
>> ffffe31d01e00000  78000000                0        0  0 0
>> ffffe31d01ed7fc0  7b5ff000                0        0  0 0
>> ffffe31d01ed8000  7b600000                0        0  0 0    <<<< note
>
> Are those ranges covered by the System RAM as well?

Sorry I forgot to answer this. If they were, the loop won't be
skipping them, right? But it really does not matter here, kernel needs
(some) page structures initialized anyways. And I do not feel
comfortable with removing the VM_BUG_ON(). The initialization is what
changed with commit b92df1de5d28, hence fixing this.

--nX

>> that nodeid and zonenr are encoded in top bits of page flags which are
>> not initialized here, hence the crash :-(
>> ffffe31d01edff80  7b7fe000                0        0  0 0
>> ffffe31d01edffc0  7b7ff000                0        0  1 1fffff00000000
>> ffffe31d01ee0000  7b800000                0        0  1 1fffff00000000
>> ffffe31d01ffffc0  7ffff000                0        0  1 1fffff00000000
>
> It is still not clear why not to do the alignment in
> memblock_next_valid_pfn rahter than its caller.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
