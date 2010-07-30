Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6537E6B02A6
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 05:12:32 -0400 (EDT)
Date: Fri, 30 Jul 2010 19:12:26 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: VFS scalability git tree
Message-ID: <20100730091226.GA10437@amd>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> I'm pleased to announce I have a git tree up of my vfs scalability work.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> 
> Branch vfs-scale-working
> 
> The really interesting new item is the store-free path walk, (43fe2b)
> which I've re-introduced. It has had a complete redesign, it has much
> better performance and scalability in more cases, and is actually sane
> code now.

Things are progressing well here with fixes and improvements to the
branch.

One thing that has been brought to my attention is that store-free path
walking (rcu-walk) drops into the normal refcounted walking on any
filesystem that has posix ACLs enabled.

Having misread that IS_POSIXACL is based on a superblock flag, I had
thought we only drop out of rcu-walk in case of encountering an inode
that actually has acls.

This is quite an important point for any performance testing work.
ACLs can actually be rcu checked quite easily in most cases, but it
takes a bit of work on APIs.

Filesystems defining their own ->permission and ->d_revalidate will
also not use rcu-walk. These could likewise be made to support rcu-walk
more widely, but it will require knowledge of rcu-walk to be pushed
into filesystems.

It's not a big deal, basically: no blocking, no stores, no referencing
non-rcu-protected data, and confirm with seqlock. That is usually the
case in fastpaths. If it cannot be satisfied, then just return -ECHILD
and you'll get called in the usual ref-walk mode next time.

But for now, keep this in mind if you plan to do any serious performance
testing work, *do not mount filesystems with ACL support*.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
