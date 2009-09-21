Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 01DAB6B012F
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 05:30:51 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] remove duplicate asm/mman.h files
Date: Mon, 21 Sep 2009 11:30:26 +0200
References: <cover.1251197514.git.ebmunson@us.ibm.com> <200909211031.25369.arnd@arndb.de> <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0909210208180.16086@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909211130.26377.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 21 September 2009, David Rientjes wrote:
> > I tried not to change the ABI in any way in my patch, and there is
> > a theoretical possibility that some user space program on ia64 currently
> > depends on that definition.
> > 
> 
> I don't buy that as justification, if some userspace program uses it based 
> on the false belief that it actually does what it says, it's probably 
> better to break their build than perpetuating the lie that it's different 
> than ~MAP_GROWSDOWN.

It's more a matter of principle of my patches. I try to strictly separate
patches that move code around (like the one I sent) from those that
change contents (like yours, or the one before that adds MAP_STACK and
MAP_HUGETLB).

Removing a definition from an exported header file either requires
specific knowledge about why it is there to start with, or more
research on the topic than I wanted to do. For instance, a theoretical
program might have a helper function correctly doing

void *xmmap(void *addr, size_t length, int prot, int flags,
                  int fd, off_t offset)
{
	if (flags & MAP_GROWSUP) { /* MAP_GROWSUP is not supported */
		errno = -EINVAL;
		return MAP_FAILED;
	}

	return mmap(addr, length, prot, flags, fd, offset);
}

Of course, such a program would only work on ia64 currently, so
it should be safe to make ia64 behave like the other architectures
in this regard.

> ia64: remove definition for MAP_GROWSUP
> 
> MAP_GROWSUP is unused.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
