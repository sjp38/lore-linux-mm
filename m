Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 94BC56B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 15:50:42 -0400 (EDT)
Received: by obfe9 with SMTP id e9so147284085obf.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 12:50:42 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id pb7si10731602oeb.72.2015.05.05.12.50.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 12:50:41 -0700 (PDT)
Message-ID: <1430854292.23761.284.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 05 May 2015 13:31:32 -0600
In-Reply-To: <20150505183947.GO3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
	 <20150505171114.GM3910@pd.tnic>
	 <1430847128.23761.276.camel@misato.fc.hp.com>
	 <20150505183947.GO3910@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-05 at 20:39 +0200, Borislav Petkov wrote:
> On Tue, May 05, 2015 at 11:32:08AM -0600, Toshi Kani wrote:
> > > Ok, I'm confused. Shouldn't the inclusive:1 case be
> > > 
> > > 			(start:mtrr_start) (mtrr_start:mtrr_end) (mtrr_end:end)
> > > 
> > > ?
> > > 
> > > If so, this function would need more changes...
> > 
> > Yes, that's how it gets separated eventually.  Since *repeat is set in
> > this case, the code only needs to separate the first part at a time.
> > The 2nd part gets separated in the next call with the *repeat.
> 
> Aah, right, the caller is supposed to adjust the interval limits on
> subsequent calls. Please reflect this in the comment because:
> 
> 		*     (start:mtrr_start) (mtrr_start:end)
> 
> is misleading for inclusive:1.

Well, the comment kinda says it already, but I will try to clarify it.

           /*
            * We have start:end spanning across an MTRR.
            * We split the region into either
            * - start_state:1
            *     (start:mtrr_end) (mtrr_end:end)
            * - end_state:1 or inclusive:1
            *     (start:mtrr_start) (mtrr_start:end)
            * depending on kind of overlap.
            * Return the type for first region and a pointer to
            * the start of second region so that caller will
            * lookup again on the second region.
            * Note: This way we handle multiple overlaps as well.
            */

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
