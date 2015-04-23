Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id DB06B6B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:01:01 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so14285638qcb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:01:01 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id o18si8933259qkh.111.2015.04.23.12.01.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 12:01:01 -0700 (PDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 23 Apr 2015 13:01:00 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2ECC71FF0026
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:52:08 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3NJ0v0f44302410
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:00:57 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3NJ0vYf017581
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 13:00:57 -0600
Date: Thu, 23 Apr 2015 12:00:56 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150423190056.GP5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <1429756070.4915.17.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230914060.32297@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504230914060.32297@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, Apr 23, 2015 at 09:20:55AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:
> 
> > > There are hooks in glibc where you can replace the memory
> > > management of the apps if you want that.
> >
> > We don't control the app. Let's say we are doing a plugin for libfoo
> > which accelerates "foo" using GPUs.
> 
> There are numerous examples of malloc implementation that can be used for
> apps without modifying the app.

Except that the app might be mapping a file or operating on a big
array in bss instead of (or as well as) using malloc()ed memory.

> > Now some other app we have no control on uses libfoo. So pointers
> > already allocated/mapped, possibly a long time ago, will hit libfoo (or
> > the plugin) and we need GPUs to churn on the data.
> 
> IF the GPU would need to suspend one of its computation thread to wait on
> a mapping to be established on demand or so then it looks like the
> performance of the parallel threads on a GPU will be significantly
> compromised. You would want to do the transfer explicitly in some fashion
> that meshes with the concurrent calculation in the GPU. You do not want
> stalls while GPU number crunching is ongoing.

Yep.  But for throughput-oriented applications, as long as stalls don't
happen very often, this can be OK.

> > The point I'm making is you are arguing against a usage model which has
> > been repeatedly asked for by large amounts of customer (after all that's
> > also why HMM exists).
> 
> I am still not clear what is the use case for this would be. Who is asking
> for this?

Ben and I are.  I have added a use case, which I will send out shortly
with the next version.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
