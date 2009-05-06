Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 84E956B0055
	for <linux-mm@kvack.org>; Wed,  6 May 2009 12:14:17 -0400 (EDT)
Date: Wed, 6 May 2009 09:14:24 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506161424.GC15712@x200.localdomain>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <4A01AC5E.6000906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A01AC5E.6000906@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Izik Eidus (ieidus@redhat.com) wrote:
> But why not go go step by step?
> We can first start with this ioctl interface, later when we add swapping  
> to the pages, we can have madvice, and still (probably easily) support  
> the ioctls by just calling from inside ksm the madvice functions for  
> that specific address)

Then we have 2 interfaces to maintain.  Makes more sense to try and get
it right the first time.

> I want to see ksm use madvice, but i believe it require some more  
> changes to mm/*.c, so it probably better to start with merging it when  
> it doesnt touch alot of stuff outisde ksm.c, and then to add swapping  
> and after that add madvice support (when the pages are swappable,  
> everyone can use it)

There's already locking issues w/ using madvise and ksm, so yes,
changes would need to be made.  Some question of how (whether) to handle
registration of unmapped ranges, closest to say ->mm->def_flags=VM_MERGE.
My hunch is there's 2 cases users might care about, a specific range
(qemu-kvm, CERN app, etc) or the entire vma space of a process.  Another
question of what to do w/ VM_LOCKED, should that exclude VM_MERGE or
let user get what asked for?

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
