Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6138C6B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 12:45:22 -0400 (EDT)
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20090429082733.f69b45c1.akpm@linux-foundation.org>
References: <20090414071152.GC23528@wotan.suse.de>
	 <20090415082507.GA23674@wotan.suse.de>
	 <20090415183847.d4fa1efb.akpm@linux-foundation.org>
	 <20090428185739.GE6377@localdomain> <20090429071233.GC3398@wotan.suse.de>
	 <20090429002418.fd9072a6.akpm@linux-foundation.org>
	 <20090429074511.GD3398@wotan.suse.de>
	 <1241008762.6336.5.camel@heimdal.trondhjem.org>
	 <20090429082733.f69b45c1.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 29 Apr 2009 12:45:14 -0400
Message-Id: <1241023514.12464.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Ravikiran G Thirumalai <kiran@scalex86.org>, Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-29 at 08:27 -0700, Andrew Morton wrote:
> I don't know what the "NFS 3 liner" is, but I trust you'll take care of
> it.

It's this one. I can send it on to Linus as soon as Nick's stuff is
upstream unless you'd prefer to fold it in with his patch.

Cheers
  Trond
---------------------------------------------------------------------
>From f0258852dcb43c748854d2ee550c9c270bb25f21 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 24 Apr 2009 17:32:22 -0400
Subject: [PATCH] NFS: Close page_mkwrite() races

Follow up to Nick Piggin's patches to ensure that nfs_vm_page_mkwrite
returns with the page lock held, and sets the VM_FAULT_LOCKED flag.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5a97bcf..ec7e27d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -517,10 +517,10 @@ static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	ret = nfs_updatepage(filp, page, 0, pagelen);
 out_unlock:
+	if (!ret)
+		return VM_FAULT_LOCKED;
 	unlock_page(page);
-	if (ret)
-		ret = VM_FAULT_SIGBUS;
-	return ret;
+	return VM_FAULT_SIGBUS;
 }
 
 static struct vm_operations_struct nfs_file_vm_ops = {
-- 
1.6.0.6



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
