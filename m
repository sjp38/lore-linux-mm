Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id EF6BB6B00B5
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 11:46:22 -0500 (EST)
Received: by eekc41 with SMTP id c41so15085500eek.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 08:46:21 -0800 (PST)
Message-ID: <4EFC995A.5090904@monstr.eu>
Date: Thu, 29 Dec 2011 17:46:18 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
MIME-Version: 1.0
Subject: Re: memblock and bootmem problems if start + size = 4GB
References: <4EEF42F5.7040002@monstr.eu> <20111219162835.GA24519@google.com> <4EF05316.5050803@monstr.eu> <20111229155836.GB3516@google.com>
In-Reply-To: <20111229155836.GB3516@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Tejun Heo wrote:
> Hello,
> 
> On Tue, Dec 20, 2011 at 10:19:18AM +0100, Michal Simek wrote:
>>> Yeah, that's an inherent problem in using [) ranges but I think
>>> chopping off the last page probably is simpler and more robust
>>> solution.  Currently, memblock_add_region() would simply ignore if
>>> address range overflows but making it just ignore the last page is
>>> several lines of addition.  Wouldn't that be effective enough while
>>> staying very simple?
>> The main problem is with PFN_DOWN/UP macros and it is in __init section.
>> The result will be definitely u32 type (for 32bit archs) anyway and seems to me
>> better solution than ignoring the last page.
> 
> Other than being able to use one more 4k page, is there any other
> benefit? Maybe others had different experiences but in my exprience
> trying to extend range coverages - be it stack top/end pointers,
> address ranges or whatnot - using [] ranges or special flag usually
> ended up adding complexity while adding almost nothing tangible.

First of all I don't like to use your term "extend range coverages".
We don't want to extend any ranges - we just wanted to place memory to the end
of address space and be able to work with. It is limitation which should be fixed somehow.
And I would expect that PFN_XX(base + size) will be in u32 range.

Probably the best solution will be to use PFN macro in one place and do not covert
addresses in common code.

+ change parameters in bootmem code because some arch do
free_bootmem_node(..., PFN_PHYS(), ...)
and
reserve_bootmem_node(..., PFN_PHYS(), ...)

and then in that functions(free/reseve_bootmem_code) are used PFN_DOWN/PFN_UP macros.
If alignment is handled by architecture code (which I believe is) then should be possible to change parameters.

For example:
void __init free_bootmem_node(pg_data_t *pgdat, unsigned long start_pfn,
			      unsigned long end_pfn)

int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long start_pfn,
				 unsigned long end_pfn, int flags)

Is there any reason to use use physical addresses instead of pfns in bootmem code?

 >  On
> extreme cases, people even carry separate valid flag to use %NULL as
> valid address, which is pretty silly, IMHO.  So, unless there's some
> benefit that I'm missing, I still think it's an overkill.  It's more
> complex and difficult to test and verify.  Why bother for a single
> page?

Where do you think this page should be placed? In common code or in architecture memory
code where one page from the top of 4G should be subtract?

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
