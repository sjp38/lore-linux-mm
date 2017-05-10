Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95296280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 03:24:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so5735464wrd.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 00:24:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p187si2653395wmd.93.2017.05.10.00.24.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 00:24:21 -0700 (PDT)
Date: Wed, 10 May 2017 09:24:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170510072419.GC31466@dhcp22.suse.cz>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <fae4a92c-e78c-32cb-606a-8e5087acb13f@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fae4a92c-e78c-32cb-606a-8e5087acb13f@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Tue 09-05-17 14:54:50, Pasha Tatashin wrote:
[...]
> >The implementation just looks too large to what I would expect. E.g. do
> >we really need to add zero argument to the large part of the memblock
> >API? Wouldn't it be easier to simply export memblock_virt_alloc_internal
> >(or its tiny wrapper memblock_virt_alloc_core) and move the zeroing
> >outside to its 2 callers? A completely untested scratched version at the
> >end of the email.
> 
> I am OK, with this change. But, I do not really see a difference between:
> 
> memblock_virt_alloc_raw()
> and
> memblock_virt_alloc_core()
> 
> In both cases we use memblock_virt_alloc_internal(), but the only difference
> is that in my case we tell memblock_virt_alloc_internal() to zero the pages
> if needed, and in your case the other two callers are zeroing it. I like
> moving memblock_dbg() inside memblock_virt_alloc_internal()

Well, I didn't object to this particular part. I was mostly concerned
about
http://lkml.kernel.org/r/1494003796-748672-4-git-send-email-pasha.tatashin@oracle.com
and the "zero" argument for other functions. I guess we can do without
that. I _think_ that we should simply _always_ initialize the page at the
__init_single_page time rather than during the allocation. That would
require dropping __GFP_ZERO for non-memblock allocations. Or do you
think we could regress for single threaded initialization?

> >Also it seems that this is not 100% correct either as it only cares
> >about VMEMMAP while DEFERRED_STRUCT_PAGE_INIT might be enabled also for
> >SPARSEMEM. This would suggest that we would zero out pages twice,
> >right?
> 
> Thank you, I will check this combination before sending out the next patch.
> 
> >
> >A similar concern would go to the memory hotplug patch which will
> >fall back to the slab/page allocator IIRC. On the other hand
> >__init_single_page is shared with the hotplug code so again we would
> >initialize 2 times.
> 
> Correct, when memory it hotplugged, to gain the benefit of this fix, and
> also not to regress by actually double zeroing "struct pages" we should not
> zero it out. However, I do not really have means to test it.

It should be pretty easy to test with kvm, but I can help with testing
on the real HW as well.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
