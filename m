Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7A16B7CB3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:26:37 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w15so1879568qtk.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:26:37 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
	<x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
Date: Thu, 06 Dec 2018 17:26:33 -0500
In-Reply-To: <x49va46e1p0.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Thu, 06 Dec 2018 17:21:31 -0500")
Message-ID: <x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

Jeff Moyer <jmoyer@redhat.com> writes:

> Matthew Wilcox <willy@infradead.org> writes:
>
>> This custom resizing array was vulnerable to a Spectre attack (speculating
>> off the end of an array to a user-controlled offset).  The XArray is
>> not vulnerable to Spectre as it always masks its lookups to be within
>> the bounds of the array.
>
> I'm not a big fan of completely re-writing the code to fix this.  Isn't
> the below patch sufficient?

Too quick on the draw.  Here's a patch that compiles.  ;-)

Cheers,
Jeff

diff --git a/fs/aio.c b/fs/aio.c
index 97f983592925..aac9659381d2 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -45,6 +45,7 @@
 
 #include <asm/kmap_types.h>
 #include <linux/uaccess.h>
+#include <linux/nospec.h>
 
 #include "internal.h"
 
@@ -1038,6 +1039,7 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
 	if (!table || id >= table->nr)
 		goto out;
 
+	id = array_index_nospec(id, table->nr);
 	ctx = rcu_dereference(table->table[id]);
 	if (ctx && ctx->user_id == ctx_id) {
 		if (percpu_ref_tryget_live(&ctx->users))
