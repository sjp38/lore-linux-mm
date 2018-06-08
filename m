Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E872E6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:32:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so5369127pfe.15
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:32:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e9-v6sor20894562plk.26.2018.06.07.18.32.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 18:32:36 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
 <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
 <20180524133805.6e9bfd4bf48de065ce1d7611@linux-foundation.org>
 <20180607151344.a22a1e7182a2142e6d24e4de@linux-foundation.org>
 <20180607233800.GA6965@redhat.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <91c87688-50d3-581c-339d-70ad658a292a@gmail.com>
Date: Fri, 8 Jun 2018 09:32:28 +0800
MIME-Version: 1.0
In-Reply-To: <20180607233800.GA6965@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Suzuki K Poulose <Suzuki.Poulose@arm.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

Hi Andrea
Thanks for the review.

On 6/8/2018 7:38 AM, Andrea Arcangeli Wrote:
> On Thu, Jun 07, 2018 at 03:13:44PM -0700, Andrew Morton wrote:
>> This patch is quite urgent and is tagged for -stable backporting, yet
>> it remains in an unreviewed state.  Any takers?
> 
> It looks a straightforward safe fix, on x86 hva_to_gfn_memslot would
> zap those bits and hide the misalignment caused by the low metadata
> bits being erroneously left set in the address, but the arm code
> notices when that's the last page in the memslot and the hva_end is
> getting aligned and the size is below one page.
> 
>> [35380.933345] [<ffff000008088f00>] dump_backtrace+0x0/0x22c
>> [35380.938723] [<ffff000008089150>] show_stack+0x24/0x2c
>> [35380.943759] [<ffff00000893c078>] dump_stack+0x8c/0xb0
>> [35380.948794] [<ffff00000820ab50>] bad_page+0xf4/0x154
>> [35380.953740] [<ffff000008211ce8>] free_pages_check_bad+0x90/0x9c
>> [35380.959642] [<ffff00000820c430>] free_pcppages_bulk+0x464/0x518
>> [35380.965545] [<ffff00000820db98>] free_hot_cold_page+0x22c/0x300
>> [35380.971448] [<ffff0000082176fc>] __put_page+0x54/0x60
>> [35380.976484] [<ffff0000080b1164>] unmap_stage2_range+0x170/0x2b4
>> [35380.982385] [<ffff0000080b12d8>] kvm_unmap_hva_handler+0x30/0x40
>> [35380.988375] [<ffff0000080b0104>] handle_hva_to_gpa+0xb0/0xec
>> [35380.994016] [<ffff0000080b2644>] kvm_unmap_hva_range+0x5c/0xd0
>> [35380.999833] [<ffff0000080a8054>] 
>>
>> I even injected a fault on purpose in kvm_unmap_hva_range by seting
>> size=size-0x200, the call trace is similar as above.  So I thought the
>> panic is similarly caused by the root cause of WARN_ON.
> 
> I think the problem triggers in the addr += PAGE_SIZE of
> unmap_stage2_ptes that never matches end because end is aligned but
> addr is not.
> 
> 	} while (pte++, addr += PAGE_SIZE, addr != end);
> 
> x86 again only works on hva_start/hva_end after converting it to
> gfn_start/end and that being in pfn units the bits are zapped before
> they risk to cause trouble.
For this panic issue on arm64, I started another thread to discuss
https://lkml.org/lkml/2018/5/2/61


-- 
Cheers,
Jia
> 
>>
>> Link: http://lkml.kernel.org/r/1525403506-6750-1-git-send-email-hejianet@gmail.com
>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>> Cc: Suzuki K Poulose <Suzuki.Poulose@arm.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
>> Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>> Cc: Jia He <hejianet@gmail.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> 
