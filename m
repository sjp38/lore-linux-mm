Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id AD3576B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 11:42:41 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so11282667qcr.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 08:42:41 -0700 (PDT)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id fb7si8497140qcb.28.2015.04.23.08.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 08:42:41 -0700 (PDT)
Received: by qgej70 with SMTP id j70so9973257qge.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 08:42:40 -0700 (PDT)
Date: Thu, 23 Apr 2015 11:42:30 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150423154229.GA2399@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com>
 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
 <1429756592.4915.23.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230907330.32297@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504230907330.32297@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, Apr 23, 2015 at 09:10:13AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:
> 
> > >  Anyone
> > > wanting performance (and that is the prime reason to use a GPU) would
> > > switch this off because the latencies are otherwise not controllable and
> > > those may impact performance severely. There are typically multiple
> > > parallel strands of executing that must execute with similar performance
> > > in order to allow a data exchange at defined intervals. That is no longer
> > > possible if you add variances that come with the "transparency" here.
> >
> > Stop trying to apply your unique usage model to the entire world :-)
> 
> Much of the HPC apps that the world is using is severely impacted by what
> you are proposing. Its the industries usage model not mine. That is why I
> was asking about the use case. Does not seem to fit the industry you are
> targeting. This is also the basic design principle that got GPUs to work
> as fast as they do today. Introducing random memory latencies there will
> kill much of the benefit of GPUs there too.

We obviously have different experience and i fear yours is restricted to
a specific uncommon application. You care about latency all my previous
experience (i developped application for HPC platform in the past) is
that latency is not the issue, throughput is. For instance i developed
on HPC where the data was coming from magnetic tape, latency here was
several minutes before the data starts streaming (yes a robot arm had
to pick the tape and load it into one of the available readers). All
people i interacted with accross various fields (physics, biology, data
mining) where not worried a bit about latency. They could not care more
about latency actually. What they care about was overall throughput and
ease of use.

You need to stop thinking HPC == low latency. Low latency is only useful
in time critical application such as the high frequency trading you seem
to care about. For people working on physics, biology, data mining, CAD,
... they do care more about throughput than latency. I strongly believe
here that this cover a far greater number of users of HPC than yours
(maybe not in term of money power ... alas).

On GPU front i have a lot of experience, more than 15 years working on
open source driver for them. I would like to think that i have a clue or
two on how they work. So when i say latency is not the primary concern
in most cases, i do mean it. GPU is about having many threads in flight
and hidding memory latency through this many threads. If you have
1000 "core" on a GPU and you have 5000 threads in flight then you have
big chance that no matter of memory latency for each clock cycle you
will still have 1000 threads ready to compute something.

I am not saying latency never matter, it is all about the kind of app
that is running and how much data it needs to consume and how much
thread the hw can keep in flight at the same time.

So yes, autonuma solution are worth investigating, as a matter of fact
even today driver actually use heuristic (taking into account hint
provided by userspace) to decide what to put into video memory or not.

For many applications the driver stack will be able to provide good
hint on what to migrate or not, but you still need to think multiple
process and so you need to share resources. This is the role of the
kernel to share resources among process, it always have been.


Now for your use case, you know before hand how many process there
gonna be and you can partition the resources accordingly and you make
better taylored decission on where things should reside. But again
this is not the common case. All HPC i know can not predict the number
of process nor partition resource for them. Program that run on those
system are updated frequently and you need to share resources with
others. For all those people and for people just working on a work
station the solution of autonuma is most likely the best. It might
not lead to 100% saturation of GPU but it will be good enough to
make a difference.

The numa code we have today for CPU case exist because it does make
a difference but you keep trying to restrict GPU user to a workload
that is specific. Go talk to people doing physic, biology, data
mining, CAD most of them do not care about latency. They have not
hard deadline to meet with their computation. They just want things
to compute as fast as possible and programming to be as easy as it
can get.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
