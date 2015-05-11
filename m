Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 94EE76B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 17:42:53 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so38562073wic.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 14:42:53 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ex6si1779308wid.103.2015.05.11.14.42.51
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 14:42:52 -0700 (PDT)
Date: Mon, 11 May 2015 23:42:44 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Message-ID: <20150511214244.GK15636@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
 <20150509090810.GB4452@pd.tnic>
 <1431372316.23761.440.camel@misato.fc.hp.com>
 <20150511201827.GI15636@pd.tnic>
 <1431376726.23761.471.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1431376726.23761.471.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Mon, May 11, 2015 at 02:38:46PM -0600, Toshi Kani wrote:
> MTRRs disabled is not an error case as it could be a normal
> configuration on some platforms / BIOS setups.

Normal how? PAT-only systems? Examples please...

> I clarified it in the above comment that uniform is set for any return
> value.

Hell no!

u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
{

	...

        *uniform = 1;

        if (!mtrr_state_set)
                return MTRR_TYPE_INVALID;

        if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
                return MTRR_TYPE_INVALID;


This is wrong and the fact that I still need to persuade you about it
says a lot.

If you want to be able to state that a type is uniform even if MTRRs are
disabled, you need to define another retval which means exactly that.

Or add an inline function called mtrr_enabled() and call it in the
mtrr_type_lookup() callers.

Or whatever.

I don't want any confusing states with two return types and people
having to figure out what it exactly means and digging into the code
and scratching heads WTF is that supposed to mean.

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
