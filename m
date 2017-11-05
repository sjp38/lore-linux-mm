Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 501606B0033
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 09:50:33 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id e123so7854848oig.14
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 06:50:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c3si4714189oia.140.2017.11.05.06.50.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Nov 2017 06:50:32 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <6d293bb3-78bd-6d20-3684-be6358bd3d7b@redhat.com>
Date: Sun, 5 Nov 2017 15:50:28 +0100
MIME-Version: 1.0
In-Reply-To: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On 11/05/2017 01:18 PM, Nicholas Piggin wrote:
> Something like the following patch may help if you could test.

The patch appears to fix it:

# /lib64/ld64.so.1 ./a.out
initial brk value: 0x7fffe4590000
probing at 0x80000001fffc

I used the follow simplified reproducer:

#include <err.h>
#include <unistd.h>
#include <inttypes.h>
#include <errno.h>
#include <stdio.h>

int
main (void)
{
   errno = 0;
   void *p = sbrk (0);
   if (errno != 0)
     err (1, "sbrk (0)");
   printf ("initial brk value: %p\n", p);
   unsigned long long target = 0x800000020000ULL;
   if ((uintptr_t) p >= target)
     errx (1, "initial brk value is already above target");
   unsigned long long increment = target - (uintptr_t) p;
   errno = 0;
   sbrk (increment);
   if (errno != 0)
     err (1, "sbrk (0x%llx)", increment);
   volatile int *pi = (volatile int *) (target - 4);
   printf ("probing at %p\n", pi);
   *pi = 1;
}


It is still probabilistic because if the increment is too large, the 
second sbrk call will fail with an out of memory error (which is 
expected), so you'll have to run it a couple of times.

If the test fails, the write at the will segfault.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
