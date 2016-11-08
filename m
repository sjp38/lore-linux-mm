Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1AEA6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 04:31:08 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so43292561pfv.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 01:31:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id pa6si18430508pac.96.2016.11.08.01.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 01:31:08 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA89ShUo078387
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 04:31:07 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26k8q7a3ua-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Nov 2016 04:31:07 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 8 Nov 2016 09:31:05 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3B07517D806A
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 09:33:05 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA89UiqO38994064
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 09:30:44 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA89UiL6000593
	for <linux-mm@kvack.org>; Tue, 8 Nov 2016 04:30:44 -0500
Date: Tue, 8 Nov 2016 10:30:42 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
 <20161104234459.GA18760@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104234459.GA18760@remoulade>
Message-Id: <20161108093042.GC3528@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Russell King <rmk+kernel@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Fri, Nov 04, 2016 at 11:44:59PM +0000, Mark Rutland wrote:
> On Wed, Nov 02, 2016 at 12:15:50PM -0700, Dave Hansen wrote:
> > On 10/31/2016 05:08 PM, Mark Rutland wrote:
> > > When an architecture does not select CONFIG_ARCH_HAS_PKEYS, the pkey_alloc
> > > syscall will return -ENOSPC for all (otherwise well-formed) requests, as the
> > > generic implementation of mm_pkey_alloc() returns -1. The other pkey syscalls
> > > perform some work before always failing, in a similar fashion.
> > > 
> > > This implies the absence of keys, but otherwise functional pkey support. This
> > > is odd, since the architecture provides no such support. Instead, it would be
> > > preferable to indicate that the syscall is not implemented, since this is
> > > effectively the case.
> > 
> > This makes the behavior of an x86 cpu without pkeys and an arm cpu
> > without pkeys differ.  Is that what we want?
> 
> My rationale was that we have no idea whether architectures will have pkey
> support in future, and if/when they do, we may have to apply additional checks
> anyhow. i.e. in cases we'd return -ENOSPC today, we might want to return
> another error code.
> 
> Returning -ENOSYS retains the current behaviour, and allows us to handle that
> ABI issue when we know what architecture support looks like.
> 
> Other architectures not using the generic syscalls seem to handle this with
> -ENOSYS, e.g. parisc with commit 18088db042dd9ae2, so there's differing
> behaviour regardless of arm specifically.

The three system calls won't return -ENOSYS on architectures which decided
to ignore them (like with with above mentioned commit), since they haven't
allocated a system call number at all.

Right now we have one architecture where these three system calls work if
the cpu supports the feature (x86).

Two architectures (arm, mips) have wired them up and thus allocated system
call numbers, even though they don't have ARCH_HAS_PKEYS set. Which seems a
bit pointless.

Three architectures (parisc, powerpc, s390) decided to ignore the system
calls completely, but still have the pkey code linked into the kernel
image.

imho the generic pkey code should be ifdef'ed with CONFIG_ARCH_HAS_PKEYS.
Otherwise only dead code will be linked and increase the kernel image size
for no good reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
