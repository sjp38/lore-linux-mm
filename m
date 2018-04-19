Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B55D6B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 16:58:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a125so4383995qkd.4
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:58:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u190si410952qka.45.2018.04.19.13.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 13:58:23 -0700 (PDT)
Date: Thu, 19 Apr 2018 16:58:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419205820.GB4981@redhat.com>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
 <20180419143825.GA3519@redhat.com>
 <20180419144356.GC25406@bombadil.infradead.org>
 <20180419163036.GC3519@redhat.com>
 <1524157119.2943.6.camel@kernel.org>
 <20180419172609.GD3519@redhat.com>
 <20180419203307.GJ30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419203307.GJ30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@kernel.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 09:33:07PM +0100, Al Viro wrote:
> On Thu, Apr 19, 2018 at 01:26:10PM -0400, Jerome Glisse wrote:
> 
> > Basicly i want a callback in __fd_install(), do_dup2(), dup_fd() and
> > add void * *private_data; to struct fdtable (also a default array to
> > struct files_struct). The callback would be part of struct file_operations.
> > and only call if it exist (os overhead is only for device driver that
> > care).
> 
> Hell, *NO*.  This is insane - you would need to maintain extra counts
> ("how many descriptors refer to this struct file... for this descriptor
> table").
> 
> Besides, _what_ private_data?  What would own and maintain it?  A specific
> driver?  What if more than one of them wants that thing?

I hadn't something complex in mind (ie timelife link to struct file and
no refcouting changes). But anyway i gave up on that idea and will add
what i need in mmu_notifier.

>  
> > Did i miss something fundamental ? copy_files() call dup_fd() so i
> > should be all set here.
> 
> That looks like an extremely misguided kludge for hell knows what purpose,
> almost certainly architecturally insane.  What are you actually trying to
> achieve?

I need a struct to link part of device context with mm struct for a
process. Most of device context is link to the struct file of the
device file (ie process open has a file descriptor for the device
file).

Device driver for GPU have some part of their process context tied to
the process mm (accessing process address space directly from the GPU).
However we can not store this context information in the struct file
private data because of clone (same struct file accross different mm).

So today driver have an hashtable in their global device structure to
lookup context information for a given mm. This is sub-optimal and
duplicate a lot of code among different drivers.

Hence why i want something generic that allow a device driver to store
context structure that is specific to a mm. I thought that adding a
new array on the side of struct file array would be a good idea but it
has too many kludges.

So i will do something inside mmu_notifier and there will be no tie to
any fs aspect. I expect only a handful of driver to care about this and
for a given platform you won't see that many devices hence you won't
have that many pointer to deal with.

Cheers,
Jerome
