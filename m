Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id AA56B6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:05:04 -0400 (EDT)
Received: by iejt8 with SMTP id t8so86907683iej.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:05:04 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id f15si2359031igo.18.2015.04.24.09.03.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 09:04:18 -0700 (PDT)
Date: Fri, 24 Apr 2015 11:03:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424150829.GA3840@gmail.com>
Message-ID: <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
References: <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423161105.GB2399@gmail.com> <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Jerome Glisse wrote:

> On Fri, Apr 24, 2015 at 09:29:12AM -0500, Christoph Lameter wrote:
> > On Thu, 23 Apr 2015, Jerome Glisse wrote:
> >
> > > No this not have been solve properly. Today solution is doing an explicit
> > > copy and again and again when complex data struct are involve (list, tree,
> > > ...) this is extremly tedious and hard to debug. So today solution often
> > > restrict themself to easy thing like matrix multiplication. But if you
> > > provide a unified address space then you make things a lot easiers for a
> > > lot more usecase. That's a fact, and again OpenCL 2.0 which is an industry
> > > standard is a proof that unified address space is one of the most important
> > > feature requested by user of GPGPU. You might not care but the rest of the
> > > world does.
> >
> > You could use page tables on the kernel side to transfer data on demand
> > from the GPU. And you can use a device driver to establish mappings to the
> > GPUs memory.
> >
> > There is no copy needed with these approaches.
>
> So you are telling me to do get_user_page() ? If so you aware that this pins
> memory ? So what happens when the GPU wants to access a range of 32GB of
> memory ? I pin everything ?

Use either a device driver to create PTEs pointing to the data or do
something similar like what DAX does. Pinning can be avoided if you use
mmu_notifiers. Those will give you a callback before the OS removes the
data and thus you can operate without pinning.

> Overall the throughput of the GPU will stay close to its theoritical maximum
> if you have enough other thread that can progress and this is very common.

GPUs operate on groups of threads not single ones. If you stall
then there will be a stall of a whole group of them. We are dealing with
accellerators here that are different for performance reasons. They are
not to be treated like regular processor, nor is memory like
operating like host mmemory.

> But IBM here want to go further and to provide a more advance solution,
> so their need are specific to there platform and we can not know if AMD,
> ARM or Intel will want to go down the same road, they do not seem to be
> interested. Does it means we should not support IBM ? I think it would be
> wrong.

What exactly is the more advanced version's benefit? What are the features
that the other platforms do not provide?

> > This sounds more like a case for a general purpose processor. If it is a
> > special device then it will typically also have special memory to allow
> > fast searches.
>
> No this kind of thing can be fast on a GPU, with GPU you easily have x500
> more cores than CPU cores, so you can slice the dataset even more and have
> each of the GPU core perform the search. Note that i am not only thinking
> of stupid memcmp here it can be something more complex like searching a
> pattern that allow variation and that require a whole program to decide if
> a chunk falls under the variation rules or not.

Then you have the problem of fast memory access and you are proposing to
complicate that access path on the GPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
