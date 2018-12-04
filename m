Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C365A6B6D7E
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:22:55 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so7582397edt.23
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:22:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18si8386578edl.65.2018.12.03.23.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:22:54 -0800 (PST)
Date: Tue, 4 Dec 2018 08:22:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181204072251.GT31738@dhcp22.suse.cz>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue 04-12-18 11:05:57, Pingfan Liu wrote:
> During my test on some AMD machine, with kexec -l nr_cpus=x option, the
> kernel failed to bootup, because some node's data struct can not be allocated,
> e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
> device->numa_node info is used as preferred_nid param for
> __alloc_pages_nodemask(), which causes NULL reference
>   ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
> This patch tries to fix the issue by falling back to the first online node,
> when encountering such corner case.

We have seen similar issues already and the bug was usually that the
zonelists were not initialized yet or the node is completely bogus.
Zonelists should be initialized by build_all_zonelists quite early so I
am wondering whether the later is the case. What is the actual node
number the device is associated with?

Your patch is not correct btw, because we want to fallback into the node in
the distance order rather into the first online node.
-- 
Michal Hocko
SUSE Labs
