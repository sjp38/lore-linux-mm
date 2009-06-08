Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 67F146B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 15:16:19 -0400 (EDT)
Date: Mon, 8 Jun 2009 12:18:41 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
In-Reply-To: <20090608185041.GN8633@ZenIV.linux.org.uk>
Message-ID: <alpine.LFD.2.01.0906081217340.6847@localhost.localdomain>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu> <20090608162913.GL8633@ZenIV.linux.org.uk> <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
 <20090608175018.GM8633@ZenIV.linux.org.uk> <alpine.LFD.2.01.0906081100000.6847@localhost.localdomain> <20090608185041.GN8633@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Miklos Szeredi <miklos@szeredi.hu>, ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>



On Mon, 8 Jun 2009, Al Viro wrote:
> 
> Sure, even though I'm not at all certain that copy_from_user() is that easy.
> We can make locking current->mm in there interruptible, all right, but that's
> only a part of the answer - even aside of the allocations, we'd need vma
> ->fault() interruptible as well, which leads to interruptible instances of
> ->readpage(), with all the fun _that_ would be.

We already have all that - the NFS people wanted it.

More importantly, you don't actually need to interrupt readpage itself - 
you just need to stop _waiting_ on it. So in your fault handler, just stop 
waiting, and instead just return FAULT_RETRY or whatever.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
