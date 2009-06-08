Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1E26B0062
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 13:49:26 -0400 (EDT)
Date: Mon, 8 Jun 2009 18:50:18 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Message-ID: <20090608175018.GM8633@ZenIV.linux.org.uk>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1oct739xu.fsf@fess.ebiederm.org> <20090606080334.GA15204@ZenIV.linux.org.uk> <E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu> <20090608162913.GL8633@ZenIV.linux.org.uk> <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 06:44:41PM +0200, Miklos Szeredi wrote:

> I'm still not getting what the problem is.  AFAICS file operations are
> either
> 
>  a) non-interruptible but finish within a short time or
>  b) may block indefinitely but are interruptible (or at least killable).
> 
> Anything else is already problematic, resulting in processes "stuck in
> D state".

Welcome to reality...

* bread() is non-interruptible
* so's copy_from_user()/copy_to_user()
* IO we are stuck upon _might_ be interruptible, but by sending a signal
to some other process

... just for starters.  If you sign up for auditing the tree to eliminate
"something's stuck in D state", you are welcome to it.  Mind you, you'll
have to audit filesystems for "doesn't check if metadata IO has failed"
first, but that _really_ needs to be done anyway.  On the ongoing basis.

Drivers, of course, are even more interesting - looking through foo_ioctl()
instances is a wonderful way to lower pH in stomach, but that's on the
"we want revoke()" side of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
