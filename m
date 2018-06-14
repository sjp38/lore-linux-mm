Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 855346B0003
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 16:19:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p12-v6so5685345qtg.5
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 13:19:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s13-v6si6283409qvk.21.2018.06.14.13.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 13:19:22 -0700 (PDT)
Subject: Re: [PATCH v13 00/24] selftests, powerpc, x86 : Memory Protection
 Keys
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <c5c119b0-f5ca-4ddc-43c0-a6b597173973@redhat.com>
Date: Thu, 14 Jun 2018 22:19:11 +0200
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/14/2018 02:44 AM, Ram Pai wrote:
> Test
> ----
> Verified for correctness on powerpc. Need help verifying on x86.
> Compiles on x86.

It breaks make in tools/testing/selftests/x86:

make: *** No rule to make target `protection_keys.c', needed by 
`/home/linux/tools/testing/selftests/x86/protection_keys_64'.  Stop.

The generic implementation no longer builds 32-bit binaries.  Is this 
the intent?

It's possible to build 32-bit binaries with a??make CC='gcc -m32'a??, so 
perhaps this is good enough?

But with that, I get a warning:

protection_keys.c: In function a??dump_mema??:
protection_keys.c:172:3: warning: format a??%lxa?? expects argument of type 
a??long unsigned inta??, but argument 4 has type a??uint64_ta?? [-Wformat=]
    dprintf1("dump[%03d][@%p]: %016lx\n", i, ptr, *ptr);
    ^

I suppose you could use %016llx and add a cast to unsigned long long to 
fix this.

Anyway, both the 32-bit and 64-bit tests fail here:

assert() at protection_keys.c::943 test_nr: 12 iteration: 1
running abort_hooks()...

I've yet checked what causes this.  It's with the kernel headers from 
4.17, but with other userspace headers based on glibc 2.17.  I hope to 
look into this some more before the weekend, but I eventually have to 
return the test machine to the pool.

Thanks,
Florian
