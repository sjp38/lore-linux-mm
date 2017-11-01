Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5C046B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 04:04:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x7so1589801pfa.19
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:04:07 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p7si3997750pgc.577.2017.11.01.01.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 01:04:06 -0700 (PDT)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3CBFA21871
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 08:04:06 +0000 (UTC)
Received: by mail-io0-f172.google.com with SMTP id m16so4385262iod.1
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 01:04:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223224.B9F5D5CA@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223224.B9F5D5CA@viggo.jf.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 1 Nov 2017 01:03:45 -0700
Message-ID: <CALCETrUVC4KMPLNzs1mH=sGs9W9-HtajHAHOtOv0-LaT6uNb+g@mail.gmail.com>
Subject: Re: [PATCH 21/23] x86, pcid, kaiser: allow flushing for future ASID switches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Tue, Oct 31, 2017 at 3:32 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> If we change the page tables in such a way that we need an
> invalidation of all contexts (aka. PCIDs / ASIDs) we can
> actively invalidate them by:
>  1. INVPCID for each PCID (works for single pages too).
>  2. Load CR3 with each PCID without the NOFLUSH bit set
>  3. Load CR3 with the NOFLUSH bit set for each and do
>     INVLPG for each address.
>
> But, none of these are really feasible since we have ~6 ASIDs (12 with
> KAISER) at the time that we need to do an invalidation.  So, we just
> invalidate the *current* context and then mark the cpu_tlbstate
> _quickly_.
>
> Then, at the next context-switch, we notice that we had
> 'all_other_ctxs_invalid' marked, and go invalidate all of the
> cpu_tlbstate.ctxs[] entries.
>
> This ensures that any futuee context switches will do a full flush
> of the TLB so they pick up the changes.

I'm convuced.  What was wrong with the old code?  I guess I just don't
see what the problem is that is solved by this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
