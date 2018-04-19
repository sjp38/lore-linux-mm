Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90DCB6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:26:13 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l8-v6so1565628qtb.11
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:26:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z15si5072863qki.266.2018.04.19.10.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 10:26:12 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:26:10 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419172609.GD3519@redhat.com>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1524157119.2943.6.camel@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 12:58:39PM -0400, Jeff Layton wrote:
> On Thu, 2018-04-19 at 12:30 -0400, Jerome Glisse wrote:
> > On Thu, Apr 19, 2018 at 07:43:56AM -0700, Matthew Wilcox wrote:
> > > On Thu, Apr 19, 2018 at 10:38:25AM -0400, Jerome Glisse wrote:
> > > > Oh can i get one more small slot for fs ? I want to ask if they are
> > > > any people against having a callback everytime a struct file is added
> > > > to a task_struct and also having a secondary array so that special
> > > > file like device file can store something opaque per task_struct per
> > > > struct file.
> > > 
> > > Do you really want something per _thread_, and not per _mm_?
> > 
> > Well per mm would be fine but i do not see how to make that happen with
> > reasonable structure. So issue is that you can have multiple task with
> > same mm but different file descriptors (or am i wrong here ?) thus there
> > would be no easy way given a struct file to lookup the per mm struct.
> > 
> > So as a not perfect solution i see a new array in filedes which would
> > allow device driver to store a pointer to their per mm data structure.
> > To be fair usualy you will only have a single fd in a single task for
> > a given device.
> > 
> > If you see an easy way to get a per mm per inode pointer store somewhere
> > with easy lookup i am all ears :)
> > 
> 
> I may be misunderstanding, but to be clear: struct files don't get
> added to a thread, per-se.
> 
> When userland calls open() or similar, the struct file gets added to
> the files_struct. Those are generally shared with other threads within
> the same process. The files_struct can also be shared with other
> processes if you clone() with the right flags.
> 
> Doing something per-thread on every open may be rather difficult to do.

Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
add void * *private_data; to struct fdtable (also a default array to
struct files_struct). The callback would be part of struct file_operations.
and only call if it exist (os overhead is only for device driver that
care).

Did i miss something fundamental ? copy_files() call dup_fd() so i
should be all set here.

I will work on patches i was hoping this would not be too much work.

Cheers,
Jerome
