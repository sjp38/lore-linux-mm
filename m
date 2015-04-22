Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44A6D6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:07:43 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so86638331qge.3
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:07:43 -0700 (PDT)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id o7si5592551qko.101.2015.04.22.10.07.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 10:07:42 -0700 (PDT)
Received: by qkx62 with SMTP id 62so231026286qkx.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:07:42 -0700 (PDT)
Date: Wed, 22 Apr 2015 13:07:38 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422170737.GB4062@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 11:16:49AM -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Paul E. McKenney wrote:
> 
> > I completely agree that some critically important use cases, such as
> > yours, will absolutely require that the application explicitly choose
> > memory placement and have the memory stay there.
> 
> 
> 
> Most of what you are trying to do here is already there and has been done.
> GPU memory is accessible. NICs work etc etc. All without CAPI. What
> exactly are the benefits of CAPI? Is driver simplification? Reduction of
> overhead? If so then the measures proposed are a bit radical and
> may result in just the opposite.
> 

No, what Paul is trying to do, and what i am trying to do with HMM, does
not exist. This is share address space btw CPU and GPU/accelerator and
leveraging GPU local memory transparently at the same time.

Today world is GPU have different address space and complex data structure
like list or tree need to be replicated accross different address space.
You might not care for this but for lot of application this is a show
stopper and the outcome is using GPU is too complex because of that.

Now if you have the exact same address space then structure you have on
the CPU are exactly view in the same way on the GPU and you can start
porting library to leverage GPU without having to change a single line of
code inside many many many applications. It is also lot easier to debug
things as you do not have to strungly with two distinct address space.

Finaly, leveraging transparently the local GPU memory is the only way to
reach the full potential of the GPU. GPU are all about bandwidth and GPU
local memory have bandwidth far greater than any system memory i know
about. Here again if you can transparently leverage this memory without
the application ever needing to know about such subtlety.


But again let me stress that application that want to be in control will
stay in control. If you want to make the decission yourself about where
things should end up then nothing in all we are proposing will preclude
you from doing that. Please just think about others people application,
not just yours, they are a lot of others thing in the world and they do
not want to be as close to the metal as you want to be. We just want to
accomodate the largest number of use case.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
