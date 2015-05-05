Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 08E666B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 16:09:36 -0400 (EDT)
Received: by wgso17 with SMTP id o17so195996974wgs.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 13:09:35 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id r18si557043wiw.123.2015.05.05.13.09.34
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 13:09:34 -0700 (PDT)
Date: Tue, 5 May 2015 22:09:31 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
Message-ID: <20150505200931.GS3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
 <20150505171114.GM3910@pd.tnic>
 <1430847128.23761.276.camel@misato.fc.hp.com>
 <20150505183947.GO3910@pd.tnic>
 <1430854292.23761.284.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430854292.23761.284.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, May 05, 2015 at 01:31:32PM -0600, Toshi Kani wrote:
> Well, the comment kinda says it already, but I will try to clarify it.
> 
>            /*
>             * We have start:end spanning across an MTRR.
>             * We split the region into either
>             * - start_state:1
>             *     (start:mtrr_end) (mtrr_end:end)
>             * - end_state:1 or inclusive:1
>             *     (start:mtrr_start) (mtrr_start:end)

What I mean is this:

		* - start_state:1
		*     (start:mtrr_end) (mtrr_end:end)
		* - end_state:1
		*     (start:mtrr_start) (mtrr_start:end)
		* - inclusive:1
		*     (start:mtrr_start) (mtrr_start:mtrr_end) (mtrr_end:end)
		*
		* depending on kind of overlap.
		*
		* Return the type of the first region and a pointer to the start
		* of next region so that caller will be advised to lookup again
		* after having adjusted start and end.
		*
		* Note: This way we handle multiple overlaps as well.
		*/

We add comments so that people can read them and can quickly understand
what the function does. Not to make them parse it and wonder why
inclusive:1 is listed together with end_state:1 which returns two
intervals.

Note that I changed the text to talk about the *next* region and not
about the *second* region, to make it even more clear.

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
