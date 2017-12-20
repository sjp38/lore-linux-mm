Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5120F6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 12:51:02 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c190so16013262qkb.12
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 09:51:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r194si5517051qke.77.2017.12.20.09.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 09:51:01 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBKHn2eM018398
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 12:51:00 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eyuy8j36q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 12:50:59 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 20 Dec 2017 10:50:33 -0700
Date: Wed, 20 Dec 2017 09:50:22 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
 <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
 <1513719296.2743.12.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513719296.2743.12.camel@kernel.crashing.org>
Message-Id: <20171220175022.GB5619@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Dave Hansen <dave.hansen@intel.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Wed, Dec 20, 2017 at 08:34:56AM +1100, Benjamin Herrenschmidt wrote:
> On Mon, 2017-12-18 at 14:28 -0800, Dave Hansen wrote:
> > > We do not have generic support for something like that on ppc.
> > > The kernel looks at the device tree to determine what hardware features
> > > are available. But does not have mechanism to tell the hardware to track
> > > which of its features are currently enabled/used by the kernel; atleast
> > > not for the memory-key feature.
> > 
> > Bummer.  You're missing out.
> > 
> > But, you could still do this with a syscall.  "Hey, kernel, do you
> > support this feature?"
> 
> I'm not sure I understand Ram's original (quoted) point, but informing
> userspace of CPU features is what AT_HWCAP's are about.

Ben, my original point was -- we developed this patch to satisfy a concern
you raised back on July 11th;  cut-n-pasted below.

-------------------------------------------------------------------
That leads to the question... How do you tell userspace.

(apologies if I missed that in an existing patch in the series)

How do we inform userspace of the key capabilities ? There are
at least two things userspace may want to know already:

	 - What protection bits are supported for a key

	 - How many keys exist

	 - Which keys are available for use by userspace. On PowerPC,
	 the kernel can reserve some keys for itself, so can the
	 hypervisor. In fact, they do.
--------------------------------------------------------------------


The argument against this patch is --  it should not be baked into
the ABI as yet, since we do not have clarity on what applications need.

As it stands today the only way to figure out the information from
userspace is by probing the kernel through calls to sys_pkey_alloc().

AT_HWCAP can be used, but that will certainly not be capable of
providing all the information that userspace might expect.

Your thoughts?
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
