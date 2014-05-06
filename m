Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 25ED56B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 19:08:36 -0400 (EDT)
Received: by mail-yk0-f176.google.com with SMTP id q9so165086ykb.21
        for <linux-mm@kvack.org>; Tue, 06 May 2014 16:08:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e20si6465805yhf.213.2014.05.06.16.08.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 16:08:35 -0700 (PDT)
Message-ID: <53696B65.6070807@oracle.com>
Date: Tue, 06 May 2014 19:08:21 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: Postpone the disabling of kmemleak early logging
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com> <1399038070-1540-7-git-send-email-catalin.marinas@arm.com> <5368FDBB.8070106@oracle.com> <20140506170549.GM23957@arm.com> <536926DD.30402@oracle.com> <49655FE2-17CA-433C-8F4A-76DD6C2FEF61@arm.com>
In-Reply-To: <49655FE2-17CA-433C-8F4A-76DD6C2FEF61@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>

On 05/06/2014 05:52 PM, Catalin Marinas wrote:
> On 6 May 2014, at 19:15, Sasha Levin <sasha.levin@oracle.com> wrote:
>> On 05/06/2014 01:05 PM, Catalin Marinas wrote:
>>> On Tue, May 06, 2014 at 04:20:27PM +0100, Sasha Levin wrote:
>>>> On 05/02/2014 09:41 AM, Catalin Marinas wrote:
>>>>> Currently, kmemleak_early_log is disabled at the beginning of the
>>>>> kmemleak_init() function, before the full kmemleak tracing is actually
>>>>> enabled. In this small window, kmem_cache_create() is called by kmemleak
>>>>> which triggers additional memory allocation that are not traced. This
>>>>> patch moves the kmemleak_early_log disabling further down and at the
>>>>> same time with full kmemleak enabling.
>>>>>
>>>>> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>>
>>>> This patch makes the kernel die during the boot process:
>>>>
>>>> [   24.471801] BUG: unable to handle kernel paging request at ffffffff922f2b93
>>>> [   24.472496] IP: [<ffffffff922f2b93>] log_early+0x0/0xcd
>>>
>>> Thanks for reporting this. I assume you run with
>>> CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF enabled and kmemleak_early_log remains
>>> set even though kmemleak is not in use.
>>>
>>> Does the patch below fix it?
>>
>> Nope, that didn't help as I don't have DEBUG_KMEMLEAK_DEFAULT_OFF enabled.
>>
>> For reference:
>>
>> $ cat .config | grep KMEMLEAK
>> CONFIG_HAVE_DEBUG_KMEMLEAK=y
>> CONFIG_DEBUG_KMEMLEAK=y
>> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=400
>> # CONFIG_DEBUG_KMEMLEAK_TEST is not set
>> # CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF is not set
> 
> I assume your dmesg shows some kmemleak error during boot? I?ll send
> another patch tomorrow.

Besides the BUG, I have these kmemleak messages:

$ grep kmemleak out.txt
[    0.000000] kmemleak: Kernel memory leak detector disabled
[    0.000000] kmemleak: Early log buffer exceeded (2742), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
