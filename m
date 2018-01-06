Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1AFE280291
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 03:43:18 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f185so3384696itc.2
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 00:43:18 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id f32si5533375ioi.249.2018.01.06.00.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 00:43:17 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
 <ac54449b-feeb-58d2-45e6-5ebb9784ed13@huawei.com>
 <332f4eab-8a3d-8b29-04f2-7c075f81b85b@linux.intel.com>
 <dcab663f-b090-7447-e43a-44cc8c4a8c8b@huawei.com>
 <6b076a05-22b6-ce3e-efba-02c65dd1438d@huawei.com>
 <80dbcf02-2035-94dc-ca29-4f17ad271fda@linux.intel.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <1e3fcdaa-75c9-99ef-3298-8015bb09b8cc@huawei.com>
Date: Sat, 6 Jan 2018 16:42:06 +0800
MIME-Version: 1.0
In-Reply-To: <80dbcf02-2035-94dc-ca29-4f17ad271fda@linux.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Jiri Kosina <jikos@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 2018/1/6 15:55, Dave Hansen wrote:
> On 01/05/2018 10:53 PM, Hanjun Guo wrote:
>>>  +	/*
>>>  +	 * PTI poisons low addresses in the kernel page tables in the
>>>  +	 * name of making them unusable for userspace.  To execute
>>>  +	 * code at such a low address, the poison must be cleared.
>>>  +	 */
>>>  +	pgd->pgd &= ~_PAGE_NX;
>>>
>>> We will have a try in a minute, and report back later.
>> And it worksi 1/4 ?we can boot/reboot the system successfully, thank
>> you all the quick response and debug!
> I think I'll just submit the attached patch if there are no objections
> (and if it works, of course!).

We tested that placing the NX clearing after pud_alloc(), and it works,
patch below should work as well.

> 
> I just stuck the NX clearing at the bottom.
> 
> 
> pti-tboot-fix.patch
> 
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This is another case similar to what EFI does: create a new set of
> page tables, map some code at a low address, and jump to it.  PTI
> mistakes this low address for userspace and mistakenly marks it
> non-executable in an effort to make it unusable for userspace.  Undo
> the poison to allow execution.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Ning Sun <ning.sun@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: tboot-devel@lists.sourceforge.net
> Cc: linux-kernel@vger.kernel.org
> ---
> 
>  b/arch/x86/kernel/tboot.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff -puN arch/x86/kernel/tboot.c~pti-tboot-fix arch/x86/kernel/tboot.c
> --- a/arch/x86/kernel/tboot.c~pti-tboot-fix	2018-01-05 21:50:55.755554960 -0800
> +++ b/arch/x86/kernel/tboot.c	2018-01-05 23:51:41.368536890 -0800
> @@ -138,6 +138,17 @@ static int map_tboot_page(unsigned long
>  		return -1;
>  	set_pte_at(&tboot_mm, vaddr, pte, pfn_pte(pfn, prot));
>  	pte_unmap(pte);
> +
> +	/*
> +	 * PTI poisons low addresses in the kernel page tables in the
> +	 * name of making them unusable for userspace.  To execute
> +	 * code at such a low address, the poison must be cleared.
> +	 *
> +	 * Note: 'pgd' actually gets set in p4d_alloc() _or_
> +	 * pud_alloc() depending on 4/5-level paging.
> +	 */
> +	pgd->pgd &= ~_PAGE_NX;
> +
>  	return 0;
>  }

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
