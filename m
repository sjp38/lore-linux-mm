Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 002926B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 10:25:18 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f62so6348347otf.6
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 07:25:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q189si2686582oig.281.2017.12.16.07.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 07:25:17 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
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
 <20171216150910.GA5461@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <2eba29f4-804d-b211-1293-52a567739cad@redhat.com>
Date: Sat, 16 Dec 2017 16:25:14 +0100
MIME-Version: 1.0
In-Reply-To: <20171216150910.GA5461@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/16/2017 04:09 PM, Ram Pai wrote:

>> It still restores the PKRU register value upon
>> regular exit from the signal handler, which I think is something we
>> should keep.
> 
> On x86, the pkru value is restored, on return from the signal handler,
> to the value before the signal handler was called. right?
> 
> In other words, if 'x' was the value when signal handler was called, it
> will be 'x' when return from the signal handler.
> 
> If correct, than it is consistent with the behavior on POWER.

That's good to know.  I tended to implement the same semantics on x86.

>> I think we still should add a flag, so that applications can easily
>> determine if a kernel has this patch.  Setting up a signal handler,
>> sending the signal, and thus checking for inheritance is a bit
>> involved, and we'd have to do this in the dynamic linker before we
>> can use pkeys to harden lazy binding.  The flag could just be a
>> no-op, apart from the lack of an EINVAL failure if it is specified.
> 
> Sorry. I am little confused.  What should I implement on POWER?
> PKEY_ALLOC_SETSIGNAL semantics?

No, we would add a flag, with a different name, and this patch only:

diff --git a/mm/mprotect.c b/mm/mprotect.c
index ec39f73..021f1d4 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -523,14 +523,17 @@ static int do_mprotect_pkey(unsigned long start, 
size_t l
         return do_mprotect_pkey(start, len, prot, pkey);
  }

+#define PKEY_ALLOC_FLAGS ((unsigned long) (PKEY_ALLOC_SETSIGNAL))
+
  SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
  {
         int pkey;
         int ret;

-       /* No flags supported yet. */
-       if (flags)
+       /* check for unsupported flags */
+       if (flags & ~PKEY_ALLOC_FLAGS)
                 return -EINVAL;
+
         /* check for unsupported init values */
         if (init_val & ~PKEY_ACCESS_MASK)
                 return -EINVAL;


This way, an application can specify the flag during key allocation, and 
knows that if the allocation succeeds, the kernel implements access 
rights inheritance in signal handlers.  I think we need this so that 
applications which are incompatible with the earlier x86 implementation 
of memory protection keys do not use them.

With my second patch (not the first one implementing 
PKEY_ALLOC_SETSIGNAL), no further changes to architecture=specific code 
are needed, except for the definition of the flag in the header files.

I'm open to a different way towards conveying this information to 
userspace.  I don't want to probe for the behavior by sending a signal 
because that is quite involved and would also be visible in debuggers, 
confusing programmers.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
