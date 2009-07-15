Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 301D96B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 19:28:00 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 13so713450eye.44
        for <linux-mm@kvack.org>; Tue, 14 Jul 2009 17:02:49 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 14 Jul 2009 19:02:49 -0500
Message-ID: <983c694e0907141702t39bebefdr4024720f0a6dc4e1@mail.gmail.com>
Subject: __get_free_pages page count increment
From: omar ramirez <or.rmz1@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have been digging about __get_free_pages function, and wanted to now
why only the first page reserved with this function increments the
page count and for the other they are marked as 0.

So here it is what I'm doing, I'm reserving a chunk of pages (using
__get_free_pages) in a display driver, then I pass that through
userspace to a dsp driver to decode a video file and return the buffer
to display.

The buffer is mapped in the dsp, which also follows the get_page
approach but it goes page-by-page on the buffer, incrementing the page
count for all of the pages (so now first page count from the buffer
will be 2 <display, dsp>, but for the rest it will be 1 <dsp>).

The issue comes once those pages are unmapped from the dsp driver,
because it will do a page_cache_release on all the reserved pages
(which leave the count as it was before, first page 1 <display> and
the rest as 0).

This will throw the BUG: bad page state error because the count is
being marked as 0 for the process using that buffer.

So my question is, is it ok that the page count is NOT incremented for
all but first page of __get_free_pages?

Thanks in advance,

omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
