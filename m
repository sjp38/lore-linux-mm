Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D29D36B0269
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 11:21:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z190so212613488qkc.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:21:26 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id 86si13742842qkx.336.2016.10.25.08.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 08:21:25 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id x11so4629013qka.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:21:25 -0700 (PDT)
Date: Tue, 25 Oct 2016 11:21:17 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161025152052.GA6131@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <24fce2e8-e2e9-a665-f2a0-b7902a337c5d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <24fce2e8-e2e9-a665-f2a0-b7902a337c5d@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

On Tue, Oct 25, 2016 at 11:07:39PM +1100, Balbir Singh wrote:
> On 25/10/16 04:09, Jerome Glisse wrote:
> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
> > 
> >> [...]
> > 
> >> 	Core kernel memory features like reclamation, evictions etc. might
> >> need to be restricted or modified on the coherent device memory node as
> >> they can be performance limiting. The RFC does not propose anything on this
> >> yet but it can be looked into later on. For now it just disables Auto NUMA
> >> for any VMA which has coherent device memory.
> >>
> >> 	Seamless integration of coherent device memory with system memory
> >> will enable various other features, some of which can be listed as follows.
> >>
> >> 	a. Seamless migrations between system RAM and the coherent memory
> >> 	b. Will have asynchronous and high throughput migrations
> >> 	c. Be able to allocate huge order pages from these memory regions
> >> 	d. Restrict allocations to a large extent to the tasks using the
> >> 	   device for workload acceleration
> >>
> >> 	Before concluding, will look into the reasons why the existing
> >> solutions don't work. There are two basic requirements which have to be
> >> satisfies before the coherent device memory can be integrated with core
> >> kernel seamlessly.
> >>
> >> 	a. PFN must have struct page
> >> 	b. Struct page must able to be inside standard LRU lists
> >>
> >> 	The above two basic requirements discard the existing method of
> >> device memory representation approaches like these which then requires the
> >> need of creating a new framework.
> > 
> > I do not believe the LRU list is a hard requirement, yes when faulting in
> > a page inside the page cache it assumes it needs to be added to lru list.
> > But i think this can easily be work around.
> > 
> > In HMM i am using ZONE_DEVICE and because memory is not accessible from CPU
> > (not everyone is bless with decent system bus like CAPI, CCIX, Gen-Z, ...)
> > so in my case a file back page must always be spawn first from a regular
> > page and once read from disk then i can migrate to GPU page.
> > 
> 
> I've not seen the HMM patchset, but read from disk will go to ZONE_DEVICE?
> Then get migrated?

Because in my case device memory is not accessible by anything except the device
(not entirely true but for sake of design it is) any page read from disk will be
first read into regular page (from regular system memory). It is only once it is
uptodate and in page cache that it can be migrated to a ZONE_DEVICE page.

So read from disk use an intermediary page. Write back is kind of the same i plan
on using a bounce page by leveraging existing bio bounce infrastructure.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
