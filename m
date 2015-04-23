Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 09A936B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 22:28:02 -0400 (EDT)
Received: by vnbf129 with SMTP id f129so341925vnb.9
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 19:28:01 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id lz1si6490515vdb.3.2015.04.22.19.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 19:28:00 -0700 (PDT)
Message-ID: <1429756070.4915.17.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Apr 2015 12:27:50 +1000
In-Reply-To: <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <1429663372.27410.75.camel@kernel.crashing.org>
	 <20150422005757.GP5561@linux.vnet.ibm.com>
	 <1429664686.27410.84.camel@kernel.crashing.org>
	 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 2015-04-22 at 10:25 -0500, Christoph Lameter wrote:
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

We don't control the app. Let's say we are doing a plugin for libfoo
which accelerates "foo" using GPUs.

Now some other app we have no control on uses libfoo. So pointers
already allocated/mapped, possibly a long time ago, will hit libfoo (or
the plugin) and we need GPUs to churn on the data.

The point I'm making is you are arguing against a usage model which has
been repeatedly asked for by large amounts of customer (after all that's
also why HMM exists).

We should focus on how to make this happen rather than trying to shovel
a *different* model that removes transparency from the equation into the
user faces.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
