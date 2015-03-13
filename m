Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 81D69829B9
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 09:54:02 -0400 (EDT)
Received: by obcvb8 with SMTP id vb8so19808899obc.0
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 06:54:02 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id o10si1085403oex.59.2015.03.13.06.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 06:54:01 -0700 (PDT)
Message-ID: <1426254791.17007.451.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 3/4] mtrr, x86: Clean up mtrr_type_lookup()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 13 Mar 2015 07:53:11 -0600
In-Reply-To: <20150313123722.GA4152@gmail.com>
References: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
	 <1426180690-24234-4-git-send-email-toshi.kani@hp.com>
	 <20150313123722.GA4152@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "Elliott, Robert (Server
 Storage)" <Elliott@hp.com>, "pebolle@tiscali.nl" <pebolle@tiscali.nl>

On Fri, 2015-03-13 at 12:37 +0000, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
 :
> > +	/* Look in fixed ranges. Just return the type as per start */
> > +	if (mtrr_state.have_fixed && (start < 0x100000)) {
> > +		int idx;
> > +
> > +		if (start < 0x80000) {
> > +			idx = 0;
> > +			idx += (start >> 16);
> > +			return mtrr_state.fixed_ranges[idx];
> > +		} else if (start < 0xC0000) {
> > +			idx = 1 * 8;
> > +			idx += ((start - 0x80000) >> 14);
> > +			return mtrr_state.fixed_ranges[idx];
> > +		} else {
> > +			idx = 3 * 8;
> > +			idx += ((start - 0xC0000) >> 12);
> > +			return mtrr_state.fixed_ranges[idx];
> > +		}
> > +	}
> 
> So why not put this into a separate helper function - named 
> mtrr_type_lookup_fixed()? It has little relation to variable ranges.

Sounds good.  I will update as suggested.

> > +
> > +	/*
> > +	 * Look in variable ranges
> > +	 * Look of multiple ranges matching this address and pick type
> > +	 * as per MTRR precedence
> > +	 */
> > +	if (!(mtrr_state.enabled & 2))
> > +		return mtrr_state.def_type;
> > +
> >  	type = __mtrr_type_lookup(start, end, &partial_end, &repeat);
> 
> And this then should be named mtrr_type_lookup_variable() or so?

Will do as well.

I will send out a new version today since I won't be able to update the
patchset next week. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
