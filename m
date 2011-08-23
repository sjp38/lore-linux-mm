Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 691E96B0178
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 17:39:19 -0400 (EDT)
Date: Tue, 23 Aug 2011 14:39:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -next] drivers/base/inode.c: let vmstat_text be optional
Message-Id: <20110823143912.0691d442.akpm@linux-foundation.org>
In-Reply-To: <20110804152211.ea10e3e7.rdunlap@xenotime.net>
References: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au>
	<20110804152211.ea10e3e7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Amerigo Wang <amwang@redhat.com>, gregkh@suse.de, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> Subject: [PATCH -next] drivers/base/inode.c: let vmstat_text be optional

The patch-against-next thing always disturbs me.  It implies that the
patch is only needed in linux-next, but often that's wrong.  So I have
to go off and work out what kernel it really is applicable to.

And that's OK, it keeps me healthy.  But two minds are better than one,
and if the originator has already worked this out, they should state it
explicitly, please.

On Thu, 4 Aug 2011 15:22:11 -0700
Randy Dunlap <rdunlap@xenotime.net> wrote:

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> vmstat_text is only available when PROC_FS or SYSFS is enabled.
> This causes build errors in drivers/base/node.c when they are
> both disabled:
> 
> drivers/built-in.o: In function `node_read_vmstat':
> node.c:(.text+0x10e28f): undefined reference to `vmstat_text'
> 
> Rather than litter drivers/base/node.c with #ifdef/#endif around
> the affected lines of code, add macros for optional sysdev
> attributes so that those lines of code will be ignored, without
> using #ifdef/#endif in the .c file(s).  I.e., the ifdeffery
> is done only in a header file with sysdev_create_file_optional()
> and sysdev_remove_file_optional().
> 
> --- linux-next-20110804.orig/include/linux/vmstat.h
> +++ linux-next-20110804/include/linux/vmstat.h
> @@ -258,6 +258,8 @@ static inline void refresh_zone_stat_thr
>  
>  #endif		/* CONFIG_SMP */
>  
> +#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS)
>  extern const char * const vmstat_text[];
> +#endif
>

The ifdef around the declaration isn't needed, really.  If we remove
it then a build-time error becomes a link-time (or even moddep-time) error,
which is a bit of a pain.  But it's less painful than having ifdefs
around squillions of declarations.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
