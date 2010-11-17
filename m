Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBD06B0093
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 15:32:19 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAHKWEHP010358
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 12:32:16 -0800
Received: from ywc21 (ywc21.prod.google.com [10.192.3.21])
	by hpaq5.eem.corp.google.com with ESMTP id oAHKWCkp005012
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 12:32:12 -0800
Received: by ywc21 with SMTP id 21so136496ywc.0
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 12:32:11 -0800 (PST)
Date: Wed, 17 Nov 2010 12:32:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3] mm: remove gfp mask from pcpu_get_vm_areas
In-Reply-To: <4CE39B89.8010908@kernel.org>
Message-ID: <alpine.DEB.2.00.1011171229040.30790@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com> <alpine.DEB.2.00.1011161937380.19230@chino.kir.corp.google.com> <4CE39B89.8010908@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Tejun Heo wrote:

> > pcpu_get_vm_areas() only uses GFP_KERNEL allocations, so remove the gfp_t
> > formal and use the mask internally.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Patch itself looks okay to me but why do you want to drop the
> argument?
> 

A recent thread[*] shows a problem whereas gfp masks may be passed into 
the vmalloc interface that restrict reclaim behavior, yet the underlying 
pte allocator unconditionally uses GFP_KERNEL.  This is a first-pass at an 
effort to remove all gfp_t formals from the vmalloc interface (and can be 
completed once gfs2, ntfs, and ceph have converted) and require them to 
use GFP_KERNEL.

Luckily for the per-cpu allocator, this was trivial since that happens to 
be the only use case already.

 [*] http://marc.info/?t=128942209500002

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
