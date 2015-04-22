Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 988236B0038
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 14:52:35 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so4930081igb.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:52:35 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id n83si4944401ioe.33.2015.04.22.11.52.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 11:52:35 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Apr 2015 12:52:34 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 8E7251FF0025
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:43:43 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3MIqCrY35324134
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:52:12 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3MIqWuS009105
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:52:32 -0600
Date: Wed, 22 Apr 2015 11:52:30 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422185230.GD5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com>
 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 01:17:58PM -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Jerome Glisse wrote:
> 
> > Now if you have the exact same address space then structure you have on
> > the CPU are exactly view in the same way on the GPU and you can start
> > porting library to leverage GPU without having to change a single line of
> > code inside many many many applications. It is also lot easier to debug
> > things as you do not have to strungly with two distinct address space.
> 
> Right. That already works. Note however that GPU programming is a bit
> different. Saying that the same code runs on the GPU is strong
> simplification. Any effective GPU code still requires a lot of knowlege to
> make it work in a high performant way.
> 
> The two distinct address spaces can be controlled already via a number of
> mechanisms and there are ways from either side to access the other one.
> This includes mmapping areas from the other side.

I believe that the two of you are talking about two distinct but closely
related use cases.  Christoph wants full performance, and is willing to
put quite a bit of development effort into getting the last little bit.
Jerome is looking to get most of the performance, but where modifications
are limited to substituting a different library.

> If you really want this then you should even be able to write a shared
> library that does this.

>From what I can see, this is indeed Jerome's goal, but he needs to be
able to do this without having to go through the program and work out
which malloc() calls should work as before and which should allocate
from device memory.

> > Finaly, leveraging transparently the local GPU memory is the only way to
> > reach the full potential of the GPU. GPU are all about bandwidth and GPU
> > local memory have bandwidth far greater than any system memory i know
> > about. Here again if you can transparently leverage this memory without
> > the application ever needing to know about such subtlety.
> 
> Well if you do this transparently then the GPU may not have access to its
> data when it needs it. You are adding demand paging to the GPUs? The
> performance would suffer significantly. AFAICT GPUs are not designed to
> work like that and would not have optimal performance with such an
> approach.

Agreed, the use case that Jerome is thinking of differs from yours.
You would not (and should not) tolerate things like page faults because
it would destroy your worst-case response times.  I believe that Jerome
is more interested in throughput with minimal change to existing code.

> > But again let me stress that application that want to be in control will
> > stay in control. If you want to make the decission yourself about where
> > things should end up then nothing in all we are proposing will preclude
> > you from doing that. Please just think about others people application,
> > not just yours, they are a lot of others thing in the world and they do
> > not want to be as close to the metal as you want to be. We just want to
> > accomodate the largest number of use case.
> 
> What I think you want to do is to automatize something that should not be
> automatized and cannot be automatized for performance reasons. Anyone
> wanting performance (and that is the prime reason to use a GPU) would
> switch this off because the latencies are otherwise not controllable and
> those may impact performance severely. There are typically multiple
> parallel strands of executing that must execute with similar performance
> in order to allow a data exchange at defined intervals. That is no longer
> possible if you add variances that come with the "transparency" here.

Let's suppose that you and Jerome were using GPGPU hardware that had
32,768 hardware threads.  You would want very close to 100% of the full
throughput out of the hardware with pretty much zero unnecessary latency.
In contrast, Jerome might be OK with (say) 20,000 threads worth of
throughput with the occasional latency hiccup.

And yes, support for both use cases is needed.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
