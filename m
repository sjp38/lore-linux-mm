Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 763238E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:47:27 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so27331715pgb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:47:27 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p186si9840382pgp.37.2019.01.02.08.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 08:47:26 -0800 (PST)
Subject: Re: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
References: <20181226131446.330864849@intel.com>
 <20181226133351.703380444@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b99ef113-a9c1-f580-0fee-9f258b861391@intel.com>
Date: Wed, 2 Jan 2019 08:47:25 -0800
MIME-Version: 1.0
In-Reply-To: <20181226133351.703380444@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Yao Yuan <yuan.yao@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On 12/26/18 5:14 AM, Fengguang Wu wrote:
> +static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
> +{
> +       struct page *page;
> +
> +       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
> +       if (!page)
> +	       return 0;
> +       return (unsigned long) page_address(page);
> +}

There seems to be a ton of *policy* baked into these patches.  For
instance: thou shalt not allocate page tables pages from PMEM.  That's
surely not a policy we want to inflict on every Linux user until the end
of time.

I think the more important question is how we can have the specific
policy that this patch implements, but also leave open room for other
policies, such as: "I don't care how slow this VM runs, minimize the
amount of fast memory it eats."
