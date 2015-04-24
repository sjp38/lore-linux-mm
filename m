Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6850E6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:00:54 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so28071763qcr.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:00:54 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id j90si11759613qgd.49.2015.04.24.09.00.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 09:00:53 -0700 (PDT)
Received: by qku63 with SMTP id 63so32533310qku.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:00:53 -0700 (PDT)
Date: Fri, 24 Apr 2015 12:00:49 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424160048.GC3840@gmail.com>
References: <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423185240.GO5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 09:30:40AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
> > If by "entire industry" you mean everyone who might want to use hardware
> > acceleration, for example, including mechanical computer-aided design,
> > I am skeptical.
> 
> The industry designs GPUs with super fast special ram and accellerators
> with special ram designed to do fast searches and you think you can demand page
> that stuff in from the main processor?
> 

Why do you think AMD and NVidia are adding page fault support to their GPU
in the first place ? They are not doing this on a whim, they have carefully
thought about that.

Are you saying you know better than the 2 biggest GPU designer on the planet ?
And who do you think is pushing for such thing in the kernel ? Do you think
we are working on this on a whim ? Because we woke up one day and thought that
it would be cool and that it should be done this way ?


Yes if all your GPU do is pagefault it will be disastrous, but is this the
usual thing we see on CPU ? No ! Are people complaining about the numerous
page fault that happens over a day ? No, the vast majority of user are
completely oblivious to page fault. This is how it works on CPU and yes this
can work for GPU too. What happens on CPU ? Well CPU can switch to work on
a different thread or a different application altogether. The same thing will
happen on the GPU. If you have enough jobs, your GPU will be busy and you
will never worry about page fault because overall your GPU will deliver the
same kind of throughput as if there was no pagefault. It can very well be
buried into the overall noise if the ratio of available runnable thread
versus page faulting thread is high enough. Which is most of the time the
case for the CPU, why would the same assumption not work on the GPU ?

Note that i am not dismissing low latency folks, i know they exist, i know
they hate page fault and in no way what we propose will make it worse for
them. They will be able to keep the same kind of control they cherish but
this does not mean you should go on a holy crusade to pretend that other
people workload does not exist. They do exist. Page fault is not evil and
it has prove usefull to the whole computer industry for CPU.


To be sure you are not misinterpretting what we propose, in no way we say
we gonna migrate thing on page fault for everyone. We are saying first
the device driver decide where thing need to be (system memory or local
memory) device driver can get hint/request from userspace for this (as they
do today). So no change whatsoever here, people that hand tune things will
keep being able to do so.

Now we want to add the case where device driver do not get any kind of
directive or hint from userspace. So what autonuma is, simply collect
informations from the GPU on what is access often and then migrate this
transparently (yes this can happen without interruption to GPU). So you
are migrating from a memory that has 16GB/s or 32GB/s bandwidth to the
device memory that have 500GB/s.

This is a valid usecase, they are many people outthere that do not want
to learn about hand tuning there application for the GPU but they could
nonetheless benefit from it.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
