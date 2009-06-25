Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B1B336B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 03:04:02 -0400 (EDT)
Date: Thu, 25 Jun 2009 00:03:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] video: arch specific page protection support for
 deferred  io
Message-Id: <20090625000359.7e201c58.akpm@linux-foundation.org>
In-Reply-To: <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
	<20090624195647.9d0064c7.akpm@linux-foundation.org>
	<aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, lethal@linux-sh.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 15:06:24 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:

> On Thu, Jun 25, 2009 at 11:56 AM, Andrew
> Morton<akpm@linux-foundation.org> wrote:
> > On Wed, 24 Jun 2009 19:54:13 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:
> >
> >> From: Magnus Damm <damm@igel.co.jp>
> >>
> >> This patch adds arch specific page protection support to deferred io.
> >>
> >> Instead of overwriting the info->fbops->mmap pointer with the
> >> deferred io specific mmap callback, modify fb_mmap() to include
> >> a #ifdef wrapped call to fb_deferred_io_mmap(). __The function
> >> fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
> >> case of non-vmalloc() frame buffers.
> >>
> >> With this patch uncached deferred io can be used together with
> >> the sh_mobile_lcdcfb driver. Without this patch arch specific
> >> page protection code in fb_pgprotect() never gets invoked with
> >> deferred io.
> >>
> >> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> >> ---
> >>
> >> __For proper runtime operation with uncached vmas make sure
> >> __"[PATCH][RFC] mm: uncached vma support with writenotify"
> >> __is applied. There are no merge order dependencies.
> >
> > So this is dependent upon a patch which is in your tree, which is in
> > linux-next?
> 
> I tried to say that there were _no_ dependencies merge wise. =)
>
> There are 3 levels of dependencies:
> 1: pgprot_noncached() patches from Arnd
> 2: mm: uncached vma support with writenotify
> 3: video: arch specfic page protection support for deferred io
> 
> 2 depends on 1 to compile, but 3 (this one) is disconnected from 2 and
> 1. So this patch can be merged independently.

OIC.  I didn't like the idea of improper runtime operation ;)

Still, it's messy.  If only because various trees might be running
untested combinations of patches.  Can we get these all into the same
tree?  Paul's?

> 
> The code is fbmem.c is currently filled with #ifdefs today, want me
> create inline versions for fb_deferred_io_open() and
> fb_deferred_io_fsync() as well?

It was a minor point.  Your call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
