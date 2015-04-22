Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id D9FFD6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:31:46 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so86104371qge.3
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:31:46 -0700 (PDT)
Received: from mail-qg0-x22c.google.com (mail-qg0-x22c.google.com. [2607:f8b0:400d:c04::22c])
        by mx.google.com with ESMTPS id dh6si5548369qcb.15.2015.04.22.09.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 09:31:46 -0700 (PDT)
Received: by qgdy78 with SMTP id y78so86114098qgd.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:31:45 -0700 (PDT)
Date: Wed, 22 Apr 2015 12:31:36 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422163135.GA4062@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 10:25:37AM -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Benjamin Herrenschmidt wrote:
> 
> > Right, it doesn't look at all like what we want.
> 
> Its definitely a way to map memory that is outside of the kernel managed
> pool into a user space process. For that matter any device driver could be
> doing this as well. The point is that we already have pletora of features
> to do this. Putting new requirements on the already
> warped-and-screwed-up-beyond-all-hope zombie of a page allocator that we
> have today is not the way to do this. In particular what I have head
> repeatedly is that we do not want kernel structures alllocated there but
> then we still want to use this because we want malloc support in
> libraries. The memory has different performance characteristics (for
> starters there may be lots of other isssues depending on the device) so we
> just add a NUMA "node" with estremely high distance.
> 
> There are hooks in glibc where you can replace the memory
> management of the apps if you want that.

Glibc hooks will not work, this is about having same address space on
CPU and GPU/accelerator while allowing backing memory to be regular
system memory or device memory all this in a transparent manner to
userspace program and library.

You also have to think at things like mmaped file, let say you have a
big file on disk and you want to crunch number from its data, you do
not want to copy it, instead you want to to the usual mmap and just
have device driver do migration to device memory (how device driver
make the decision is a different problem and this can be entirely
leave to the userspace application or their can be heuristic or both).

Glibc hooks do not work with share memory either and again this is
a usecase we care about. You really have to think of let's have today
applications start using those accelerators without the application
even knowing about it.

So you would not know before hand what will end up being use by the
GPU/accelerator and would need to be allocated from special memory.
We do not want today model of using GPU, we want to provide tomorrow
infrastructure for using GPU in a transparent way.


I understand that the application you care about wants to be clever
and can make better decission and we intend to support that, but this
does not need to be at the expense of all the others applications.
Like i said numerous time the decission to migrate memory is a device
driver decission and how the device driver make that decission can
be entirely control by userspace through proper device driver API.

The numa idea is interesting for application that do not know about
this and do not need to know. It would allow to have heuristic inside
the kernel, under the control of the device driver and that could be
disabled by application that know better.


Bottom line is we want today anonymous, share or file mapped memory
to stay the only kind of memory that exist and we want to choose the
backing store of each of those kind for better placement depending
on how memory is use (again which can be in the total control of
the application). But we do not want to introduce a third kind of
disjoint memory to userspace, this is today situation and we want
to move forward to tomorrow solution.


Cheers,
Jerome


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
