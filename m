Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4D95C900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 20:50:05 -0400 (EDT)
Received: by iget9 with SMTP id t9so95380747ige.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:50:05 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id qe2si12156766igb.46.2015.04.21.17.50.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 17:50:04 -0700 (PDT)
Date: Tue, 21 Apr 2015 19:50:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422000538.GB6046@gmail.com>
Message-ID: <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 21 Apr 2015, Jerome Glisse wrote:

> Memory on this device should not be considered as something special
> (even if it is). More below.

Uhh?

> So big use case here, let say you have an application that rely on a
> scientific library that do matrix computation. Your application simply
> use malloc and give pointer to this scientific library. Now let say
> the good folks working on this scientific library wants to leverage
> the GPU, they could do it by allocating GPU memory through GPU specific
> API and copy data in and out. For matrix that can be easy enough, but
> still inefficient. What you really want is the GPU directly accessing
> this malloced chunk of memory, eventualy migrating it to device memory
> while performing the computation and migrating it back to system memory
> once done. Which means that you do not want some kind of filesystem or
> anything like that.

With a filesystem the migration can be controlled by the application. It
can copy stuff whenever it wants to.Having the OS do that behind my back
is not something that feels safe and secure.

> By allowing transparent migration you allow library to just start using
> the GPU without the application being non the wiser about that. More
> over when you start playing with data set that use more advance design
> pattern (list, tree, vector, a mix of all the above) you do not want
> to have to duplicate the list for the GPU address space and for the
> regular CPU address space (which you would need to do in case of a
> filesystem solution).

There is no need for duplication if both address spaces use the same
addresses. F.e. DAX would allow you to mmap arbitrary portions of memory
of the GPU into a process space. Since this is cache coherent both
processor cache and coprocessor cache would be able to hold cachelines
from the device or from main memory.

> So the corner stone of HMM and Paul requirement are the same, we want
> to be able to move normal anonymous memory as well as regular file
> backed page to device memory for some period of time while at the same
> time allowing the usual memory management to keep going as if nothing
> was different.

This still sounds pretty wild and is doing major changes to core OS
mechanisms with little reason from that I can see. There are already
mechanisms in place that do what you want.

> Paul is working on a platform that is more advance that the one HMM try
> to address and i believe the x86 platform will not have functionality
> such a CAPI, at least it is not part of any roadmap i know about for
> x86.

We will be one of the first users of Paul's Platform. Please do not do
crazy stuff but give us a sane solution where we can control the
hardware. No strange VM hooks that automatically move stuff back and forth
please. If you do this we will have to disable them anyways because they
would interfere with our needs to have the code not be disturbed by random
OS noise. We need detailed control as to when and how we move data.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
