Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7766B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:25:32 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so84901962pfn.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:25:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id tg6si2603962pab.0.2016.01.25.09.25.31
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 09:25:31 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/3] Fixes for vm_insert_pfn_prot()
Date: Mon, 25 Jan 2016 12:25:14 -0500
Message-Id: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

Commit 1745cbc5d0 recently added vm_insert_pfn_prot().  Unfortunately,
it doesn't actually work on x86 with PAT enabled (which is basically
all machines, so I don't know if anyone actually tested it).  Also,
vm_insert_pfn_prot() continues with a couple of old-school traditions,
of taking an unsigned long instead of a pfn_t, and returning an errno
that then has to be translated in the fault handler.

I was looking at adding a somewhat similar function for DAX, so this
patchset includes changing DAX to use Andy's interface.  I'd like to see
at least the first two patches go into Ingo's tree.  The third patch can
find its way into the -mm tree later to stay with the other DAX patches.

Matthew Wilcox (3):
  x86: Honour passed pgprot in track_pfn_insert() and track_pfn_remap()
  mm: Convert vm_insert_pfn_prot to vmf_insert_pfn_prot
  dax: Handle write faults more efficiently

 arch/x86/entry/vdso/vma.c |  6 ++--
 arch/x86/mm/pat.c         |  4 +--
 fs/dax.c                  | 73 ++++++++++++++++++++++++++++++++++-------------
 include/linux/mm.h        |  4 +--
 mm/memory.c               | 31 +++++++++++---------
 5 files changed, 78 insertions(+), 40 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
