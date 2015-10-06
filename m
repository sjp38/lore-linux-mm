Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9C86B0271
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 13:16:55 -0400 (EDT)
Received: by iofh134 with SMTP id h134so229940507iof.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 10:16:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l67si23619040iol.112.2015.10.06.10.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 10:16:54 -0700 (PDT)
Message-ID: <1444151812.10788.14.camel@redhat.com>
Subject: Re: [PATCH V4 2/3] arm64: support initrd outside kernel linear map
From: Mark Salter <msalter@redhat.com>
Date: Tue, 06 Oct 2015 13:16:52 -0400
In-Reply-To: <20151006171140.GE26433@leverpostej>
References: <1439830867-14935-1-git-send-email-msalter@redhat.com>
	 <1439830867-14935-3-git-send-email-msalter@redhat.com>
	 <20150908113113.GA20562@leverpostej> <20151006171140.GE26433@leverpostej>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, 2015-10-06 at 18:11 +0100, Mark Rutland wrote:
> On Tue, Sep 08, 2015 at 12:31:13PM +0100, Mark Rutland wrote:
> > Hi Mark,
> > 
> > On Mon, Aug 17, 2015 at 06:01:06PM +0100, Mark Salter wrote:
> > > The use of mem= could leave part or all of the initrd outside of
> > > the kernel linear map. This will lead to an error when unpacking
> > > the initrd and a probable failure to boot. This patch catches that
> > > situation and relocates the initrd to be fully within the linear
> > > map.
> > 
> > With next-20150908, this patch results in a confusing message at boot when not
> > using an initrd:
> > 
> > Moving initrd from [4080000000-407fffffff] to [9fff49000-9fff48fff]
> > 
> > I think that can be solved by folding in the diff below.
> 
> Mark, it looks like this fell by the wayside.
> 
> Do you have any objection to this? I'll promote this to it's own patch
> if not.
> 
> Mark.
> 
> > 
> > Thanks,
> > Mark.
> > 
> > diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> > index 6bab21f..2322479 100644
> > --- a/arch/arm64/kernel/setup.c
> > +++ b/arch/arm64/kernel/setup.c
> > @@ -364,6 +364,8 @@ static void __init relocate_initrd(void)
> >                 to_free = ram_end - orig_start;
> >  
> >         size = orig_end - orig_start;
> > +       if (!size)
> > +               return;
> >  
> >         /* initrd needs to be relocated completely inside linear mapping */
> >         new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),

Sorry, no. That looks perfectly good to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
