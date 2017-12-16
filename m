Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D797C4403D7
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 12:20:36 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id o29so9157657qto.12
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 09:20:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g82si9383337qke.10.2017.12.16.09.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 09:20:35 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBGHIwYj098308
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 12:20:35 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ew0h5js2s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 12:20:34 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 16 Dec 2017 10:20:34 -0700
Date: Sat, 16 Dec 2017 09:20:26 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Support setting access rights for signal handlers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
 <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
 <c220f36f-c04a-50ae-3fd7-2c6245e27057@intel.com>
 <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
 <20171214001756.GA5471@ram.oc3035372033.ibm.com>
 <cf13f6e0-2405-4c58-4cf1-266e8baae825@redhat.com>
 <20171216150910.GA5461@ram.oc3035372033.ibm.com>
 <2eba29f4-804d-b211-1293-52a567739cad@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2eba29f4-804d-b211-1293-52a567739cad@redhat.com>
Message-Id: <20171216172026.GC5461@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Sat, Dec 16, 2017 at 04:25:14PM +0100, Florian Weimer wrote:
> On 12/16/2017 04:09 PM, Ram Pai wrote:
> 
> >>It still restores the PKRU register value upon
> >>regular exit from the signal handler, which I think is something we
> >>should keep.
> >
> >On x86, the pkru value is restored, on return from the signal handler,
> >to the value before the signal handler was called. right?
> >
> >In other words, if 'x' was the value when signal handler was called, it
> >will be 'x' when return from the signal handler.
> >
> >If correct, than it is consistent with the behavior on POWER.
> 
> That's good to know.  I tended to implement the same semantics on x86.
> 
> >>I think we still should add a flag, so that applications can easily
> >>determine if a kernel has this patch.  Setting up a signal handler,
> >>sending the signal, and thus checking for inheritance is a bit
> >>involved, and we'd have to do this in the dynamic linker before we
> >>can use pkeys to harden lazy binding.  The flag could just be a
> >>no-op, apart from the lack of an EINVAL failure if it is specified.
> >
> >Sorry. I am little confused.  What should I implement on POWER?
> >PKEY_ALLOC_SETSIGNAL semantics?
> 
> No, we would add a flag, with a different name, and this patch only:
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index ec39f73..021f1d4 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -523,14 +523,17 @@ static int do_mprotect_pkey(unsigned long
> start, size_t l
>         return do_mprotect_pkey(start, len, prot, pkey);
>  }
> 
> +#define PKEY_ALLOC_FLAGS ((unsigned long) (PKEY_ALLOC_SETSIGNAL))
> +
>  SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
>  {
>         int pkey;
>         int ret;
> 
> -       /* No flags supported yet. */
> -       if (flags)
> +       /* check for unsupported flags */
> +       if (flags & ~PKEY_ALLOC_FLAGS)
>                 return -EINVAL;
> +
>         /* check for unsupported init values */
>         if (init_val & ~PKEY_ACCESS_MASK)
>                 return -EINVAL;
> 
> 
> This way, an application can specify the flag during key allocation,
> and knows that if the allocation succeeds, the kernel implements
> access rights inheritance in signal handlers.  I think we need this
> so that applications which are incompatible with the earlier x86
> implementation of memory protection keys do not use them.
> 
> With my second patch (not the first one implementing
> PKEY_ALLOC_SETSIGNAL), no further changes to architecture=specific
> code are needed, except for the definition of the flag in the header
> files.

Ok. Sounds like I do not have much to do. My patches in its current form
will continue to work and provide the semantics you envision.


> 
> I'm open to a different way towards conveying this information to
> userspace.  I don't want to probe for the behavior by sending a
> signal because that is quite involved and would also be visible in
> debuggers, confusing programmers.

I am fine with your proposal.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
