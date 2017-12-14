Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37DD96B0268
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:53:25 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a74so5135995pfg.20
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:53:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bi5si3381423plb.4.2017.12.14.08.53.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 08:53:20 -0800 (PST)
Date: Thu, 14 Dec 2017 17:53:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: save/restore current->journal_info in handle_mm_fault
Message-ID: <20171214165314.GB1930@quack2.suse.cz>
References: <20171214105527.5885-1-zyan@redhat.com>
 <20171214134338.GA1474@quack2.suse.cz>
 <CAAM7YA=ThWbBpOe1wgeYjGt3ogr9kT6uy3UpqSn94XqbhjOHJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAM7YA=ThWbBpOe1wgeYjGt3ogr9kT6uy3UpqSn94XqbhjOHJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <ukernel@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "Yan, Zheng" <zyan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>, stable@vger.kernel.org

On Thu 14-12-17 22:30:26, Yan, Zheng wrote:
> On Thu, Dec 14, 2017 at 9:43 PM, Jan Kara <jack@suse.cz> wrote:
> > On Thu 14-12-17 18:55:27, Yan, Zheng wrote:
> >> We recently got an Oops report:
> >>
> >> BUG: unable to handle kernel NULL pointer dereference at (null)
> >> IP: jbd2__journal_start+0x38/0x1a2
> >> [...]
> >> Call Trace:
> >>   ext4_page_mkwrite+0x307/0x52b
> >>   _ext4_get_block+0xd8/0xd8
> >>   do_page_mkwrite+0x6e/0xd8
> >>   handle_mm_fault+0x686/0xf9b
> >>   mntput_no_expire+0x1f/0x21e
> >>   __do_page_fault+0x21d/0x465
> >>   dput+0x4a/0x2f7
> >>   page_fault+0x22/0x30
> >>   copy_user_generic_string+0x2c/0x40
> >>   copy_page_to_iter+0x8c/0x2b8
> >>   generic_file_read_iter+0x26e/0x845
> >>   timerqueue_del+0x31/0x90
> >>   ceph_read_iter+0x697/0xa33 [ceph]
> >>   hrtimer_cancel+0x23/0x41
> >>   futex_wait+0x1c8/0x24d
> >>   get_futex_key+0x32c/0x39a
> >>   __vfs_read+0xe0/0x130
> >>   vfs_read.part.1+0x6c/0x123
> >>   handle_mm_fault+0x831/0xf9b
> >>   __fget+0x7e/0xbf
> >>   SyS_read+0x4d/0xb5
> >>
> >> ceph_read_iter() uses current->journal_info to pass context info to
> >> ceph_readpages(). Because ceph_readpages() needs to know if its caller
> >> has already gotten capability of using page cache (distinguish read
> >> from readahead/fadvise). ceph_read_iter() set current->journal_info,
> >> then calls generic_file_read_iter().
> >>
> >> In above Oops, page fault happened when copying data to userspace.
> >> Page fault handler called ext4_page_mkwrite(). Ext4 code read
> >> current->journal_info and assumed it is journal handle.
> >>
> >> I checked other filesystems, btrfs probably suffers similar problem
> >> for its readpage. (page fault happens when write() copies data from
> >> userspace memory and the memory is mapped to a file in btrfs.
> >> verify_parent_transid() can be called during readpage)
> >>
> >> Cc: stable@vger.kernel.org
> >> Signed-off-by: "Yan, Zheng" <zyan@redhat.com>
> >
> > I agree with the analysis but the patch is too ugly too live. Ceph just
> > should not be abusing current->journal_info for passing information between
> > two random functions or when it does a hackery like this, it should just
> > make sure the pieces hold together. Poluting generic code to accommodate
> > this hack in Ceph is not acceptable. Also bear in mind there are likely
> > other code paths (e.g. memory reclaim) which could recurse into another
> > filesystem confusing it with non-NULL current->journal_info in the same
> > way.
> 
> But ...
> 
> some filesystem set journal_info in its write_begin(), then clear it
> in write_end(). If buffer for write is mapped to another filesystem,
> current->journal can leak to the later filesystem's page_readpage().
> The later filesystem may read current->journal and treat it as its own
> journal handle.  Besides, most filesystem's vm fault handle is
> filemap_fault(), filemap also may tigger memory reclaim.

Did you really observe this? Because write path uses
iov_iter_copy_from_user_atomic() which does not allow page faults to
happen. All page faulting happens in iov_iter_fault_in_readable() before
->write_begin() is called. And the recursion problems like you mention
above are exactly the reason why things are done in a more complicated way
like this.

> >
> > In this particular case I'm not sure why does ceph pass 'filp' into
> > readpage() / readpages() handler when it already gets that pointer as part
> > of arguments...
> 
> It actually a flag which tells ceph_readpages() if its caller is
> ceph_read_iter or readahead/fadvise/madvise. because when there are
> multiple clients read/write a file a the same time, page cache should
> be disabled.

I'm not sure I understand the reasoning properly but from what you say
above it rather seems the 'hint' should be stored in the inode (or possibly
struct file)?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
