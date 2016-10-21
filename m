Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5B936B0038
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 13:40:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so57916168pfi.7
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 10:40:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z18si3533673pfk.163.2016.10.21.10.40.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 10:40:21 -0700 (PDT)
Date: Fri, 21 Oct 2016 10:40:20 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH v2 0/8] mm/swap: Regular page swap optimizations
Message-ID: <20161021174020.GA29180@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
 <fe4d056b-5a96-c208-f6bd-32a265482c56@de.ibm.com>
 <ffa08555-c170-7c6b-0c7e-798e9988adba@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ffa08555-c170-7c6b-0c7e-798e9988adba@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Fri, Oct 21, 2016 at 12:05:19PM +0200, Christian Borntraeger wrote:
> On 10/21/2016 10:16 AM, Christian Borntraeger wrote:
> > [  308.206297] Call Trace:
> > [  308.206299] ([<000000000025d3ec>] __alloc_pages_nodemask+0x134/0xdf8)
> > [  308.206303] ([<0000000000280d6a>] kmalloc_order+0x42/0x70)
> > [  308.206305] ([<0000000000280dd8>] kmalloc_order_trace+0x40/0xf0)
> > [  308.206310] ([<00000000002a7090>] init_swap_address_space+0x68/0x138)
> > [  308.206312] ([<00000000002ac858>] SyS_swapon+0xbd0/0xf80)
> > [  308.206317] ([<0000000000785476>] system_call+0xd6/0x264)
> > [  308.206318] Last Breaking-Event-Address:
> > [  308.206319]  [<000000000025db38>] __alloc_pages_nodemask+0x880/0xdf8
> > [  308.206320] ---[ end trace aaeca736f47ac05b ]---
> > 
> 
> Looks like that 1TB of swap is just too big for your logic (you try kmalloc without checking the size).
> 

Thanks for giving this patch series a spin.
Let's use vzalloc instead.  Can you try the following change.

Thanks.

Tim

--->8---
diff --git a/mm/swap_state.c b/mm/swap_state.c
index af4ed5f..0f84526 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -526,11 +526,9 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 	unsigned int i, nr;
 
 	nr = DIV_ROUND_UP(nr_pages, SWAP_ADDRESS_SPACE_PAGES);
-	spaces = kzalloc(sizeof(struct address_space) * nr, GFP_KERNEL);
+	spaces = vzalloc(sizeof(struct address_space) * nr);
 	if (!spaces) {
-		spaces = vzalloc(sizeof(struct address_space) * nr);
-		if (!spaces)
-			return -ENOMEM;
+		return -ENOMEM;
 	}
 	for (i = 0; i < nr; i++) {
 		space = spaces + i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
