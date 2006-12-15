Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBFHvpKa006346
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 12:57:51 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBFHvp0D509922
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 10:57:51 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBFHvoKd018000
	for <linux-mm@kvack.org>; Fri, 15 Dec 2006 10:57:51 -0700
Subject: Re: [PATCH] Fix sparsemem on Cell
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200612151822.23764.mb@bu3sch.de>
References: <20061215165335.61D9F775@localhost.localdomain>
	 <200612151822.23764.mb@bu3sch.de>
Content-Type: text/plain
Date: Fri, 15 Dec 2006 09:57:50 -0800
Message-Id: <1166205470.8105.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Buesch <mb@bu3sch.de>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, apw@shadowen.org, mkravetz@us.ibm.com, hch@infradead.org, jk@ozlabs.org, linux-kernel@vger.kernel.org, akpm@osdl.org, paulus@samba.org, benh@kernel.crashing.org, gone@us.ibm.com, cbe-oss-dev@ozlabs.org, naveen.b.s@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 2006-12-15 at 18:22 +0100, Michael Buesch wrote:
> On Friday 15 December 2006 17:53, Dave Hansen wrote:
> >  lxc-dave/init/main.c     |    4 ++++
> >  lxc-dave/mm/page_alloc.c |   28 +++++++++++++++++++++++++---
> >  2 files changed, 29 insertions(+), 3 deletions(-)
> >
> > diff -puN init/main.c~sparsemem-fix init/main.c
> > --- lxc/init/main.c~sparsemem-fix	2006-12-15 08:49:53.000000000 -0800
> > +++ lxc-dave/init/main.c	2006-12-15 08:49:53.000000000 -0800
> > @@ -770,6 +770,10 @@ static int init(void * unused)
> >  	free_initmem();
> >  	unlock_kernel();
> >  	mark_rodata_ro();
> > +	/*
> > +	 * Memory hotplug requires that this system_state transition
> > +	 * happer after free_initmem().  (see memmap_init_zone())
> 
> s/happer/happens/
> 
> Other than that, can't this possibly race and crash here?
> I mean, it's not a big race window, but it can happen, no?

That's a good point.  Nice eye.

There are three routes in here: boot-time init, an ACPI call, and a
write to a sysfs file.  Bootmem is taken care of.  The write to a sysfs
file can't happen yet because userspace isn't up.

The only question would be about ACPI.  I _guess_ an ACPI event could
come in at any time, and could hit this race window.  

One other thought I had was to add an argument to memmap_init_zone() to
indicate that the memory being fed to it was contiguous and did not need
the validation checks.

Anybody have thoughts on that?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
