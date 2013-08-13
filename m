Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 04DE96B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 03:05:01 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 0/3] Pin page control subsystem
Date: Tue, 13 Aug 2013 16:04:59 +0900
Message-Id: <1376377502-28207-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, k.kozlowski@samsung.com, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

!! NOTICE !!
It's totally untested patchset so please AVOID real testing.
I'd like to show just concept and want to discuss it on very early stage.
(so there isn't enough description but I guess code is very simple so
not a big problem to understand the intention).

This patchset is for solving *kernel* pinpage migration problem more
general. Now, zswap, zram and z* family, not sure upcoming what
solution are using memory don't live in harmony with VM.
(I don't remember ballon compaction but we might be able to unify
ballon compaction with this.)

VM sometime want to migrate and/or reclaim pages for CMA, memory-hotplug,
THP and so on but at the moment, it could handle only userspace pages
so if above example subsystem have pinned a some page in a range VM want
to migrate, migration is failed so above exmaple couldn't work well.

This patchset is for basic facility for the role.

patch 1 introduces a new page flags and patch 2 introduce pinpage control
subsystem. So, subsystems want to control pinpage should implement own
pinpage_xxx functions because each subsystem would have other character
so what kinds of data structure for managing pinpage information depends
on them. Otherwise, they can use general functions defined in pinpage
subsystem. patch 3 hacks migration.c so that migration is
aware of pinpage now and migrate them with pinpage subsystem.

It exposes new rule that users of pinpage control subsystem shouldn't use
struct page->flags and struct page->lru field freely because lru field
is used for migration.c and flags field is used for lock_page in pinpage
control subsystem. I think it's not a big problem because subsystem can
use other fields of the page descriptor, instead.

This patch's limitation is that it couldn't apply user space pages
although I'd REALLY REALLY like to unify them.
IOW, it couldn't handle long pin page by get_user_pages.
Basic hurdle is that how to handle nesting cases caused by that
several subsystem pin on same page with GUP but they could have 
different migrate methods. It could add rather complexity and overhead
but I'm not sure it's worth because proved culprit until now is AIO
ring pages and Gu and Benjamin have approached it with another way
so I'd like to hear their opinions.

Minchan Kim (3):
  mm: Introduce new page flag
  pinpage control subsystem
  mm: migrate pinned page

 include/linux/page-flags.h |    2 +
 include/linux/pinpage.h    |   39 +++++++++++++
 mm/Makefile                |    2 +-
 mm/compaction.c            |   26 ++++++++-
 mm/migrate.c               |   58 ++++++++++++++++---
 mm/page_alloc.c            |    1 +
 mm/pinpage.c               |  134 ++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 252 insertions(+), 10 deletions(-)
 create mode 100644 include/linux/pinpage.h
 create mode 100644 mm/pinpage.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
