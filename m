Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE09A6B025E
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 08:22:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n8so853093wmg.4
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:22:57 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id m70si3410077wmh.265.2017.10.23.05.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 05:22:56 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
Date: Mon, 23 Oct 2017 14:22:30 +0200
MIME-Version: 1.0
In-Reply-To: <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 2017-10-23 13:42, Michal Hocko wrote:
> I do not remember any such a request either. I can see some merit in the
> described use case. It is not specific on why hugetlb pages are used for
> the allocator memory because that comes with it own issues.

That is yet for the user to specify. As of now hugepages still require a 
special setup that not all people might have as of now - to my knowledge 
a kernel being compiled with CONFIG_TRANSPARENT_HUGEPAGE=y and a number 
of such pages being allocated either through the kernel boot line or 
through /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages. I'm 
deliberately ignoring 1-GiB pages here because those are only 
allocatable during boot, when no processes have been spawned and memory 
is still not fragmented.

My point is that I can see people not being too eager to support 1 GiB 
pages as of now unless for very specific use case. 2-MiB pages, on the 
other hand, shouldn't have those limitations anymore. User-space 
programs should be capable of allocating such pages without the need for 
the user to fiddle with nr_hugepages beforehand.

Some time ago I've written some code to detect TLB capabilities on my 
current testing CPU, those are the results:

[TLB] Instruction TLB: 2M/4M pages, fully associative, 8 entries
[TLB] Data TLB: 4 KByte pages, 4-way set associative, 64 entries
[TLB] Data TLB: 2 MByte or 4 MByte pages, 4-way set associative, 32 
entries and a separate array with 1 GByte pages, 4-way set associative, 
4 entries
[TLB] Instruction TLB: 4KByte pages, 8-way set associative, 64 entries
[STLB] Shared 2nd-Level TLB: 4 KByte/2MByte pages, 8-way associative, 
1024 entries

With the knowledge that allocations in the Mebibyte range aren't 
uncommon at all nowadays and that one 2-MiB page eliminates the need for 
512 4-KiB pages, we really should make advances towards treating 2-MiB 
pages just as casual as older pages. Allocators can still query if the 
kernel supports the specified page size, and specifying MAP_HUGETLB | 
MAP_HUGE_2MB would still be required in order to not break older 
programs, but from my perspective there is a lot to gain here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
