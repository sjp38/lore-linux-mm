Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 562858E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 05:21:57 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so33544257pgb.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 02:21:57 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g2si43813877plp.130.2019.01.07.02.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 02:21:56 -0800 (PST)
Date: Mon, 7 Jan 2019 18:21:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
Message-ID: <20190107102152.d3infdyw3zupu2xj@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.703380444@intel.com>
 <b99ef113-a9c1-f580-0fee-9f258b861391@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <b99ef113-a9c1-f580-0fee-9f258b861391@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Yao Yuan <yuan.yao@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 02, 2019 at 08:47:25AM -0800, Dave Hansen wrote:
>On 12/26/18 5:14 AM, Fengguang Wu wrote:
>> +static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
>> +{
>> +       struct page *page;
>> +
>> +       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
>> +       if (!page)
>> +	       return 0;
>> +       return (unsigned long) page_address(page);
>> +}
>
>There seems to be a ton of *policy* baked into these patches.  For
>instance: thou shalt not allocate page tables pages from PMEM.  That's
>surely not a policy we want to inflict on every Linux user until the end
>of time.

Right. It's straight forward policy for users that care performance.
The project is planned by 3 steps, at this moment we are in phase (1):

1) core functionalities, easy to backport
2) upstream-able total solution
3) upstream when API stabilized

The dumb kernel interface /proc/PID/idle_pages enables doing
the majority policies in user space. However for the other smaller
parts, it looks easier to just implement an obvious policy first.
Then to consider more possibilities.

>I think the more important question is how we can have the specific
>policy that this patch implements, but also leave open room for other
>policies, such as: "I don't care how slow this VM runs, minimize the
>amount of fast memory it eats."

Agreed. I'm open for more ways. We can treat these patches as the
soliciting version. If anyone send reasonable improvements or even
totally different way of doing it, I'd be happy to incorporate.

Thanks,
Fengguang
