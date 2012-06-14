Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 8C8D76B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:56:46 -0400 (EDT)
Message-ID: <4FD9DF79.3090206@redhat.com>
Date: Thu, 14 Jun 2012 08:56:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: bugs in page colouring code
References: <20120613152936.363396d5@cuia.bos.redhat.com> <20120614084219.GD22007@linux-sh.org>
In-Reply-To: <20120614084219.GD22007@linux-sh.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Borislav Petkov <borislav.petkov@amd.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On 06/14/2012 04:42 AM, Paul Mundt wrote:
> On Wed, Jun 13, 2012 at 03:29:36PM -0400, Rik van Riel wrote:
>> ARM&  MIPS seem to share essentially the same page colouring code, with
>> these two bugs:
>>
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
>>
>> The fix would be to return an address that is a whole shm_align_mask
>> lower: (((base - shm_align_mask)&  ~shm_align_mask) + off
>
> 'addr' in this case is already adjusted by callers of COLOUR_ALIGN_DOWN(), so
> this shouldn't be an issue, unless I'm missing something?

The problem is flipping the sign of "off".

Say you have 8 possible page colours, and the file is
being mapped at pgoff 1.

Depending on addr, you can either end up with the mmap
starting at colour 7, or at colour 1. If you have multiple
programs mapping the file, you could have one mapping starting
at colour 7, one at colour 1...

>> This fails to take into account that the same file might be mapped
>> MAP_SHARED from some programs, and MAP_PRIVATE from another.  The
>> fix could be a simple as always enforcing colour alignment when we
>> are mmapping a file (filp is non-zero).
>>
> If that combination is possible then defaulting to colour alignment seems
> reasonable. Whether that combination is reasonable or not is another matter.

The combination is definitely possible. I do not know if
it is reasonable, but it seems like an easy fix to also
enforce colouring for MAP_PRIVATE file mappings.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
