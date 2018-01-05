Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 203476B0505
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:17:23 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q1so2731392pgv.4
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:17:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b61si4359818plc.277.2018.01.05.11.17.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 11:17:22 -0800 (PST)
Date: Fri, 5 Jan 2018 20:17:17 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
In-Reply-To: <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
Message-ID: <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com> <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com> <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com> <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm> <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, 5 Jan 2018, Dave Hansen wrote:

> > --- a/arch/x86/platform/efi/efi_64.c
> > +++ b/arch/x86/platform/efi/efi_64.c
> > @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
> >  		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
> >  		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
> >  		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
> > +		/*
> > +		 * pgprot API doesn't clear it for PGD
> > +		 *
> > +		 * Will be brought back automatically in _epilog()
> > +		 */
> > +		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
> >  	}
> >  	__flush_tlb_all();
> 
> Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
> the &init_mm in there and *not* set _PAGE_USER?

That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for 
reasons that are behind me.

I did put this on my TODO list, but for later.

(and yes, I tried clearing _PAGE_USER from init_mm's PGD, and no obvious 
breakages appeared, but I wanted to give it more thought later).

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
