Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 86C096B0073
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 07:33:44 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id l6so939605oag.4
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 04:33:44 -0700 (PDT)
Received: from mail-oa0-x236.google.com (mail-oa0-x236.google.com [2607:f8b0:4003:c02::236])
        by mx.google.com with ESMTPS id m10si9702426obe.66.2014.06.05.04.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 04:33:43 -0700 (PDT)
Received: by mail-oa0-f54.google.com with SMTP id j17so937650oag.13
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 04:33:43 -0700 (PDT)
Date: Thu, 05 Jun 2014 06:33:40 -0500
From: Felipe Contreras <felipe.contreras@gmail.com>
Message-ID: <53905594d284f_71f12992fc6a@nysa.notmuch>
Subject: Interactivity regression since v3.11 in mm/vmscan.c
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

Hi,

For a while I've noticed that my machine bogs down in certain
situations, usually while doing heavy I/O operations, it is not just the
I/O operations, but everything, including the graphical interface, even
the mouse pointer.

As far as I can recall this did not happen in the past.

I noticed this specially on certain operations, for example updating a
a game on Steam (to an exteranl USB 3.0 device), or copying TV episodes
to a USB memory stick (probably flash-based).

Today I decided to finally hunt down the problem, so I created a
synthetic test that basically consists on copying a bunch of files from
one drive to another (from an SSD to an external USB 3.0). This is
pretty similar to what I noticed; the graphical interface slows down.

Then I bisected the issue and it turns out that indeed it wasn't
happening in the past, it started happening in v3.11, and it was
triggered by this commit:

  e2be15f (mm: vmscan: stall page reclaim and writeback pages based on
  dirty/writepage pages encountered)

Then I went back to the latest stable version (v3.14.5), and commented
out the line I think is causing the slow down:

  if (nr_unqueued_dirty == nr_taken || nr_immediate)
	  congestion_wait(BLK_RW_ASYNC, HZ/10);

After that I don't notice the slow down any more.

Anybody has any ideas how to fix the issue properly?

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
