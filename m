Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 32B696B006E
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:46:41 -0400 (EDT)
Received: by obew15 with SMTP id w15so59240349obe.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:46:40 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id u14si3702191oie.102.2015.05.29.07.46.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 07:46:40 -0700 (PDT)
Message-ID: <1432909628.23540.40.camel@misato.fc.hp.com>
Subject: Re: [PATCH v10 11/12] x86, mm, pat: Refactor !pat_enabled handling
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 29 May 2015 08:27:08 -0600
In-Reply-To: <20150529085842.GA31435@pd.tnic>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
	 <1432739944-22633-12-git-send-email-toshi.kani@hp.com>
	 <20150529085842.GA31435@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Fri, 2015-05-29 at 10:58 +0200, Borislav Petkov wrote:
> On Wed, May 27, 2015 at 09:19:03AM -0600, Toshi Kani wrote:
> > This patch refactors the !pat_enabled code paths and integrates
> 
> Please refrain from using such empty phrases like "This patch does this
> and that" in your commit messages - it is implicitly obvious that it is
> "this patch" when one reads it.
> 
> > them into the PAT abstraction code.  The PAT table is emulated by
> > corresponding to the two cache attribute bits, PWT (Write Through)
> > and PCD (Cache Disable).  The emulated PAT table is the same as the
> > BIOS default setup when the system has PAT but the "nopat" boot
> > option is specified.  The emulated PAT table is also used when
> > MSR_IA32_CR_PAT returns 0 (9d34cfdf4).
> 
> 9d34cfdf4 - what is that thing? A commit message? If so, we quote them
> like this:
> 
>   9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correctly")
> 
> note the 12 chars length of the commit id.

Yes, it refers the commit message above.

> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > Reviewed-by: Juergen Gross <jgross@suse.com>
> > ---
> >  arch/x86/mm/init.c     |    6 ++--
> >  arch/x86/mm/iomap_32.c |   12 ++++---
> >  arch/x86/mm/ioremap.c  |   10 +-----
> >  arch/x86/mm/pageattr.c |    6 ----
> >  arch/x86/mm/pat.c      |   77 +++++++++++++++++++++++++++++-------------------
> >  5 files changed, 57 insertions(+), 54 deletions(-)
> 
> So I started applying your pile and everything was ok-ish until I came
> about this trainwreck. You have a lot of changes in here, the commit
> message is certainly lacking sufficient explanation as to why and this
> patch is changing stuff which the previous one adds.

This !pat_enabled path cleanup was suggested during review and is
independent from the WT enablement.  So, I thought it'd be better to
place it as an additional change on top of the WT set, so that it'd be
easier to bisect when there is any issue found in the !pat_enabled path.

> So a lot of unnecesary code movement.
>
> Then you have stuff like this:
> 
> 	+       } else if (!cpu_has_pat && pat_enabled) {
> 
> How can a CPU not have PAT but have it enabled?!?

This simply preserves the original error check in the code.  This error
check makes sure that all CPUs have the PAT feature supported when PAT
is enabled.  This error can only happen when heterogeneous CPUs are
installed/emulated on the system/guest.  This check may be paranoid, but
this cleanup is not meant to modify such an error check.

> So this is not how we do patchsets.
> 
> Please do the cleanups *first*. Do them in small, self-contained changes
> explaining *why* you're doing them.
> 
> *Then* add the new functionality, .i.e. the WT.

Can you consider the patch 10/12-11/12 as a separate patchset from the
WT series?  If that is OK, I will resubmit 10/12 (BUG->panic) and 11/12
(commit log update). 

> Oh, and when you do your next version, do the patches against tip/master
> because there are a bunch of changes in the PAT code already.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
