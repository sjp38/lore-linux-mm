Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD3A6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:36:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z2-v6so7722466plk.3
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:36:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u192sor286432pgc.162.2018.04.09.13.36.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Apr 2018 13:36:37 -0700 (PDT)
Date: Mon, 9 Apr 2018 13:36:35 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180409203635.GD203367@gmail.com>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
 <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
 <20180409185016.GA203367@gmail.com>
 <20180409201232.3rweldbjtvxjj5ql@linux-n805>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409201232.3rweldbjtvxjj5ql@linux-n805>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Mon, Apr 09, 2018 at 01:12:32PM -0700, Davidlohr Bueso wrote:
> On Mon, 09 Apr 2018, Eric Biggers wrote:
> 
> > It's necessary because if we don't hold a reference to sfd->file, then it can be
> > a stale pointer when we compare it in __shm_open().  In particular, if the new
> > struct file happened to be allocated at the same address as the old one, then
> > 'sfd->file == shp->shm_file' so the mmap would be allowed.  But, it will be a
> > different shm segment than was intended.  The caller may not even have
> > permissions to map it normally, yet it would be done anyway.
> > 
> > In the end it's just broken to have a pointer to something that can be freed out
> > from under you...
> 
> So this is actually handled by shm_nattch, serialized by the ipc perm->lock.
> shm_destroy() is called when 0, which in turn does the fput(shm_file). Note
> that shm_file is given a count of 1 when a new segment is created (deep in
> get_empty_filp()). So I don't think the pointer is going anywhere, or am I missing
> something?
> 
> Thanks,
> Davidlohr

In the remap_file_pages() case, a reference is taken to the ->vm_file, then the
segment is unmapped.  If that brings ->shm_nattch to 0, then the underlying shm
segment and ID can be removed, which (currently) causes the real shm file to be
freed.  But, the outer file still exists and will have ->mmap() called on it.
That's why the outer file needs to hold a reference to the real shm file.

Eric
