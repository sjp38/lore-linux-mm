Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73FB06B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 08:11:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k101so7062044iod.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 05:11:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l130si5983530oif.124.2017.09.19.05.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 05:11:24 -0700 (PDT)
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
 <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
 <fb013ae6-6f47-248b-db8b-a0abae530377@redhat.com>
 <ee87215d-9704-7269-4ec1-226f2e32a751@oracle.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
Date: Tue, 19 Sep 2017 14:11:19 +0200
MIME-Version: 1.0
In-Reply-To: <ee87215d-9704-7269-4ec1-226f2e32a751@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On 09/18/2017 07:11 PM, Mike Kravetz wrote:
> On 09/18/2017 06:45 AM, Florian Weimer wrote:
>> On 09/15/2017 11:53 PM, Mike Kravetz wrote:
>>> +If the value of \fIold_size\fP is zero, and \fIold_address\fP refers to
>>> +a private anonymous mapping, then
>>> +.BR mremap ()
>>> +will create a new mapping of the same pages. \fInew_size\fP
>>> +will be the size of the new mapping and the location of the new mapping
>>> +may be specified with \fInew_address\fP, see the description of
>>> +.B MREMAP_FIXED
>>> +below.  If a new mapping is requested via this method, then the
>>> +.B MREMAP_MAYMOVE
>>> +flag must also be specified.  This functionality is deprecated, and no
>>> +new code should be written to use this feature.  A better method of
>>> +obtaining multiple mappings of the same private anonymous memory is via the
>>> +.BR memfd_create()
>>> +system call.
>>
>> Is there any particular reason to deprecate this?
>>
>> In glibc, we cannot use memfd_create and keep the file descriptor around because the application can close descriptors beneath us.
>>
>> (We might want to use alias mappings to avoid run-time code generation for PLT-less LD_AUDIT interceptors.)
>>
> 
> Hi Florian,
> 
> When I brought up this mremap 'duplicate mapping' functionality on the mm
> mail list, most developers were surprised.  It seems this functionality exists
> mostly 'by chance', and it was not really designed.  It certainly was never
> documented.  There were suggestions to remove the functionality, which led
> to my claim that it was being deprecated.  However, in hindsight that may
> have been too strong.

This history is certainly a bit odd.

> I can drop this wording, but would still like to suggest memfd_create as
> the preferred method of creating duplicate mappings.  It would be good if
> others on Cc: could comment as well.

mremap seems to work with non-anonymous mappings, too:

#include <err.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

/* Hopefully large enough to prevent crossing of a page boundary in
    the implementation.  */
__attribute__ ((aligned (256), noclone, noinline, weak))
int
callback (void)
{
   return 17;
}

int
main (void)
{
   long pagesize = sysconf (_SC_PAGESIZE);
   if (pagesize < 0)
     err (1, "sysconf");
   uintptr_t addr = (uintptr_t) &callback;
   addr = addr / pagesize * pagesize;
   printf ("old function address: %p\n", &callback);
   ptrdiff_t page_offset = (uintptr_t) &callback - addr;
   void *newaddr = mremap ((void *) addr, 0, pagesize, MREMAP_MAYMOVE);
   if (newaddr == MAP_FAILED)
     err (1, "mremap");
   if (memcmp ((void *) addr, newaddr, pagesize) != 0)
     errx (1, "page contents differs");
   int (*newfunc) (void) = newaddr + page_offset;
   printf ("new function address: %p\n", newfunc);
   if (newfunc () != 17)
     errx (1, "invalid return value from newfunc");
   if (callback () != 17)
     errx (1, "invalid return value from callback");
   return 0;
}

(The code needs adjustment for architectures where function pointers 
point to a descriptor and not the actual code.)

This looks very useful for generating arbitrary callback wrappers 
without actual run-time code generation.  memfd_create would not work 
for that.

> Just curious, does glibc make use of this today?  Or, is this just something
> that you think may be useful.

To my knowledge, we do not use this today.  But it certainly looks very 
useful.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
