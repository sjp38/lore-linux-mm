Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B49B36B005A
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:10:22 -0400 (EDT)
Date: Thu, 25 Jun 2009 12:09:34 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] video: arch specific page protection support for deferred io
Message-ID: <20090625030933.GB13668@linux-sh.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se> <20090624195647.9d0064c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090624195647.9d0064c7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 24, 2009 at 07:56:47PM -0700, Andrew Morton wrote:
> On Wed, 24 Jun 2009 19:54:13 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:
> 
> > From: Magnus Damm <damm@igel.co.jp>
> > 
> > This patch adds arch specific page protection support to deferred io.
> > 
> > Instead of overwriting the info->fbops->mmap pointer with the
> > deferred io specific mmap callback, modify fb_mmap() to include
> > a #ifdef wrapped call to fb_deferred_io_mmap().  The function
> > fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
> > case of non-vmalloc() frame buffers.
> > 
> > With this patch uncached deferred io can be used together with
> > the sh_mobile_lcdcfb driver. Without this patch arch specific
> > page protection code in fb_pgprotect() never gets invoked with
> > deferred io.
> > 
> > Signed-off-by: Magnus Damm <damm@igel.co.jp>
> > ---
> > 
> >  For proper runtime operation with uncached vmas make sure
> >  "[PATCH][RFC] mm: uncached vma support with writenotify"
> >  is applied. There are no merge order dependencies.
> 
> So this is dependent upon a patch which is in your tree, which is in
> linux-next?
> 
This patch is not in the sh tree, either, we wanted it to go via -mm, but
it has the issue that it depends on pgprot_noncached() being generally
defined, so there is a bit of an ordering mess. It could be re-posted
with an ifdef pgprot_noncached to get it merged while we wait for the
outstanding architectures to catch up, and this is indeed what the bulk
of the in-tree pgprot_noncached() users in generic places end up doing
already.

Of course I can take both through the sh tree once people are happy with
the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
