Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04BF56B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:32:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56-v6so4698891wrc.5
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 03:32:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si865106edi.408.2018.04.19.03.32.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 03:32:54 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:32:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution
 to page waitqueue
Message-ID: <20180419103250.qvusqkjq6hlz3ch6@quack2.suse.cz>
References: <20180404191831.5378-1-jglisse@redhat.com>
 <20180418141337.mrnxqolo6aar3ud3@quack2.suse.cz>
 <20180418155429.GA3476@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418155429.GA3476@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tim Chen <tim.c.chen@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

On Wed 18-04-18 11:54:30, Jerome Glisse wrote:
> > Overall I think you'd need to make a good benchmarking comparison showing
> > how much this helps some real workloads (your motivation) and also how
> > other loads on lower end machines are affected.
> 
> Do you have any specific benchmark you would like to see ? My list was:
>   https://github.com/01org/lkp-tests
>   https://github.com/gormanm/mmtests

So e.g. mmtests have a *lot* of different tests so it's probably not
realistic for you to run them all. I'd look at bonnie++ (file & dir tests),
dbench, reaim - these are crappy IO benchmarks because they mostly fit into
page cache but for your purposes this is exactly what you want to see
differences in CPU overhead :).

> > > ----------------------------------------------------------------------
> > > The What ?
> > > 
> > > Aim of this patch serie is to introduce generic page write protection
> > > for any kind of regular page in a process (private anonymous or back
> > > by regular file). This feature already exist, in one form, for private
> > > anonymous page, as part of KSM (Kernel Share Memory).
> > > 
> > > So this patch serie is two fold. First it factors out the page write
> > > protection of KSM into a generic write protection mechanim which KSM
> > > becomes the first user of. Then it add support for regular file back
> > > page memory (regular file or share memory aka shmem). To achieve this
> > > i need to cut the dependency lot of code have on page->mapping so i
> > > can set page->mapping to point to special structure when write
> > > protected.
> > 
> > So I'm interested in this write protection mechanism but I didn't find much
> > about it in the series. How does it work? I can see KSM writeprotects pages
> > in page tables so that works for userspace mappings but what about
> > in-kernel users modifying pages - e.g. pages in page cache carrying
> > filesystem metadata do get modified a lot like this.
> 
> So i only care about page which are mmaped into a process address space.
> At first i only want to intercept CPU write access through mmap of file
> but i also intend to extend write syscall to also "fault" on the write
> protection ie it will call a callback to unprotect the page allowing the
> write protector to take proper action while write syscall is happening.
> 
> I am affraid truely generic write protection for metadata pages is bit
> out of scope of what i am doing. However the mechanism i am proposing
> can be extended for that too. Issue is that all place that want to write
> to those page need to be converted to something where write happens
> between write_begin and write_end section (mmap and CPU pte does give
> this implicitly through page fault, so does write syscall). Basicly
> there is a need to make sure that write and write protection can be
> ordered against one another without complex locking.

I understand metadata pages are not interesting for your use case. However
from mm point of view these are page cache pages as any other. So maybe my
question should have been: How do we make sure this mechanism will not be
used for pages for which it cannot work?

> > > A write protected page has page->mapping pointing to a structure like
> > > struct rmap_item for KSM. So this structure has a list for each unique
> > > combination:
> > >     struct write_protect {
> > >         struct list_head *mappings; /* write_protect_mapping list */
> > >         ...
> > >     };
> > > 
> > >     struct write_protect_mapping {
> > >         struct list_head list
> > >         struct address_space *mapping;
> > >         unsigned long offset;
> > >         unsigned long private;
> > >         ...
> > >     };
> > 
> > Auch, the fact that we could share a page as data storage for several
> > inode+offset combinations that are not sharing underlying storage just
> > looks viciously twisted ;) But is it really that useful to warrant
> > complications? In particular I'm afraid that filesystems expect consistency
> > between their internal state (attached to page->private) and page state
> > (e.g. page->flags) and when there are multiple internal states attached to
> > the same page this could go easily wrong...
> 
> So at first i want to limit to write protect (not KSM) thus page->flags
> will stay consistent (ie page is only ever associated with a single
> mapping). For KSM yes the page->flags can be problematic, however here
> we can assume that page is clean (and uptodate) and not under write
> back. So problematic flags for KSM:
>   - private (page_has_buffers() or PagePrivate (nfs, metadata, ...))
>   - private_2 (FsCache)
>   - mappedtodisk
>   - swapcache
>   - error
> 
> Idea again would be to PageFlagsWithMapping(page, mapping) so that for
> non KSM write protected page you test the usual page->flags and for
> write protected page you find the flag value using mapping as lookup
> index. Usualy those flag are seldomly changed/accessed. Again the
> overhead (ignoring code size) would only be for page which are KSM.
> So maybe KSM will not make sense because perf overhead it has with
> page->flags access (i don't think so but i haven't tested this).

Yeah, sure, page->flags could be dealt with in a similar way but at this
point I don't think it's worth it. And without page->flags I don't think
abstracting page->private makes much sense - or am I missing something why
you need page->private depend on the mapping? So what I wanted to suggest
is that we leave page->private as is currently and just concentrate on
page->mapping hacks...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
