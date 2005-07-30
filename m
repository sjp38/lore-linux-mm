Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j6UKrZxT010111
	for <linux-mm@kvack.org>; Sat, 30 Jul 2005 15:53:35 -0500
Received: from thistle-e236.americas.sgi.com (thistle-e236.americas.sgi.com [128.162.236.204])
	by flecktone.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j6UKrYDN13264255
	for <linux-mm@kvack.org>; Sat, 30 Jul 2005 15:53:35 -0500 (CDT)
Received: from lnx-holt.americas.sgi.com (lnx-holt.americas.sgi.com [128.162.233.109]) by thistle-e236.americas.sgi.com (8.12.9/SGI-server-1.8) with ESMTP id j6UKrYNi38023315 for <linux-mm@kvack.org>; Sat, 30 Jul 2005 15:53:34 -0500 (CDT)
Received: from lnx-holt.americas.sgi.com (localhost.localdomain [127.0.0.1])
	by lnx-holt.americas.sgi.com (8.13.4/8.13.4) with ESMTP id j6UKrKUr003908
	for <linux-mm@kvack.org>; Sat, 30 Jul 2005 15:53:20 -0500
Received: (from holt@localhost)
	by lnx-holt.americas.sgi.com (8.13.4/8.13.4/Submit) id j6UKrJF8003903
	for linux-mm@kvack.org; Sat, 30 Jul 2005 15:53:19 -0500
Date: Sat, 30 Jul 2005 15:53:19 -0500
From: Robin Holt <holt@sgi.com>
Subject: get_user_pages() with write=1 and force=1 gets read-only pages.
Message-ID: <20050730205319.GA1233@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am chasing a bug which I think I understand, but would like some
confirmation.

I believe I have two processes calling get_user_pages at approximately
the same time.  One is calling with write=0.  The other with write=1
and force=1.  The vma has the vm_ops->nopage set to filemap_nopage.

Both faulters get to the point in do_no_page of being ready to insert
the pte.  The first one to get the mm->page_table_lock must be the reader.
The readable pte gets inserted and results in the writer detecting the
pte and returning VM_FAULT_MINOR.

Upon return, the writer the does 'lookup_write = write && !force;'
and then calls follow_page without having the write flag set.

Am I on the right track with this?  Is the correct fix to not just pass
in the write flag untouched?  I believe the change was made by Roland
McGrath, but I don't see an email address for him.

Thanks,
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
