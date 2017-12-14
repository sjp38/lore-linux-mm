Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB9FF6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:18:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w74so1961197wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:18:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j11si2597009wra.11.2017.12.13.18.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 18:18:50 -0800 (PST)
Date: Wed, 13 Dec 2017 18:18:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: save current->journal_info before calling
 fault/page_mkwrite
Message-Id: <20171213181847.7295af1db2276837f184d0f9@linux-foundation.org>
In-Reply-To: <12AE4806-72D3-4AA2-A483-693375DA7D36@redhat.com>
References: <20171213035836.916-1-zyan@redhat.com>
	<20171213165923.0ea4eb3e996b7d8bf1fff72f@linux-foundation.org>
	<12AE4806-72D3-4AA2-A483-693375DA7D36@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <zyan@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-ext4@vger.kernel.org, viro@zeniv.linux.org.uk, jlayton@redhat.com, linux-mm@kvack.org

On Thu, 14 Dec 2017 10:09:58 +0800 "Yan, Zheng" <zyan@redhat.com> wrote:

> 
> 
> > On 14 Dec 2017, at 08:59, Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > On Wed, 13 Dec 2017 11:58:36 +0800 "Yan, Zheng" <zyan@redhat.com> wrote:
> > 
> >> We recently got an Oops report:
> >> 
> >> BUG: unable to handle kernel NULL pointer dereference at (null)
> >> IP: jbd2__journal_start+0x38/0x1a2
> >> [...]
> >> Call Trace:
> >>  ext4_page_mkwrite+0x307/0x52b
> >>  _ext4_get_block+0xd8/0xd8
> >>  do_page_mkwrite+0x6e/0xd8
> >>  handle_mm_fault+0x686/0xf9b
> >>  mntput_no_expire+0x1f/0x21e
> >>  __do_page_fault+0x21d/0x465
> >>  dput+0x4a/0x2f7
> >>  page_fault+0x22/0x30
> >>  copy_user_generic_string+0x2c/0x40
> >>  copy_page_to_iter+0x8c/0x2b8
> >>  generic_file_read_iter+0x26e/0x845
> >>  timerqueue_del+0x31/0x90
> >>  ceph_read_iter+0x697/0xa33 [ceph]
> >>  hrtimer_cancel+0x23/0x41
> >>  futex_wait+0x1c8/0x24d
> >>  get_futex_key+0x32c/0x39a
> >>  __vfs_read+0xe0/0x130
> >>  vfs_read.part.1+0x6c/0x123
> >>  handle_mm_fault+0x831/0xf9b
> >>  __fget+0x7e/0xbf
> >>  SyS_read+0x4d/0xb5
> >> 
> >> The reason is that page fault can happen when one filesystem copies
> >> data from/to userspace, the filesystem may set current->journal_info.
> >> If the userspace memory is mapped to a file on another filesystem,
> >> the later filesystem may also want to use current->journal_info.
> >> 
> > 
> > whoops.
> > 
> > A cc:stable will be needed here...
> > 
> > A filesystem doesn't "copy data from/to userspace".  I assume here
> > we're referring to a read() where the source is a pagecache page for
> > filesystem A and the destination is a MAP_SHARED page in filesystem B?
> > 
> > But in that case I don't see why filesystem A would have a live
> > ->journal_info?  It's just doing a read.
> 
> 
> Background: when there are multiple cephfs clients read/write a file at time same time, read/write should go directly to object store daemon, using page cache is disabled.
> 
> ceph_read_iter() uses current->journal_info to pass context information to ceph_readpages().  ceph_readpages() needs to know if its caller has already gotten capability of using page cache (distinguish read from readahead/fadvise). If not, it tries getting the capability by itself. I checked other filesystem, btrfs probably suffers similar problem for its readpages. (verify_parent_transid() uses current->journal_info and it can be called by by btrfs_get_extent())
> 

Ah.  Well please let's get all that into the changelog.

> > Can you explain why you chose these two sites?  Rather than, for
> > example, way up in handle_mm_fault()?

And please answer this?

> > It's hard to believe that a fault handler will alter ->journal_info if
> > it is handling a read fault, so perhaps we only need to do this for a
> > write fault?  Although such an optimization probably isn't worthwhile. 
> > The whole thing is only about three instructions.
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
