Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A89A6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 16:25:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c11-v6so357523pll.13
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 13:25:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si821150pfn.1.2018.04.09.13.25.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Apr 2018 13:25:56 -0700 (PDT)
Date: Mon, 9 Apr 2018 13:12:32 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] ipc/shm: fix use-after-free of shm file via
 remap_file_pages()
Message-ID: <20180409201232.3rweldbjtvxjj5ql@linux-n805>
References: <94eb2c06f65e5e2467055d036889@google.com>
 <20180409043039.28915-1-ebiggers3@gmail.com>
 <20180409094813.bsjc3u2hnsrdyiuk@black.fi.intel.com>
 <20180409185016.GA203367@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180409185016.GA203367@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>, "Eric W . Biederman" <ebiederm@xmission.com>, syzkaller-bugs@googlegroups.com

On Mon, 09 Apr 2018, Eric Biggers wrote:

>It's necessary because if we don't hold a reference to sfd->file, then it can be
>a stale pointer when we compare it in __shm_open().  In particular, if the new
>struct file happened to be allocated at the same address as the old one, then
>'sfd->file == shp->shm_file' so the mmap would be allowed.  But, it will be a
>different shm segment than was intended.  The caller may not even have
>permissions to map it normally, yet it would be done anyway.
>
>In the end it's just broken to have a pointer to something that can be freed out
>from under you...

So this is actually handled by shm_nattch, serialized by the ipc perm->lock.
shm_destroy() is called when 0, which in turn does the fput(shm_file). Note
that shm_file is given a count of 1 when a new segment is created (deep in
get_empty_filp()). So I don't think the pointer is going anywhere, or am I missing
something?

Thanks,
Davidlohr
