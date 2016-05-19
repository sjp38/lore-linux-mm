Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id E45CC6B025E
	for <linux-mm@kvack.org>; Thu, 19 May 2016 04:05:44 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i5so141963211ige.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:05:44 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id lc4si5642550obb.74.2016.05.19.01.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 01:05:43 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id w198so14750237oiw.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:05:43 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 19 May 2016 10:05:43 +0200
Message-ID: <CAJfpegv7N7WJkRJjGS_YRDvmgStLFz-fuxkdaVFFknOFuQwKng@mail.gmail.com>
Subject: why does page_cache_pipe_buf_confirm() need to check page->mapping?
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Abhijith Das <adas@redhat.com>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Jens,

I haven't done a great deal of research into this, but checking
page->mapping in page_cache_pipe_buf_confirm() might be bogus.

If the page is truncated *after* being spliced into the pipe, why on
earth does the buffer become invalid?

This looks to be a problem for filesystems that invalidate pages
(because the the data is possibly stale) and the pipe read returns
-ENODATA even though the data is there, it's just possibly different
from what was spliced into the pipe.  But I don't think that's a
reason for throwing away that buffer and definitely not a reason to
return an error.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
