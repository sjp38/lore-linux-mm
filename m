Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 397D46B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 10:49:46 -0400 (EDT)
Received: by oift201 with SMTP id t201so7770760oif.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:49:46 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id g8si8938910oep.106.2015.05.12.07.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 07:49:45 -0700 (PDT)
Message-ID: <1431441030.24419.81.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 12 May 2015 08:30:30 -0600
In-Reply-To: <20150512072809.GA3497@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-8-git-send-email-toshi.kani@hp.com>
	 <20150509090810.GB4452@pd.tnic>
	 <1431372316.23761.440.camel@misato.fc.hp.com>
	 <20150511201827.GI15636@pd.tnic>
	 <1431376726.23761.471.camel@misato.fc.hp.com>
	 <20150511214244.GK15636@pd.tnic>
	 <1431382179.24419.12.camel@misato.fc.hp.com>
	 <20150512072809.GA3497@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-12 at 09:28 +0200, Borislav Petkov wrote:
> On Mon, May 11, 2015 at 04:09:39PM -0600, Toshi Kani wrote:
> > There may not be any type conflict with MTRR_TYPE_INVALID.
> 
> Because...?

Because you cannot have a memory type conflict with MTRRs when MTRRs are
disabled.  mtrr_type_lookup() returns MTRR_TYPE_INVALID when MTRRs are
disabled.  This is stated in the comments of mtrr_type_lookup() and the
MTRR_TYPE_INVALID definition itself.

BIOS can disable MTRRs, or VM may choose not to implement MTRRs.  The OS
needs to handle this case as a valid config, and this is not an error
case.

> Let me guess: you cannot change this function to return a signed value
> which is the type when positive and an error when negative?

No, that is not the reason. 

> > I will change the caller to check MTRR_TYPE_INVALID, and treat it as a
> > uniform case.
> 
> That would be, of course, also wrong.

I am confused... In your previous comments, you mentioned that:

| If you want to be able to state that a type is uniform even if MTRRs
| are disabled, you need to define another retval which means exactly
| that.

There may not be type conflict when MTRRs are disabled.  There is no
point of defining a new return value.

| Or add an inline function called mtrr_enabled() and call it in the
| mtrr_type_lookup() callers.

MTRR_TYPE_INVALID means MTRRs disabled.  So, the caller checking with
this value is the same as checking with mtrr_enabled() you suggested.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
