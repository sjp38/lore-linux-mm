Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA24931
	for <linux-mm@kvack.org>; Wed, 3 Jun 1998 15:40:51 -0400
Received: from localhost.phys.uu.nl (root@anx1p7.fys.ruu.nl [131.211.33.96])
	by max.fys.ruu.nl (8.8.7/8.8.7/hjm) with ESMTP id VAA08090
	for <linux-mm@kvack.org>; Wed, 3 Jun 1998 21:40:37 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.8.3/8.8.3) with SMTP id TAA06393 for <linux-mm@kvack.org>; Wed, 3 Jun 1998 19:56:05 +0200
Date: Wed, 3 Jun 1998 19:56:05 +0200 (MET DST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Bug in do_munmap (fwd)
Message-ID: <Pine.LNX.3.95.980603195556.3900B-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
Date: Sun, 31 May 1998 21:40:14 +1700 (PDT)
From: Perry Harrington <pedward@sun4.apsoft.com>
To: Rik Van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Bug in do_munmap

Rik,

 After the PTE bug post to bugtraq last week, I've been investigating
this.  There definitely appears to be a bug, where exactly, I'm unsure.
I've run the PTE killer under 2.1.95 and have confirmed that indeed
768 pages are allocated for the VMA.  munmap is called for each mapping,
however zap_page_range doesn't appear to be freeing all the pages.

 So, to summarize, I have confirmed that 768 pages are not freed, however
the code does call zap_page_range, which should free the PTEs associated
with that mapping.

I think I found the problem.  In zap_page_range:

	pgd_t * dir;
        unsigned long end = address + size;

        dir = pgd_offset(mm, address);
        flush_cache_range(mm, end - size, end);
        while (address < end) {
                zap_pmd_range(dir, address, end - address);
                address = (address + PGDIR_SIZE) & PGDIR_MASK;
                dir++;
        }

As you can see, dir is never freed.  If you look at zap_pmd_range, dir
is used as a lookup point.  dir is what's being left around after the
mmap.  The reason that this isn't a system wide memory leak is because
the pages are freed when the process is reaped. Does this sound right?

--Perry

-- 
Perry Harrington       Linux rules all OSes.    APSoft      ()
email: perry@apsoft.com 			Think Blue. /\
