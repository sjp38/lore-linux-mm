Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 908036B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:18:36 -0400 (EDT)
Received: by wizk4 with SMTP id k4so121333393wiz.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 13:18:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id x15si22226535wju.179.2015.05.11.13.18.34
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 13:18:35 -0700 (PDT)
Date: Mon, 11 May 2015 22:18:27 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150511201827.GI15636@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
 <20150509090810.GB4452@pd.tnic>
 <1431372316.23761.440.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1431372316.23761.440.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Mon, May 11, 2015 at 01:25:16PM -0600, Toshi Kani wrote:
> > > @@ -235,13 +240,19 @@ static u8 mtrr_type_lookup_variable(u64 start, u64 end, u64 *partial_end,
> > >   * Return Values:
> > >   * MTRR_TYPE_(type)  - The effective MTRR type for the region
> > >   * MTRR_TYPE_INVALID - MTRR is disabled
> > > + *
> > > + * Output Argument:
> > > + * uniform - Set to 1 when MTRR covers the region uniformly, i.e. the region
> > > + *	     is fully covered by a single MTRR entry or the default type.
> > 
> > I'd call this "single_mtrr". "uniform" could also mean that the resulting
> > type is uniform, i.e. of the same type but spanning multiple MTRRs.
> 
> Actually, that is the intend of "uniform" and the same type but spanning
> multiple MTRRs should set "uniform" to 1.  The patch does not check such

So why does it say "is fully covered by a single MTRR entry or the
default type." - the stress being on *single*

You need to make up your mind.

> We need to set "uniform" to 1 when MTRRs are disabled since there is no
> type conflict with MTRRs.

No, this is wrong.

When we return an *error*, "uniform" should be *undefined* because MTRRs
are disabled and callers should be checking whether it returned an error
first and only *then* look at uniform.

> The warning was suggested by reviewers in the previous review so that
> driver writers will notice the issue.

No, we don't flood dmesg so that driver writers notice stuff. We better
fix the callers.

> Returning 0 here will lead
> ioremap() to use 4KB mappings, but does not cause ioremap() to fail.

I guess a pr_warn_once() should be better then. Flooding dmesg with
error messages for which the user can't really do anything about doesn't
bring us anything.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
