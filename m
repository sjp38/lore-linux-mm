Date: Wed, 28 May 2003 09:53:46 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: hard question re: swap cache
Message-ID: <21290000.1054133626@baldur.austin.ibm.com>
In-Reply-To: <20030527214157.31893.qmail@web41501.mail.yahoo.com>
References: <20030527214157.31893.qmail@web41501.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carl Spalletta <cspalletta@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Your question is a bit ambiguous because in kernel terms there are two
distinct cases.

A shared page, ie one mapped by mmap or shmmap is not anonymous in kernel
terms.  It has a temporary file created for the region.  A shared page in
this file is tracked through the page cache, so it's trivially found via
either page cache lookup or by pagein through file system calls.

A truly anonymous page is generally either bss space or stack, and can only
become shared through fork.  When a page of this type is unmapped, its
address in swap space is written into the page table entry.  The page is
also put into the swap cache at this time.  When the process tries to map
the page again, it uses the swap address to look first in the swap cache,
or, failing that, read it from swap space.

An additional twist to this is that pages are not unmapped for swapout on a
per-process basis in 2.5.  Page stealing is done via the active and
inactive lists, which are by physical page.  They are unmapped in all
processes at the same time by using the pte_chain mechanism.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
