Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 187266B03D8
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:53:11 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so41540854wma.2
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 06:53:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si10753317wmo.50.2016.12.23.06.53.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Dec 2016 06:53:10 -0800 (PST)
Date: Fri, 23 Dec 2016 15:53:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: pmd dirty emulation in page fault handler
Message-ID: <20161223145305.GF23109@dhcp22.suse.cz>
References: <1482364101-16204-1-git-send-email-minchan@kernel.org>
 <20161222081713.GA32480@node.shutemov.name>
 <20161222145203.GA18970@bbox>
 <20161223091725.GA23117@dhcp22.suse.cz>
 <20161223095336.GA5305@bbox>
 <20161223115421.GD23109@dhcp22.suse.cz>
 <20161223140131.GA5724@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223140131.GA5724@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jason Evans <je@fb.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, "[4.5+]" <stable@vger.kernel.org>, Andreas Schwab <schwab@suse.de>

On Fri 23-12-16 23:01:31, Minchan Kim wrote:
> On Fri, Dec 23, 2016 at 12:54:21PM +0100, Michal Hocko wrote:
> > On Fri 23-12-16 18:53:36, Minchan Kim wrote:
[...]
> > > stucks until VM marked the pmd dirty.
> > > 
> > > How the emulation work depends on the architecture. In case of arm64,
> > > when it set up pte firstly, it sets pte PTE_RDONLY to get a chance to
> > > mark the pte dirty via triggering page fault when store access happens.
> > > Once the page fault occurs, VM marks the pte dirty and arch code for
> > > setting pte will clear PTE_RDONLY for application to proceed.
> > > 
> > > IOW, if VM doesn't mark the pte dirty, application hangs forever by
> > > repeated fault(i.e., store op but the pte is PTE_RDONLY).
> > > 
> > > This patch enables dirty-bit emulation for those architectures.
> > 
> > Yes this is helpful and much more clear, thank you. One thing that is
> > still not clear to me is why cannot we handle that in the arch specific
> > code. I mean what is the side effect of doing pmd_mkdirty for
> > architectures which do not need it?
> 
> For architecture which supports H/W access/dirty bit, it couldn't be
> reached there code path so there is no side effect, I think.

ahh, I knew I was missing something. It definitely wasn't obvious to me
and my x86 config it simply generates code to call
huge_pmd_set_accessed.

> A thing
> I can think of is just increasing code size little bit. Maybe, we
> could optimize away some ifdef magic but not sure worth it.

it is not
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
