Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31EB56B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 09:51:06 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d4-v6so15282492plr.17
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 06:51:06 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40106.outbound.protection.outlook.com. [40.107.4.106])
        by mx.google.com with ESMTPS id g28-v6si181784plj.307.2018.06.01.06.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jun 2018 06:51:04 -0700 (PDT)
In-Reply-To: 
From: Peter Rosin <peda@axentia.se>
Subject: Re: [PATCH v3 00/16] Provide saturating helpers for allocation
Message-ID: <0634bebc-e16d-ed40-ee26-5401e4bc7b50@axentia.se>
Date: Fri, 1 Jun 2018 15:50:57 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Kees Cook wrote:
> This is a stab at providing three new helpers for allocation size
> calculation:
> 
> struct_size(), array_size(), and array3_size().
> 
> These are implemented on top of Rasmus's overflow checking functions. The
> existing allocators are adjusted to use the more efficient overflow
> checks as well.
> 
> While the tree-wide conversions continue to be largely unchanged,
> I've updated their commit logs a bit with some more details on
> rationale and options. Notably, while there are NO plans to replace
> kmalloc_array() and kcalloc() with kmalloc(array_size(...),...) and
> kzalloc(array_size(...),...), the treewide conversions only add the
> new helpers, as making the ..._array() and ...calloc() conversions
> balloons the Coccinelle script terribly (I haven't found a way to
> make the replacement function name depend on the matched regular expression).
> So, while nothing does:
>     kmalloc_array(a, b, ...) -> kmalloc(array_size(a, b), ...)
> the treewide changes DO perform changes like this:
>     kmalloc(a * b, ...) -> kmalloc(array_size(a, b), ...)
> 
> It should also be noted that the treewide changes overlap with a few
> recently reported "real" overflows, so these aren't theoretical fixes.
> 
> At the very least, I'd like to get the helpers and self-test landed in
> the v4.18 merge window (coming right up!) since those are relatively
> self-contained. If the treewide changes need adjustment we've got,
> in theory, through the end of -rc2 to land those.

In some places you make an effort to have the count as the first
argument, e.g. in "treewide: Use array_size() for kmalloc()-family"

-	kbuf = kmalloc(sizeof(*kbuf) * maxevents, GFP_KERNEL);
+	kbuf = kmalloc(array_size(maxevents, sizeof(*kbuf)), GFP_KERNEL);

which is reordered, and from the same patch

-	mapping->bitmaps = kzalloc(extensions * sizeof(unsigned long *),
-				GFP_KERNEL);
+	mapping->bitmaps = kzalloc(array_size(extensions, sizeof(unsigned long *)),
+				   GFP_KERNEL);

which is not reordered. That is all fine by me.

But then, in "treewide: Use array_size() for devm_*alloc()-like, leftovers"
this reordering thing is not happening, e.g.

 	values = devm_kzalloc(&pdev->dev,
-			      sizeof(*mux->data.values) * mux->data.n_values,
+			      array_size(sizeof(*mux->data.values), mux->data.n_values),
 			      GFP_KERNEL);

Also, the above shows two of numerous examples of the tools breaking the
80 column "rule", even though the surrounding code makes decent effort to
uphold it.

I can see why these things happen, but they are annoying.

Cheers,
Peter
