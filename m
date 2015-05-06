Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 408E36B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 20:01:19 -0400 (EDT)
Received: by oign205 with SMTP id n205so20948958oig.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 17:01:19 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id gw4si180790obc.87.2015.05.06.17.01.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 17:01:18 -0700 (PDT)
Message-ID: <1430955730.23761.348.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 6/7] mtrr, x86: Clean up mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 06 May 2015 17:42:10 -0600
In-Reply-To: <20150506224931.GL22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-7-git-send-email-toshi.kani@hp.com>
	 <20150506134127.GE22949@pd.tnic>
	 <1430928030.23761.328.camel@misato.fc.hp.com>
	 <20150506224931.GL22949@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Thu, 2015-05-07 at 00:49 +0200, Borislav Petkov wrote:
> On Wed, May 06, 2015 at 10:00:30AM -0600, Toshi Kani wrote:
> > Ingo asked me to describe this info here in his review...
> 
> Ok.
> 
> > mtrr_type_lookup_fixed() checks the above conditions at entry, and
> > returns immediately with TYPE_INVALID.  I think it is safer to have such
> > checks in mtrr_type_lookup_fixed() in case there will be multiple
> > callers.
> 
> This is not what I mean - I mean to call mtrr_type_lookup_fixed() based
> on @start and not unconditionally, like you do.
> 
> And there most likely won't be multiple callers because we're phasing
> out MTRR use.
> 
> And even if there are, they better look at how this function is being
> called before calling it. Which I seriously doubt - it is a static
> function which you *just* came up with.

Well, creating mtrr_type_lookup_fixed() is one of the comments I had in
the previous code review.  Anyway, let me make sure if I understand your
comment correctly.  Do the following changes look right to you?

1) Change the caller responsible for the condition checks.

        if ((start < 0x100000) &&
            (mtrr_state.have_fixed) &&
            (mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
                return mtrr_type_lookup_fixed(start, end);

2) Delete the checks with mtrr_state in mtrr_type_lookup_fixed() as they
are done by the caller.  Keep the check with '(start >= 0x100000)' to
assure that the code handles the range [0xC0000 - 0xFFFFF] correctly.

static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
{
        int idx;

        if (start >= 0x100000)
                 return MTRR_TYPE_INVALID;
 
-       if (!(mtrr_state.have_fixed) ||
-           !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))
-               return MTRR_TYPE_INVALID;


> > Right, and there is more.  As the original code had comment "Just return
> > the type as per start", which I noticed that I had accidentally removed,
> > the code only returns the type of the start address.  The fixed ranges
> > have multiple entries with different types.  Hence, a given range may
> > overlap with multiple fixed entries.  I will restore the comment in the
> > function header to clarify this limitation.
> 
> Ok, let's cleanup this function first and then consider fixing other
> possible bugs which haven't been fixed since forever. Again, we might
> not even need to address them because we won't be using MTRRs once we
> switch to PAT completely, which is what Luis is working on.

Right.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
