Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F14B28028F
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 01:55:13 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id j34so3472580otb.19
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 22:55:13 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id y12si2158337otd.147.2018.01.05.22.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 22:55:12 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
From: Hanjun Guo <guohanjun@huawei.com>
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
Message-ID: <6b076a05-22b6-ce3e-efba-02c65dd1438d@huawei.com>
Date: Sat, 6 Jan 2018 14:53:15 +0800
MIME-Version: 1.0
In-Reply-To: <dcab663f-b090-7447-e43a-44cc8c4a8c8b@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Jiri Kosina <jikos@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 2018/1/6 14:28, Hanjun Guo wrote:
> Hi Dave,
> 
> Thank you very much for the quick response! Minor comments inline.
> 
> On 2018/1/6 14:06, Dave Hansen wrote:
>> On 01/05/2018 08:54 PM, Hanjun Guo wrote:
>>> Do you mean NX bit will be brought back later? I'm asking this because
>>> I tested this patch which it fixed the boot panic issue but the system
>>> will hang when rebooting the system, because rebooting will also call efi
>>> then panic as NS bit is set.
>> Wow, you're running a lot of very lighly-used code paths!  You actually
>> found a similar but totally separate issue from what I gather.  Thank
>> you immensely for the quick testing and bug reports!
>>
>> Could you test the attached fix?
>>
>> For those playing along at home, I think this will end up being needed
>> for 4.15 and probably all the backports.  I want to see if it works
>> before I submit it for real, though.
>>
>>
>> pti-tboot-fix.patch
>>
>>
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> This is another case similar to what EFI does: create a new set of
>> page tables, map some code at a low address, and jump to it.  PTI
>> mistakes this low address for userspace and mistakenly marks it
>> non-executable in an effort to make it unusable for userspace.  Undo
>> the poison to allow execution.
>>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Ning Sun <ning.sun@intel.com>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: "H. Peter Anvin" <hpa@zytor.com>
>> Cc: x86@kernel.org
>> Cc: tboot-devel@lists.sourceforge.net
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>
>>  b/arch/x86/kernel/tboot.c |    7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff -puN arch/x86/kernel/tboot.c~pti-tboot-fix arch/x86/kernel/tboot.c
>> --- a/arch/x86/kernel/tboot.c~pti-tboot-fix	2018-01-05 21:50:55.755554960 -0800
>> +++ b/arch/x86/kernel/tboot.c	2018-01-05 22:01:51.393553325 -0800
>> @@ -124,6 +124,13 @@ static int map_tboot_page(unsigned long
>>  	pte_t *pte;
>>  
>>  	pgd = pgd_offset(&tboot_mm, vaddr);
>> +	/*
>> +	 * PTI poisons low addresses in the kernel page tables in the
>> +	 * name of making them unusable for userspace.  To execute
>> +	 * code at such a low address, the poison must be cleared.
>> +	 */
>> +	pgd->pgd &= ~_PAGE_NX;
> 
> ...
> 
>> +
>>  	p4d = p4d_alloc(&tboot_mm, pgd, vaddr);
> 
> Seems pgd will be re-set after p4d_alloc(), so should
> we put the code behind (or after pud_alloc())?
> 
>>  	if (!p4d)
>>  		return -1;
> 
>  +	/*
>  +	 * PTI poisons low addresses in the kernel page tables in the
>  +	 * name of making them unusable for userspace.  To execute
>  +	 * code at such a low address, the poison must be cleared.
>  +	 */
>  +	pgd->pgd &= ~_PAGE_NX;
> 
> We will have a try in a minute, and report back later.

And it worksi 1/4 ?we can boot/reboot the system successfully, thank
you all the quick response and debug!

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
