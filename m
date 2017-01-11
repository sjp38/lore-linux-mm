Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFB516B0038
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:13:20 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 3so1003362377oih.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:13:20 -0800 (PST)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id o65si2316569oib.219.2017.01.11.06.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 06:13:20 -0800 (PST)
Received: by mail-oi0-x241.google.com with SMTP id x84so23379552oix.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 06:13:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170111115143.GJ16116@quack2.suse.cz>
References: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
 <20170111115143.GJ16116@quack2.suse.cz>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 11 Jan 2017 15:13:19 +0100
Message-ID: <CAJfpeguuBgypYh3G1Ew1a37o4WuRozPzLe=D_gh2BbtYXE=zzg@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] sharing pages between mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, lsf-pc@lists.linux-foundation.org

On Wed, Jan 11, 2017 at 12:51 PM, Jan Kara <jack@suse.cz> wrote:
> On Wed 11-01-17 11:29:28, Miklos Szeredi wrote:
>> I know there's work on this for xfs, but could this be done in generic mm
>> code?
>>
>> What are the obstacles?  page->mapping and page->index are the obvious
>> ones.
>
> Yes, these two are the main that come to my mind. Also you'd need to
> somehow share the mapping->i_mmap tree so that unmap_mapping_range() works.
>
>> If that's too difficult is it maybe enough to share mappings between
>> files while they are completely identical and clone the mapping when
>> necessary?
>
> Well, but how would the page->mapping->host indirection work? Even if you
> have identical contents of the mappings, you still need to be aware there
> are several inodes behind them and you need to pick the right one
> somehow...

When do we actually need page->mapping->host?  The only place where
it's not available is page writeback.  Then we can know that the
original page was already cow-ed and after being cowed, the page
belong only to a single inode.

What then happens if the newly written data is cloned before being
written back?   We can either write back the page during the clone, so
that only clean pages are ever shared.  Or we can let dirty pages be
shared between inodes.  In that latter case the question is: do we
care about which inode we use for writing back the data?  Is the inode
needed at all?  I don't know enough about filesystem internals to see
clearly what happens in such a situation.

>> All COW filesystems would benefit, as well as layered ones: lots of
>> fuse fs, and in some cases overlayfs too.
>>
>> Related:  what can DAX do in the presence of cloned block?
>
> For DAX handling a block COW should be doable if that is what you are
> asking about. Handling of blocks that can be written to while they are
> shared will be rather difficult (you have problems with keeping dirty bits
> in the radix tree consistent if nothing else).

What happens if you do:

- clone_file_range(A, off1, B, off2, len);

- mmap both A and B using DAX.

The mapping will contain the same struct page for two different mappings, no?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
