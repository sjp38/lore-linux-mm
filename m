Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E439D6B0005
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:33:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 33-v6so1375931plf.19
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 07:33:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 5-v6si1551296pfx.61.2018.07.26.07.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 07:33:57 -0700 (PDT)
Date: Thu, 26 Jul 2018 07:33:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180726143353.GA27612@bombadil.infradead.org>
References: <000000000000d624c605705e9010@google.com>
 <20180709143610.GD2662@bombadil.infradead.org>
 <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
 <20180723140150.GA31843@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org>
 <alpine.LSU.2.11.1807231531240.2545@eggly.anvils>
 <20180723225454.GC18236@bombadil.infradead.org>
 <alpine.LSU.2.11.1807240121590.1105@eggly.anvils>
 <alpine.LSU.2.11.1807252334420.1212@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1807252334420.1212@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Wed, Jul 25, 2018 at 11:53:15PM -0700, Hugh Dickins wrote:
> Now I've learnt that an oops on 0xffffffffffffffbe points to EEXIST,
> not to EREMOTE, it's easy: patch below fixes those four xfstests
> (and no doubt a similar oops I've seen occasionally under swapping
> load): so gives clean xfstests runs for non-huge and huge tmpfs.

Excellent!

I'm adding this:

+++ b/lib/test_xarray.c
@@ -741,6 +741,13 @@ static noinline void check_create_range_2(struct xarray *xa
, unsigned order)
        XA_BUG_ON(xa, !xa_empty(xa));
 }
 
+static noinline void check_create_range_3(void)
+{
+       XA_STATE(xas, NULL, 0);
+       xas_set_err(&xas, -EEXIST);
+       xas_create_range(&xas);
+}
+
 static noinline void check_create_range(struct xarray *xa)
 {
        unsigned int order;
@@ -755,6 +762,8 @@ static noinline void check_create_range(struct xarray *xa)
                if (order < 10)
                        check_create_range_2(xa, order);
        }
+
+       check_create_range_3();
 }
 
 static LIST_HEAD(shadow_nodes);

and fixing the bug differently ;-)  But many thanks for spotting it!

I'll look into the next bug you reported ...
