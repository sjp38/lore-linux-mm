Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5F496B000A
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:52:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p21so3543260qke.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:52:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y8si774821qkb.402.2018.04.19.07.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 07:52:22 -0700 (PDT)
Date: Thu, 19 Apr 2018 10:52:19 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/79] Generic page write protection and a solution
 to page waitqueue
Message-ID: <20180419145219.GB3519@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
 <20180418141337.mrnxqolo6aar3ud3@quack2.suse.cz>
 <20180418155429.GA3476@redhat.com>
 <20180419103250.qvusqkjq6hlz3ch6@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419103250.qvusqkjq6hlz3ch6@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tim Chen <tim.c.chen@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Tejun Heo <tj@kernel.org>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

On Thu, Apr 19, 2018 at 12:32:50PM +0200, Jan Kara wrote:
> On Wed 18-04-18 11:54:30, Jerome Glisse wrote:

[...]

> > I am affraid truely generic write protection for metadata pages is bit
> > out of scope of what i am doing. However the mechanism i am proposing
> > can be extended for that too. Issue is that all place that want to write
> > to those page need to be converted to something where write happens
> > between write_begin and write_end section (mmap and CPU pte does give
> > this implicitly through page fault, so does write syscall). Basicly
> > there is a need to make sure that write and write protection can be
> > ordered against one another without complex locking.
> 
> I understand metadata pages are not interesting for your use case. However
> from mm point of view these are page cache pages as any other. So maybe my
> question should have been: How do we make sure this mechanism will not be
> used for pages for which it cannot work?

Oh that one is easy, the API take vma + addr or rather mm struct + addr
(ie like KSM today kind of). I will change wording in v1 to almost
generic write protection :) or process' page write protection (but this
would not work for special pfn/vma so not generic their either).

> > > > A write protected page has page->mapping pointing to a structure like
> > > > struct rmap_item for KSM. So this structure has a list for each unique
> > > > combination:
> > > >     struct write_protect {
> > > >         struct list_head *mappings; /* write_protect_mapping list */
> > > >         ...
> > > >     };
> > > > 
> > > >     struct write_protect_mapping {
> > > >         struct list_head list
> > > >         struct address_space *mapping;
> > > >         unsigned long offset;
> > > >         unsigned long private;
> > > >         ...
> > > >     };
> > > 
> > > Auch, the fact that we could share a page as data storage for several
> > > inode+offset combinations that are not sharing underlying storage just
> > > looks viciously twisted ;) But is it really that useful to warrant
> > > complications? In particular I'm afraid that filesystems expect consistency
> > > between their internal state (attached to page->private) and page state
> > > (e.g. page->flags) and when there are multiple internal states attached to
> > > the same page this could go easily wrong...
> > 
> > So at first i want to limit to write protect (not KSM) thus page->flags
> > will stay consistent (ie page is only ever associated with a single
> > mapping). For KSM yes the page->flags can be problematic, however here
> > we can assume that page is clean (and uptodate) and not under write
> > back. So problematic flags for KSM:
> >   - private (page_has_buffers() or PagePrivate (nfs, metadata, ...))
> >   - private_2 (FsCache)
> >   - mappedtodisk
> >   - swapcache
> >   - error
> > 
> > Idea again would be to PageFlagsWithMapping(page, mapping) so that for
> > non KSM write protected page you test the usual page->flags and for
> > write protected page you find the flag value using mapping as lookup
> > index. Usualy those flag are seldomly changed/accessed. Again the
> > overhead (ignoring code size) would only be for page which are KSM.
> > So maybe KSM will not make sense because perf overhead it has with
> > page->flags access (i don't think so but i haven't tested this).
> 
> Yeah, sure, page->flags could be dealt with in a similar way but at this
> point I don't think it's worth it. And without page->flags I don't think
> abstracting page->private makes much sense - or am I missing something why
> you need page->private depend on the mapping? So what I wanted to suggest
> is that we leave page->private as is currently and just concentrate on
> page->mapping hacks...

Well i wanted to go up to KSM or at least as close as possible to KSM
for file back page. But i can focus on page->mapping first, do write
protection with that and also do the per page wait queue for page lock.
Which i believe are both nice features. This will also make the patchset
smaller and easier to review (less scary).

KSM can be done on top of that latter and i will be happy to help. I
have a bunch of coccinelle patches for page->private, page->index and
i can do some for page->flags.

Cheers,
Jerome
