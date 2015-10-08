Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 74ED86B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 04:49:41 -0400 (EDT)
Received: by lbbwt4 with SMTP id wt4so39036150lbb.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 01:49:40 -0700 (PDT)
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com. [209.85.217.181])
        by mx.google.com with ESMTPS id y72si28848051lfd.85.2015.10.08.01.49.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 01:49:39 -0700 (PDT)
Received: by lbcao8 with SMTP id ao8so39405459lbc.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 01:49:39 -0700 (PDT)
Date: Thu, 8 Oct 2015 10:49:53 +0200
From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: [PATCH V4 2/3] arm64: support initrd outside kernel linear map
Message-ID: <20151008084953.GA20114@cbox>
References: <1439830867-14935-1-git-send-email-msalter@redhat.com>
 <1439830867-14935-3-git-send-email-msalter@redhat.com>
 <20150908113113.GA20562@leverpostej>
 <20151006171140.GE26433@leverpostej>
 <1444151812.10788.14.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444151812.10788.14.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Oct 06, 2015 at 01:16:52PM -0400, Mark Salter wrote:
> On Tue, 2015-10-06 at 18:11 +0100, Mark Rutland wrote:
> > On Tue, Sep 08, 2015 at 12:31:13PM +0100, Mark Rutland wrote:
> > > Hi Mark,
> > > 
> > > On Mon, Aug 17, 2015 at 06:01:06PM +0100, Mark Salter wrote:
> > > > The use of mem= could leave part or all of the initrd outside of
> > > > the kernel linear map. This will lead to an error when unpacking
> > > > the initrd and a probable failure to boot. This patch catches that
> > > > situation and relocates the initrd to be fully within the linear
> > > > map.
> > > 
> > > With next-20150908, this patch results in a confusing message at boot when not
> > > using an initrd:
> > > 
> > > Moving initrd from [4080000000-407fffffff] to [9fff49000-9fff48fff]
> > > 
> > > I think that can be solved by folding in the diff below.
> > 
> > Mark, it looks like this fell by the wayside.
> > 
> > Do you have any objection to this? I'll promote this to it's own patch
> > if not.
> > 
> > Mark.
> > 
> > > 
> > > Thanks,
> > > Mark.
> > > 
> > > diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> > > index 6bab21f..2322479 100644
> > > --- a/arch/arm64/kernel/setup.c
> > > +++ b/arch/arm64/kernel/setup.c
> > > @@ -364,6 +364,8 @@ static void __init relocate_initrd(void)
> > >                 to_free = ram_end - orig_start;
> > >  
> > >         size = orig_end - orig_start;
> > > +       if (!size)
> > > +               return;
> > >  
> > >         /* initrd needs to be relocated completely inside linear mapping */
> > >         new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),
> 
> Sorry, no. That looks perfectly good to me.
> 
FYI: I applied these patches to 4.0 (only a trivial conflict on the x86
side) and this fixed an issue for me booting systems with mem=X,
reducing the amount of physical memory available on a system, which
would otherwise cause the system to just silently halt during boot.

Note that this seems to fix even more than it promises, because one of
those systems does not use an initrd, but I'm thinking maybe this fixes
issues with the DT as well?

In any case, I think this may be a good candidate for cc'ing to stable?

Thanks,
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
