Received: by zproxy.gmail.com with SMTP id k1so220796nzf
        for <linux-mm@kvack.org>; Thu, 06 Oct 2005 03:29:33 -0700 (PDT)
Message-ID: <aec7e5c30510060329kb59edagb619f00b8a58bf3e@mail.gmail.com>
Date: Thu, 6 Oct 2005 19:29:33 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] i386: srat and numaq cleanup
In-Reply-To: <1128530262.26009.27.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051005083846.4308.37575.sendpatchset@cherry.local>
	 <1128530262.26009.27.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/6/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Wed, 2005-10-05 at 17:39 +0900, Magnus Damm wrote:
> > Cleanup the i386 NUMA code by creating inline no-op functions for
> > get_memcfg_numaq/srat() and get_zholes_size_numaq/srat().
>
> >  arch/i386/kernel/srat.c   |   10 ++++++++--
> >  include/asm-i386/mmzone.h |   26 +++++++++++++++++---------
> >  include/asm-i386/numaq.h  |   10 ++++++++--
> >  include/asm-i386/srat.h   |   15 ++++++++++-----
> >  4 files changed, 43 insertions(+), 18 deletions(-)
>
> I'm highly suspicious of any "cleanup" that adds more code than it
> deletes.  What does this clean up?

Hehe, I realized that it added code when I generated the diffstat, but
I believe that the code gets cleaner.

The patch removes #ifdefs from get_memcfg_numa() and introduces an
inline get_zholes_size(). The #ifdefs are moved down one level to the
files srat.h and numaq.h and empty inline functions are added. These
empty inline function are probably the reason for the added lines.

> This patch is a little bit confused.  It makes the
> get_zholes_size_srat() always safe to call at runtime.  However, it
> still creates a compile-time stub version of it as well.

Without this patch get_zholes_size() is defined in either srat.c or
numaq.h. With this patch get_zholes_size() is turned into an inline
function like get_memcfg_numa(), and this function calls all
machine-specific implementations.

This new behavior requires that the machine-specific code keeps track
if it has been initialized or not, and only lets get_zholes_size_xxx()
return non-NULL if initialized.

> In addition, you already have the srat.c-local zholes_size_init, but you
> still add the has_srat variable.  Seems a bit superfluous.

Nah, zholes_size_init is used to call get_zholes_init() just once. 
has_srat is used to determine if get_memcfg_numa() did succeed.

> Calling get_zholes_size_numaq() at runtime is unnecessary.  The NUMA-Q
> is not supported with the ARCH_GENERIC code.

Yes. But does this patch do anything that makes that harder?

Another side effect of the patch is that get_zholes_size() always gets
defined, regardless of if numaq or srat is enabled or not. That is
useful for the NUMA emulation code.

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
