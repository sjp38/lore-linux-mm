Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC696B7CA8
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:21:35 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q33so1831777qte.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:21:35 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
Date: Thu, 06 Dec 2018 17:21:31 -0500
In-Reply-To: <20181128183531.5139-1-willy@infradead.org> (Matthew Wilcox's
	message of "Wed, 28 Nov 2018 10:35:31 -0800")
Message-ID: <x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

Matthew Wilcox <willy@infradead.org> writes:

> This custom resizing array was vulnerable to a Spectre attack (speculating
> off the end of an array to a user-controlled offset).  The XArray is
> not vulnerable to Spectre as it always masks its lookups to be within
> the bounds of the array.

I'm not a big fan of completely re-writing the code to fix this.  Isn't
the below patch sufficient?

-Jeff

diff --git a/fs/aio.c b/fs/aio.c
index 97f983592925..9402ae0b63d5 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1038,6 +1038,7 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
 	if (!table || id >= table->nr)
 		goto out;
 
+	id = array_index_nospec(index, table->nr);
 	ctx = rcu_dereference(table->table[id]);
 	if (ctx && ctx->user_id == ctx_id) {
 		if (percpu_ref_tryget_live(&ctx->users))
