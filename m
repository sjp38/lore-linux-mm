Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1906B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:19:05 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id h4so13470566qtj.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:19:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c188si828033qkg.417.2017.12.18.14.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 14:19:04 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBIMHnDT130197
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:19:03 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2exk7dfej5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:19:02 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 18 Dec 2017 17:19:01 -0500
Date: Mon, 18 Dec 2017 14:18:50 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
Message-Id: <20171218221850.GD5461@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Mon, Dec 18, 2017 at 10:54:26AM -0800, Dave Hansen wrote:
> On 11/06/2017 12:57 AM, Ram Pai wrote:
> > Expose useful information for programs using memory protection keys.
> > Provide implementation for powerpc and x86.
> > 
> > On a powerpc system with pkeys support, here is what is shown:
> > 
> > $ head /sys/kernel/mm/protection_keys/*

> > ==> /sys/kernel/mm/protection_keys/disable_access_supported <==
> > true
> 
> This is cute, but I don't think it should be part of the ABI.  Put it in

thanks :)

> debugfs if you want it for cute tests.  The stuff that this tells you
> can and should come from pkey_alloc() for the ABI.

Applications can make system calls with different parameters and on
failure determine indirectly that such a feature may not be available in
the kernel/hardware.  But from an application point of view, I think, it
is a very clumsy/difficult way to determine that.

For example, an application can keep making pkey_alloc() calls and count
till the call fails, to determine the number of keys supported by the
system. And then the application has to release those keys too.  Too
much side-effect just to determine a simple thing. Do we want the
application to endure this pain?

I think we should aim to provide sufficient API/ABI for the application
to consume the feature efficiently, and not any more.

I do not claim that the ABI exposed by this patch is sufficiently
optimal. But I do believe it is tending towards it.

currently the following ABI is  exposed.

a) total number of keys available in the system. This information may
	not be useful and can possibly be dropped.

b) minimum number of keys available to the application.
	if libraries consumes a few, they could provide a library
	interface to the application informing the number available to
	the application.  The library interface can leverage (b) to
	provide the information.

c) types of disable-rights supported by keys.
	Helps the application to determine the types of disable-features
	available. This is helpful, otherwise the app has to 
	make pkey_alloc() call with the corresponding parameter set
	and see if it suceeds or fails. Painful from an application
	point of view, in my opinion.

> 
> http://man7.org/linux/man-pages/man7/pkeys.7.html
> 
> >        Any application wanting to use protection keys needs to be able to
> >        function without them.  They might be unavailable because the
> >        hardware that the application runs on does not support them, the
> >        kernel code does not contain support, the kernel support has been
> >        disabled, or because the keys have all been allocated, perhaps by a
> >        library the application is using.  It is recommended that
> >        applications wanting to use protection keys should simply call
> >        pkey_alloc(2) and test whether the call succeeds, instead of
> >        attempting to detect support for the feature in any other way.
> 
> Do you really not have standard way on ppc to say whether hardware
> features are supported by the kernel?  For instance, how do you know if
> a given set of registers are known to and are being context-switched by
> the kernel?

I think on x86 you look for some hardware registers to determine which
hardware features are enabled by the kernel.

We do not have generic support for something like that on ppc.
The kernel looks at the device tree to determine what hardware features
are available. But does not have mechanism to tell the hardware to track
which of its features are currently enabled/used by the kernel; atleast
not for the memory-key feature.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
