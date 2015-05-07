Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1476B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 03:52:19 -0400 (EDT)
Received: by wief7 with SMTP id f7so7296875wie.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 00:52:17 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id cl2si1969131wjc.117.2015.05.07.00.52.15
        for <linux-mm@kvack.org>;
        Thu, 07 May 2015 00:52:16 -0700 (PDT)
Date: Thu, 7 May 2015 09:52:10 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 6/7] mtrr, x86: Clean up mtrr_type_lookup()
Message-ID: <20150507075210.GA6859@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-7-git-send-email-toshi.kani@hp.com>
 <20150506134127.GE22949@pd.tnic>
 <1430928030.23761.328.camel@misato.fc.hp.com>
 <20150506224931.GL22949@pd.tnic>
 <1430955730.23761.348.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430955730.23761.348.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, May 06, 2015 at 05:42:10PM -0600, Toshi Kani wrote:
> Well, creating mtrr_type_lookup_fixed() is one of the comments I had in
> the previous code review.  Anyway, let me make sure if I understand your
> comment correctly.  Do the following changes look right to you?
> 
> 1) Change the caller responsible for the condition checks.
> 
>         if ((start < 0x100000) &&
>             (mtrr_state.have_fixed) &&
>             (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
>                 return mtrr_type_lookup_fixed(start, end);
> 
> 2) Delete the checks with mtrr_state in mtrr_type_lookup_fixed() as they
> are done by the caller.  Keep the check with '(start >= 0x100000)' to
> assure that the code handles the range [0xC0000 - 0xFFFFF] correctly.

That is a good defensive measure.

> static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
> {
>         int idx;
> 
>         if (start >= 0x100000)
>                  return MTRR_TYPE_INVALID;
>  
> -       if (!(mtrr_state.have_fixed) ||
> -           !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> -               return MTRR_TYPE_INVALID;

Yeah, that's what I mean.

Thanks.

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
