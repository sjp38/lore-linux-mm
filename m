Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I487sY015577
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 18 Jul 2006 00:08:07 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I487nc286928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:07 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I4866q010104
	for <linux-mm@kvack.org>; Mon, 17 Jul 2006 22:08:07 -0600
Date: Mon, 17 Jul 2006 22:08:05 -0600
From: Dave Kleikamp <shaggy@austin.ibm.com>
Message-Id: <20060718040804.11926.76333.sendpatchset@kleikamp.austin.ibm.com>
Subject: [RFC:PATCH 000/008] Tail Packing in the the Page Cache
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, Dave McCracken <dmccr@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

These patches are still a bit rough, but I wanted to post something before
my OLS presentation on Friday.

The goal of these patches is to avoid excessive internal fragmentation in
the page cache when the base page size is large.  The new function is
enabled by the option, CONFIG_FILE_TAILS, which currently depends on
CONFIG_PPC_64K_PAGES, but should eventually be available on any 64-bit
architecture.

Instead of allocating an entire page to hold the data for a smaller file
tail, we allocate a buffer from the slab cache (using malloc) and anchor it
to the address space (inode->mapping->tail).  A dummy page structure is
used to represent the tail in the page cache and lru list.

Any time the size of the file is increased, or the tail of the file is
mmapped, the tail is unpacked into a regular page.

I'm still experiencing an occasional hang with these patches.  I don't
recommend running with them, unless you are really interested in debugging.

Note: I had originally attempted to perform I/O directly on the dummy page,
but I was unable to get it working before the OLS deadline, so I simplified
things a bit and pack the data into the tail after it is initially read into
a normal page.  I expect that I can improve these patches quite a bit before
they are ready for submission.

These patches are based on linux-2.6.17.

The title of my presentation is "Efficient Use of the Page Cache with 64K
Pages" and will be held in conference room B at 11:00 on Friday, July 21st.

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
