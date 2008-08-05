Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m75LuQnO023430
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 17:56:26 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m75LuP0a178622
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 15:56:25 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m75LuPkE024081
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 15:56:25 -0600
Subject: Re: Turning on Sparsemem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4898C88E.9070006@sciatl.com>
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz>
	 <20080730093552.GD1369@brain> <4890957F.6080705@sciatl.com>
	 <4898C88E.9070006@sciatl.com>
Content-Type: text/plain
Date: Tue, 05 Aug 2008 14:56:24 -0700
Message-Id: <1217973384.10907.70.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-05 at 14:39 -0700, C Michael Sundius wrote:
> Hi Andy and Dave,
> 
> I turned on sparsemem as you described before. I am crashing in
> the mem_init() function when I try a call to pfn_to_page().
> 
> I've noticed that that macro uses the sparsemem macro 
> __pfn_to_section(pfn) and
> that intern calls __nr_to_section(nr). That finally looks at the 
> mem_section[] variable.
> well.. this returns NULL since it seems as though my mem_section[] array 
> looks
> to be not initialized correctly.
> 
> QUESTION: where does this array get initialized. I've looked through the 
> code and
> can't seem to see how that is initialized.

My first guess is that you're missing a call to sparse_init() in your
architecture-specific code.  On x86_32, we do that in paging_init(),
just before zone_sizes_init() (arch/x86/mm/init_32.c).

Before you call this, you'll also have to call memory_present(...) on
the memory that you do have.  But, you should probably already have done
that.

> recall I'm using mips32 processor, but I've looked in all the processors.
> it seems as though sparse_init() and memory present() both use 
> __nr_to_section()
> and thus would require mem_section[] to be set up already.

__nr_to_section() is special.  It takes a section number and just gives
you back the 'struct mem_section'.  It doesn't actually look into that
mem_section and make sure it is valid, it just locates the data
structure.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
