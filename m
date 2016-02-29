Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id EB2186B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 16:24:34 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so7582501wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:24:34 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id h207si14006357wme.0.2016.02.29.13.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 13:24:33 -0800 (PST)
Date: Mon, 29 Feb 2016 13:24:31 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: include/linux/bug.h:93:12: error: dereferencing pointer to
 incomplete type
Message-ID: <20160229212430.GA24030@cloud>
References: <201602290757.VADI7RS5%fengguang.wu@intel.com>
 <20160229124937.984ac318110f686d96532088@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229124937.984ac318110f686d96532088@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 12:49:37PM -0800, Andrew Morton wrote:
> On Mon, 29 Feb 2016 07:33:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > FYI, the error/warning still remains.
> > 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   fc77dbd34c5c99bce46d40a2491937c3bcbd10af
> > commit: 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
> > date:   1 year, 11 months ago
> > config: mn10300-allnoconfig (attached as .config)
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 5d2acfc7b974bbd3858b4dd3f2cdc6362dd8843a
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=mn10300 
> > 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mn10300, c6x: CONFIG_GENERIC_BUG must depend on CONFIG_BUG
> 
> CONFIG_BUG=n && CONFIG_GENERIC_BUG=y make no sense and things break:
> 
>    In file included from include/linux/page-flags.h:9:0,
>                     from kernel/bounds.c:9:
>    include/linux/bug.h:91:47: warning: 'struct bug_entry' declared inside parameter list
>     static inline int is_warning_bug(const struct bug_entry *bug)
>                                                   ^
>    include/linux/bug.h:91:47: warning: its scope is only this definition or declaration, which is probably not what you want
>    include/linux/bug.h: In function 'is_warning_bug':
> >> include/linux/bug.h:93:12: error: dereferencing pointer to incomplete type
>      return bug->flags & BUGFLAG_WARNING;
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Cc: Josh Triplett <josh@joshtriplett.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This looks like the right patch; I thought it had already been
submitted.

That said, what would it take to move GENERIC_BUG and BUG into
architecture-independent configuration, including such a dependency?

>  arch/c6x/Kconfig     |    1 +
>  arch/mn10300/Kconfig |    1 +
>  2 files changed, 2 insertions(+)
> 
> diff -puN arch/c6x/Kconfig~mn10300-c6x-config_generic_bug-must-depend-on-config_bug arch/c6x/Kconfig
> --- a/arch/c6x/Kconfig~mn10300-c6x-config_generic_bug-must-depend-on-config_bug
> +++ a/arch/c6x/Kconfig
> @@ -36,6 +36,7 @@ config GENERIC_HWEIGHT
>  
>  config GENERIC_BUG
>  	def_bool y
> +	depends on BUG
>  
>  config C6X_BIG_KERNEL
>  	bool "Build a big kernel"
> diff -puN arch/mn10300/Kconfig~mn10300-c6x-config_generic_bug-must-depend-on-config_bug arch/mn10300/Kconfig
> --- a/arch/mn10300/Kconfig~mn10300-c6x-config_generic_bug-must-depend-on-config_bug
> +++ a/arch/mn10300/Kconfig
> @@ -53,6 +53,7 @@ config GENERIC_HWEIGHT
>  
>  config GENERIC_BUG
>  	def_bool y
> +	depends on BUG
>  
>  config QUICKLIST
>  	def_bool y
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
