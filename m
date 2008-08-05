Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m75MJjV4014437
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 18:19:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75MJjUw220778
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 18:19:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75MJjOc028847
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 18:19:45 -0400
Subject: Re: Turning on Sparsemem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4898CE71.60709@sciatl.com>
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz>
	 <20080730093552.GD1369@brain> <4890957F.6080705@sciatl.com>
	 <4898C88E.9070006@sciatl.com> <1217973384.10907.70.camel@nimitz>
	 <4898CE71.60709@sciatl.com>
Content-Type: text/plain
Date: Tue, 05 Aug 2008 15:19:38 -0700
Message-Id: <1217974778.10907.82.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-05 at 15:04 -0700, C Michael Sundius wrote:
> still that code is strange to me:
> 
> -------------code
> static inline struct mem_section *__nr_to_section(unsigned long nr)
> {
>         if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>                 return NULL;
>         return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
> }
> 
> --------------
> 
> on the first line of the function above, what does it mean "if not 
> <struct>"?  seems that returns true if
> the contents of that struct is "0"... but either way, doesn't that have 
> to be initialized to something before
> it is called from memory_present()?

Yeah, this is confusing code.  The goal here was to not have any #ifdefs
for the normal vs. extreme cases.  In the !EXTREME case, the
mem_section[] array is statically allocated and that first check gets
optimized out completely.  We check for it, but the compiler kills that
check.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
