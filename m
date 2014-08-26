Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9876F6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 13:45:50 -0400 (EDT)
Received: by mail-oi0-f51.google.com with SMTP id v63so3993699oia.10
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:45:50 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id i7si3593294obx.83.2014.08.26.10.45.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 10:45:49 -0700 (PDT)
Received: by mail-ob0-f172.google.com with SMTP id wn1so12079978obc.31
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:45:49 -0700 (PDT)
Message-ID: <53FCC7CB.8010701@gmail.com>
Date: Tue, 26 Aug 2014 10:45:47 -0700
From: David Daney <ddaney.cavm@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
References: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com> <20140825171600.GH25892@linux-mips.org> <53FBCD09.1050003@gentoo.org> <53FBD676.8080307@gmail.com> <53FBF3C3.90509@gentoo.org>
In-Reply-To: <53FBF3C3.90509@gentoo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Kinard <kumba@gentoo.org>
Cc: Ralf Baechle <ralf@linux-mips.org>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>

On 08/25/2014 07:41 PM, Joshua Kinard wrote:
> On 08/25/2014 20:36, David Daney wrote:
>> On 08/25/2014 04:55 PM, Joshua Kinard wrote:
>>> On 08/25/2014 13:16, Ralf Baechle wrote:
>>>> On Sat, Aug 02, 2014 at 05:11:37AM +0400, Max Filippov wrote:
>>>>
>>>>> this series adds mapping color control to the generic kmap code, allowing
>>>>> architectures with aliasing VIPT cache to use high memory. There's also
>>>>> use example of this new interface by xtensa.
>>>>
>>>> I haven't actually ported this to MIPS but it certainly appears to be
>>>> the right framework to get highmem aliases handled on MIPS, too.
>>>>
>>>> Though I still consider increasing PAGE_SIZE to 16k the preferable
>>>> solution because it will entirly do away with cache aliases.
>>>
>>> Won't setting PAGE_SIZE to 16k break some existing userlands (o32)?  I use a
>>> 4k PAGE_SIZE because the last few times I've tried 16k or 64k, init won't
>>> load (SIGSEGVs or such, which panicks the kernel).
>>>
>>
>> It isn't supposed to break things.  Using "stock" toolchains should result
>> in executables that will run with any page size.
>>
>> In the past, some geniuses came up with some linker (ld) patches that, in
>> order to save a few KB of RAM, produced executables that ran only on 4K pages.
>>
>> There were some equally astute Debian emacs package maintainers that were
>> carrying emacs patches into Debian that would not work on non-4K page size
>> systems.
>>
>> That said, I think such thinking should be punished.  The punishment should
>> be to not have their software run when we select non-4K page sizes.  The
>> vast majority of prepackaged software runs just fine with a larger page size.
>
> Well, it does appear to mostly work now w/ 16k PAGE_SIZE.  The Octane booted
> into userland with just a couple of "illegal instruction" errors from 'rm'
> and 'mdadm'.  I wonder if that's tied to a hardcoded PAGE_SIZE somewhere.
> Have to dig around and find something that reproduces the problem on demand.
>

What does the output of "readelf -lW" look like for the failing 
programs?  If the "Offset" and "VirtAddr" constraints for the LOAD 
Program Headers are not possible to achieve with the selected PAGE_SIZE, 
you will see problems.  A "correct" toolchain will generate binaries 
that work with any PAGE_SIZE up to 64K.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
