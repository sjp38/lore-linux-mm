Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E69856B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 16:08:19 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oBNL8Di5012166
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 13:08:18 -0800
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by kpbe13.cbf.corp.google.com with ESMTP id oBNL7gPE025244
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 13:08:12 -0800
Received: by pzk5 with SMTP id 5so2067621pzk.31
        for <linux-mm@kvack.org>; Thu, 23 Dec 2010 13:08:12 -0800 (PST)
Date: Thu, 23 Dec 2010 13:08:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Fix unconditional GFP_KERNEL allocations in
 __vmalloc().
In-Reply-To: <20101217162626.DA0A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012231305080.26724@chino.kir.corp.google.com>
References: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com> <20101217162626.DA0A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, andreas.dilger@oracle.com, behlendorf1@llnl.gov
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, KOSAKI Motohiro wrote:

> > (Patch based on 2.6.36 tag).
> > 
> > These GFP_KERNEL allocations could happen even though the caller of __vmalloc()
> > requested a stricter gfp mask (such as GFP_NOFS or GFP_ATOMIC).
> > 
> > This was first noticed in Lustre, where it led to deadlocks due to a filesystem
> > thread which requested a GFP_NOFS __vmalloc() allocation ended up calling down
> > to Lustre itself to free memory, despite this not being allowed by GFP_NOFS.
> > 
> > Further analysis showed that some in-tree filesystems (namely GFS, Ceph and XFS)
> > were vulnerable to the same bug due to calling __vmalloc() or vm_map_ram() in
> > contexts where __GFP_FS allocations are not allowed.
> > 
> > Fixing this bug required changing a few mm interfaces to accept gfp flags.
> > This needed to be done in all architectures, thus the large number of changes.
> 
> I like this patch. but please separate it two patches.
> 
>  1) add gfp_mask argument to some function
>  2) vmalloc use flexible mask instead GFP_KERNEL always.
> 
> I mean please consider to make reviewers friendly patch.
> IOW, please see your diffstat. ;)
> 

I agree, I'm also wondering if it would be easier to introduce seperate, 
lower-level versions of the functions that the current interfaces would 
then use instead of converting all of their current use cases.  Using 
pmd_alloc_one() as an example: convert existing pmd_alloc_one() to 
__pmd_alloc_one() for each arch and add the gfp_t formal), then introduce 
a new pmd_alloc_one() that does __pmd_alloc_one(..., GFP_KERNEL).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
