Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A66988E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 19:35:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so42928pfn.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:35:36 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 19-v6si23397469pgy.577.2018.09.11.16.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 16:35:35 -0700 (PDT)
Subject: Re: [RFC v9 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
 <20180911211645.GA12159@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b69d3f7d-e9ba-b95c-45cd-44489950751b@linux.alibaba.com>
Date: Tue, 11 Sep 2018 16:35:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180911211645.GA12159@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/11/18 2:16 PM, Matthew Wilcox wrote:
> On Wed, Sep 12, 2018 at 04:58:11AM +0800, Yang Shi wrote:
>>   mm/mmap.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> I really think you're going about this the wrong way by duplicating
> vm_munmap().

If we don't duplicate vm_munmap() or do_munmap(), we need pass an extra 
parameter to them to tell when it is fine to downgrade write lock or if 
the lock has been acquired outside it (i.e. in mmap()/mremap()), right? 
But, vm_munmap() or do_munmap() is called not only by mmap-related, but 
also some other places, like arch-specific places, which don't need 
downgrade write lock or are not safe to do so.

Actually, I did this way in the v1 patches, but it got pushed back by 
tglx who suggested duplicate the code so that the change could be done 
in mm only without touching other files, i.e. arch-specific stuff. I 
didn't have strong argument to convince him.

And, Michal prefers have VM_HUGETLB and VM_PFNMAP handled separately for 
safe and bisectable sake, which needs call the regular do_munmap().

In addition to this, I just found mpx code may call do_munmap() 
recursively when I was looking into the mpx code.

We might be able to handle these by the extra parameter, but it sounds 
it make the code hard to understand and error prone.

Thanks,
Yang
