Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCA36B0006
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 18:13:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k27-v6so6462927wre.23
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 15:13:55 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id s140si84026wmb.142.2018.04.19.15.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 15:13:54 -0700 (PDT)
Date: Thu, 19 Apr 2018 23:13:50 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419221350.GN30522@ZenIV.linux.org.uk>
References: <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <20180419203307.GJ30522@ZenIV.linux.org.uk>
 <20180419205820.GB4981@redhat.com>
 <20180419212137.GM30522@ZenIV.linux.org.uk>
 <20180419214751.GD4981@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419214751.GD4981@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 05:47:51PM -0400, Jerome Glisse wrote:
> On Thu, Apr 19, 2018 at 10:21:37PM +0100, Al Viro wrote:
> > On Thu, Apr 19, 2018 at 04:58:20PM -0400, Jerome Glisse wrote:
> > 
> > > I need a struct to link part of device context with mm struct for a
> > > process. Most of device context is link to the struct file of the
> > > device file (ie process open has a file descriptor for the device
> > > file).
> > 
> > Er...  You do realize that
> > 	fd = open(...)
> > 	mmap(fd, ...)
> > 	close(fd)
> > is absolutely legitimate, right?  IOW, existence/stability/etc. of
> > a file descriptor is absolutely *not* guaranteed - in fact, there might
> > be not a single file descriptor referring to a given openen and mmaped
> > file.
> 
> Yes and that's fine, on close(fd) the device driver is tear down

No, it is not.  _NOTHING_ is done on that close(fd), other than removing
a reference from descriptor table.  In this case struct file is still
open and remains such until munmap().

That's why descriptor table is a very bad place for sticking that kind of
information.  Besides, as soon as your syscall (ioctl, write, whatever)
has looked struct file up, the mapping from descriptors to struct file
can change.  Literally before fdget() has returned to caller.  Another
thread could do dup() and close() of the original descriptor.  Or
just plain close(), for that matter - struct file will remain open until
fdput().

> and
> struct i want to store is tear down too and free.

So do a hash table indexed by pair (void *, struct mm_struct *) and
do lookups there...  And use radeon_device as the first half of the
key.  Or struct file *, or pointer to whatever private data you maintain
for an opened file...
