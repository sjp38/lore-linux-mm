Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id AAA04371
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Tue, 15 Jun 1999 00:16:32 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: from google.engr.sgi.com (google.engr.sgi.com [192.48.174.30])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id AAA75778
	for <@cthulhu.engr.sgi.com:linux-mm@kvack.org>;
	Tue, 15 Jun 1999 00:16:27 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: (from kanoj@localhost) by google.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF) id AAA88552 for linux-mm@kvack.org; Tue, 15 Jun 1999 00:16:24 -0700 (PDT)
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906150716.AAA88552@google.engr.sgi.com>
Subject: filecache/swapcache questions
Date: Tue, 15 Jun 1999 00:16:24 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all.

I am trying to understand some of the swapcache/filecache code. I
have a few questions (I am sure I will have more soon), which I am
jotting down here in the hope that someone can answer them. It is
quite possible that I am reading the code wrong ...


Q1. Is it really needed to put all the swap pages in the swapper_inode
i_pages? 

Q2. shrink_mmap has code that reads:

                if (PageSwapCache(page)) {
                        if (referenced && swap_count(page->offset) != 1)
                                continue;
                        delete_from_swap_cache(page);
                        return 1;
                }

How will it be possible for a page to be in the swapcache, for its
reference count to be 1 (which has been checked just before), and
for its swap_count(page->offset) to also be 1? I can see this being
possible only if an unmap/exit path might lazily leave a anonymous
page in the swap cache, but I don't believe that happens. Ipc/shm 
pages are not candidates here, since they temporarily raise the page
reference count while swapping.

Q3. Is there some mechanism to detect io errors for swap cache pages
similar to what the PG_uptodate bit provides for filemap pages?

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
