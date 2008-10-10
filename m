Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9AICJb2024831
	for <linux-mm@kvack.org>; Sat, 11 Oct 2008 05:12:19 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9AIDJPg4309014
	for <linux-mm@kvack.org>; Sat, 11 Oct 2008 05:13:36 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9AIDJaO019795
	for <linux-mm@kvack.org>; Sat, 11 Oct 2008 05:13:19 +1100
Date: Fri, 10 Oct 2008 23:42:53 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081010181253.GA20796@skywalker>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 11:32:56PM +0530, Aneesh Kumar K.V wrote:
> The range_cyclic writeback mode use the address_space
> writeback_index as the start index for writeback. With
> delayed allocation we were updating writeback_index
> wrongly resulting in highly fragmented file. Number of
> extents reduced from 4000 to 27 for a 3GB file with
> the below patch.
> 
> The patch also removes the range_cont writeback mode
> added for ext4 delayed allocation. Instead we add
> two new flags in writeback_control which control
> the behaviour of write_cache_pages.
> 

Need the below update. Will send the updated patch to ext4 list.

[2.6.27-rc9-1-working@linux-review-ext]$ git diff
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a85930c..4f359f4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -960,7 +960,7 @@ int write_cache_pages(struct address_space *mapping,
                goto retry;
        }
        if (!wbc->no_index_update &&
-               (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))) {
+               (wbc->range_cyclic || (range_whole && nr_to_write > 0))) {
                mapping->writeback_index = index;
        }
        if (!wbc->no_nrwrite_update)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
