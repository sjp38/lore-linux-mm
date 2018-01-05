Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B430C28027E
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:55:40 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u128so2605922oib.8
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:55:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x79si1649210oia.52.2018.01.05.11.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 11:55:39 -0800 (PST)
Date: Fri, 5 Jan 2018 20:55:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Message-ID: <20180105195535.GZ26807@redhat.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
 <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
 <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, Jan 05, 2018 at 08:17:17PM +0100, Jiri Kosina wrote:
> On Fri, 5 Jan 2018, Dave Hansen wrote:
> 
> > > --- a/arch/x86/platform/efi/efi_64.c
> > > +++ b/arch/x86/platform/efi/efi_64.c
> > > @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
> > >  		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
> > >  		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
> > >  		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
> > > +		/*
> > > +		 * pgprot API doesn't clear it for PGD
> > > +		 *
> > > +		 * Will be brought back automatically in _epilog()
> > > +		 */
> > > +		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
> > >  	}
> > >  	__flush_tlb_all();

Upstream & downstream looks different, how the above looks completely
different I don't know, but I got it and updating is easy. Great
catch.

> > 
> > Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
> > the &init_mm in there and *not* set _PAGE_USER?
> 
> That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for 
> reasons that are behind me.

For vsyscalls? I also had to single out warnings out of init_mm.pgd
for the same reasons.

How does the below (untested) look?
