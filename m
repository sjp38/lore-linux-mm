Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B2A936B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:28:53 -0400 (EDT)
Message-ID: <4FD9F4EB.7080108@redhat.com>
Date: Thu, 14 Jun 2012 10:27:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: bugs in page colouring code
References: <20120613152936.363396d5@cuia.bos.redhat.com> <20120614132053.GD28714@n2100.arm.linux.org.uk>
In-Reply-To: <20120614132053.GD28714@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Borislav Petkov <borislav.petkov@amd.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Nicolas Pitre <nico@linaro.org>

On 06/14/2012 09:20 AM, Russell King - ARM Linux wrote:
> On Wed, Jun 13, 2012 at 03:29:36PM -0400, Rik van Riel wrote:
>> COLOUR_ALIGN_DOWN can use the pgoff % shm_align_mask either positively
>>     or negatively, depending on the address initially found by
>>     get_unmapped_area
>>
>> static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
>>                                                unsigned long pgoff)
>> {
>>          unsigned long base = addr&  ~shm_align_mask;
>>          unsigned long off = (pgoff<<  PAGE_SHIFT)&  shm_align_mask;
>>
>>          if (base + off<= addr)
>>                  return base + off;
>>
>>          return base - off;
>> }
>
> Yes, that is bollocks code, introduced by this commit:
>
> commit 7dbaa466780a754154531b44c2086f6618cee3a8
> Author: Rob Herring<rob.herring@calxeda.com>
> Date:   Tue Nov 22 04:01:07 2011 +0100

It's not just ARM that has this bug. It appears to
be cut'n'pasted from other architectures (MIPS? SPARC?).

>> The fix would be to return an address that is a whole shm_align_mask
>> lower: (((base - shm_align_mask)&  ~shm_align_mask) + off
>
> Yes, agreed.

I will make sure the arch-independent colouring
code does that.

> This brings up the question: should a MAP_PRIVATE mapping see updates
> to the backing file made via a shared mapping and/or writing the file
> directly?  After all, a r/w MAP_PRIVATE mapping which has been CoW'd
> won't see the updates.
>
> So I'd argue that a file mapped MAP_SHARED must be mapped according to
> the colour rules, but a MAP_PRIVATE is free not to be so.

OK, fair enough.

>> Secondly, MAP_FIXED never checks for page colouring alignment.
>> I assume the cache aliasing on AMD Bulldozer is merely a performance
>> issue, and we can simply ignore page colouring for MAP_FIXED?
>> That will be easy to get right in an architecture-independent
>> implementation.
>
> There's a whole bunch of issues with MAP_FIXED, specifically address
> space overflow has been discussed previously, and resulted in this patch:
>
> [PATCH 0/6] get rid of extra check for TASK_SIZE in get_unmapped_area

Turns out, get_unmapped_area_prot (the function
that calls arch_get_unmapped_area) checks for
these overflows, so we should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
