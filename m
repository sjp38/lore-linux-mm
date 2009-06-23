Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D79C6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 07:13:49 -0400 (EDT)
Date: Tue, 23 Jun 2009 12:14:08 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] remove unused line for mmap_region()
In-Reply-To: <4A3EFF93.4000100@gmail.com>
Message-ID: <Pine.LNX.4.64.0906231155180.6167@sister.anvils>
References: <1245595421-3441-1-git-send-email-shijie8@gmail.com>
 <Pine.LNX.4.64.0906211917350.4583@sister.anvils> <4A3EFF93.4000100@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jun 2009, Huang Shijie wrote:
> >   
> I knew the file's ->mmap method can change addr and pgoff,
> but I think the comment of DavidM is enough to remind the
> person who wants to use pgoff lower down that pgoff maybe
> go wrong for a while.

Indeed it's a very helpful comment from DaveM there.  Unfortunately,
we can't really repeat that comment on every line below where
somebody might in future want to insert a use of pgoff, and not all
of us are as good at actually reading nearby comments as you are!

> 
> But now, it (this line) looks like a big fly on 'Mona Lisa'. :)
> > However, what would be likely to need pgoff lower down, other than
> > another attempt at vma_merge?  And given how we're now working with
> > the vma_merge higher up (before pgoff had a chance to be adjusted),
> > I think we can conclude that anything needing to meddle with pgoff
> > would be setting some vm_flags that prevent merging anyway.
> >
> Could you tell some drivers which will meddle with pgoff?

I can't name a list of drivers offhand, no (but note VM_PFNMAP areas
have a particular use for vm_pgoff, so all those drivers are likely
to be on the list).  May I please leave that investigation to you?

What I expect you to find in the end is that every driver which does
meddle with pgoff in its ->mmap, also has some other characteristic
(e.g. sets VM_IO or VM_DONTEXPAND or VM_RESERVED or VM_PFNMAP, or
even some other flag which the new vm_flags wouldn't have set),
which will prevent its vmas being merged anyway.

> If a driver changes pgoff,the work done by vma_merge higher
> up will be invalidated. The process gets a wrong memory map.

It's probably all okay; but I won't be astonished if you discover
one or two cases which ought to be fixed up, probably by adding
one of those flags.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
