Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3A7236B0072
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:12:38 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so4700654eaa.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 12:12:36 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 26 Nov 2012 12:12:16 -0800
Message-ID: <CALCETrW=0gQMBW=nLKCWS-O7H5q6zYFCbFGOcC2PTS668=Z_NA@mail.gmail.com>
Subject: mmap_sem contention issues
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

I'm having serious latency problems due to mmap_sem contention.  I
have a real-time thread that has (soft) page faults on locked pages,
and it blocks for multiple milliseconds on
(call_rwsem_down_read_failed do_page_fault page_fault).  Can this be
fixed?

Some ideas:

1. Drop mmap_sem during the filesystem part of mmap and munmap.
(MAP_POPULATE in particular is a disaster -- using it will easily
increase latency from a few milliseconds to a respectable fraction of
a second.)

2. Come up with some way to lock specific vm_area_structs for read
access without taking mmap_sem at all.  This looks unpleasant with the
current rbtree structure -- something like a radix tree might work
much better if the nodes were to contain their own locks.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
