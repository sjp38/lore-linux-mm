Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6E86B004F
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:26:46 -0400 (EDT)
Date: Wed, 6 May 2009 17:26:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
In-Reply-To: <4A01AC5E.6000906@redhat.com>
Message-ID: <Pine.LNX.4.64.0905061706590.4005@blonde.anvils>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
 <1241475935-21162-2-git-send-email-ieidus@redhat.com>
 <1241475935-21162-3-git-send-email-ieidus@redhat.com>
 <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com>
 <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils>
 <4A01AC5E.6000906@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, 6 May 2009, Izik Eidus wrote:
> 
> We can first start with this ioctl interface, later when we add swapping to
> the pages, we can have madvice, and still (probably easily) support the ioctls
> by just calling from inside ksm the madvice functions for that specific
> address)
> 
> I want to see ksm use madvice, but i believe it require some more changes to
> mm/*.c, so it probably better to start with merging it when it doesnt touch
> alot of stuff outisde ksm.c, and then to add swapping and after that add
> madvice support (when the pages are swappable, everyone can use it)
> 
> What you think about that?

I think it's the wrong order to follow.

The /dev/ksm interface is fine for your use while it's out of tree,
but we want to get the user interface right when bringing it into
mainline.  I recall Chris being very clear on that too.

Changing from /dev/ksm to madvise() is not a lot of work, it's mainly
a matter of deleting code, and tidying up interfaces which would need
more work anyway (I haven't commented on your curious -EPERMs yet!).

It doesn't involve whether you've enabled swapping or not - let's
forget the CAP_IPC_LOCK idea, and delegate that issue to limitation
via sysfs, along with the ability to limit wild overuse of the feature
- permissions on a sysfs node or something else?

It does nudge towards making some decisions which need to be made
anyway - that tends to be what a correct interface forces upon you.
Like the issue of whether to go on covering unmapped areas or not -
though possibly we could put off that decision, if it's doc'ed
for now.

And if it only covers mapped areas, then there will need to be a
VM_flag for it, mainly so mm can call into ksm.c when it's unmapped;
but I don't see it sinking hooks deeply into mm/*.c.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
