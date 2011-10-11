Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2E8B26B002F
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:22:11 -0400 (EDT)
Date: Tue, 11 Oct 2011 20:22:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] treewide: Use __printf not
 __attribute__((format(printf,...)))
Message-ID: <20111011172208.GA3633@shutemov.name>
References: <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
 <20110825165006.af771ef7.akpm@linux-foundation.org>
 <1314316801.19476.6.camel@Joe-Laptop>
 <20110825170534.0d425c75.akpm@linux-foundation.org>
 <1314319088.19476.17.camel@Joe-Laptop>
 <20110825180734.9beae279.akpm@linux-foundation.org>
 <1314327338.19476.30.camel@Joe-Laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1314327338.19476.30.camel@Joe-Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org

On Thu, Aug 25, 2011 at 07:55:37PM -0700, Joe Perches wrote:
> Standardize the style for compiler based printf format verification.
> Standardized the location of __printf too.
> 
> Done via script and a little typing.
> 
> $ grep -rPl --include=*.[ch] -w "__attribute__" * | \
>   grep -vP "^(tools|scripts|include/linux/compiler-gcc.h)" | \
>   xargs perl -n -i -e 'local $/; while (<>) { s/\b__attribute__\s*\(\s*\(\s*format\s*\(\s*printf\s*,\s*(.+)\s*,\s*(.+)\s*\)\s*\)\s*\)/__printf($1, $2)/g ; print; }'
> 
> Completely untested...

This patch breaks ARCH=um (linux-next-20111011):

In file included from /home/kas/git/public/linux-next/arch/um/os-Linux/aio.c:17:0:
/home/kas/git/public/linux-next/arch/um/include/shared/user.h:26:17: error: expected declaration specifiers or a??...a?? before numeric constant
/home/kas/git/public/linux-next/arch/um/include/shared/user.h:26:20: error: expected declaration specifiers or a??...a?? before numeric constant
/home/kas/git/public/linux-next/arch/um/include/shared/user.h:29:17: error: expected declaration specifiers or a??...a?? before numeric constant
/home/kas/git/public/linux-next/arch/um/include/shared/user.h:29:20: error: expected declaration specifiers or a??...a?? before numeric constant
/home/kas/git/public/linux-next/arch/um/os-Linux/aio.c: In function a??do_aioa??:
/home/kas/git/public/linux-next/arch/um/os-Linux/aio.c:93:3: error: implicit declaration of function a??printka?? [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> ---
> 
> On Thu, 2011-08-25 at 18:07 -0700, Andrew Morton wrote:
> > On Thu, 25 Aug 2011 17:38:08 -0700 Joe Perches <joe@perches.com> wrote:
> > > So if you really like it that much:
> > Well I don't particularly like it, personally.  But they're there, so
> > we either fully use them or fully unuse them, then remove them.
>  
> I don't mind one way or another, and I do
> like consistency, so I guess the __printf
> form is a bit better match to the other
> __attribute__ #defines.
> 
> I just don't have any particular desire
> to push it to anyone though.
> 
> Here it is, totally untested.

<skip/>

> diff --git a/arch/um/include/shared/user.h b/arch/um/include/shared/user.h
> index 293f7c7..e253af9 100644
> --- a/arch/um/include/shared/user.h
> +++ b/arch/um/include/shared/user.h
> @@ -23,14 +23,12 @@
>  #include <stddef.h>
>  #endif
>  
> -extern void panic(const char *fmt, ...)
> -	__attribute__ ((format (printf, 1, 2)));
> +extern __printf(1, 2) void panic(const char *fmt, ...);
>  
>  #ifdef UML_CONFIG_PRINTK
> -extern int printk(const char *fmt, ...)
> -	__attribute__ ((format (printf, 1, 2)));
> +extern __printf(1, 2) int printk(const char *fmt, ...);
>  #else
> -static inline int printk(const char *fmt, ...)
> +static inline __printf(1, 2) int printk(const char *fmt, ...)
>  {
>  	return 0;
>  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
