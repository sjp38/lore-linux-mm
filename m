From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v5 0/2] Updating ctime and mtime for memory-mapped files
Date: Thu, 17 Jan 2008 03:57:44 +0300
Message-Id: <12005314662518-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

This is the fifth version of my solution for the bug #2645:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

New since the previous version:

1) the case of retouching an already-dirty page pointed out
   by Miklos Szeredi has been correctly addressed;

2) a few cosmetic changes according to the latest feedback;

3) fixed the error of calling a possibly sleeping function
   from an atomic context.

The design for the first item above was suggested by Peter Zijlstra:

> It would require scanning the PTEs and marking them read-only again on
> MS_ASYNC, and some more logic in set_page_dirty() because that currently
> bails out early if the page in question is already dirty.

Miklos' test program now produces the following output for
the repeated calls to msync() with the MS_ASYNC flag:

debian:~/miklos# ./miklos_test file
begin   1200529196      1200529196      1200528798
write   1200529197      1200529197      1200528798
mmap    1200529197      1200529197      1200529198
b       1200529197      1200529197      1200529198
msync b 1200529199      1200529199      1200529198
c       1200529199      1200529199      1200529198
msync c 1200529201      1200529201      1200529198
d       1200529201      1200529201      1200529198
munmap  1200529201      1200529201      1200529198
close   1200529201      1200529201      1200529198
sync    1200529204      1200529204      1200529198
debian:~/miklos#

Miklos' test program can be found using the following link:

http://lkml.org/lkml/2008/1/14/104

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
