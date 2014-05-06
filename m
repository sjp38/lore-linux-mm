Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 97A9E6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 17:52:19 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so3937535wib.5
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:52:19 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id vo1si6106871wjc.237.2014.05.06.14.52.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 14:52:18 -0700 (PDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so4305553wiw.2
        for <linux-mm@kvack.org>; Tue, 06 May 2014 14:52:18 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm: Postpone the disabling of kmemleak early logging
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <536926DD.30402@oracle.com>
Date: Tue, 6 May 2014 22:52:16 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <49655FE2-17CA-433C-8F4A-76DD6C2FEF61@arm.com>
References: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com> <1399038070-1540-7-git-send-email-catalin.marinas@arm.com> <5368FDBB.8070106@oracle.com> <20140506170549.GM23957@arm.com> <536926DD.30402@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>

On 6 May 2014, at 19:15, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 05/06/2014 01:05 PM, Catalin Marinas wrote:
>> On Tue, May 06, 2014 at 04:20:27PM +0100, Sasha Levin wrote:
>>> On 05/02/2014 09:41 AM, Catalin Marinas wrote:
>>>> Currently, kmemleak_early_log is disabled at the beginning of the
>>>> kmemleak_init() function, before the full kmemleak tracing is =
actually
>>>> enabled. In this small window, kmem_cache_create() is called by =
kmemleak
>>>> which triggers additional memory allocation that are not traced. =
This
>>>> patch moves the kmemleak_early_log disabling further down and at =
the
>>>> same time with full kmemleak enabling.
>>>>=20
>>>> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>=20
>>> This patch makes the kernel die during the boot process:
>>>=20
>>> [   24.471801] BUG: unable to handle kernel paging request at =
ffffffff922f2b93
>>> [   24.472496] IP: [<ffffffff922f2b93>] log_early+0x0/0xcd
>>=20
>> Thanks for reporting this. I assume you run with
>> CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF enabled and kmemleak_early_log =
remains
>> set even though kmemleak is not in use.
>>=20
>> Does the patch below fix it?
>=20
> Nope, that didn't help as I don't have DEBUG_KMEMLEAK_DEFAULT_OFF =
enabled.
>=20
> For reference:
>=20
> $ cat .config | grep KMEMLEAK
> CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy
> CONFIG_DEBUG_KMEMLEAK=3Dy
> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=3D400
> # CONFIG_DEBUG_KMEMLEAK_TEST is not set
> # CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF is not set

I assume your dmesg shows some kmemleak error during boot? I=92ll send
another patch tomorrow.

The code around kmemleak_init was changed by commit 8910ae896c8c
(kmemleak: change some global variables to int). It looks like it
wasn=92t just a simple conversion but slightly changed the
kmemleak_early_log logic which led to false positives for the kmemleak
cache objects and that=92s what my patch was trying to solve.

The failure is caused by kmemleak_alloc() still calling log_early() much
later after the __init section has been freed because kmemleak_early_log
hasn=92t been set to 0 (the default off is one path, another is the
kmemleak_error path).

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
