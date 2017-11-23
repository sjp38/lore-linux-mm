Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 549026B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 23:08:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 192so17910200pgd.18
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 20:08:04 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 61si15213219plr.279.2017.11.22.20.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 20:08:03 -0800 (PST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7569921909
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:08:02 +0000 (UTC)
Received: by mail-it0-f43.google.com with SMTP id m191so8812572itg.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 20:08:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171123003447.1DB395E3@viggo.jf.intel.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 22 Nov 2017 20:07:41 -0800
Message-ID: <CALCETrUx-3bXEsZSuaSBkEf7r+MmGoOb9fM8A3eGQpwq0qc2HA@mail.gmail.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 22, 2017 at 4:34 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> These actions when dealing with a user address *and* the
> PGD has _PAGE_USER set.  That way, in-kernel users of low addresses
> typically used by userspace are not accidentally poisoned.

This seems sane.

> +/*
> + * Take a PGD location (pgdp) and a pgd value that needs
> + * to be set there.  Populates the shadow and returns
> + * the resulting PGD that must be set in the kernel copy
> + * of the page tables.
> + */
> +static inline pgd_t kaiser_set_shadow_pgd(pgd_t *pgdp, pgd_t pgd)
> +{
> +#ifdef CONFIG_KAISER
> +       if (pgd_userspace_access(pgd)) {
> +               if (pgdp_maps_userspace(pgdp)) {
> +                       /*
> +                        * The user/shadow page tables get the full
> +                        * PGD, accessible from userspace:
> +                        */
> +                       kernel_to_shadow_pgdp(pgdp)->pgd = pgd.pgd;
> +                       /*
> +                        * For the copy of the pgd that the kernel
> +                        * uses, make it unusable to userspace.  This
> +                        * ensures if we get out to userspace with the
> +                        * wrong CR3 value, userspace will crash
> +                        * instead of running.
> +                        */
> +                       pgd.pgd |= _PAGE_NX;
> +               }
> +       } else if (pgd_userspace_access(*pgdp)) {
> +               /*
> +                * We are clearing a _PAGE_USER PGD for which we
> +                * presumably populated the shadow.  We must now
> +                * clear the shadow PGD entry.
> +                */
> +               if (pgdp_maps_userspace(pgdp)) {
> +                       kernel_to_shadow_pgdp(pgdp)->pgd = pgd.pgd;
> +               } else {
> +                       /*
> +                        * Attempted to clear a _PAGE_USER PGD which
> +                        * is in the kernel porttion of the address
> +                        * space.  PGDs are pre-populated and we
> +                        * never clear them.
> +                        */
> +                       WARN_ON_ONCE(1);
> +               }
> +       } else {
> +               /*
> +                * _PAGE_USER was not set in either the PGD being set
> +                * or cleared.  All kernel PGDs should be
> +                * pre-populated so this should never happen after
> +                * boot.
> +                */
> +       }
> +#endif
> +       /* return the copy of the PGD we want the kernel to use: */
> +       return pgd;
> +}
> +

The more I read this code, the more I dislike "shadow".  Shadow
pagetables mean something specific in the virtualization world and,
more importantly, the word "shadow" fails to convey *which* table it
is.  Unless I'm extra confused, mm->pgd points to the kernelmode
tables.  So can we replace the word "shadow" with "usermode"?  That
will also make the entry stuff way clearer.  (Or I have it backwards,
in which case "kernelmode" would be the right choice.)  And rename the
argument.

That confusion aside, I'm trying to wrap my head around this.  I think
the description above makes sense, but I'm struggling to grok the code
and how it matches the description.  May I suggest an alternative
implementation?  (Apologies for epic whitespace damage.)

/*
 * Install an entry into the usermode pgd.  pgdp points to the kernelmode
 * entry whose usermode counterpart we're supposed to set.  pgd is the
 * desired entry.  Returns pgd, possibly modified if the actual entry installed
 * into the kernelmode needs different mode bits.
 */
static inline pgd_t kaiser_set_usermode_pgd(pgd_t *pgdp, pgd_t pgd) {
  VM_BUG_ON(pgdp points to a usermode table);

  if (pgdp_maps_userspace(pgdp)) {
    /* Install the pgd as requested into the usermode tables. */
    kernelmode_to_usermode_pgdp(pgdp)->pgd = pgd.pgd;

    if (pgd_val(pgd) & _PAGE_USER) {
      /*
       * This is a normal user pgd -- the kernelmode mapping should have NX
       * set to prevent erroneous usermode execution with the kernel tables.
       */
      return __pgd(pgd_val(pgd) | _PAGE_NX;
    } else {
      /* This is a weird mapping, e.g. EFI.  Map it straight through. */
      return pgd;
    }
  } else {
    /*
     * We can get here due to vmalloc, a vmalloc fault, memory
hot-add, or initial setup
     * of kernelmode page tables.  Regardless of which particular code
path we're in,
     * these mappings should not be automatically propagated to the
usermode tables.
     */
    return pgd;
  }
}

As a side benefit, this shouldn't have magical interactions with the
vsyscall page any more.

Are there cases that this would get wrong?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
