Received: by rv-out-0910.google.com with SMTP id f1so93911rvb
        for <linux-mm@kvack.org>; Wed, 08 Aug 2007 05:03:48 -0700 (PDT)
Message-ID: <288dbef70708080503k12c8a15w96ade47789dd26e0@mail.gmail.com>
Date: Wed, 8 Aug 2007 20:03:48 +0800
From: "Shaohua Li" <shaoh.li@gmail.com>
Subject: Re: swap out memory
In-Reply-To: <288dbef70708060553i4405f8d9lefa6132c86190d7b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <288dbef70708060553i4405f8d9lefa6132c86190d7b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hch@infradead.org, Avi Kivity <avi@qumranet.com>
List-ID: <linux-mm.kvack.org>

2007/8/6, Shaohua Li <shaoh.li@gmail.com>:
> Hi,
> I'm trying to swap out kvm guest pages. The idea is to free some pages
> when memory pressure is high. kvm has special things to handle like
> shadow page tables. Before guest page is released, we need free some
> data, that is guest page has 'private' data, so we can't directly make
> the guest page swapout with Linux swapout mechanism. I'd like write
> guest pages to a file or swap. kvm guest pages are in its address
> space and added into lru list like normal page (the address space is
> very like a shmem file's, kvm has a memory based file system). When
> vmscan decided to free one guest page, kvm guest pages's
> aops.writepage will free the private data and then write it out to
> block device. The problem is how to write guest pages. I thought we
> have some choices:
>
> 1. swap it to swapfile. Like shmem does, using move_to_swap_cache to
> move guest page from its address space to swap address space, and
> finally it's written to swapfile. This method works well, but as kvm
> is a module, I must export some swap relelated APIs, which Christoph
> Hellwig dislike.
>
> 2. write it to a file. Just like the stack fs does, in kvm address
> space's .writepage, let low fs's aops write the page. This involves
> allocating a new page for low fs file and copy kvm page to the new
> page. As this (doing swap) is done when memory is tight, allocating
> new page isn't good. The copy isn't good too.
>
> 3.write it to a file. Using bmap to get file's block info and using
> low level sumbit_bio for read/write. This is like what swapfile does,
> but we do it by ourselves, so don't need use swap symbols.
>
> Do you have any suggestion which method is good, or if you have better
> choice I could try?
Can anybody share some hints? I really apprecate any comments.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
