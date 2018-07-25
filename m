Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB1046B02BE
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:20:47 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z18-v6so6522208qki.22
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:20:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e2-v6si1537389qki.380.2018.07.25.07.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 07:20:46 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <8eb22489-fa6b-9825-bc63-07867a40d59b@redhat.com>
 <20180724131343.GK28386@dhcp22.suse.cz>
 <af5353ee-319e-17ec-3a39-df997a5adf43@redhat.com>
 <20180724133530.GN28386@dhcp22.suse.cz>
 <6c753cae-f8b6-5563-e5ba-7c1fefdeb74e@redhat.com>
 <20180725135147.GN28386@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <344d5f15-c621-9973-561e-6ed96b29ea88@redhat.com>
Date: Wed, 25 Jul 2018 16:20:41 +0200
MIME-Version: 1.0
In-Reply-To: <20180725135147.GN28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 25.07.2018 15:51, Michal Hocko wrote:
> On Tue 24-07-18 16:13:09, David Hildenbrand wrote:
> [...]
>> So I see right now:
>>
>> - Pg_reserved + e.g. new page type (or some other unique identifier in
>>   combination with Pg_reserved)
>>  -> Avoid reads of pages we know are offline
>> - extend is_ram_page()
>>  -> Fake zero memory for pages we know are offline
>>
>> Or even both (avoid reading and don't crash the kernel if it is being done).
> 
> I really fail to see how that can work without kernel being aware of
> PageOffline. What will/should happen if you run an old kdump tool on a
> kernel with this partially offline memory?
> 

New kernel with old dump tool:

a) we have not fixed up is_ram_page()

-> crash, as we access memory we shouldn't

b) we have fixed up is_ram_page()

-> We have a callback to check for applicable memory in the hypervisor
whether the parts are accessible / online or not accessible / offline.
(e.g. via a device driver that controls a certain memory region)

-> Don't read, but fake a page full of 0


So instead of the kernel being aware of it, it asks via is_ram_page()
the hypervisor.


I don't think a) is a problem. AFAICS, we have to update makedumpfile
for every new kernel. We can perform changes and update makedumpfile
to be compatible with new dump tools.

E.g. remember SECTION_IS_ONLINE you introduced ? It broke dump
tools and required

commit 4bf4f2b0a855ccf4c7ffe13290778e92b2f5bbc9
Author: Pratyush Anand <panand@redhat.com>
Date:   Thu Aug 17 12:47:13 2017 +0900

    [PATCH v2] Fix SECTION_MAP_MASK for kernel >= v.13
    
    * Required for kernel 4.13
    
    commit 2d070eab2e82 "mm: consider zone which is not fully populated to
    have holes" added a new flag SECTION_IS_ONLINE and therefore
    SECTION_MAP_MASK has been changed. We are not able to find correct
    mem_map in makedumpfile for kernel version v4.13-rc1 and onward because
    of the above kernel change.
    
    This patch fixes the MASK value keeping the code backward compatible
    
    Signed-off-by: Pratyush Anand <panand@redhat.com>


Same would apply for the new combination of PageReserved + X, where we
tell dump tools to exclude this page.

-- 

Thanks,

David / dhildenb
