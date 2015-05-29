From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 11/12] x86, mm, pat: Refactor !pat_enabled handling
Date: Fri, 29 May 2015 10:58:42 +0200
Message-ID: <20150529085842.GA31435@pd.tnic>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-12-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432739944-22633-12-git-send-email-toshi.kani@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de
List-Id: linux-mm.kvack.org

On Wed, May 27, 2015 at 09:19:03AM -0600, Toshi Kani wrote:
> This patch refactors the !pat_enabled code paths and integrates

Please refrain from using such empty phrases like "This patch does this
and that" in your commit messages - it is implicitly obvious that it is
"this patch" when one reads it.

> them into the PAT abstraction code.  The PAT table is emulated by
> corresponding to the two cache attribute bits, PWT (Write Through)
> and PCD (Cache Disable).  The emulated PAT table is the same as the
> BIOS default setup when the system has PAT but the "nopat" boot
> option is specified.  The emulated PAT table is also used when
> MSR_IA32_CR_PAT returns 0 (9d34cfdf4).

9d34cfdf4 - what is that thing? A commit message? If so, we quote them
like this:

  9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correctly")

note the 12 chars length of the commit id.

> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Juergen Gross <jgross@suse.com>
> ---
>  arch/x86/mm/init.c     |    6 ++--
>  arch/x86/mm/iomap_32.c |   12 ++++---
>  arch/x86/mm/ioremap.c  |   10 +-----
>  arch/x86/mm/pageattr.c |    6 ----
>  arch/x86/mm/pat.c      |   77 +++++++++++++++++++++++++++++-------------------
>  5 files changed, 57 insertions(+), 54 deletions(-)

So I started applying your pile and everything was ok-ish until I came
about this trainwreck. You have a lot of changes in here, the commit
message is certainly lacking sufficient explanation as to why and this
patch is changing stuff which the previous one adds.

So a lot of unnecesary code movement.

Then you have stuff like this:

	+       } else if (!cpu_has_pat && pat_enabled) {

How can a CPU not have PAT but have it enabled?!?

So this is not how we do patchsets.

Please do the cleanups *first*. Do them in small, self-contained changes
explaining *why* you're doing them.

*Then* add the new functionality, .i.e. the WT.

Oh, and when you do your next version, do the patches against tip/master
because there are a bunch of changes in the PAT code already.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
