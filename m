Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 759506B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:58:28 -0400 (EDT)
Received: by wggv3 with SMTP id v3so32747200wgg.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:58:27 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id go8si16319268wib.8.2015.03.16.00.58.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 00:58:26 -0700 (PDT)
Received: by wibg7 with SMTP id g7so25596690wib.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:58:26 -0700 (PDT)
Date: Mon, 16 Mar 2015 08:58:21 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 4/5] mtrr, x86: Clean up mtrr_type_lookup()
Message-ID: <20150316075821.GA16062@gmail.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-5-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426282421-25385-5-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> MTRRs contain fixed and variable entries.  mtrr_type_lookup()
> may repeatedly call __mtrr_type_lookup() to handle a request
> that overlaps with variable entries.  However,
> __mtrr_type_lookup() also handles the fixed entries, which
> do not have to be repeated.  Therefore, this patch creates
> separate functions, mtrr_type_lookup_fixed() and
> mtrr_type_lookup_variable(), to handle the fixed and variable
> ranges respectively.
> 
> The patch also updates the function headers to clarify the
> return values and output argument.  It updates comments to
> clarify that the repeating is necessary to handle overlaps
> with the default type, since overlaps with multiple entries
> alone can be handled without such repeating.
> 
> There is no functional change in this patch.

Nice cleanup!

I also suggest adding a small table to the comments before the 
function, that lists the fixed purpose MTRRs and their address ranges 
- to make it more obvious what the magic hexadecimal constants within 
the code are doing.

> +static u8 mtrr_type_lookup_fixed(u64 start, u64 end)
> +{
> +	int idx;
> +
> +	if (start >= 0x100000)
> +		return 0xFF;

Btw., as a separate cleanup patch, we should probably also change 
'0xFF' (which is sometimes written as 0xff) to be some sufficiently 
named constant, and explain its usage somewhere?

> +	if (!(mtrr_state.have_fixed) ||
> +	    !(mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED))

Btw., can MTRR_STATE_MTRR_FIXED_ENABLED ever be set in 
mtrr_state.enabled, without mtrr_state.have_fixed being set?

AFAICS get_mtrr_state() will only ever fill in mtrr_state with fixed 
MTRRs if mtrr_state.have_fixed != 0 - but I might be mis-reading the 
(rather convoluted) flow of code ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
