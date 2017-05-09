Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A350E28035A
	for <linux-mm@kvack.org>; Tue,  9 May 2017 14:55:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z15so6809133ite.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 11:55:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u80si872881ioi.16.2017.05.09.11.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 11:55:03 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <fae4a92c-e78c-32cb-606a-8e5087acb13f@oracle.com>
Date: Tue, 9 May 2017 14:54:50 -0400
MIME-Version: 1.0
In-Reply-To: <20170509181234.GA4397@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

Hi Michal,

> I like the idea of postponing the zeroing from the allocation to the
> init time. To be honest the improvement looks much larger than I would
> expect (Btw. this should be a part of the changelog rather than a
> outside link).

The improvements are larger, because this time was never measured, as 
Linux does not have early boot time stamps. I added them for x86 and 
SPARC to emasure the performance. I am pushing those changes through 
separate patchsets.

> 
> The implementation just looks too large to what I would expect. E.g. do
> we really need to add zero argument to the large part of the memblock
> API? Wouldn't it be easier to simply export memblock_virt_alloc_internal
> (or its tiny wrapper memblock_virt_alloc_core) and move the zeroing
> outside to its 2 callers? A completely untested scratched version at the
> end of the email.

I am OK, with this change. But, I do not really see a difference between:

memblock_virt_alloc_raw()
and
memblock_virt_alloc_core()

In both cases we use memblock_virt_alloc_internal(), but the only 
difference is that in my case we tell memblock_virt_alloc_internal() to 
zero the pages if needed, and in your case the other two callers are 
zeroing it. I like moving memblock_dbg() inside 
memblock_virt_alloc_internal()

> 
> Also it seems that this is not 100% correct either as it only cares
> about VMEMMAP while DEFERRED_STRUCT_PAGE_INIT might be enabled also for
> SPARSEMEM. This would suggest that we would zero out pages twice,
> right?

Thank you, I will check this combination before sending out the next patch.

> 
> A similar concern would go to the memory hotplug patch which will
> fall back to the slab/page allocator IIRC. On the other hand
> __init_single_page is shared with the hotplug code so again we would
> initialize 2 times.

Correct, when memory it hotplugged, to gain the benefit of this fix, and 
also not to regress by actually double zeroing "struct pages" we should 
not zero it out. However, I do not really have means to test it.

> 
> So I suspect more changes are needed. I will have a closer look tomorrow.

Thank you for reviewing this work. I will wait for your comments before 
sending out updated patches.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
