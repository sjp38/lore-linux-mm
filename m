Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E53896B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 23:36:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r64so23586909ioi.10
        for <linux-mm@kvack.org>; Wed, 31 May 2017 20:36:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g66si1208100ite.33.2017.05.31.20.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 20:36:01 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
 <20170515193817.GC7551@dhcp22.suse.cz>
 <9b3d68aa-d2b6-2b02-4e75-f8372cbeb041@oracle.com>
 <20170516083601.GB2481@dhcp22.suse.cz>
 <07a6772b-711d-4fdc-f688-db76f1ec4c45@oracle.com>
 <20170529115358.GJ19725@dhcp22.suse.cz>
 <ae992f21-3edf-1ae7-41db-641052e411c7@oracle.com>
 <20170531163131.GY27783@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <2fa60098-d9be-f57d-cb86-3b55cfe915b7@oracle.com>
Date: Wed, 31 May 2017 23:35:48 -0400
MIME-Version: 1.0
In-Reply-To: <20170531163131.GY27783@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

> OK, so why cannot we make zero_struct_page 8x 8B stores, other arches
> would do memset. You said it would be slower but would that be
> measurable? I am sorry to be so persistent here but I would be really
> happier if this didn't depend on the deferred initialization. If this is
> absolutely a no-go then I can live with that of course.

Hi Michal,

This is actually a very good idea. I just did some measurements, and it 
looks like performance is very good.

Here is data from SPARC-M7 with 3312G memory with single thread performance:

Current:
memset() in memblock allocator takes: 8.83s
__init_single_page() take: 8.63s

Option 1:
memset() in __init_single_page() takes: 61.09s (as we discussed because 
of membar overhead, memset should really be optimized to do STBI only 
when size is 1 page or bigger).

Option 2:

8 stores (stx) in __init_single_page(): 8.525s!

So, even for single thread performance we can double the initialization 
speed of "struct page" on SPARC by removing memset() from memblock, and 
using 8 stx in __init_single_page(). It appears we never miss L1 in 
__init_single_page() after the initial 8 stx.

I will update patches with memset() on other platforms, and stx on SPARC.

My experimental code looks like this:

static void __meminit __init_single_page(struct page *page, unsigned 
long pfn, unsigned long zone, int nid)
{
         __asm__ __volatile__(
         "stx    %%g0, [%0 + 0x00]\n"
         "stx    %%g0, [%0 + 0x08]\n"
         "stx    %%g0, [%0 + 0x10]\n"
         "stx    %%g0, [%0 + 0x18]\n"
         "stx    %%g0, [%0 + 0x20]\n"
         "stx    %%g0, [%0 + 0x28]\n"
         "stx    %%g0, [%0 + 0x30]\n"
         "stx    %%g0, [%0 + 0x38]\n"
         :
         :"r"(page));
         set_page_links(page, zone, nid, pfn);
         init_page_count(page);
         page_mapcount_reset(page);
         page_cpupid_reset_last(page);

         INIT_LIST_HEAD(&page->lru);
#ifdef WANT_PAGE_VIRTUAL
         /* The shift won't overflow because ZONE_NORMAL is below 4G. */
         if (!is_highmem_idx(zone))
                 set_page_address(page, __va(pfn << PAGE_SHIFT));
#endif
}

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
