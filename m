Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98CB16B2064
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:12:10 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so1369489eda.3
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:12:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si83007edh.181.2018.11.20.06.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:12:09 -0800 (PST)
Date: Tue, 20 Nov 2018 15:12:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
Message-ID: <20181120141207.GK22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 17:07:15, Kirill A. Shutemov wrote:
> On Tue, Nov 20, 2018 at 02:43:23PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > filemap_map_pages takes a speculative reference to each page in the
> > range before it tries to lock that page. While this is correct it
> > also can influence page migration which will bail out when seeing
> > an elevated reference count. The faultaround code would bail on
> > seeing a locked page so we can pro-actively check the PageLocked
> > bit before page_cache_get_speculative and prevent from pointless
> > reference count churn.
> 
> Looks fine to me.

Thanks for the review.

> But please drop a line of comment in the code. As is it might be confusing
> for a reader.

This?

diff --git a/mm/filemap.c b/mm/filemap.c
index c76d6a251770..7c4e439a2e85 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2554,6 +2554,10 @@ void filemap_map_pages(struct vm_fault *vmf,
 
 		head = compound_head(page);
 
+		/*
+		 * Check the locked pages before taking a reference to not
+		 * go in the way of migration.
+		 */
 		if (PageLocked(head))
 			goto next;
 		if (!page_cache_get_speculative(head))
-- 
Michal Hocko
SUSE Labs
