Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91D846B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:21:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o16-v6so3899468wri.8
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:21:43 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id w6-v6si1046968wrk.170.2018.04.19.14.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:21:42 -0700 (PDT)
Date: Thu, 19 Apr 2018 22:21:37 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419212137.GM30522@ZenIV.linux.org.uk>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <20180419203307.GJ30522@ZenIV.linux.org.uk>
 <20180419205820.GB4981@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180419205820.GB4981@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jeff Layton <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 04:58:20PM -0400, Jerome Glisse wrote:

> I need a struct to link part of device context with mm struct for a
> process. Most of device context is link to the struct file of the
> device file (ie process open has a file descriptor for the device
> file).

Er...  You do realize that
	fd = open(...)
	mmap(fd, ...)
	close(fd)
is absolutely legitimate, right?  IOW, existence/stability/etc. of
a file descriptor is absolutely *not* guaranteed - in fact, there might
be not a single file descriptor referring to a given openen and mmaped
file.

> Device driver for GPU have some part of their process context tied to
> the process mm (accessing process address space directly from the GPU).
> However we can not store this context information in the struct file
> private data because of clone (same struct file accross different mm).
> 
> So today driver have an hashtable in their global device structure to
> lookup context information for a given mm. This is sub-optimal and
> duplicate a lot of code among different drivers.

Umm...  Examples?

> Hence why i want something generic that allow a device driver to store
> context structure that is specific to a mm. I thought that adding a
> new array on the side of struct file array would be a good idea but it
> has too many kludges.
> 
> So i will do something inside mmu_notifier and there will be no tie to
> any fs aspect. I expect only a handful of driver to care about this and
> for a given platform you won't see that many devices hence you won't
> have that many pointer to deal with.

Let's step back for a second - lookups by _what_?  If you are associating
somethin with a mapping, vm_area_struct would be a natural candidate for
storing such data, wouldn't it?

What do you have and what do you want to find?
