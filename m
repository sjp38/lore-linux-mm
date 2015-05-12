Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 61E276B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 12:31:53 -0400 (EDT)
Received: by wizk4 with SMTP id k4so161930042wiz.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 09:31:52 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id g14si28305821wjz.39.2015.05.12.09.31.51
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 09:31:51 -0700 (PDT)
Date: Tue, 12 May 2015 18:31:48 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150512163148.GH3497@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
 <20150509090810.GB4452@pd.tnic>
 <1431372316.23761.440.camel@misato.fc.hp.com>
 <20150511201827.GI15636@pd.tnic>
 <1431376726.23761.471.camel@misato.fc.hp.com>
 <20150511214244.GK15636@pd.tnic>
 <1431382179.24419.12.camel@misato.fc.hp.com>
 <20150512072809.GA3497@pd.tnic>
 <1431441030.24419.81.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1431441030.24419.81.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, May 12, 2015 at 08:30:30AM -0600, Toshi Kani wrote:
> MTRR_TYPE_INVALID means MTRRs disabled.  So, the caller checking with
> this value is the same as checking with mtrr_enabled() you suggested.

So then you don't have to set *uniform = 1 on entry to
mtrr_type_lookup(). And change the retval test

	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK))

to
	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) && (mtrr != MTRR_TYPE_WRBACK))

You can put the MTRR_TYPE_INVALID first so that it shortcuts.

You need the distinction between MTRRs *disabled* and an MTRR region
being {non-,}uniform.

If MTRRs are disabled, uniform doesn't *mean* *anything* because it is
undefined. When MTRRs are disabled, the range is *not* covered by MTRRs
because, well, them MTRRs are disabled.

And it might be fine for *your* use case to set *uniform even when MTRRs
are disabled but it might matter in the future. So we better design it
correct from the beginning.

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
