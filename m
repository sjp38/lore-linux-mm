Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE9D6B027C
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:32:12 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g12-v6so3134833lji.3
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:32:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v201sor1180741lfa.38.2018.11.05.13.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 13:32:10 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: kstrdup_quotable_cmdline and gfp flags
Message-ID: <84197642-f414-81dc-ee68-1a4c1cdea5ae@rasmusvillemoes.dk>
Date: Mon, 5 Nov 2018 22:32:07 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.cz>, Jordan Crouse <jcrouse@codeaurora.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

kstrdup_quotable_cmdline takes gfp flags and passes those on to
kstrdup_quotable, but before that it has done a kmalloc(PAGE_SIZE) with
a hard-coded GFP_KERNEL. There is one caller of kstrdup_quotable_cmdline
which passes GFP_ATOMIC, and the commit introducing that (65a3c2748e)
conveniently has this piece of history:

    v2: Use GFP_ATOMIC while holding the rcu lock per Chris Wilson

So, should the GFP_KERNEL in kstrdup_quotable_cmdline simply be changed
to use the passed-in gfp, or is there some deeper reason for the
GFP_KERNEL (in which case it doesn't really make sense to take gfp at
all...)? It came from a tree-wide GFP_TEMPORARY -> GFP_KERNEL conversion.

Rasmus
