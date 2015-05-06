Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0956B6B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:49:38 -0400 (EDT)
Received: by wief7 with SMTP id f7so640030wie.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 15:49:37 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id cq9si305024wjc.42.2015.05.06.15.49.36
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 15:49:36 -0700 (PDT)
Date: Thu, 7 May 2015 00:49:31 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 6/7] mtrr, x86: Clean up mtrr_type_lookup()
Message-ID: <20150506224931.GL22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-7-git-send-email-toshi.kani@hp.com>
 <20150506134127.GE22949@pd.tnic>
 <1430928030.23761.328.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430928030.23761.328.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Wed, May 06, 2015 at 10:00:30AM -0600, Toshi Kani wrote:
> Ingo asked me to describe this info here in his review...

Ok.

> mtrr_type_lookup_fixed() checks the above conditions at entry, and
> returns immediately with TYPE_INVALID.  I think it is safer to have such
> checks in mtrr_type_lookup_fixed() in case there will be multiple
> callers.

This is not what I mean - I mean to call mtrr_type_lookup_fixed() based
on @start and not unconditionally, like you do.

And there most likely won't be multiple callers because we're phasing
out MTRR use.

And even if there are, they better look at how this function is being
called before calling it. Which I seriously doubt - it is a static
function which you *just* came up with.

> Right, and there is more.  As the original code had comment "Just return
> the type as per start", which I noticed that I had accidentally removed,
> the code only returns the type of the start address.  The fixed ranges
> have multiple entries with different types.  Hence, a given range may
> overlap with multiple fixed entries.  I will restore the comment in the
> function header to clarify this limitation.

Ok, let's cleanup this function first and then consider fixing other
possible bugs which haven't been fixed since forever. Again, we might
not even need to address them because we won't be using MTRRs once we
switch to PAT completely, which is what Luis is working on.

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
