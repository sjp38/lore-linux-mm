Received: from flint.arm.linux.org.uk ([3ffe:8260:2002:1:201:2ff:fe14:8fad])
	by caramon.arm.linux.org.uk with asmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.04)
	id 17Y75D-0005LO-00
	for linux-mm@kvack.org; Fri, 26 Jul 2002 16:32:47 +0100
Received: from rmk by flint.arm.linux.org.uk with local (Exim 4.04)
	id 17Y75C-000640-00
	for linux-mm@kvack.org; Fri, 26 Jul 2002 16:32:46 +0100
Date: Fri, 26 Jul 2002 16:32:46 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: ARM: page tables, caching, etc
Message-ID: <20020726163246.G19802@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been thinking about ARM page tables and cache stuff for 2.5...

On ARM, our caches aren't coherent with TLB fetches.  Currently, we
handle this by writing back the cache line, and draining the write
buffer when we write to a PTE in set_pte.

I'd like to use pte_offset_map()/pte_offset_map_nested() to map user
space page tables uncached, and get rid of the cache handling within
set_pte().

However, kernel page tables can't currently be sanely remapped, and
set_pte() is also used to on kernel page tables.  This means that
set_pte() would have to retain it's cache handling, unless...

What if set_pte_kernel() was introduced to replace set_pte() for
kernel page tables?  ARM could have the extra cache maintainence for
set_pte_kernel() and remove it from set_pte().  Other architectures
where this is not an issue could just do the following:

#define set_pte_kernel set_pte

and ignore the issue.  I'll be preparing some code today to try to
gauge if this is going to be a worthwhile improvement for ARM.  If
anyone has any strong objections to this, I'd prefer to know now. 8)

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
