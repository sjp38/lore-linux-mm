Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 09C3E6B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 13:02:02 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id u20so8966375oif.22
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 10:02:01 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id dm7si18964433oeb.48.2014.11.03.10.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 10:02:00 -0800 (PST)
Message-ID: <1415036879.29109.26.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 1/7] x86, mm, pat: Set WT to PA7 slot of PAT MSR
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 03 Nov 2014 10:47:59 -0700
In-Reply-To: <alpine.DEB.2.11.1411031812390.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
	 <1414450545-14028-2-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1411031812390.5308@nanos>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

On Mon, 2014-11-03 at 18:14 +0100, Thomas Gleixner wrote:
> On Mon, 27 Oct 2014, Toshi Kani wrote:
> > +	} else {
> > +		/*
> > +		 * PAT full support. WT is set to slot 7, which minimizes
> > +		 * the risk of using the PAT bit as slot 3 is UC and is
> > +		 * currently unused. Slot 4 should remain as reserved.
> 
> This comment makes no sense. What minimizes which risk and what has
> this to do with slot 3 and slot 4?

This is for precaution.  Since the patch enables the PAT bit the first
time, it was suggested that we keep slot 4 reserved and set it to WB.
The PAT bit still has no effect to slot 0/1/2 (WB/WC/UC-) after this
patch.  Slot 7 is the safest slot since slot 3 (UC) is unused today.

https://lkml.org/lkml/2014/9/4/691
https://lkml.org/lkml/2014/9/5/394

> > +		 *
> > +		 *  PTE encoding used in Linux:
> > +		 *      PAT
> > +		 *      |PCD
> > +		 *      ||PWT  PAT
> > +		 *      |||    slot
> > +		 *      000    0    WB : _PAGE_CACHE_MODE_WB
> > +		 *      001    1    WC : _PAGE_CACHE_MODE_WC
> > +		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
> > +		 *      011    3    UC : _PAGE_CACHE_MODE_UC
> > +		 *      100    4    <reserved>
> > +		 *      101    5    <reserved>
> > +		 *      110    6    <reserved>
> 
> Well, they are still mapped to WB/WC/UC_MINUS ....

Right, the reserved slots are also initialized with their safe values.
However, the macros _PAGE_CACHE_MODE_XXX only refer to the slots
specified above.

> > +		 *      111    7    WT : _PAGE_CACHE_MODE_WT
> > +		 */
> > +		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> > +		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
> > +	}
> 
> Thanks,

Thanks for the review!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
