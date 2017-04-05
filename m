Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37F2B6B03CC
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:55:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so3331778wrc.14
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:55:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e140si25857961wmd.56.2017.04.05.13.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:55:41 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v35KhoNg029719
	for <linux-mm@kvack.org>; Wed, 5 Apr 2017 16:55:39 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29n3d4dj0w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Apr 2017 16:55:39 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 5 Apr 2017 16:55:38 -0400
Date: Wed, 5 Apr 2017 15:55:29 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170404073412.GC15132@dhcp22.suse.cz>
 <20170404082302.GE15132@dhcp22.suse.cz>
 <20170404160239.ftvuxklioo6zvuxl@arbab-laptop>
 <20170404164452.GQ15132@dhcp22.suse.cz>
 <20170404183012.a6biape5y7vu6cjm@arbab-laptop>
 <20170404194122.GS15132@dhcp22.suse.cz>
 <20170404214339.6o4c4uhwudyhzbbo@arbab-laptop>
 <20170405064239.GB6035@dhcp22.suse.cz>
 <20170405154852.kdkwuudjv2jwvj5g@arbab-laptop>
 <20170405163439.GS6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170405163439.GS6035@dhcp22.suse.cz>
Message-Id: <20170405205529.2bs4yhrfffmkwi5g@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Apr 05, 2017 at 06:34:39PM +0200, Michal Hocko wrote:
>This is really interesting. Because add_memory_resource does the
>following
>	/* call arch's memory hotadd */
>	ret = arch_add_memory(nid, start, size);
>
>	if (ret < 0)
>		goto error;
>
>	/* we online node here. we can't roll back from here. */
>	node_set_online(nid);
>
>so we are setting the node online _after_ arch_add_memory but the code
>which adds those sysfs file is called from
>
>arch_add_memory
>  __add_pages
>    __add_section
>      register_new_memory
>        register_mem_sect_under_node
>          node_online check

Okay, so it turns out the original code ends up creating the sysfs links 
not here, but just a little bit afterwards.

add_memory
  add_memory_resource
    arch_add_memory
      [your quoted stack trace above]
    ...
    set_node_online
    ...
    register_one_node
      link_mem_sections
	register_mem_sect_under_node

The reason they're not getting created now is because 
NODE_DATA(nid)->node_spanned_pages = 0 at this point.

link_mem_sections: nid=1, start_pfn=0x10000, end_pfn=0x10000

This is another uninitialized situation, like the one with 
node_start_pfn which caused my removal crash. Except here I'm not sure 
the correct place to splice in and set it.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
