Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 14E026B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 02:27:57 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBH7RsCh018113
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Dec 2010 16:27:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 576ED45DE5C
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 16:27:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EADB45DE5A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 16:27:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 308F21DB804A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 16:27:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0C001DB8047
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 16:27:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Fix unconditional GFP_KERNEL allocations in __vmalloc().
In-Reply-To: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
References: <1292381126-5710-1-git-send-email-ricardo.correia@oracle.com>
Message-Id: <20101217162626.DA0A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Dec 2010 16:27:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, andreas.dilger@oracle.com, behlendorf1@llnl.gov
List-ID: <linux-mm.kvack.org>

> (Patch based on 2.6.36 tag).
> 
> These GFP_KERNEL allocations could happen even though the caller of __vmalloc()
> requested a stricter gfp mask (such as GFP_NOFS or GFP_ATOMIC).
> 
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

I like this patch. but please separate it two patches.

 1) add gfp_mask argument to some function
 2) vmalloc use flexible mask instead GFP_KERNEL always.

I mean please consider to make reviewers friendly patch.
IOW, please see your diffstat. ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
