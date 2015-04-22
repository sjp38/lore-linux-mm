Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1978A6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 14:18:01 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so49331039ied.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:18:00 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id w1si5156153icv.7.2015.04.22.11.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 11:18:00 -0700 (PDT)
Date: Wed, 22 Apr 2015 13:17:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422170737.GB4062@gmail.com>
Message-ID: <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 22 Apr 2015, Jerome Glisse wrote:

> Now if you have the exact same address space then structure you have on
> the CPU are exactly view in the same way on the GPU and you can start
> porting library to leverage GPU without having to change a single line of
> code inside many many many applications. It is also lot easier to debug
> things as you do not have to strungly with two distinct address space.

Right. That already works. Note however that GPU programming is a bit
different. Saying that the same code runs on the GPU is strong
simplification. Any effective GPU code still requires a lot of knowlege to
make it work in a high performant way.

The two distinct address spaces can be controlled already via a number of
mechanisms and there are ways from either side to access the other one.
This includes mmapping areas from the other side.

If you really want this then you should even be able to write a shared
library that does this.

> Finaly, leveraging transparently the local GPU memory is the only way to
> reach the full potential of the GPU. GPU are all about bandwidth and GPU
> local memory have bandwidth far greater than any system memory i know
> about. Here again if you can transparently leverage this memory without
> the application ever needing to know about such subtlety.

Well if you do this transparently then the GPU may not have access to its
data when it needs it. You are adding demand paging to the GPUs? The
performance would suffer significantly. AFAICT GPUs are not designed to
work like that and would not have optimal performance with such an
approach.

> But again let me stress that application that want to be in control will
> stay in control. If you want to make the decission yourself about where
> things should end up then nothing in all we are proposing will preclude
> you from doing that. Please just think about others people application,
> not just yours, they are a lot of others thing in the world and they do
> not want to be as close to the metal as you want to be. We just want to
> accomodate the largest number of use case.

What I think you want to do is to automatize something that should not be
automatized and cannot be automatized for performance reasons. Anyone
wanting performance (and that is the prime reason to use a GPU) would
switch this off because the latencies are otherwise not controllable and
those may impact performance severely. There are typically multiple
parallel strands of executing that must execute with similar performance
in order to allow a data exchange at defined intervals. That is no longer
possible if you add variances that come with the "transparency" here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
