Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C66E46B004F
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 00:22:12 -0400 (EDT)
Date: Wed, 24 Jun 2009 05:22:48 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] remove unused line for mmap_region()
In-Reply-To: <4A419A7F.8050604@gmail.com>
Message-ID: <Pine.LNX.4.64.0906240512300.31848@sister.anvils>
References: <1245595421-3441-1-git-send-email-shijie8@gmail.com>
 <Pine.LNX.4.64.0906211917350.4583@sister.anvils> <4A3EFF93.4000100@gmail.com>
 <Pine.LNX.4.64.0906231155180.6167@sister.anvils> <4A419A7F.8050604@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 2009, Huang Shijie wrote:
> > What I expect you to find in the end is that every driver which does
> > meddle with pgoff in its ->mmap, also has some other characteristic
> > (e.g. sets VM_IO or VM_DONTEXPAND or VM_RESERVED or VM_PFNMAP, or
> > even some other flag which the new vm_flags wouldn't have set),
> > which will prevent its vmas being merged anyway.
> >
> Unfortunately,the driver's -->mmap is called below the vma_merge(),
> so even if the driver sets the VM_SPECIAL flag, it does not prevent the
> vmas being merged actually.

It does not prevent it by virtue of being VM_SPECIAL at that point,
you're right, but I believe it does prevent it by virtue of presenting
a different vm_flags.  Collapsing a definition to make it clearer, see

	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
		return 0;

at the beginning of is_mergeable_vma().  We have to make an exception
of VM_CAN_NONLINEAR precisely because it gets set by a normal ->mmap,
but cannot be predicted by mmap_region() before its vma_merge().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
