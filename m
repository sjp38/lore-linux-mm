Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07CF844040A
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 17:25:31 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u3so10350196pfl.5
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 14:25:30 -0800 (PST)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTPS id v1si7180417pfi.8.2017.12.16.14.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 14:25:30 -0800 (PST)
Subject: Re: [PATCH] mm: thp: avoid uninitialized variable use
References: <20171215125129.2948634-1-arnd@arndb.de>
 <8d5476e2-5f87-1134-62d4-9f649c4e709a@alibaba-inc.com>
 <CAK8P3a3arg08JuBrz+Pqa47xsFCHtxTJ+7ywepeJpJro02NEjg@mail.gmail.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <63b69d2b-1c1d-6f08-30a6-e996b6842000@alibaba-inc.com>
Date: Sun, 17 Dec 2017 06:25:17 +0800
MIME-Version: 1.0
In-Reply-To: <CAK8P3a3arg08JuBrz+Pqa47xsFCHtxTJ+7ywepeJpJro02NEjg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 12/16/17 4:24 AM, Arnd Bergmann wrote:
> On Fri, Dec 15, 2017 at 7:01 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>>
>>
>> On 12/15/17 4:51 AM, Arnd Bergmann wrote:
>>>
>>> When the down_read_trylock() fails, 'vma' has not been initialized
>>> yet, which gcc now warns about:
>>>
>>> mm/khugepaged.c: In function 'khugepaged':
>>> mm/khugepaged.c:1659:25: error: 'vma' may be used uninitialized in this
>>> function [-Werror=maybe-uninitialized]
>>
>>
>> Arnd,
>>
>> Thanks for catching this. I'm wondering why my test didn't catch it. It
>> might be because my gcc is old. I'm using gcc 4.8.5 on centos 7.
> 
> Correct, gcc-4.8 and earlier have too many false-positive warnings with
> -Wmaybe-uninitialized, so we turn it off on those versions. 4.9 is much
> better here, but I'd recommend using gcc-6 or gcc-7 when you upgrade,
> they have a much better set of default warnings besides producing better
> binary code.

Thanks, I just upgraded gcc to 6.4 on my cetnos 7 machine. But, I ran 
into a build error with 4.15-rc3 kernel, but 4.14 is fine. I bisected to 
a commit in Makefile. I will email my bug report to the mailing list.

Regards,
Yang

> 
> See http://git.infradead.org/users/segher/buildall.git for a simple way
> to build toolchains suitable for building kernels in varying architectures
> and versions.
> 
>         Arnd
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
