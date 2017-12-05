Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 660676B0268
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 03:52:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so11867578wrc.20
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 00:52:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x33si37733edx.66.2017.12.05.00.52.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 00:52:54 -0800 (PST)
Date: Tue, 5 Dec 2017 09:52:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171205085251.o5ol7tupoh2xbmb7@dhcp22.suse.cz>
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204105549.GA31332@rei>
 <efb6eae4-7f30-42c3-0efe-0ab5fbf0fdb4@nvidia.com>
 <20171205070510.aojohhvixijk3i27@dhcp22.suse.cz>
 <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

On Mon 04-12-17 23:42:00, John Hubbard wrote:
> On 12/04/2017 11:05 PM, Michal Hocko wrote:
> > On Mon 04-12-17 18:14:18, John Hubbard wrote:
> >> On 12/04/2017 02:55 AM, Cyril Hrubis wrote:
> >>> Hi!
> >>> I know that we are not touching the rest of the existing description for
> >>> MAP_FIXED however the second sentence in the manual page says that "addr
> >>> must be a multiple of the page size." Which however is misleading as
> >>> this is not enough on some architectures. Code in the wild seems to
> >>> (mis)use SHMLBA for aligment purposes but I'm not sure that we should
> >>> advise something like that in the manpages.
> >>>
> >>> So what about something as:
> >>>
> >>> "addr must be suitably aligned, for most architectures multiple of page
> >>> size is sufficient, however some may impose additional restrictions for
> >>> page mapping addresses."
> >>>
> >>
> >> Hi Cyril,
> >>
> >> Right, so I've been looking into this today, and I think we can go a bit
> >> further than that, even. The kernel, as far back as the *original* git
> >> commit in 2005, implements mmap on ARM by requiring that the address is
> >> aligned to SHMLBA:
> >>
> >> arch/arm/mm/mmap.c:50:
> >>
> >> 	if (flags & MAP_FIXED) {
> >> 		if (aliasing && flags & MAP_SHARED &&
> >> 		    (addr - (pgoff << PAGE_SHIFT)) & (SHMLBA - 1))
> >> 			return -EINVAL;
> >> 		return addr;
> >> 	}
> >>
> >> So, given that this has been the implementation for the last 12+ years (and
> >> probably the whole time, in fact), I think we can be bold enough to use this
> >> wording for the second sentence of MAP_FIXED:
> >>
> >> "addr must be a multiple of SHMLBA (<sys/shm.h>), which in turn is either
> >> the system page size (on many architectures) or a multiple of the system
> >> page size (on some architectures)."
> >>
> >> What do you think?
> > 
> > I am not sure this is a good idea. This is pulling way too many
> > implementation details into the man page IMHO. Note that your wording is
> > even incorrect because this applies only to shared mappings and on some
> > architectures it even requires special memory regions. We do not want
> > all that in the man page...
> > 
> 
> Hi Michal,
> 
> OK, so it sounds like Cyril's original wording would be just about right,
> after all, like this?
> 
> "addr must be suitably aligned. For most architectures multiple of page
> size is sufficient; however, some may impose additional restrictions."
> 
> (It does seem unfortunate that the man page cannot help the programmer
> actually write correct code here. He or she is forced to read the kernel
> implementation, in order to figure out the true alignment rules. I was
> hoping we could avoid that.)

I strongly suspect that this is more the architecture than the kernel
implementation imposed restriction.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
