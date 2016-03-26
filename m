Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 597016B007E
	for <linux-mm@kvack.org>; Sat, 26 Mar 2016 14:50:52 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id av4so30200332igc.1
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 11:50:52 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id qt10si2208399igb.47.2016.03.26.11.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Mar 2016 11:50:51 -0700 (PDT)
Received: by mail-ig0-x22e.google.com with SMTP id l20so32022401igf.0
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 11:50:51 -0700 (PDT)
Date: Sat, 26 Mar 2016 13:50:49 -0500
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Bloat caused by unnecessary calls to compound_head()?
Message-ID: <20160326185049.GA4257@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com

Hi,

I noticed that after the recent "page-flags" patchset, there are an excessive
number of calls to compound_head() in certain places.

For example, the frequently executed mark_page_accessed() function already
starts out by calling compound_head(), but then each time it tests a page flag
afterwards, there is an extra, seemingly unnecessary, call to compound_head().
This causes a series of instructions like the following to appear no fewer than
10 times throughout the function:

ffffffff81119db4:       48 8b 53 20             mov    0x20(%rbx),%rdx
ffffffff81119db8:       48 8d 42 ff             lea    -0x1(%rdx),%rax
ffffffff81119dbc:       83 e2 01                and    $0x1,%edx
ffffffff81119dbf:       48 0f 44 c3             cmove  %rbx,%rax
ffffffff81119dc3:       48 8b 00                mov    (%rax),%rax

Part of the problem, I suppose, is that the compiler doesn't know that the pages
can't be linked more than one level deep.

Is this a known tradeoff, and have any possible solutions been considered?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
