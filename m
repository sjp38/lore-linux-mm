Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9UGNXbs012174
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 12:23:33 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UHNcji061832
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 11:23:39 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UHNbSM032131
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 11:23:37 -0600
Subject: migratepage failures on reiserfs
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 10:27:04 -0800
Message-Id: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: reiserfs-devel@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

While testing hotplug memory remove, I ran into this issue. Given a
range of pages hotplug memory remove tries to migrate those pages.

migrate_pages() keeps failing to migrate pages containing pagecache
pages for reiserfs files. I noticed that reiserfs doesn't have 
->migratepage() ops. So, fallback_migrate_page() code tries to
do try_to_release_page(). try_to_release_page() fails to drop_buffers()
since b_count == 1. Here is what my debug shows:

	migrate pages failed pfn 258111/flags 3f00000000801
	bh c00000000b53f6e0 flags 110029 count 1
	
Any one know why the b_count == 1 and not getting dropped to zero ? 

Thanks,
Badari 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
