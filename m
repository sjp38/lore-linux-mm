Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACBFB6B0580
	for <linux-mm@kvack.org>; Wed,  9 May 2018 16:02:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m4-v6so5956953pgu.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 13:02:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u31-v6sor5843867pgn.261.2018.05.09.13.02.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 13:02:36 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 0/6] Provide saturating helpers for allocation
Date: Wed,  9 May 2018 13:02:17 -0700
Message-Id: <20180509200223.22451-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

This is a stab at providing three new helpers for allocation size
calculation:

struct_size(), array_size(), and array3_size().

These are implemented on top of Rasmus's overflow checking functions. The
existing allocators are adjusted to use the more efficient overflow
checks as well.

I have left out the 8 tree-wide conversion patches of open-coded
multiplications into the new helpers, as those are largely
unchanged from v1. Everything can be seen here, though:
https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/log/?h=kspp/overflow/array_size

The question remains for what to do with the *calloc() and *_array*()
API. They could be entirely removed in favor of using the new helpers:

kcalloc(n, size, gfp)        ->  kzalloc(array_size(n, size), gfp)
kmalloc_array(n, size, gfp)  ->  kmalloc(array_size(n, size), gfp)

Changes from v1:
- use explicit overflow helpers instead of array_size() helpers.
- drop early-checks for SIZE_MAX.
- protect devm_kmalloc()-family from addition overflow.
- added missing overflow.h includes.
- fixed 0-day issues in a few treewide manual conversions

-Kees
