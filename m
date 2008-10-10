Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9AFswRM032040
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 21:24:58 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9AFsw5H917576
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 21:24:58 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9AFsv5K002348
	for <linux-mm@kvack.org>; Sat, 11 Oct 2008 02:54:58 +1100
Date: Fri, 10 Oct 2008 21:24:47 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch 4/8] mm: write_cache_pages type overflow fix
Message-ID: <20081010155447.GA14628@skywalker>
References: <20081009155039.139856823@suse.de> <20081009174822.516911376@suse.de> <20081009082336.GB6637@infradead.org> <20081010131030.GB16353@mit.edu> <20081010131325.GA16246@infradead.org> <20081010133719.GC16353@mit.edu> <1223646482.25004.13.camel@quoit> <20081010140535.GD16353@mit.edu> <20081010140829.GA7983@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010140829.GA7983@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Theodore Tso <tytso@mit.edu>, Steven Whitehouse <steve@chygwyn.com>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 10:08:29AM -0400, Christoph Hellwig wrote:
> On Fri, Oct 10, 2008 at 10:05:35AM -0400, Theodore Tso wrote:
> > 3) A version which (optionally via a flag in the wbc structure)
> > instructs write_cache_pages() to not pursue those updates.  This has
> > not been written yet.
> 
> This one sounds best to me (although we'd have to actualy see it..)

something like  the below ?

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index bd91987..7599af2 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -63,6 +63,8 @@ struct writeback_control {
 	unsigned for_writepages:1;	/* This is a writepages() call */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
 	unsigned more_io:1;		/* more io to be dispatched */
+	/* flags which control the write_cache_pages behaviour */
+	int writeback_flags;
 };
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 718efa6..c198ead 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -876,11 +876,18 @@ int write_cache_pages(struct address_space *mapping,
 	pgoff_t end;		/* Inclusive */
 	int scanned = 0;
 	int range_whole = 0;
+	int flags = wbc->writeback_flags;
+	long *nr_to_write, count;
 
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
 		wbc->encountered_congestion = 1;
 		return 0;
 	}
+	if (flags & WB_NO_NRWRITE_UPDATE) {
+		count  = wbc->nr_to_write;
+		nr_to_write = &count;
+	} else
+		nr_to_write = &wbc->nr_to_write;
 
 	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
@@ -939,7 +946,7 @@ int write_cache_pages(struct address_space *mapping,
 				unlock_page(page);
 				ret = 0;
 			}
-			if (ret || (--(wbc->nr_to_write) <= 0))
+			if (ret || (--(*nr_to_write) <= 0))
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
 				wbc->encountered_congestion = 1;
@@ -958,8 +965,11 @@ int write_cache_pages(struct address_space *mapping,
 		index = 0;
 		goto retry;
 	}
-	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
+	if ((wbc->range_cyclic ||
+			(range_whole && wbc->nr_to_write > 0)) && 
+			(flags & ~WB_NO_INDEX_UPDATE)) {
 		mapping->writeback_index = index;
+	}
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
