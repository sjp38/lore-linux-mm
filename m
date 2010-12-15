Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DB2AF6B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 21:59:01 -0500 (EST)
Subject: Re: [PATCH] Fix unconditional GFP_KERNEL allocations in
 __vmalloc().
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
References: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 03:53:20 +0100
Message-ID: <1292381600.2994.6.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, andreas.dilger@oracle.com, behlendorf1@llnl.gov
List-ID: <linux-mm.kvack.org>

On Wed, 2010-12-15 at 03:45 +0100, Ricardo M. Correia wrote:
> (Patch based on 2.6.36 tag).
> 
> These GFP_KERNEL allocations could happen even though the caller of __vmalloc()
> requested a stricter gfp mask (such as GFP_NOFS or GFP_ATOMIC).

Sorry for taking a while to write this patch. For the discussion behind
it, you can read: http://marc.info/?t=128942209500002&r=1&w=2

Please note that I have only tested this patch on my laptop (x86-64)
 with one Kconfig.

Since I have done all these changes manually and I don't have any
non-x86-64 machines, it's possible that I may have typoed or missed
something and that this patch may break compilation on other
architectures or with other config options.

Any suggestions are welcome.

Thanks,
Ricardo

> This was first noticed in Lustre, where it led to deadlocks due to a filesystem
> thread which requested a GFP_NOFS __vmalloc() allocation ended up calling down
> to Lustre itself to free memory, despite this not being allowed by GFP_NOFS.
> 
> Further analysis showed that some in-tree filesystems (namely GFS, Ceph and XFS)
> were vulnerable to the same bug due to calling __vmalloc() or vm_map_ram() in
> contexts where __GFP_FS allocations are not allowed.
> 
> Fixing this bug required changing a few mm interfaces to accept gfp flags.
> This needed to be done in all architectures, thus the large number of changes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
