Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A0A836B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:59:39 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k9so2822711iok.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:59:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor1424786ioi.82.2017.10.31.16.59.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 16:59:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223228.9F2B69B4@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223228.9F2B69B4@viggo.jf.intel.com>
From: Kees Cook <keescook@google.com>
Date: Tue, 31 Oct 2017 16:59:37 -0700
Message-ID: <CAGXu5jK3nwcO=520a0V22bs_-8wBYAO+E5aeX53PUfevA2KvVQ@mail.gmail.com>
Subject: Re: [PATCH 23/23] x86, kaiser: add Kconfig
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, x86@kernel.org

On Tue, Oct 31, 2017 at 3:32 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> PARAVIRT generally requires that the kernel not manage its own page
> tables.  It also means that the hypervisor and kernel must agree
> wholeheartedly about what format the page tables are in and what
> they contain.  KAISER, unfortunately, changes the rules and they
> can not be used together.

A quick look through "#ifdef CONFIG_KAISER" looks like it might be
possible to make this a runtime setting at some point. When doing
KASLR, it was much more useful to make this runtime selectable so that
distro kernels could build the support in, but let users decide if
they wanted to enable it.

> I've seen conflicting feedback from maintainers lately about whether
> they want the Kconfig magic to go first or last in a patch series.
> It's going last here because the partially-applied series leads to
> kernels that can not boot in a bunch of cases.  I did a run through
> the entire series with CONFIG_KAISER=y to look for build errors,
> though.

Yeah, I think last tends to be the best, though it isn't great for
debugging. Doing it earlier, though, tends to lead to a lot of
confusion about whether some feature is actually operating sanely or
not.

-Kees

> Note from Hugh Dickins on why it depends on SMP:
>
>         It is absurd that KAISER should depend on SMP, but
>         apparently nobody has tried a UP build before: which
>         breaks on implicit declaration of function
>         'per_cpu_offset' in arch/x86/mm/kaiser.c.
>
>         Now, you would expect that to be trivially fixed up; but
>         looking at the System.map when that block is #ifdef'ed
>         out of kaiser_init(), I see that in a UP build
>         __per_cpu_user_mapped_end is precisely at
>         __per_cpu_user_mapped_start, and the items carefully
>         gathered into that section for user-mapping on SMP,
>         dispersed elsewhere on UP.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
>
>  b/security/Kconfig |   10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff -puN security/Kconfig~kaiser-kconfig security/Kconfig
> --- a/security/Kconfig~kaiser-kconfig   2017-10-31 15:04:01.680648908 -0700
> +++ b/security/Kconfig  2017-10-31 15:04:01.684649097 -0700
> @@ -54,6 +54,16 @@ config SECURITY_NETWORK
>           implement socket and networking access controls.
>           If you are unsure how to answer this question, answer N.
>
> +config KAISER
> +       bool "Remove the kernel mapping in user mode"
> +       depends on X86_64 && SMP && !PARAVIRT
> +       help
> +         This feature reduces the number of hardware side channels by
> +         ensuring that the majority of kernel addresses are not mapped
> +         into userspace.
> +
> +         See Documentation/x86/kaiser.txt for more details.
> +
>  config SECURITY_INFINIBAND
>         bool "Infiniband Security Hooks"
>         depends on SECURITY && INFINIBAND
> _



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
