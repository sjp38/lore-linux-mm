Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51800440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 07:52:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 5so858073wmk.0
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 04:52:06 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r20si5620537wmd.158.2017.11.09.04.52.04
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 04:52:04 -0800 (PST)
Date: Thu, 9 Nov 2017 13:51:55 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 04/30] x86, kaiser: disable global pages by default with
 KAISER
Message-ID: <20171109125155.lglrqo6mwd5hzzb7@pd.tnic>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194653.D6C7EFF4@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171108194653.D6C7EFF4@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, Nov 08, 2017 at 11:46:53AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Global pages stay in the TLB across context switches.  Since all
> contexts share the same kernel mapping, we use global pages to
> allow kernel entries in the TLB to survive when we context
> switch.
> 
> But, even having these entries in the TLB opens up something that
> an attacker can use [1].
> 
> Disable global pages so that kernel TLB entries are flushed when
> we run userspace.  This way, all accesses to kernel memory result
> in a TLB miss whether there is good data there or not.  Without
> this, even when KAISER switches pages tables, the kernel entries
> might remain in the TLB.
> 
> We keep _PAGE_GLOBAL available so that we can use it for things
> that are global even with KAISER like the entry/exit code and
> data.
> 
> 1. The double-page-fault attack:
>    http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
> 
>  b/arch/x86/include/asm/pgtable_types.h |   14 +++++++++++++-
>  b/arch/x86/mm/pageattr.c               |   16 ++++++++--------
>  2 files changed, 21 insertions(+), 9 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
