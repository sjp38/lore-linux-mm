Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C857C6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 17:51:38 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up7so1289898pbc.40
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 14:51:38 -0700 (PDT)
Received: from psmtp.com ([74.125.245.162])
        by mx.google.com with SMTP id js8si3130642pbc.284.2013.10.23.14.51.37
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 14:51:37 -0700 (PDT)
Message-ID: <526844E6.1080307@codeaurora.org>
Date: Wed, 23 Oct 2013 14:51:34 -0700
From: Olav Haugan <ohaugan@codeaurora.org>
MIME-Version: 1.0
Subject: zram/zsmalloc issues in very low memory conditions
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sjenning@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

I am trying to use zram in very low memory conditions and I am having
some issues. zram is in the reclaim path. So if the system is very low
on memory the system is trying to reclaim pages by swapping out (in this
case to zram). However, since we are very low on memory zram fails to
get a page from zsmalloc and thus zram fails to store the page. We get
into a cycle where the system is low on memory so it tries to swap out
to get more memory but swap out fails because there is not enough memory
in the system! The major problem I am seeing is that there does not seem
to be a way for zram to tell the upper layers to stop swapping out
because the swap device is essentially "full" (since there is no more
memory available for zram pages). Has anyone thought about this issue
already and have ideas how to solve this or am I missing something and I
should not be seeing this issue?

I am also seeing a couple other issues that I was wondering whether
folks have already thought about:

1) The size of a swap device is statically computed when the swap device
is turned on (nr_swap_pages). The size of zram swap device is dynamic
since we are compressing the pages and thus the swap subsystem thinks
that the zram swap device is full when it is not really full. Any
plans/thoughts about the possibility of being able to update the size
and/or the # of available pages in a swap device on the fly?

2) zsmalloc fails when the page allocated is at physical address 0 (pfn
= 0) since the handle returned from zsmalloc is encoded as (<PFN>,
<obj_idx>) and thus the resulting handle will be 0 (since obj_idx starts
at 0). zs_malloc returns the handle but does not distinguish between a
valid handle of 0 and a failure to allocate. A possible solution to this
would be to start the obj_idx at 1. Is this feasible?

Thanks,

Olav Haugan

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
