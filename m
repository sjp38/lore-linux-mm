Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 193166B0102
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 20:38:25 -0400 (EDT)
Received: by pxi15 with SMTP id 15so6403348pxi.23
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:38:17 -0700 (PDT)
Message-ID: <4A93FAA5.5000001@vflare.org>
Date: Tue, 25 Aug 2009 20:22:21 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com> <4A92EBB4.1070101@vflare.org> <Pine.LNX.4.64.0908242132320.8144@sister.anvils> <4A930313.9070404@vflare.org> <Pine.LNX.4.64.0908242224530.10534@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908242224530.10534@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/25/2009 03:16 AM, Hugh Dickins wrote:
> On Tue, 25 Aug 2009, Nitin Gupta wrote:
>> On 08/25/2009 02:09 AM, Hugh Dickins wrote:
>>> On Tue, 25 Aug 2009, Nitin Gupta wrote:
>>>> On 08/24/2009 11:03 PM, Pekka Enberg wrote:
>>>>>
>>>>> What's the purpose of passing PFNs around? There's quite a lot of PFN
>>>>> to struct page conversion going on because of it. Wouldn't it make
>>>>> more sense to return (and pass) a pointer to struct page instead?
>>>>
>>>> PFNs are 32-bit on all archs
>>>
>>> Are you sure?  If it happens to be so for all machines built today,
>>> I think it can easily change tomorrow.  We consistently use unsigned long
>>> for pfn (there, now I've said that, I bet you'll find somewhere we don't!)
>>>
>>> x86_64 says MAX_PHYSMEM_BITS 46 and ia64 says MAX_PHYSMEM_BITS 50 and
>>> mm/sparse.c says
>>> unsigned long max_sparsemem_pfn = 1UL<<   (MAX_PHYSMEM_BITS-PAGE_SHIFT);
>>>
>>
>> For PFN to exceed 32-bit we need to have physical memory>  16TB (2^32 * 4KB).
>> So, maybe I can simply add a check in ramzswap module load to make sure that
>> RAM is indeed<  16TB and then safely use 32-bit for PFN?
>
> Others know much more about it, but I believe that with sparsemem you
> may be handling vast holes in physical memory: so a relatively small
> amount of physical memory might in part be mapped with gigantic pfns.
>
> So if you go that route, I think you'd rather have to refuse pages
> with oversized pfns (or refuse configurations with any oversized pfns),
> than base it upon the quantity of physical memory in the machine.
>
> Seems ugly to me, as it did to Pekka; but I can understand that you're
> very much in the business of saving memory, so doubling the size of some
> of your tables (I may be oversimplifying) would be repugnant to you.
>
> You could add a CONFIG option, rather like CONFIG_LBDAF, to switch on
> u64-sized pfns; but you'd still have to handle what happens when the
> pfn is too big to fit in u32 without that option; and if distros always
> switch the option on, to accomodate the larger machines, then there may
> have been no point to adding it.
>

Thanks for these details.

Now I understand that use of 32-bit PFN on 64-bit archs is unsafe. So,
there is no option but to include extra bits for PFNs or use struct page.

* Solution of ramzswap block device:

Use 48 bit PFNs (32 + 8) and have a compile time error to make sure that
that MAX_PHYSMEM_BITS is < 48 + PAGE_SHIFT. The ramzswap table can accommodate
48-bits without any increase in table size.

--- ramzswap_new.h	2009-08-25 20:10:38.054033804 +0530
+++ ramzswap.h	2009-08-25 20:09:28.386069100 +0530
@@ -110,9 +110,9 @@

  /* Indexed by page no. */
  struct table {
-	u32 pagenum_1;
+	u32 pagenum;
  	u16 offset;
-	u8 pagenum_2;
+	u8 count;	/* object ref count (not yet used) */
  	u8 flags;
  };


(removal for 'count' field will hurt later when we implement
memory defragmentation support).


* Solution for allocator:

Use struct page instead of PFN. This is better than always using 64-bit PFNs
since we get rid of all casts. Use of 48-bit PFNs as above will create too
much mess. However, use of struct page increases per-pool overhead by 4K on
64-bit systems. This should be okay.


Please let me know if you have any comments. I will make these changes in next
revision.

There is still some problem with memory allocator naming. Its no longer a
separate module, the symbols are not exported and its now compiled with ramzswap
block driver itself. So, I am hoping xv_malloc() does not causes any confusion
with any existing name now. It really should not cause any confustion. I would
love to retain this name for allocator.

Thanks,
Nitin




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
