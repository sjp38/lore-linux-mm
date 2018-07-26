Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A21B36B0007
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:40:31 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id c2-v6so1102067ybl.16
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 09:40:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16-v6sor422033yba.105.2018.07.26.09.40.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 09:40:30 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:40:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <20180726143353.GA27612@bombadil.infradead.org>
Message-ID: <alpine.LSU.2.11.1807260936040.1101@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org> <alpine.LSU.2.11.1807221856350.5536@eggly.anvils> <20180723140150.GA31843@bombadil.infradead.org> <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org> <alpine.LSU.2.11.1807231531240.2545@eggly.anvils> <20180723225454.GC18236@bombadil.infradead.org> <alpine.LSU.2.11.1807240121590.1105@eggly.anvils> <alpine.LSU.2.11.1807252334420.1212@eggly.anvils>
 <20180726143353.GA27612@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Thu, 26 Jul 2018, Matthew Wilcox wrote:
> On Wed, Jul 25, 2018 at 11:53:15PM -0700, Hugh Dickins wrote:
> 
> and fixing the bug differently ;-)  But many thanks for spotting it!

I thought you might :)

> 
> I'll look into the next bug you reported ...

No need: that idea now works a lot better when I use the initialized
"start", instead of the uninitialized "index".

Hugh

--- mmotm/mm/khugepaged.c	2018-07-20 17:54:41.978805312 -0700
+++ linux/mm/khugepaged.c	2018-07-26 09:20:22.416949014 -0700
@@ -1352,6 +1352,7 @@ static void collapse_shmem(struct mm_str
 			goto out;
 	} while (1);
 
+	xas_set(&xas, start);
 	for (index = start; index < end; index++) {
 		struct page *page = xas_next(&xas);
 
