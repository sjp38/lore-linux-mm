Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8CHIfRP031294
	for <linux-mm@kvack.org>; Tue, 12 Sep 2006 13:18:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8CHIbUN054306
	for <linux-mm@kvack.org>; Tue, 12 Sep 2006 13:18:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8CHIbT6010118
	for <linux-mm@kvack.org>; Tue, 12 Sep 2006 13:18:37 -0400
Subject: Re: [RFC] Could we get rid of zone_table?
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0609111714320.7466@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609111714320.7466@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Sep 2006 10:18:32 -0700
Message-Id: <1158081512.9141.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-09-11 at 17:17 -0700, Christoph Lameter wrote:
> I think the only case where we cannot encode the node number
> are the early 32 bit NUMA systems? In that case one would only
> need an array that maps the sections to the corresponding pgdat
> structure and would then get to the zone from there. Dave, could
> you add something like that to sparse.c? 

It can certainly be done.  However, I'd rather keep it out of the actual
struct mem_section, mostly because anything we do will be for a
relatively rare, and relatively obsolete set of platforms.  

Any new structure (or any mem_section additions) will just shift the
exact same work that we're doing today with zone_table[] somewhere else.
The impact into page_alloc.c is also pretty minimal.  It is a single
#ifdef, over a structure and a single function, right?

If you really want to get stuff out of page_alloc.c, I guess you could
make a zone_table.c or something.  Also, if you want to make
FLAGS_HAS_NODE a bit simpler, perhaps we can just make it a Kconfig
option dependent on NUMA && X86.  I wouldn't have a problem with it
being unconditionally enabled there.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
