Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id D7F6B6B006E
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 08:51:26 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gq15so40937248lab.12
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 05:51:26 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id g4si6521087lab.66.2015.02.02.05.51.24
        for <linux-mm@kvack.org>;
        Mon, 02 Feb 2015 05:51:24 -0800 (PST)
Date: Mon, 2 Feb 2015 15:50:10 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 05/19] ia64: expose number of page table levels on
 Kconfig level
Message-ID: <20150202135010.GA12902@node.dhcp.inet.fi>
References: <1422629008-13689-6-git-send-email-kirill.shutemov@linux.intel.com>
 <1422663426-220551-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1422881799.19005.31.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422881799.19005.31.camel@x220>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Mon, Feb 02, 2015 at 01:56:39PM +0100, Paul Bolle wrote:
> On Sat, 2015-01-31 at 02:17 +0200, Kirill A. Shutemov wrote:
> > We would want to use number of page table level to define mm_struct.
> > Let's expose it as CONFIG_PGTABLE_LEVELS.
> > 
> > We need to define PGTABLE_LEVELS before sourcing init/Kconfig:
> > arch/Kconfig will define default value and it's sourced from init/Kconfig.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Fenghua Yu <fenghua.yu@intel.com>
> > ---
> >  v2: fix default for IA64_PAGE_SIZE_64KB
> > ---
> >  arch/ia64/Kconfig                | 18 +++++-------------
> >  arch/ia64/include/asm/page.h     |  4 ++--
> >  arch/ia64/include/asm/pgalloc.h  |  4 ++--
> >  arch/ia64/include/asm/pgtable.h  | 12 ++++++------
> >  arch/ia64/kernel/ivt.S           | 12 ++++++------
> >  arch/ia64/kernel/machine_kexec.c |  4 ++--
> >  6 files changed, 23 insertions(+), 31 deletions(-)
> > 
> > diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> > index 074e52bf815c..4f9a6661491b 100644
> > --- a/arch/ia64/Kconfig
> > +++ b/arch/ia64/Kconfig
> > @@ -1,3 +1,8 @@
> > +config PGTABLE_LEVELS
> > +	int "Page Table Levels" if !IA64_PAGE_SIZE_64KB
> > +	range 3 4 if !IA64_PAGE_SIZE_64KB
> > +	default 3
> > +
> 
> Why didn't you choose to make this something like
>     config PGTABLE_LEVELS
> 	int
> 	default 3 if PGTABLE_3
> 	default 4 if PGTABLE_4
> 
> >  source "init/Kconfig"
> >  
> >  source "kernel/Kconfig.freezer"
> > @@ -286,19 +291,6 @@ config IA64_PAGE_SIZE_64KB
> >  
> >  endchoice
> >  
> > -choice
> > -	prompt "Page Table Levels"
> > -	default PGTABLE_3
> > -
> > -config PGTABLE_3
> > -	bool "3 Levels"
> > -
> > -config PGTABLE_4
> > -	depends on !IA64_PAGE_SIZE_64KB
> > -	bool "4 Levels"
> > -
> > -endchoice
> > -
> >  if IA64_HP_SIM
> >  config HZ
> >  	default 32
> 
> ... and drop this hunk (ie, keep this choice as it is)? That would make
> upgrading to a release that uses PGTABLE_LEVELS do the right thing
> automagically, wouldn't it? As currently in the !IA64_PAGE_SIZE_64KB
> case people need to reconfigure their "Page Table Levels".

Again: I can do it if maintainers prefer.

But I don't see much sense in having arch-specific kconfig option if we
have generic one.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
