Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17C8B6B0009
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:31:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o2-v6so3452809plk.0
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 11:31:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v2si3508141pgf.75.2018.04.19.11.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 11:31:10 -0700 (PDT)
Message-ID: <1524162667.2943.22.camel@kernel.org>
Subject: Re: [LSF/MM] schedule suggestion
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 19 Apr 2018 14:31:07 -0400
In-Reply-To: <20180419172609.GD3519@redhat.com>
References: <20180418211939.GD3476@redhat.com>
	 <20180419015508.GJ27893@dastard> <20180419143825.GA3519@redhat.com>
	 <20180419144356.GC25406@bombadil.infradead.org>
	 <20180419163036.GC3519@redhat.com> <1524157119.2943.6.camel@kernel.org>
	 <20180419172609.GD3519@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, 2018-04-19 at 13:26 -0400, Jerome Glisse wrote:
> On Thu, Apr 19, 2018 at 12:58:39PM -0400, Jeff Layton wrote:
> > On Thu, 2018-04-19 at 12:30 -0400, Jerome Glisse wrote:
> > > On Thu, Apr 19, 2018 at 07:43:56AM -0700, Matthew Wilcox wrote:
> > > > On Thu, Apr 19, 2018 at 10:38:25AM -0400, Jerome Glisse wrote:
> > > > > Oh can i get one more small slot for fs ? I want to ask if they are
> > > > > any people against having a callback everytime a struct file is added
> > > > > to a task_struct and also having a secondary array so that special
> > > > > file like device file can store something opaque per task_struct per
> > > > > struct file.
> > > > 
> > > > Do you really want something per _thread_, and not per _mm_?
> > > 
> > > Well per mm would be fine but i do not see how to make that happen with
> > > reasonable structure. So issue is that you can have multiple task with
> > > same mm but different file descriptors (or am i wrong here ?) thus there
> > > would be no easy way given a struct file to lookup the per mm struct.
> > > 
> > > So as a not perfect solution i see a new array in filedes which would
> > > allow device driver to store a pointer to their per mm data structure.
> > > To be fair usualy you will only have a single fd in a single task for
> > > a given device.
> > > 
> > > If you see an easy way to get a per mm per inode pointer store somewhere
> > > with easy lookup i am all ears :)
> > > 
> > 
> > I may be misunderstanding, but to be clear: struct files don't get
> > added to a thread, per-se.
> > 
> > When userland calls open() or similar, the struct file gets added to
> > the files_struct. Those are generally shared with other threads within
> > the same process. The files_struct can also be shared with other
> > processes if you clone() with the right flags.
> > 
> > Doing something per-thread on every open may be rather difficult to do.
> 
> Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
> add void * *private_data; to struct fdtable (also a default array to
> struct files_struct). The callback would be part of struct file_operations.
> and only call if it exist (os overhead is only for device driver that
> care).
> 
> Did i miss something fundamental ? copy_files() call dup_fd() so i
> should be all set here.
> 
> I will work on patches i was hoping this would not be too much work.
> 

No, I think I misunderstood. I was thinking you wanted to iterate over
all of the threads that might be associated with a struct file, and
that's rather non-trivial.

A callback when you add a file to the files_struct seems like it would
probably be OK (in principle).
-- 
Jeff Layton <jlayton@kernel.org>
