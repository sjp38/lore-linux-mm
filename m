Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 22DAA6B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 02:03:31 -0400 (EDT)
Date: Wed, 27 Mar 2013 09:01:42 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: page_alloc: avoid marking zones full prematurely after
 zone_reclaim()
Message-ID: <20130327060141.GA23703@longonot.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org

Hello Mel Gorman,

The patch 290d1a3ce0ec: "mm: page_alloc: avoid marking zones full 
prematurely after zone_reclaim()" from Mar 23, 2013, leads to the 
following warning:
"mm/page_alloc.c:1957 get_page_from_freelist()
	 warn: bitwise AND condition is false here"

mm/page_alloc.c
  1948                                  /*
  1949                                   * Failed to reclaim enough to meet watermark.
  1950                                   * Only mark the zone full if checking the min
  1951                                   * watermark or if we failed to reclaim just
  1952                                   * 1<<order pages or else the page allocator
  1953                                   * fastpath will prematurely mark zones full
  1954                                   * when the watermark is between the low and
  1955                                   * min watermarks.
  1956                                   */
  1957                                  if ((alloc_flags & ALLOC_WMARK_MIN) ||
                                                           ^^^^^^^^^^^^^^^
This is zero.

  1958                                      ret == ZONE_RECLAIM_SOME)
  1959                                          goto this_zone_full;

[snip]

  2333  static inline int
  2334  gfp_to_alloc_flags(gfp_t gfp_mask)
  2335  {
  2336          int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
                                  ^^^^^^^^^^^^^^^
  2337          const gfp_t wait = gfp_mask & __GFP_WAIT;

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
