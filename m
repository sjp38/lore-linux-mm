Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 448CA6B0069
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 10:09:19 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id c142so4785234qke.15
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 07:09:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n39si6239533qtc.319.2017.12.16.07.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 07:09:18 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBGF8YJM053210
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 10:09:17 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ew08mrbp1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 10:09:17 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 16 Dec 2017 10:09:17 -0500
Date: Sat, 16 Dec 2017 07:09:10 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Support setting access rights for signal handlers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
 <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
 <c220f36f-c04a-50ae-3fd7-2c6245e27057@intel.com>
 <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
 <20171214001756.GA5471@ram.oc3035372033.ibm.com>
 <cf13f6e0-2405-4c58-4cf1-266e8baae825@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf13f6e0-2405-4c58-4cf1-266e8baae825@redhat.com>
Message-Id: <20171216150910.GA5461@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Thu, Dec 14, 2017 at 12:21:44PM +0100, Florian Weimer wrote:
> On 12/14/2017 01:17 AM, Ram Pai wrote:
> >On Wed, Dec 13, 2017 at 04:40:11PM +0100, Florian Weimer wrote:
> >>On 12/13/2017 04:22 PM, Dave Hansen wrote:
> >>>On 12/13/2017 07:08 AM, Florian Weimer wrote:
> >>>>Okay, this model is really quite different from x86.  Is there a
> >>>>good reason for the difference?
> >>>
> >>>Yes, both implementations are simple and take the "natural" behavior.
> >>>x86 changes XSAVE-controlled register values on entering a signal, so we
> >>>let them be changed (including PKRU).  POWER hardware does not do this
> >>>to its PKRU-equivalent, so we do not force it to.
> >>
> >>Whuy?  Is there a technical reason not have fully-aligned behavior?
> >>Can POWER at least implement the original PKEY_ALLOC_SETSIGNAL
> >>semantics (reset the access rights for certain keys before switching
> >>to the signal handler) in a reasonably efficient manner?
> >
> >This can be done on POWER. I can also change the behavior on POWER
> >to exactly match x86; i.e reset the value to init value before
> >calling the signal handler.
> 
> Maybe we can implement a compromise?
> 
> Assuming I got the attached patch right, it implements PKRU
> inheritance in signal handlers, similar to what you intend to
> implement for POWER.

Ok.

> It still restores the PKRU register value upon
> regular exit from the signal handler, which I think is something we
> should keep.

On x86, the pkru value is restored, on return from the signal handler,
to the value before the signal handler was called. right?

In other words, if 'x' was the value when signal handler was called, it
will be 'x' when return from the signal handler.

If correct, than it is consistent with the behavior on POWER.

> 
> I think we still should add a flag, so that applications can easily
> determine if a kernel has this patch.  Setting up a signal handler,
> sending the signal, and thus checking for inheritance is a bit
> involved, and we'd have to do this in the dynamic linker before we
> can use pkeys to harden lazy binding.  The flag could just be a
> no-op, apart from the lack of an EINVAL failure if it is specified.

Sorry. I am little confused.  What should I implement on POWER? 
PKEY_ALLOC_SETSIGNAL semantics?

Let me know. Thanks for driving this to some consistency.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
