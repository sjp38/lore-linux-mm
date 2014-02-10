Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6F86B003A
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:21 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so6690178pab.30
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yt9si16577925pab.91.2014.02.10.12.41.16
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/8] Sort out mess in __do_fault()
Date: Mon, 10 Feb 2014 22:40:58 +0200
Message-Id: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

Current __do_fault() is awful and unmaintainable. These patches try to
sort it out by split __do_fault() into three destinct codepaths:
 - to handle read page fault;
 - to handle write page fault to private mappings;
 - to handle write page fault to shared mappings;

I also found page refcount leak in PageHWPoison() path of __do_fault().

Kirill A. Shutemov (8):
  mm, hwpoison: release page on PageHWPoison() in __do_fault()
  mm: rename __do_fault() -> do_fault()
  mm: do_fault(): extract to call vm_ops->do_fault() to separate
    function
  mm: introduce do_read_fault()
  mm: introduce do_cow_fault()
  mm: introduce do_shared_fault() and drop do_fault()
  mm: consolidate code to call vm_ops->page_mkwrite()
  mm: consolidate code to setup pte

 mm/memory.c | 394 ++++++++++++++++++++++++++++++------------------------------
 1 file changed, 194 insertions(+), 200 deletions(-)

-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
