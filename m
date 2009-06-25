Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 39E756B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 16:56:12 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] video: arch specific page protection support for deferred io
Date: Thu, 25 Jun 2009 22:57:49 +0200
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se> <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com> <45a44e480906251106h6cd72a72h380da4283be62506@mail.gmail.com>
In-Reply-To: <45a44e480906251106h6cd72a72h380da4283be62506@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906252257.50235.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Magnus Damm <magnus.damm@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, linux-mm@kvack.org, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Thursday 25 June 2009, Jaya Kumar wrote:
> The patch looks good. I was going to suggest that it might be
> attractive to use __attribute__(weak) for each of the dummy functions
> instead of ifdefs in this case, but I can't remember if there was a
> consensus about attribute-weak versus ifdefs.

We rarely use weak functions, the canonical way to express an optional
subsystem is along the lines of

/* include/linux/foo.h */
#ifdef CONFIG_FOO
extern int bar(void);
#else
static inline int bar(void)
{
	return 0;
}
#endif
---
/* foo/foo.c */
int bar(void)
{
	/* the real thing here */
	...
}
---
# foo/Makefile 
obj-$(CONFIG_FOO) += foo.c

Most uses of __weak or __attribute__((weak)) are for working default
implementations that can be overridden by architecture specific code.
However, for these the preferred way to express seems to have shifted
towards variations of:

/* include/linux/foo.h */
#include <asm/foo.h>
#ifndef bar
static inline int bar(void)
{
	/* generic implementation */
	...
}
#endif
/* arch/*/include/asm/foo.h */
#define bar bar
static inline int bar(void)
{
	/* arch specific implementation */
	...
}

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
