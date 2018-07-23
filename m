Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C9FBB6B0003
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 22:28:13 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id i15-v6so9092749ybk.18
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 19:28:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o203-v6sor1940952ybb.3.2018.07.22.19.28.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Jul 2018 19:28:12 -0700 (PDT)
Date: Sun, 22 Jul 2018 19:28:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <20180709143610.GD2662@bombadil.infradead.org>
Message-ID: <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Mon, 9 Jul 2018, Matthew Wilcox wrote:
> On Fri, Jul 06, 2018 at 06:19:02PM -0700, syzbot wrote:
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    526674536360 Add linux-next specific files for 20180706
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=116d16fc400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
> > dashboard link: https://syzkaller.appspot.com/bug?extid=b8e0dfee3fd8c9012771
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=170e462c400000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15f1ba2c400000
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com
> 
> #syz fix: shmem: Convert shmem_add_to_page_cache to XArray

I don't see the patch, but I do see a diff in shmem_add_to_page_cache()
between mmotm 4.18.0-rc3-mm1 and current mmotm 4.18.0-rc5-mm1,
relating to use of xas_create_range().

Whether or not that fixed syzbot's kernel BUG at mm/shmem.c:815!
I don't know, but I'm afraid it has not fixed linux-next breakage of
huge tmpfs: I get a similar page_to_pgoff BUG at mm/filemap.c:1466!

Please try something like
mount -o remount,huge=always /dev/shm
cp /dev/zero /dev/shm

Writing soon crashes in find_lock_entry(), looking up offset 0x201
but getting the page for offset 0x3c1 instead.

I've spent a while on it, but better turn over to you, Matthew:
my guess is that xas_create_range() does not create the layout
you expect from it.

Thanks,
Hugh
