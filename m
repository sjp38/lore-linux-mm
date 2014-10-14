Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 786026B006C
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:59:55 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so7474625pdj.13
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:59:55 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id hh5si4219864pbc.151.2014.10.14.04.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 14 Oct 2014 04:59:54 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDF008XWNZR2110@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 14 Oct 2014 20:59:51 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [RFC PATCH 0/9] mm/zbud: support highmem pages
Date: Tue, 14 Oct 2014 20:59:19 +0900
Message-id: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>
Cc: Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

zbud is a memory allocator for storing compressed data pages. It keeps
two data objects of arbitrary size on a single page. This simple design
provides very deterministic behavior on reclamation, which is one of
reasons why zswap selected zbud as a default allocator over zsmalloc.

Unlike zsmalloc, however, zbud does not support highmem. This is
problomatic especially on 32-bit machines having relatively small
lowmem. Compressing anonymous pages from highmem and storing them into
lowmem could eat up lowmem spaces.

This limitation is due to the fact that zbud manages its internal data
structures on zbud_header which is kept in the head of zbud_page. For
example, zbud_pages are tracked by several lists and have some status
information, which are being referenced at any time by the kernel. Thus,
zbud_pages should be allocated on a memory region directly mapped,
lowmem.

After some digging out, I found that internal data structures of zbud
can be kept in the struct page, the same way as zsmalloc does. So, this
series moves out all fields in zbud_header to struct page. Though it
alters quite a lot, it does not add any functional differences except
highmem support. I am afraid that this kind of modification abusing
several fields in struct page would be ok.

Heesub Shin (9):
  mm/zbud: tidy up a bit
  mm/zbud: remove buddied list from zbud_pool
  mm/zbud: remove lru from zbud_header
  mm/zbud: remove first|last_chunks from zbud_header
  mm/zbud: encode zbud handle using struct page
  mm/zbud: remove list_head for buddied list from zbud_header
  mm/zbud: drop zbud_header
  mm/zbud: allow clients to use highmem pages
  mm/zswap: use highmem pages for compressed pool

 mm/zbud.c  | 244 ++++++++++++++++++++++++++++++-------------------------------
 mm/zswap.c |   4 +-
 2 files changed, 121 insertions(+), 127 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
