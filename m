Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3D62806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 09:32:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so1255414wrd.0
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:32:49 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id l62si18107958wml.35.2017.04.20.06.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 06:32:48 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id o81so10852646wmb.0
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:32:48 -0700 (PDT)
Date: Thu, 20 Apr 2017 15:29:20 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [fuse-devel] trying to steal weird page?
Message-ID: <20170420132920.GA5214@veci.piliscsaba.szeredi.hu>
References: <CAB3-ZyT5pPc68BiQ2aC4r1608YgaN5U4H8TjddPN9jiUTE0rRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAB3-ZyT5pPc68BiQ2aC4r1608YgaN5U4H8TjddPN9jiUTE0rRg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Antonio SJ Musumeci <trapexit@spawn.link>
Cc: fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2017 at 11:30:00AM -0400, Antonio SJ Musumeci wrote:
> A user reported getting the below errors when *not* using direct_io
> but atomic_o_trunc, auto_cache, big_writes, default_permissions,
> splice_move, splice_read, and splice_write are enabled.
> 
> Any ideas?

I think this is due to the PageWaiters bit added in v4.10 by

62906027091f ("mm: add PageWaiters indicating tasks are waiting for a page bit")

That bit is harmless and probably left behind due to a race.  Following patch
should fix the warning.

Thanks,
Miklos

---
 fs/fuse/dev.c |    1 +
 1 file changed, 1 insertion(+)

--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -811,6 +811,7 @@ static int fuse_check_page(struct page *
 	       1 << PG_uptodate |
 	       1 << PG_lru |
 	       1 << PG_active |
+	       1 << PG_waiters |
 	       1 << PG_reclaim))) {
 		printk(KERN_WARNING "fuse: trying to steal weird page\n");
 		printk(KERN_WARNING "  page=%p index=%li flags=%08lx, count=%i, mapcount=%i, mapping=%p\n", page, page->index, page->flags, page_count(page), page_mapcount(page), page->mapping);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
