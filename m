Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E79146B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 16:32:52 -0500 (EST)
Received: by padhk6 with SMTP id hk6so31084651pad.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 13:32:52 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s131si3486343pfs.12.2015.12.11.13.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 13:32:52 -0800 (PST)
Date: Fri, 11 Dec 2015 16:32:27 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151211213227.GA22996@char.us.oracle.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Dec 11, 2015 at 09:19:17PM +0000, Luck, Tony wrote:
> > I still don't get the BIT(63) thing.  Can you explain it?
> 
> It will be more obvious when I get around to writing copy_from_user().
> 
> Then we will have a function that can take page faults if there are pages
> that are not present.  If the page faults can't be fixed we have a -EFAULT
> condition. We can also take machine checks if we reads from a location with an
> uncorrected error.
> 
> We need to distinguish these two cases because the action we take is
> different. For the unresolved page fault we already have the ABI that the
> copy_to/from_user() functions return zero for success, and a non-zero
> return is the number of not-copied bytes.
> 
> So for my new case I'm setting bit63 ... this is never going to be set for
> a failed page fault.

Isn't 63 NX?

> 
> copy_from_user() conceptually will look like this:
> 
> int copy_from_user(void *to, void *from, unsigned long n)
> {
> 	u64 ret = mcsafe_memcpy(to, from, n);
> 
> 	if (COPY_HAD_MCHECK(r)) {
> 		if (memory_failure(COPY_MCHECK_PADDR(ret) >> PAGE_SIZE, ...))
> 			force_sig(SIGBUS, current);
> 		return something;
> 	} else
> 		return ret;
> }
> 
> -Tony
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
