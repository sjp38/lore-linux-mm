Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7334E6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 13:16:26 -0400 (EDT)
Received: by obcus9 with SMTP id us9so10823067obc.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 10:16:26 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id h127si9182371oif.35.2015.05.12.10.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 10:16:25 -0700 (PDT)
Message-ID: <1431449829.24419.104.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 7/7] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 12 May 2015 10:57:09 -0600
In-Reply-To: <20150512163148.GH3497@pd.tnic>
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
	 <20150512163148.GH3497@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-12 at 18:31 +0200, Borislav Petkov wrote:
> On Tue, May 12, 2015 at 08:30:30AM -0600, Toshi Kani wrote:
> > MTRR_TYPE_INVALID means MTRRs disabled.  So, the caller checking with
> > this value is the same as checking with mtrr_enabled() you suggested.
> 
> So then you don't have to set *uniform = 1 on entry to
> mtrr_type_lookup(). And change the retval test
> 
> 	if ((!uniform) && (mtrr != MTRR_TYPE_WRBACK))
> 
> to
> 	if ((mtrr != MTRR_TYPE_INVALID) && (!uniform) && (mtrr != MTRR_TYPE_WRBACK))

Yes, that's what I was thinking as well.  Will do.

> You can put the MTRR_TYPE_INVALID first so that it shortcuts.
> 
> You need the distinction between MTRRs *disabled* and an MTRR region
> being {non-,}uniform.
> 
> If MTRRs are disabled, uniform doesn't *mean* *anything* because it is
> undefined. When MTRRs are disabled, the range is *not* covered by MTRRs
> because, well, them MTRRs are disabled.
> 
> And it might be fine for *your* use case to set *uniform even when MTRRs
> are disabled but it might matter in the future. So we better design it
> correct from the beginning.

I think it is a matter of how "uniform" is defined, but your point is
taken and I will change it accordingly.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
