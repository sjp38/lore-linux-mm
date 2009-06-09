Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 191F06B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:19:45 -0400 (EDT)
Date: Tue, 9 Jun 2009 12:52:51 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Message-ID: <20090609105251.GK14820@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu> <20090608162913.GL8633@ZenIV.linux.org.uk> <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu> <20090608175018.GM8633@ZenIV.linux.org.uk> <alpine.LFD.2.01.0906081100000.6847@localhost.localdomain> <20090608185041.GN8633@ZenIV.linux.org.uk> <alpine.LFD.2.01.0906081217340.6847@localhost.localdomain> <m1ocsxykk2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1ocsxykk2.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 11:42:53PM -0700, Eric W. Biederman wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
> 
> > On Mon, 8 Jun 2009, Al Viro wrote:
> >> 
> >> Sure, even though I'm not at all certain that copy_from_user() is that easy.
> >> We can make locking current->mm in there interruptible, all right, but that's
> >> only a part of the answer - even aside of the allocations, we'd need vma
> >> ->fault() interruptible as well, which leads to interruptible instances of
> >> ->readpage(), with all the fun _that_ would be.
> >
> > We already have all that - the NFS people wanted it.
> >
> > More importantly, you don't actually need to interrupt readpage itself - 
> > you just need to stop _waiting_ on it. So in your fault handler, just stop 
> > waiting, and instead just return FAULT_RETRY or whatever.
> 
> That sounds doable.  Has that code been merged yet?
> 
> I took a quick look and it didn't see anyone breaking out of page fault with a
> signal or code to really handle that.

The problem is get_user_pages I think. Now that we have a good number of
fault flags, we can pass down whether the caller is able to be
interrupted or not.

Ben H had some interest in doing this, but I don't know how far he got
with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
