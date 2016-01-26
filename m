Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 94D296B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:34:25 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id b35so148922117qge.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:34:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 199si3087461qhe.38.2016.01.26.12.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:34:24 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] Sanitization of buddy pages
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
 <56A70C9D.8060102@oracle.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A7D84D.7020101@redhat.com>
Date: Tue, 26 Jan 2016 12:34:21 -0800
MIME-Version: 1.0
In-Reply-To: <56A70C9D.8060102@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <labbott@fedoraproject.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>

On 01/25/2016 10:05 PM, Sasha Levin wrote:
> On 01/25/2016 11:55 AM, Laura Abbott wrote:
>> Hi,
>>
>> This is an implementation of page poisoning/sanitization for all arches. It
>> takes advantage of the existing implementation for
>> !ARCH_SUPPORTS_DEBUG_PAGEALLOC arches. This is a different approach than what
>> the Grsecurity patches were taking but should provide equivalent functionality.
>>
>> For those who aren't familiar with this, the goal of sanitization is to reduce
>> the severity of use after free and uninitialized data bugs. Memory is cleared
>> on free so any sensitive data is no longer available. Discussion of
>> sanitization was brough up in a thread about CVEs
>> (lkml.kernel.org/g/<20160119112812.GA10818@mwanda>)
>>
>> I eventually expect Kconfig names will want to be changed and or moved if this
>> is going to be used for security but that can happen later.
>>
>> Credit to Mathias Krause for the version in grsecurity
>>
>> Laura Abbott (3):
>>    mm/debug-pagealloc.c: Split out page poisoning from debug page_alloc
>>    mm/page_poison.c: Enable PAGE_POISONING as a separate option
>>    mm/page_poisoning.c: Allow for zero poisoning
>>
>>   Documentation/kernel-parameters.txt |   5 ++
>>   include/linux/mm.h                  |  13 +++
>>   include/linux/poison.h              |   4 +
>>   mm/Kconfig.debug                    |  35 +++++++-
>>   mm/Makefile                         |   5 +-
>>   mm/debug-pagealloc.c                | 127 +----------------------------
>>   mm/page_alloc.c                     |  10 ++-
>>   mm/page_poison.c                    | 158 ++++++++++++++++++++++++++++++++++++
>>   8 files changed, 228 insertions(+), 129 deletions(-)
>>   create mode 100644 mm/page_poison.c
>>
>
> Should poisoning of this kind be using kasan rather than "old fashioned"
> poisoning?
>
>

The two aren't mutually exclusive. kasan is serving a different purpose even
though it has sanitize in the name. kasan is designed to detect errors, the
purpose of this series is to make sure the memory is really cleared out.
This series also doesn't have the memory overhead of kasan.
  
> Thanks,
> Sasha
>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
