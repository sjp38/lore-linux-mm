Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08A8D6B0003
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:07:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t10-v6so13987310plh.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 19:07:37 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f39-v6si3249135plb.149.2018.10.21.19.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 19:07:36 -0700 (PDT)
Date: Mon, 22 Oct 2018 16:47:00 +0800
From: Yi Zhang <yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Message-ID: <20181022084659.GA84523@tiger-server>
References: <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
 <fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com>
 <20180920224953.GA53363@tiger-server>
 <CAPcyv4g6OS=_uSjJenn5WVmpx7zCRCbzJaBr_m0Bq=qyEyVagg@mail.gmail.com>
 <20180921224739.GA33892@tiger-server>
 <c8ad8ed7-ca8c-4dd7-819b-8d9c856fbe04@redhat.com>
 <CAPcyv4j9K-wkq8oK-8_twWViKhyGSHD7cOE5UoRN-09xKXPq7A@mail.gmail.com>
 <159bb198-a4a1-0fee-bf57-24c3c28788bd@redhat.com>
 <20181019123348.04ee7dd8@gnomeregan.cam.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
In-Reply-To: <20181019123348.04ee7dd8@gnomeregan.cam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Barret Rhoden <brho@google.com>
Cc: David Hildenbrand <david@redhat.com>, Dan Williams <dan.j.williams@intel.com>, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On 2018-10-19 at 12:33:48 -0400, Barret Rhoden wrote:
> On 2018-09-21 at 21:29 David Hildenbrand <david@redhat.com> wrote:
> > On 21/09/2018 20:17, Dan Williams wrote:
> > > On Fri, Sep 21, 2018 at 7:24 AM David Hildenbrand <david@redhat.com> wrote:
> > > [..]  
> > >>> Remove the PageReserved flag sounds more reasonable.
> > >>> And Could we still have a flag to identify it is a device private memory, or
> > >>> where these pages coming from?  
> > >>
> > >> We could use a page type for that or what you proposed. (as I said, we
> > >> might have to change hibernation code to skip the pages once we drop the
> > >> reserved flag).  
> > > 
> > > I think it would be reasonable to reject all ZONE_DEVICE pages in
> > > saveable_page().
> > >   
> > 
> > Indeed, that sounds like the easiest solution - guess that answer was
> > too easy for me to figure out :) .
> > 
> 
> Just to follow-up, is the plan to clear PageReserved for nvdimm pages
> instead of the approach taken in this patch set?  Or should we special
> case nvdimm/dax pages in kvm_is_reserved_pfn()?
Yes, we are going to remove the PageReserved flag for nvdimm pages.
Added Alex, attached the patch-set.
> 
> Thanks,
> 
> Barret
> 
> 
> 

--cWoXeonUoKmBZSoM
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <alexander.h.duyck@linux.intel.com>
X-Original-To: yi.z.zhang@linux.intel.com
Delivered-To: yi.z.zhang@linux.intel.com
Received: from orsmga001.jf.intel.com (orsmga001.jf.intel.com [10.7.209.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by linux.intel.com (Postfix) with ESMTPS id DEBC8580430;
	Wed, 17 Oct 2018 16:54:31 -0700 (PDT)
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.54,393,1534834800";
   d="scan'208";a="100366643"
Received: from ahduyck-mobl.amr.corp.intel.com (HELO localhost.localdomain) ([10.7.198.154])
  by orsmga001.jf.intel.com with ESMTP; 17 Oct 2018 16:54:31 -0700
Subject: [mm PATCH v4 5/6] mm: Add reserved flag setting to set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
 alexander.h.duyck@linux.intel.com, linux-kernel@vger.kernel.org,
 willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com,
 khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz,
 sparclinux@vger.kernel.org, dan.j.williams@intel.com,
 ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org,
 kirill.shutemov@linux.intel.com
Date: Wed, 17 Oct 2018 16:54:31 -0700
Message-ID: <20181017235431.17213.11512.stgit@localhost.localdomain>
In-Reply-To: <20181017235043.17213.92459.stgit@localhost.localdomain>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

This patch modifies the set_page_links function to include the setting of
the reserved flag via a simple AND and OR operation. The motivation for
this is the fact that the existing __set_bit call still seems to have
effects on performance as replacing the call with the AND and OR can reduce
initialization time.

Looking over the assembly code before and after the change the main
difference between the two is that the reserved bit is stored in a value
that is generated outside of the main initialization loop and is then
written with the other flags field values in one write to the page->flags
value. Previously the generated value was written and then then a btsq
instruction was issued.

On my x86_64 test system with 3TB of persistent memory per node I saw the
persistent memory initialization time on average drop from 23.49s to
19.12s per node.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/mm.h |    9 ++++++++-
 mm/page_alloc.c    |   29 +++++++++++++++++++----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e2c9631af05..14d06d7d2986 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1171,11 +1171,18 @@ static inline void set_page_node(struct page *page, unsigned long node)
 	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
 }
 
+static inline void set_page_reserved(struct page *page, bool reserved)
+{
+	page->flags &= ~(1ul << PG_reserved);
+	page->flags |= (unsigned long)(!!reserved) << PG_reserved;
+}
+
 static inline void set_page_links(struct page *page, enum zone_type zone,
-	unsigned long node, unsigned long pfn)
+	unsigned long node, unsigned long pfn, bool reserved)
 {
 	set_page_zone(page, zone);
 	set_page_node(page, node);
+	set_page_reserved(page, reserved);
 #ifdef SECTION_IN_PAGE_FLAGS
 	set_page_section(page, pfn_to_section_nr(pfn));
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a0b81e0bef03..e7fee7a5f8a3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1179,7 +1179,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
 	mm_zero_struct_page(page);
-	set_page_links(page, zone, nid, pfn);
+	set_page_links(page, zone, nid, pfn, false);
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
@@ -1195,7 +1195,8 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 static void __meminit __init_pageblock(unsigned long start_pfn,
 				       unsigned long nr_pages,
 				       unsigned long zone, int nid,
-				       struct dev_pagemap *pgmap)
+				       struct dev_pagemap *pgmap,
+				       bool is_reserved)
 {
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	struct page *start_page = pfn_to_page(start_pfn);
@@ -1231,19 +1232,16 @@ static void __meminit __init_pageblock(unsigned long start_pfn,
 		 * call because of the fact that the pfn number is used to
 		 * get the section_nr and this function should not be
 		 * spanning more than a single section.
+		 *
+		 * We can use a non-atomic operation for setting the
+		 * PG_reserved flag as we are still initializing the pages.
 		 */
-		set_page_links(page, zone, nid, start_pfn);
+		set_page_links(page, zone, nid, start_pfn, is_reserved);
 		init_page_count(page);
 		page_mapcount_reset(page);
 		page_cpupid_reset_last(page);
 
 		/*
-		 * We can use the non-atomic __set_bit operation for setting
-		 * the flag as we are still initializing the pages.
-		 */
-		__SetPageReserved(page);
-
-		/*
 		 * ZONE_DEVICE pages union ->lru with a ->pgmap back
 		 * pointer and hmm_data.  It is a bug if a ZONE_DEVICE
 		 * page is ever freed or placed on a driver-private list.
@@ -5612,7 +5610,18 @@ static void __meminit __memmap_init_hotplug(unsigned long size, int nid,
 		pfn = max(ALIGN_DOWN(pfn - 1, pageblock_nr_pages), start_pfn);
 		stride -= pfn;
 
-		__init_pageblock(pfn, stride, zone, nid, pgmap);
+		/*
+		 * The last argument of __init_pageblock is a boolean
+		 * value indicating if the page will be marked as reserved.
+		 *
+		 * Mark page reserved as it will need to wait for onlining
+		 * phase for it to be fully associated with a zone.
+		 *
+		 * Under certain circumstances ZONE_DEVICE pages may not
+		 * need to be marked as reserved, however there is still
+		 * code that is depending on this being set for now.
+		 */
+		__init_pageblock(pfn, stride, zone, nid, pgmap, true);
 
 		cond_resched();
 	}


--cWoXeonUoKmBZSoM--
