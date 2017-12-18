Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0C406B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:28:22 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 3so4605727plv.17
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:28:22 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h1si9943696pld.629.2017.12.18.14.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 14:28:21 -0800 (PST)
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add
 sysfs interface
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
Date: Mon, 18 Dec 2017 14:28:14 -0800
MIME-Version: 1.0
In-Reply-To: <20171218221850.GD5461@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On 12/18/2017 02:18 PM, Ram Pai wrote:
> b) minimum number of keys available to the application.
> 	if libraries consumes a few, they could provide a library
> 	interface to the application informing the number available to
> 	the application.  The library interface can leverage (b) to
> 	provide the information.

OK, let's see a real user of this including a few libraries.  Then we'll
put it in the kernel.

> c) types of disable-rights supported by keys.
> 	Helps the application to determine the types of disable-features
> 	available. This is helpful, otherwise the app has to 
> 	make pkey_alloc() call with the corresponding parameter set
> 	and see if it suceeds or fails. Painful from an application
> 	point of view, in my opinion.

Again, let's see a real-world use of this.  How does it look?  How does
an app "fall back" if it can't set a restriction the way it wants to?

Are we *sure* that such an interface makes sense?  For instance, will it
be possible for some keys to be execute-disable while other are only
write-disable?

> I think on x86 you look for some hardware registers to determine which
> hardware features are enabled by the kernel.

No, we use CPUID.  It's a part of the ISA that's designed for
enumerating CPU and (sometimes) OS support for CPU features.

> We do not have generic support for something like that on ppc.
> The kernel looks at the device tree to determine what hardware features
> are available. But does not have mechanism to tell the hardware to track
> which of its features are currently enabled/used by the kernel; atleast
> not for the memory-key feature.

Bummer.  You're missing out.

But, you could still do this with a syscall.  "Hey, kernel, do you
support this feature?"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
