Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0056B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 10:04:12 -0400 (EDT)
Received: by obfe9 with SMTP id e9so32051005obf.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 07:04:12 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id i8si1306261obe.19.2015.05.07.07.04.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 07:04:11 -0700 (PDT)
Message-ID: <1431006304.23761.349.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 6/7] mtrr, x86: Clean up mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 07 May 2015 07:45:04 -0600
In-Reply-To: <20150507075210.GA6859@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-7-git-send-email-toshi.kani@hp.com>
	 <20150506134127.GE22949@pd.tnic>
	 <1430928030.23761.328.camel@misato.fc.hp.com>
	 <20150506224931.GL22949@pd.tnic>
	 <1430955730.23761.348.camel@misato.fc.hp.com>
	 <20150507075210.GA6859@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Thu, 2015-05-07 at 09:52 +0200, Borislav Petkov wrote:
> On Wed, May 06, 2015 at 05:42:10PM -0600, Toshi Kani wrote:
> > Well, creating mtrr_type_lookup_fixed() is one of the comments I had in
> > the previous code review.  Anyway, let me make sure if I understand your
> > comment correctly.  Do the following changes look right to you?
> > 
> > 1) Change the caller responsible for the condition checks.
> > 
> >         if ((start < 0x100000) &&
> >             (mtrr_state.have_fixed) &&
> >             (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> >                 return mtrr_type_lookup_fixed(start, end);
> > 
> > 2) Delete the checks with mtrr_state in mtrr_type_lookup_fixed() as they
> > are done by the caller.  Keep the check with '(start >= 0x100000)' to
> > assure that the code handles the range [0xC0000 - 0xFFFFF] correctly.
> 
> That is a good defensive measure.
> 
> > static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
> > {
> >         int idx;
> > 
> >         if (start >= 0x100000)
> >                  return MTRR_TYPE_INVALID;
> >  
> > -       if (!(mtrr_state.have_fixed) ||
> > -           !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
> > -               return MTRR_TYPE_INVALID;
> 
> Yeah, that's what I mean.

Thanks for the clarification! Will change accordingly.
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
