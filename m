Message-Id: <200603091214.k29CE0g20029@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [patch] hugetlb strict commit accounting
Date: Thu, 9 Mar 2006 04:14:01 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote on Thursday, March 09, 2006 4:02 AM
> David Gibson wrote on Thursday, March 09, 2006 3:27 AM
> > Again, there are no changes to the fault handler.  Including the
> > promised changes which would mean my instantiation serialization path
> > isn't necessary ;-).
> 
> This is the major portion that I omitted in the first patch and is the
> real kicker that fulfills the promise of guaranteed available hugetlb
> page for shared mapping.

Take a look at the following snippets of earlier patch:  in
hugetlb_reserve_pages(), region_chg() calculates an estimate how many
pages is needed, then calls to hugetlb_acct_memory() to make sure there
are enough pages available, then another call to region_add to confirm
the reservation.  It looks OK to me.


+int hugetlb_acct_memory(long delta)
+{
+	atomic_add(delta, &resv_huge_pages);
+	if (delta > 0 && atomic_read(&resv_huge_pages) >
+			VMACCTPG(hugetlb_total_pages())) {
+		atomic_add(-delta, &resv_huge_pages);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static int hugetlb_reserve_pages(struct inode *inode, int from, int to)
+{
+	int ret, chg;
+
+	chg = region_chg(&inode->i_mapping->private_list, from, to);
+	if (chg < 0)
+		return chg;
+	ret = hugetlb_acct_memory(chg);
+	if (ret < 0)
+		return ret;
+	region_add(&inode->i_mapping->private_list, from, to);
+	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
