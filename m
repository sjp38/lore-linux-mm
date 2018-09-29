Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A83E28E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 23:12:36 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id l8-v6so4576380ybk.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 20:12:36 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b189-v6si1564183ybh.41.2018.09.28.20.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 20:12:35 -0700 (PDT)
Subject: Re: [PATCH 3/4] infiniband/mm: convert to the new put_user_page()
 call
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-3-jhubbard@nvidia.com> <20180928153922.GA17076@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
Date: Fri, 28 Sep 2018 20:12:33 -0700
MIME-Version: 1.0
In-Reply-To: <20180928153922.GA17076@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On 9/28/18 8:39 AM, Jason Gunthorpe wrote:
> On Thu, Sep 27, 2018 at 10:39:47PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
[...]
>>
>> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
>> index a41792dbae1f..9430d697cb9f 100644
>> +++ b/drivers/infiniband/core/umem.c
>> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>>  		page = sg_page(sg);
>>  		if (!PageDirty(page) && umem->writable && dirty)
>>  			set_page_dirty_lock(page);
>> -		put_page(page);
>> +		put_user_page(page);
> 
> Would it make sense to have a release/put_user_pages_dirtied to absorb
> the set_page_dity pattern too? I notice in this patch there is some
> variety here, I wonder what is the right way?
> 
> Also, I'm told this code here is a big performance bottleneck when the
> number of pages becomes very long (think >> GB of memory), so having a
> future path to use some kind of batching/threading sound great.
> 

Yes. And you asked for this the first time, too. Consistent! :) Sorry for
being slow to pick it up. It looks like there are several patterns, and
we have to support both set_page_dirty() and set_page_dirty_lock(). So
the best combination looks to be adding a few variations of
release_user_pages*(), but leaving put_user_page() alone, because it's
the "do it yourself" basic one. Scatter-gather will be stuck with that.

Here's a differential patch with that, that shows a nice little cleanup in 
a couple of IB places, and as you point out, it also provides the hooks for 
performance upgrades (via batching) in the future.

Does this API look about right?

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index c7516029af33..48afec362c31 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -123,11 +123,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 {
        size_t i;
 
-       for (i = 0; i < npages; i++) {
-               if (dirty)
-                       set_page_dirty_lock(p[i]);
-               put_user_page(p[i]);
-       }
+       release_user_pages_lock(p, npages, dirty);
 
        if (mm) { /* during close after signal, mm can be NULL */
                down_write(&mm->mmap_sem);
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 3f8fd42dd7fc..c57a3a6730b6 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -40,13 +40,7 @@
 static void __qib_release_user_pages(struct page **p, size_t num_pages,
                                     int dirty)
 {
-       size_t i;
-
-       for (i = 0; i < num_pages; i++) {
-               if (dirty)
-                       set_page_dirty_lock(p[i]);
-               put_user_page(p[i]);
-       }
+       release_user_pages_lock(p, num_pages, dirty);
 }
 
 /*
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72caf803115f..b280d0181e06 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -138,6 +138,9 @@ extern int overcommit_ratio_handler(struct ctl_table *, int, void __user *,
 extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
                                    size_t *, loff_t *);
 
+int set_page_dirty(struct page *page);
+int set_page_dirty_lock(struct page *page);
+
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
 /* to align the pointer to the (next) page boundary */
@@ -949,12 +952,56 @@ static inline void put_user_page(struct page *page)
        put_page(page);
 }
 
-/* A drop-in replacement for release_pages(): */
+/* For get_user_pages*()-pinned pages, use these variants instead of
+ * release_pages():
+ */
+static inline void release_user_pages_dirty(struct page **pages,
+                                           unsigned long npages)
+{
+       while (npages) {
+               set_page_dirty(pages[npages]);
+               put_user_page(pages[npages]);
+               --npages;
+       }
+}
+
+static inline void release_user_pages_dirty_lock(struct page **pages,
+                                                unsigned long npages)
+{
+       while (npages) {
+               set_page_dirty_lock(pages[npages]);
+               put_user_page(pages[npages]);
+               --npages;
+       }
+}
+
+static inline void release_user_pages_basic(struct page **pages,
+                                           unsigned long npages)
+{
+       while (npages) {
+               put_user_page(pages[npages]);
+               --npages;
+       }
+}
+
 static inline void release_user_pages(struct page **pages,
-                                     unsigned long npages)
+                                     unsigned long npages,
+                                     bool set_dirty)
 {
-       while (npages)
-               put_user_page(pages[--npages]);
+       if (set_dirty)
+               release_user_pages_dirty(pages, npages);
+       else
+               release_user_pages_basic(pages, npages);
+}
+
+static inline void release_user_pages_lock(struct page **pages,
+                                          unsigned long npages,
+                                          bool set_dirty)
+{
+       if (set_dirty)
+               release_user_pages_dirty_lock(pages, npages);
+       else
+               release_user_pages_basic(pages, npages);
 }
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
@@ -1548,8 +1595,6 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_cleaned(struct page *page, struct address_space *mapping,
                          struct bdi_writeback *wb);
-int set_page_dirty(struct page *page);
-int set_page_dirty_lock(struct page *page);
 void __cancel_dirty_page(struct page *page);
 static inline void cancel_dirty_page(struct page *page)
 {


> Otherwise this RDMA part seems fine to me, there might be some minor
> conflicts however. I assume you want to run this through the -mm tree?
> 
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
> 

Great, thanks for the ACK.


thanks,
-- 
John Hubbard
NVIDIA
