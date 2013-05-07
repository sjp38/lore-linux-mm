Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6ADCC6B00D1
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:19:55 -0400 (EDT)
Subject: [RFC][PATCH 0/7] mm: Batch page reclamation under shink_page_list
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 May 2013 14:19:54 -0700
Message-Id: <20130507211954.9815F9D1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, Dave Hansen <dave@sr71.net>

These are an update of Tim Chen's earlier work:

	http://lkml.kernel.org/r/1347293960.9977.70.camel@schen9-DESK

I broke the patches up a bit more, and tried to incorporate some
changes based on some feedback from Mel and Andrew.

--

To do page reclamation in shrink_page_list function, there are
two locks taken on a page by page basis.  One is the tree lock
protecting the radix tree of the page mapping and the other is
the mapping->i_mmap_mutex protecting the mapped pages.  This set
deals only with mapping->tree_lock.

Tim managed to get 14% throughput improvement when with a workload
putting heavy pressure of page cache by reading many large mmaped
files simultaneously on a 8 socket Westmere server.

I've been testing these by running large parallel kernel compiles
on systems that are under memory pressure.  During development,
I caught quite a few races on smaller setups, and it's being
quite stable that large (160 logical CPU / 1TB) system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
