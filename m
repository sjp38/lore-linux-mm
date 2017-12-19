Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCDD46B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:32:39 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id 33so15086251qty.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:32:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b31si3271948qtc.303.2017.12.19.08.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 08:32:38 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBJGTxOL125282
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:32:37 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ey46pyusd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:32:36 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 19 Dec 2017 11:32:34 -0500
Date: Tue, 19 Dec 2017 08:32:25 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
 <877etj9ekv.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877etj9ekv.fsf@concordia.ellerman.id.au>
Message-Id: <20171219163225.GC5481@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Dave Hansen <dave.hansen@intel.com>, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Tue, Dec 19, 2017 at 09:50:24PM +1100, Michael Ellerman wrote:
> Dave Hansen <dave.hansen@intel.com> writes:
> 
> > On 11/06/2017 12:57 AM, Ram Pai wrote:
> >> Expose useful information for programs using memory protection keys.
> >> Provide implementation for powerpc and x86.
> >> 
> >> On a powerpc system with pkeys support, here is what is shown:
> >> 
> >> $ head /sys/kernel/mm/protection_keys/*
> >> ==> /sys/kernel/mm/protection_keys/disable_access_supported <==
> >> true
> >
> > This is cute, but I don't think it should be part of the ABI.  Put it in
> > debugfs if you want it for cute tests.  The stuff that this tells you
> > can and should come from pkey_alloc() for the ABI.
> 
> Yeah I agree this is not sysfs material.
> 
> In particular the total/usable numbers are completely useless vs other
> threads allocating pkeys out from under you.

The usable number is the minimum number of keys available for use by the
application, not the number of keys **currently** available.  Its a
static number.

I am dropping this patch. We can revisit this when a clear request for
such a feature emerges.

> 
> >
> >>        Any application wanting to use protection keys needs to be able to
> >>        function without them.  They might be unavailable because the
> >>        hardware that the application runs on does not support them, the
> >>        kernel code does not contain support, the kernel support has been
> >>        disabled, or because the keys have all been allocated, perhaps by a
> >>        library the application is using.  It is recommended that
> >>        applications wanting to use protection keys should simply call
> >>        pkey_alloc(2) and test whether the call succeeds, instead of
> >>        attempting to detect support for the feature in any other way.
> >
> > Do you really not have standard way on ppc to say whether hardware
> > features are supported by the kernel?  For instance, how do you know if
> > a given set of registers are known to and are being context-switched by
> > the kernel?
> 
> Yes we do, we emit feature bits in the AT_HWCAP entry of the aux vector,
> same as some other architectures.

Ah. I was not aware of this.
Thanks,
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
