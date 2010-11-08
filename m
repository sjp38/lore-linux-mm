Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 326E28D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 05:16:07 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Potential NULL pointer derefence found by static analysis tool
Date: Mon, 8 Nov 2010 09:01:25 +0100
References: <09BDD4480B142748B1A500A56F2CB8A362E32C@pgsmsx503.gar.corp.intel.com>
In-Reply-To: <09BDD4480B142748B1A500A56F2CB8A362E32C@pgsmsx503.gar.corp.intel.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201011080901.25410.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: "Chew, Chiau Ee" <chiau.ee.chew@intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 02 November 2010, Chew, Chiau Ee wrote:
> Hi Bergmann:
> 
> Using the static analysis tool (Klocwork), we found the function calls in a particular code section
> (Line 65 to 69) under /include/asm-generic/memory_model.h may potentially lead to the occurrence of
> NULL pointer dereferencing. Below are the code snippets to explain how the NULL pointer dereferencing may occur. 

Your analysis appears to be correct, but I don't know enough about this code to
understand if this is a problem. My understanding at this point is that it cannot
happen because of the way that memsections are done as long as a valid pfn is
passed into the function.

The pfn should always be valid because it comes from the kernel itself and only
very few functions call this. I have Cc'd the linux-mm mailing list for more input
on this.

	Arnd

> Kernel version: 2.6.36
> 
> 
> -> /include/asm-generic/memory_model.h Line 67: '__sec' is assigned the      
>    return value from function '__pfn_to_section'
> 
>   	Line 65-69 under /include/asm-generic/memory_model.h: 
>   	#define __pfn_to_page(pfn)                              \
>   	({      unsigned long __pfn = (pfn);                    \
>           struct mem_section *__sec = __pfn_to_section(__pfn);    \
>           __section_mem_map_addr(__sec) + __pfn;          \
>   	})
> 
> 
> -> /include/linux/mmzone.h Line1045: The return value of function  
>    '__pfn_to_section' is determined by function '__nr_to_section'
> 
> 	Line 1043-1046 under /include/linux/mmzone.h 
> 	static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> 	{
>       	return __nr_to_section(pfn_to_section_nr(pfn));
> 	}	
> 
> 
> 
> -> /include/linux/mmzone.h Line 998-999: If      
>    mem_section[SECTION_NR_TO_ROOT(nr)]is false, then function  
>    '__nr_to_section' explicitly returns a NULL value, 
>    which eventually will be the value of __sec
> 	
> 	Line 996 to 1001 under /include/linux/mmzone.h
>  	static inline struct mem_section *__nr_to_section(unsigned long nr)
>  	{
> 	        if (!mem_section[SECTION_NR_TO_ROOT(nr)])
> 	                return NULL;
> 		  return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
> 	}
> 
> -> '__sec' is being passed to function '__section_mem_map_addr' as 'section'    
>    argument at Line 68 in include/asm-generic/memory_model.h. 'section' is 
>    explicitly dereference at Line 1018 in /include/linux/mmzone.h
> 
> 	Line 65-69 under /include/asm-generic/memory_model.h:
>   	#define __pfn_to_page(pfn)                              \
>   	({      unsigned long __pfn = (pfn);                    \
>   	        struct mem_section *__sec = __pfn_to_section(__pfn);    \
>   	       __section_mem_map_addr(__sec) + __pfn;          \
>   	})
> 
> 	Line 1016-1021 under /include/linux/mmzone.h:
> 	static inline struct page *__section_mem_map_addr(struct mem_section *section)
> 	{
> 	        unsigned long map = section->section_mem_map;
> 	        map &= SECTION_MAP_MASK;
> 	        return (struct page *)map;
> 	}
> 
> 
> Thanks,
> Chiau Ee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
