Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2E86B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:47:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i21-v6so4457075qtp.10
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:47:56 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u19si2214910qke.222.2018.04.19.14.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:47:55 -0700 (PDT)
Date: Thu, 19 Apr 2018 17:47:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419214751.GD4981@redhat.com>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <20180419203307.GJ30522@ZenIV.linux.org.uk>
 <20180419205820.GB4981@redhat.com>
 <20180419212137.GM30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419212137.GM30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 10:21:37PM +0100, Al Viro wrote:
> On Thu, Apr 19, 2018 at 04:58:20PM -0400, Jerome Glisse wrote:
> 
> > I need a struct to link part of device context with mm struct for a
> > process. Most of device context is link to the struct file of the
> > device file (ie process open has a file descriptor for the device
> > file).
> 
> Er...  You do realize that
> 	fd = open(...)
> 	mmap(fd, ...)
> 	close(fd)
> is absolutely legitimate, right?  IOW, existence/stability/etc. of
> a file descriptor is absolutely *not* guaranteed - in fact, there might
> be not a single file descriptor referring to a given openen and mmaped
> file.

Yes and that's fine, on close(fd) the device driver is tear down and
struct i want to store is tear down too and free.

> 
> > Device driver for GPU have some part of their process context tied to
> > the process mm (accessing process address space directly from the GPU).
> > However we can not store this context information in the struct file
> > private data because of clone (same struct file accross different mm).
> > 
> > So today driver have an hashtable in their global device structure to
> > lookup context information for a given mm. This is sub-optimal and
> > duplicate a lot of code among different drivers.
> 
> Umm...  Examples?

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/radeon/radeon_mn.c
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/i915/i915_gem_userptr.c
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c

RDMA folks too have similar construct.

> 
> > Hence why i want something generic that allow a device driver to store
> > context structure that is specific to a mm. I thought that adding a
> > new array on the side of struct file array would be a good idea but it
> > has too many kludges.
> > 
> > So i will do something inside mmu_notifier and there will be no tie to
> > any fs aspect. I expect only a handful of driver to care about this and
> > for a given platform you won't see that many devices hence you won't
> > have that many pointer to deal with.
> 
> Let's step back for a second - lookups by _what_?  If you are associating
> somethin with a mapping, vm_area_struct would be a natural candidate for
> storing such data, wouldn't it?
> 
> What do you have and what do you want to find?

So you are in an ioctl against the device file, you have struct file
and driver store a pointer to some file context info in struct file
private data which itself has a pointer to some global device driver
structure which itself has a pointer to struct device.

Hence i have struct mm (from current->mm), and dev_t easily available.

The context information is tie to the mm for the device and can only
be use against said mm. Even if the struct file of the device outlive
the original process, no one can use that struct with a process that
do not have the same mm. Moreover that struct is freed if the mm is
destroy.

If child, share the struct file but have a different and want to use
same feature then a new structure is created and has same property ie
can only be use against this new mm.

The link with struct file is not explicit but you can only use objects
tie to that struct through ioctl against the struct file.

Hopes this clarify the use case.

Cheers,
Jerome
