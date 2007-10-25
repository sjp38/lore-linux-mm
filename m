Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l9P5KUYl011679
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:20:30 -0700
Received: from rv-out-0910.google.com (rvbl15.prod.google.com [10.140.88.15])
	by zps38.corp.google.com with ESMTP id l9P5KIcm013289
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:20:30 -0700
Received: by rv-out-0910.google.com with SMTP id l15so339907rvb
        for <linux-mm@kvack.org>; Wed, 24 Oct 2007 22:20:30 -0700 (PDT)
Message-ID: <b040c32a0710242220w615be4f0kd34f86a9d9b048c5@mail.gmail.com>
Date: Wed, 24 Oct 2007 22:20:30 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
In-Reply-To: <1193263944.4039.87.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
	 <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
	 <1193256124.18417.70.camel@localhost.localdomain>
	 <1193263944.4039.87.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 10/24/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> But, I think what I'm realizing is that the free paths for shared vs.
> private are actually quite distinct.  Even more now after your patches
> abolish using and actual put_page() (and the destructors) on private
> pages losing their last mapping.
>
> I think it may make a lot of sense to have
> {alloc,free}_{private,shared}_huge_page().  It'll really help
> readability, and I _think_ it gives you a handy dandy place to add the
> different quota operations needed.

Here is my version of re-factoring hugetlb_put_quota() into
free_huge_page.  Not exactly what Dave suggested, but at least
consolidate quota credit in one place.


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 12aca8e..6513f56 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -364,7 +364,6 @@ static void truncate_hugepages(
 			++next;
 			truncate_huge_page(page);
 			unlock_page(page);
-			hugetlb_put_quota(mapping);
 			freed++;
 		}
 		huge_pagevec_release(&pvec);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8b809ec..70c58cd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -116,6 +116,9 @@
  static void free_huge_page(struct page *page)
 {
  	int nid = page_to_nid(page);
+	struct address_space *mapping;
+
+	mapping = (struct address_space *) page_private(page);

 	BUG_ON(page_count(page));
  	INIT_LIST_HEAD(&page->lru);
@@ -129,6 +132,9 @@ static void free_huge_page(struct page *page)
 		enqueue_huge_page(page);
 	}
 	spin_unlock(&hugetlb_lock);
+	if (mapping)
+		hugetlb_put_quota(mapping);
+	set_page_private(page, 0);
 }

 /*
@@ -369,6 +375,7 @@ static struct page *alloc_huge_page(

 	spin_unlock(&hugetlb_lock);
 	set_page_refcounted(page);
+	set_page_private(page, (unsigned long) vma->vm_file->f_mapping);
 	return page;

 fail:
@@ -382,6 +389,8 @@ fail:
 	if (!use_reserved_page)
  		page = alloc_buddy_huge_page(vma, addr);

+	if (page)
+		set_page_private(page, (unsigned long) vma->vm_file->f_mapping);
 	return page;
 }

@@ -788,7 +797,6 @@ retry:
  			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
 				put_page(page);
-				hugetlb_put_quota(mapping);
  				if (err == -EEXIST)
  					goto retry;
  				goto out;
@@ -822,7 +830,6 @@ out:

  backout:
 	spin_unlock(&mm->page_table_lock);
-	hugetlb_put_quota(mapping);
 	unlock_page(page);
 	put_page(page);
  	goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
