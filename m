Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6AE06B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 06:24:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so66703832pfk.3
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 03:24:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id sn2si28008608pac.336.2016.11.08.03.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 03:24:08 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA8BJdQN119429
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 06:24:08 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26k9kk07xy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Nov 2016 06:24:08 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 8 Nov 2016 11:24:05 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9993C2190056
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 11:23:17 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA8BO3Hq15335712
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 11:24:03 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA8BO21t024225
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 04:24:03 -0700
Date: Tue, 8 Nov 2016 12:24:01 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
 <20161104234459.GA18760@remoulade>
 <20161108093042.GC3528@osiris>
 <20161108104112.GM1041@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108104112.GM1041@n2100.armlinux.org.uk>
Message-Id: <20161108112400.GE3528@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Mark Rutland <mark.rutland@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tue, Nov 08, 2016 at 10:41:12AM +0000, Russell King - ARM Linux wrote:
> On Tue, Nov 08, 2016 at 10:30:42AM +0100, Heiko Carstens wrote:
> > Two architectures (arm, mips) have wired them up and thus allocated system
> > call numbers, even though they don't have ARCH_HAS_PKEYS set. Which seems a
> > bit pointless.
> 
> I don't think it's pointless at all.  First, read the LWN article for
> the userspace side of the interface: https://lwn.net/Articles/689395/
> 
> From reading this, it seems (at least to me) that these pkey syscalls
> are going to be the application level API - which means applications
> are probably going to want to make these calls.
> 
> Sure, they'll have to go through glibc, and glibc can provide stubs,
> but the problem with that is if we do get hardware pkey support (eg,
> due to pressure to increase security) then we're going to end up
> needing both kernel changes and glibc changes to add the calls.
> 
> Since one of the design goals of pkeys is to allow them to work when
> there is no underlying hardware support, I see no reason not to wire
> them up in architecture syscall tables today, so that we have a cross-
> architecture kernel version where the pkey syscalls become available.
> glibc (and other libcs) don't then have to mess around with per-
> architecture recording of which kernel version the pkey syscalls were
> added.
> 
> Not wiring up the syscalls doesn't really gain anything: the code
> present when !ARCH_HAS_PKEYS will still be part of the kernel image,
> it just won't be callable.

That can be easily solved (see below).

> So, on balance, I've decided to wire them up on ARM, even though the
> hardware doesn't support them, to avoid unnecessary pain in userspace
> from the ARM side of things.
> 
> Obviously what other architectures do is their own business.

It would make sense if this would be handled the same across architectures.

We could simply ifdef the small pkey block in mprotect.c and rely on the
pkey cond_syscalls added with e2753293ac4b. The result would actually be
the same what Mark proposed, except with less generated code.

Something like this:

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 11936526b08b..9fb86b107e49 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -484,6 +484,8 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 	return do_mprotect_pkey(start, len, prot, -1);
 }
 
+#ifdef CONFIG_ARCH_HAS_PKEYS
+
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
@@ -534,3 +536,4 @@ SYSCALL_DEFINE1(pkey_free, int, pkey)
 	 */
 	return ret;
 }
+#endif /* CONFIG_ARCH_HAS_PKEYS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
