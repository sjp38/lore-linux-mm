Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8DC6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 18:28:52 -0400 (EDT)
Received: by obbkp3 with SMTP id kp3so111017854obb.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 15:28:52 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id wz3si7822632obc.33.2015.05.11.15.28.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 15:28:51 -0700 (PDT)
Message-ID: <1431382179.24419.12.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 11 May 2015 16:09:39 -0600
In-Reply-To: <20150511214244.GK15636@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
	 <20150509090810.GB4452@pd.tnic>
	 <1431372316.23761.440.camel@misato.fc.hp.com>
	 <20150511201827.GI15636@pd.tnic>
	 <1431376726.23761.471.camel@misato.fc.hp.com>
	 <20150511214244.GK15636@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Mon, 2015-05-11 at 23:42 +0200, Borislav Petkov wrote:
> On Mon, May 11, 2015 at 02:38:46PM -0600, Toshi Kani wrote:
> > MTRRs disabled is not an error case as it could be a normal
> > configuration on some platforms / BIOS setups.
> 
> Normal how? PAT-only systems? Examples please...

BIOS initializes and enables MTRRs at POST.  While the most (if not all)
BIOSes do it today, I do not think the x86 arch requires BIOS to enable
them.

Here is a quote from Intel SDM:
===
11.11.5 MTRR Initialization

On a hardware reset, the P6 and more recent processors clear the valid
flags in variable-range MTRRs and clear the E flag in the
IA32_MTRR_DEF_TYPE MSR to disable all MTRRs. All other bits in the MTRRs
are undefined.

Prior to initializing the MTRRs, software (normally the system BIOS)
must initialize all fixed-range and variablerange MTRR register fields
to 0. Software can then initialize the MTRRs according to known types of
memory, including memory on devices that it auto-configures.
Initialization is expected to occur prior to booting the operating
system.
===

> > I clarified it in the above comment that uniform is set for any return
> > value.
> 
> Hell no!
> 
> u8 mtrr_type_lookup(u64 start, u64 end, u8 *uniform)
> {
> 
> 	...
> 
>         *uniform = 1;
> 
>         if (!mtrr_state_set)
>                 return MTRR_TYPE_INVALID;
> 
>         if (!(mtrr_state.enabled & MTRR_STATE_MTRR_ENABLED))
>                 return MTRR_TYPE_INVALID;
> 
> 
> This is wrong and the fact that I still need to persuade you about it
> says a lot.
> 
> If you want to be able to state that a type is uniform even if MTRRs are
> disabled, you need to define another retval which means exactly that.

There may not be any type conflict with MTRR_TYPE_INVALID. 

> Or add an inline function called mtrr_enabled() and call it in the
> mtrr_type_lookup() callers.
> 
> Or whatever.
> 
> I don't want any confusing states with two return types and people
> having to figure out what it exactly means and digging into the code
> and scratching heads WTF is that supposed to mean.

I will change the caller to check MTRR_TYPE_INVALID, and treat it as a
uniform case.

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
