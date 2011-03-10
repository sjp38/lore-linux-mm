Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5C3468D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 16:33:34 -0500 (EST)
Date: Thu, 10 Mar 2011 15:33:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: COW userspace memory mapping question
In-Reply-To: <faf1c53253ae791c39448de707b96c15@anilinux.org>
Message-ID: <alpine.DEB.2.00.1103101532230.2161@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org> <alpine.DEB.2.00.1103101309090.2161@router.home> <faf1c53253ae791c39448de707b96c15@anilinux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mordae <mordae@anilinux.org>
Cc: linux-mm@kvack.org

On Thu, 10 Mar 2011, Mordae wrote:

> As I understand that, before a process forks, all of it's private memory
> pages are somehow magically marked. When a process with access to such
> page attempts to modify it, the page is duplicated and the copy replaces
> the shared page for this process. Then the actual modification is
> carried on.

Its not magic. The kernel simply marks the pages as readonly and does a
copy operation when the page is modified.

> What I am interested in is a hypothetical system call
>
>   void *mcopy(void *dst, void *src, size_t len, int flags);
>
> which would make src pages marked in the same way and mapped *also* to
> the dst. Afterwards, any modification to either mapping would not
> influence the other.
>
> Now, is there something like that?

If you have a file backed mmap (could be tmpfs) then it is possible.

First establish an RW mapping of the file.

Then -- when you want to take the snapshot -- unmap it and do two mmaps to
the old and new location. Make both readonly and MAP_PRIVATE. That will
cause the kernel to create readonly pages that are subject to COW.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
