Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2586B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 04:16:47 -0400 (EDT)
Received: by wijp15 with SMTP id p15so8788272wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 01:16:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fs15si11283362wic.53.2015.08.20.01.16.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 01:16:45 -0700 (PDT)
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D58CEB.9070701@suse.cz>
Date: Thu, 20 Aug 2015 10:16:43 +0200
MIME-Version: 1.0
In-Reply-To: <55D4A462.3070505@internode.on.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 08/19/2015 05:44 PM, Arthur Marsh wrote:
> Hi, I've found that the Linus' git head kernel has had some unwelcome
> behaviour where chromium browser would exhaust all swap space in the
> course of a few hours. The behaviour appeared before the release of
> 4.2.0-rc7.

Do you have any more details about the memory/swap usage? Is it really 
that chromium process(es) itself eats more memory and starts swapping, 
or that something else (a graphics driver?) eats kernel memory, and 
chromium as one of the biggest processes is driven to swap by that? Can 
you provide e.g. top output with good/bad kernels?

Also what does /proc/meminfo and /proc/zoneinfo look like when it's 
swapping?

To see which processes use swap, you can try [1] :
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ 
print ""}' $file; done | sort -k 2 -n -r | less

Thanks

[1] http://www.cyberciti.biz/faq/linux-which-process-is-using-swap/

> This does not happen with kernel 4.2.0-rc6.
>
> When I tried a git-bisect, the results where not conclusive due to the
> problem taking over an hour to appear after booting, the closest I came
> was around this commit (the actual problem may be a few commits either
> side):
>
> git bisect good
> 4f258a46346c03fa0bbb6199ffaf4e1f9f599660 is the first bad commit
> commit 4f258a46346c03fa0bbb6199ffaf4e1f9f599660
> Author: Martin K. Petersen <martin.petersen@oracle.com>
> Date:   Tue Jun 23 12:13:59 2015 -0400
>
>       sd: Fix maximum I/O size for BLOCK_PC requests
>
>       Commit bcdb247c6b6a ("sd: Limit transfer length") clamped the maximum
>       size of an I/O request to the MAXIMUM TRANSFER LENGTH field in the
> BLOCK
>       LIMITS VPD. This had the unfortunate effect of also limiting the
> maximum
>       size of non-filesystem requests sent to the device through sg/bsg.
>
>       Avoid using blk_queue_max_hw_sectors() and set the max_sectors queue
>       limit directly.
>
>       Also update the comment in blk_limits_max_hw_sectors() to clarify that
>       max_hw_sectors defines the limit for the I/O controller only.
>
>       Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>
>       Reported-by: Brian King <brking@linux.vnet.ibm.com>
>       Tested-by: Brian King <brking@linux.vnet.ibm.com>
>       Cc: stable@vger.kernel.org # 3.17+
>       Signed-off-by: James Bottomley <JBottomley@Odin.com>
>
> :040000 040000 fbd0519d9ee0a8f92a7dab9a9c6d7b7868974fba
> b4cf554c568813704993538008aed5b704624679 M      block
> :040000 040000 f2630c903cd36ede2619d173f9d1ea0d725ea111
> ff6b6f732afbf6f4b6b26a827c463de50f0e356c M      drivers
>
> Has anyone seen a similar problem?
> I can supply .config and other information if requested.
>
> Arthur.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
