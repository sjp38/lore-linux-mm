Received: by wa-out-1112.google.com with SMTP id m33so1864608wag
        for <linux-mm@kvack.org>; Mon, 06 Aug 2007 05:53:21 -0700 (PDT)
Message-ID: <288dbef70708060553i4405f8d9lefa6132c86190d7b@mail.gmail.com>
Date: Mon, 6 Aug 2007 20:53:20 +0800
From: "Shaohua Li" <shaoh.li@gmail.com>
Subject: swap out memory
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hch@infradead.org
List-ID: <linux-mm.kvack.org>

Hi,
I'm trying to swap out kvm guest pages. The idea is to free some pages
when memory pressure is high. kvm has special things to handle like
shadow page tables. Before guest page is released, we need free some
data, that is guest page has 'private' data, so we can't directly make
the guest page swapout with Linux swapout mechanism. I'd like write
guest pages to a file or swap. kvm guest pages are in its address
space and added into lru list like normal page (the address space is
very like a shmem file's, kvm has a memory based file system). When
vmscan decided to free one guest page, kvm guest pages's
aops.writepage will free the private data and then write it out to
block device. The problem is how to write guest pages. I thought we
have some choices:

1. swap it to swapfile. Like shmem does, using move_to_swap_cache to
move guest page from its address space to swap address space, and
finally it's written to swapfile. This method works well, but as kvm
is a module, I must export some swap relelated APIs, which Christoph
Hellwig dislike.

2. write it to a file. Just like the stack fs does, in kvm address
space's .writepage, let low fs's aops write the page. This involves
allocating a new page for low fs file and copy kvm page to the new
page. As this (doing swap) is done when memory is tight, allocating
new page isn't good. The copy isn't good too.

3.write it to a file. Using bmap to get file's block info and using
low level sumbit_bio for read/write. This is like what swapfile does,
but we do it by ourselves, so don't need use swap symbols.

Do you have any suggestion which method is good, or if you have better
choice I could try?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
