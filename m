Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 767B06B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:01:56 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 66-v6so436307plb.18
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:01:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r73-v6si8942052pfk.83.2018.07.23.07.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 23 Jul 2018 07:01:53 -0700 (PDT)
Date: Mon, 23 Jul 2018 07:01:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
Message-ID: <20180723140150.GA31843@bombadil.infradead.org>
References: <000000000000d624c605705e9010@google.com>
 <20180709143610.GD2662@bombadil.infradead.org>
 <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1807221856350.5536@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Sun, Jul 22, 2018 at 07:28:01PM -0700, Hugh Dickins wrote:
> Whether or not that fixed syzbot's kernel BUG at mm/shmem.c:815!
> I don't know, but I'm afraid it has not fixed linux-next breakage of
> huge tmpfs: I get a similar page_to_pgoff BUG at mm/filemap.c:1466!
> 
> Please try something like
> mount -o remount,huge=always /dev/shm
> cp /dev/zero /dev/shm
> 
> Writing soon crashes in find_lock_entry(), looking up offset 0x201
> but getting the page for offset 0x3c1 instead.

Hmm.  I don't see a crash while running that command, but I do see an RCU
stall in find_get_entries() called from shmem_undo_range() when running
'cp' the second time -- ie while truncating the /dev/shm/zero file.
Maybe I'm seeing the same bug as you, and maybe I'm seeing a different
one.  Do we have a shmem test suite somewhere?

> I've spent a while on it, but better turn over to you, Matthew:
> my guess is that xas_create_range() does not create the layout
> you expect from it.

I've dumped the XArray tree on my machine and it actually looks fine
*except* that the pages pointed to are free!  That indicates to me I
screwed up somebody's reference count somewhere.
