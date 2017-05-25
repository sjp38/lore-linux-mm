Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14CA76B02B4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 11:42:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j28so232502738pfk.14
        for <linux-mm@kvack.org>; Thu, 25 May 2017 08:42:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z20si27664195pfi.56.2017.05.25.08.42.26
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 08:42:27 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 0/3] mm: kmemleak: Improve vmalloc() false positives for thread stack allocation
Date: Thu, 25 May 2017 16:42:14 +0100
Message-Id: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,

This is a follow up from [1] (mm: kmemleak: Treat vm_struct as
alternative reference to vmalloc'ed objects).

The first two patches are just clean-up and refactoring. The third
introduces the kmemleak_vmalloc() API which allows a vmalloc() caller to
keep either the returned pointer or a pointer to vm_struct as a
reference (see the patch description for the implementation details).
The false positives were noticed with alloc_thread_stack_node(),
free_thread_stack() and CONFIG_VMAP_STACK where a per-CPU array is used
to cache the freed thread stacks as vm_struct pointers.

Changes since v1:

- Split the patch into three for easier review
- Only call update_refs() if !color_gray() on the found object, it
  avoids an unnecessary function call

[1] http://lkml.kernel.org/r/1495474514-24425-1-git-send-email-catalin.marinas@arm.com

Catalin Marinas (3):
  mm: kmemleak: Slightly reduce the size of some structures on 64-bit
    architectures
  mm: kmemleak: Factor object reference updating out of scan_block()
  mm: kmemleak: Treat vm_struct as alternative reference to vmalloc'ed
    objects

 Documentation/dev-tools/kmemleak.rst |   1 +
 include/linux/kmemleak.h             |   7 ++
 mm/kmemleak.c                        | 136 +++++++++++++++++++++++++++++------
 mm/vmalloc.c                         |   7 +-
 4 files changed, 123 insertions(+), 28 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
