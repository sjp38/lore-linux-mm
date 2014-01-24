Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 35C1E6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 01:56:41 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so3915131qcr.14
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 22:56:41 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id l7si5473312qgl.40.2014.01.23.22.56.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 22:56:40 -0800 (PST)
Message-ID: <52E20E98.7010703@ti.com>
Date: Fri, 24 Jan 2014 01:56:24 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com> <CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com> <52E20A56.1000507@ti.com>
In-Reply-To: <52E20A56.1000507@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Friday 24 January 2014 01:38 AM, Santosh Shilimkar wrote:
> Yinghai,
> 
> On Friday 24 January 2014 12:55 AM, Yinghai Lu wrote:
>> On Thu, Jan 23, 2014 at 2:49 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>>>> Linus's current tree doesn't boot on an 8-node/1TB NUMA system that I
>>>> have.  Its reboots are *LONG*, so I haven't fully bisected it, but it's
>>>> down to a just a few commits, most of which are changes to the memblock
>>>> code.  Since the panic is in the memblock code, it looks like a
>>>> no-brainer.  It's almost certainly the code from Santosh or Grygorii
>>>> that's triggering this.
>>>>
>>>> Config and good/bad dmesg with memblock=debug are here:
>>>>
>>>>         http://sr71.net/~dave/intel/3.13/
>>>>
>>>> Please let me know if you need it bisected further than this.
>> Please check attached patch, and it should fix the problem.
>>
> 
> [...]
> 
>>
>> Subject: [PATCH] x86: Fix numa with reverting wrong memblock setting.
>>
>> Dave reported Numa on x86 is broken on system with 1T memory.
>>
>> It turns out
>> | commit 5b6e529521d35e1bcaa0fe43456d1bbb335cae5d
>> | Author: Santosh Shilimkar <santosh.shilimkar@ti.com>
>> | Date:   Tue Jan 21 15:50:03 2014 -0800
>> |
>> |    x86: memblock: set current limit to max low memory address
>>
>> set limit to low wrongly.
>>
>> max_low_pfn_mapped is different from max_pfn_mapped.
>> max_low_pfn_mapped is always under 4G.
>>
>> That will memblock_alloc_nid all go under 4G.
>>
>> Revert that offending patch.
>>
>> Reported-by: Dave Hansen <dave.hansen@intel.com>
>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>
>>
> This mostly will fix the $subject issue but the regression 
> reported by Andrew [1] will surface with the revert. Its clear
> now that even though commit fixed the issue, it wasn't the fix.
> 
> Would be great if you can have a look at the thread.
> 
The patch which is now commit 457ff1d {lib/swiotlb.c: use 
memblock apis for early memory allocations} was the breaking the
boot on Andrew's machine. Now if I look back the patch, based on your
above description, I believe below hunk waS/is the culprit.

@@ -172,8 +172,9 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	/*
 	 * Get the overflow emergency buffer
 	 */
-	v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
-						PAGE_ALIGN(io_tlb_overflow));
+	v_overflow_buffer = memblock_virt_alloc_nopanic(
+						PAGE_ALIGN(io_tlb_overflow),
+						PAGE_SIZE);
 	if (!v_overflow_buffer)
 		return -ENOMEM;


Looks like 'v_overflow_buffer' must be allocated from low memory in this
case. Is that correct ?

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
