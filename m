Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77EDB6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 20:38:11 -0400 (EDT)
Subject: Re: [PATCH] mm: Neaten warn_alloc_failed
From: Joe Perches <joe@perches.com>
In-Reply-To: <20110825170534.0d425c75.akpm@linux-foundation.org>
References: 
	 <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
	 <20110825165006.af771ef7.akpm@linux-foundation.org>
	 <1314316801.19476.6.camel@Joe-Laptop>
	 <20110825170534.0d425c75.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Aug 2011 17:38:08 -0700
Message-ID: <1314319088.19476.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2011-08-25 at 17:05 -0700, Andrew Morton wrote:
> On Thu, 25 Aug 2011 17:00:01 -0700
> Joe Perches <joe@perches.com> wrote:
> > On Thu, 2011-08-25 at 16:50 -0700, Andrew Morton wrote:
> > > On Thu, 25 Aug 2011 13:26:19 -0700
> > > Joe Perches <joe@perches.com> wrote:
> > > > Add __attribute__((format (printf...) to the function
> > > > to validate format and arguments.  Use vsprintf extension
> > > > %pV to avoid any possible message interleaving. Coalesce
> > > > format string.  Convert printks/pr_warning to pr_warn.
> > []
> > > > -extern void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
> > > > +extern __attribute__((format (printf, 3, 4)))
> > > > +void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > looky:
> > Looky what?
> > There are _far_ more uses of __attribute__((format...)
> > than __printf(...)
> > I generally go with what's more commonly used,
> > especially when it's 206 to 8, and 1 of the
> > 8 is the #define itself.
> > $ grep -rP --include=*.[ch] "__attribute__.*format" * | wc -l
> > 206
> > $ grep -rP --include=*.[ch]  -w "__printf" * | wc -l
> > 8
> So?

So if you really like it that much:

grep -rPl --include=*.[ch] -w "__attribute__" * |
grep -v "^tools" | grep -v "^scripts" | grep -v "include/linux/compiler-gcc.h" |
xargs perl -n -i -e 'local $/; while (<>) { s/\b__attribute__\s*\(\s*\(\s*format\s*\(\s*printf\s*,\s*(.+)\s*,\s*(.+)\s*\)\s*\)\s*\)/__printf($1, $2)/g ; print; }'

Then they're all the same.

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
