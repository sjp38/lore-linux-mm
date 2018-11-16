Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 365C06B08AC
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 04:14:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so10926640edd.16
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 01:14:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15-v6si2090942ejr.254.2018.11.16.01.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 01:14:10 -0800 (PST)
Date: Fri, 16 Nov 2018 10:14:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181116091409.GD14706@dhcp22.suse.cz>
References: <20181114150029.GY23419@dhcp22.suse.cz>
 <20181115051034.GK2653@MiWiFi-R3L-srv>
 <20181115073052.GA23831@dhcp22.suse.cz>
 <20181115075349.GL2653@MiWiFi-R3L-srv>
 <20181115083055.GD23831@dhcp22.suse.cz>
 <20181115131211.GP2653@MiWiFi-R3L-srv>
 <20181115131927.GT23831@dhcp22.suse.cz>
 <20181115133840.GR2653@MiWiFi-R3L-srv>
 <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116012433.GU2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com

On Fri 16-11-18 09:24:33, Baoquan He wrote:
> On 11/15/18 at 03:32pm, Michal Hocko wrote:
> > On Thu 15-11-18 21:38:40, Baoquan He wrote:
> > > On 11/15/18 at 02:19pm, Michal Hocko wrote:
> > > > On Thu 15-11-18 21:12:11, Baoquan He wrote:
> > > > > On 11/15/18 at 09:30am, Michal Hocko wrote:
> > > > [...]
> > > > > > It would be also good to find out whether this is fs specific. E.g. does
> > > > > > it make any difference if you use a different one for your stress
> > > > > > testing?
> > > > > 
> > > > > Created a ramdisk and put stress bin there, then run stress -m 200, now
> > > > > seems it's stuck in libc-2.28.so migrating. And it's still xfs. So now xfs
> > > > > is a big suspect. At bottom I paste numactl printing, you can see that it's
> > > > > the last 4G.
> > > > > 
> > > > > Seems it's trying to migrate libc-2.28.so, but stress program keeps trying to
> > > > > access and activate it.
> > > > 
> > > > Is this still with faultaround disabled? I have seen exactly same
> > > > pattern in the bug I am working on. It was ext4 though.
> > > 
> > > After a long time struggling, the last 2nd block where libc-2.28.so is
> > > located is reclaimed, now it comes to the last memory block, still
> > > stress program itself. swap migration entry has been made and trying to
> > > unmap, now it's looping there.
> > > 
> > > [  +0.004445] migrating pfn 190ff2bb0 failed 
> > > [  +0.000013] page:ffffea643fcaec00 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x0
> > > [  +0.012809] shmem_aops 
> > > [  +0.000011] name:"stress" 
> > > [  +0.002550] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
> > > [  +0.010715] raw: 01dfffffc008004e ffffea643fcaec48 ffffea643fc714c8 ffff888dfb268f48
> > > [  +0.007828] raw: 0000000000000000 0000000000000000 000000cb000000c8 ffff888e72e92000
> > > [  +0.007810] page->mem_cgroup:ffff888e72e92000
> > [...]
> > > [  +0.004455] migrating pfn 190ff2bb0 failed 
> > > [  +0.000018] page:ffffea643fcaec00 count:203 mapcount:201 mapping:ffff888dfb268f48 index:0x0
> > > [  +0.014392] shmem_aops 
> > > [  +0.000010] name:"stress" 
> > > [  +0.002565] flags: 0x1dfffffc008004e(referenced|uptodate|dirty|workingset|swapbacked)
> > > [  +0.010675] raw: 01dfffffc008004e ffffea643fcaec48 ffffea643fc714c8 ffff888dfb268f48
> > > [  +0.007819] raw: 0000000000000000 0000000000000000 000000cb000000c8 ffff888e72e92000
> > > [  +0.007808] page->mem_cgroup:ffff888e72e92000
> > 
> > OK, so this is tmpfs backed code of your stree test. This just tells us
> > that this is not fs specific. Reference count is 2 more than the map
> > count which is the expected state. So the reference count must have been
> > elevated at the time when the migration was attempted. Shmem supports
> > fault around so this might be still possible (assuming it is enabled).
> > If not we really need to dig deeper. I will think of a debugging patch.
> 
> Disabled faultaround and reboot, test again, it's looping forever in the
> last block again, on node2, stress progam itself again. The weird is
> refcount seems to have been crazy, a random number now. There must be
> something going wrong.

Could you try to apply this debugging patch on top please? It will dump
stack trace for each reference count elevation for one page that fails
to migrate after multiple passes.

diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 14d14beb1f7f..b64ebf253381 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -72,9 +72,12 @@ static inline int page_count(struct page *page)
 	return atomic_read(&compound_head(page)->_refcount);
 }
 
+struct page *page_to_track;
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_refcount, v);
+	if (page == page_to_track)
+		dump_stack();
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
 		__page_ref_set(page, v);
 }
@@ -91,6 +94,8 @@ static inline void init_page_count(struct page *page)
 static inline void page_ref_add(struct page *page, int nr)
 {
 	atomic_add(nr, &page->_refcount);
+	if (page == page_to_track)
+		dump_stack();
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, nr);
 }
@@ -105,6 +110,8 @@ static inline void page_ref_sub(struct page *page, int nr)
 static inline void page_ref_inc(struct page *page)
 {
 	atomic_inc(&page->_refcount);
+	if (page == page_to_track)
+		dump_stack();
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, 1);
 }
@@ -129,6 +136,8 @@ static inline int page_ref_inc_return(struct page *page)
 {
 	int ret = atomic_inc_return(&page->_refcount);
 
+	if (page == page_to_track)
+		dump_stack();
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
 		__page_ref_mod_and_return(page, 1, ret);
 	return ret;
@@ -156,6 +165,8 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
 {
 	int ret = atomic_add_unless(&page->_refcount, nr, u);
 
+	if (page == page_to_track)
+		dump_stack();
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
 		__page_ref_mod_unless(page, nr, ret);
 	return ret;
diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..9b2e395a3d68 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1338,6 +1338,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	return rc;
 }
 
+struct page *page_to_track;
+
 /*
  * migrate_pages - migrate the pages specified in a list, to the free pages
  *		   supplied as the target for the page migration
@@ -1375,6 +1377,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
+	page_to_track = NULL;
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
 
@@ -1417,6 +1420,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				goto out;
 			case -EAGAIN:
 				retry++;
+				if (pass > 1 && !page_to_track)
+					page_to_track = page;
 				break;
 			case MIGRATEPAGE_SUCCESS:
 				nr_succeeded++;
-- 
Michal Hocko
SUSE Labs
