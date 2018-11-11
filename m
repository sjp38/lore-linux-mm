Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4C7C6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 08:36:15 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v2-v6so6727689wrn.0
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 05:36:15 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id v13-v6si11566450wri.216.2018.11.11.05.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 05:36:14 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.0 \(3445.100.39\))
Subject: Re: crashkernel=512M is no longer working on this aarch64 server
From: Qian Cai <cai@gmx.us>
In-Reply-To: <20181111123553.3a35a15c@mschwideX1>
Date: Sun, 11 Nov 2018 08:36:09 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <77E3BE32-F509-43B3-8C5F-252416C04B7C@gmx.us>
References: <1A7E2E89-34DB-41A0-BBA2-323073A7E298@gmx.us>
 <20181111123553.3a35a15c@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>



> On Nov 11, 2018, at 6:35 AM, Martin Schwidefsky =
<schwidefsky@de.ibm.com> wrote:
>=20
> On Sat, 10 Nov 2018 23:41:34 -0500
> Qian Cai <cai@gmx.us> wrote:
>=20
>> It was broken somewhere between b00d209241ff and 3541833fd1f2.
>>=20
>> [    0.000000] cannot allocate crashkernel (size:0x20000000)
>>=20
>> Where a good one looks like this,
>>=20
>> [    0.000000] crashkernel reserved: 0x0000000008600000 - =
0x0000000028600000 (512 MB)
>>=20
>> Some commits look more suspicious than others.
>>=20
>>      mm: add mm_pxd_folded checks to pgtable_bytes accounting =
functions
>>      mm: introduce mm_[p4d|pud|pmd]_folded
>>      mm: make the __PAGETABLE_PxD_FOLDED defines non-empty
>=20
> The intent of these three patches is to add extra checks to the
> pgtable_bytes accounting function. If applied incorrectly the expected
> result would be warnings like this:
>  BUG: non-zero pgtables_bytes on freeing mm: 16384
>=20
> The change Linus worried about affects the __PAGETABLE_PxD_FOLDED =
defines.
> These defines are used with #ifdef, #ifndef, and __is_defined() for =
the
> new mm_p?d_folded() macros. I can not see how this would make a =
difference
> for your iomem setup.
>=20
>> # diff -u ../iomem.good.txt ../iomem.bad.txt=20
>> --- ../iomem.good.txt	2018-11-10 22:28:20.092614398 -0500
>> +++ ../iomem.bad.txt	2018-11-10 20:39:54.930294479 -0500
>> @@ -1,9 +1,8 @@
>> 00000000-3965ffff : System RAM
>>   00080000-018cffff : Kernel code
>> -  018d0000-020affff : reserved
>> -  020b0000-045affff : Kernel data
>> -  08600000-285fffff : Crash kernel
>> -  28730000-2d5affff : reserved
>> +  018d0000-0762ffff : reserved
>> +  07630000-09b2ffff : Kernel data
>> +  231b0000-2802ffff : reserved
>>   30ec0000-30ecffff : reserved
>>   35660000-3965ffff : reserved
>> 39660000-396fffff : reserved
>> @@ -127,7 +126,7 @@
>>   7c5200000-7c520ffff : 0004:48:00.0
>> 1040000000-17fbffffff : System RAM
>>   13fbfd0000-13fdfdffff : reserved
>> -  16fba80000-17fbfdffff : reserved
>> +  16fafd0000-17fbfdffff : reserved
>>   17fbfe0000-17fbffffff : reserved
>> 1800000000-1ffbffffff : System RAM
>>   1bfbff0000-1bfdfeffff : reserved
>=20
> The easiest way to verify if the three commits have something to do =
with your
> problem is to revert them and run your test. Can you do that please ?
Yes, you are right. Those commits have nothing to do with the problem. I =
should
realized it earlier as those are virtual memory vs physical memory. =
Sorry for the
nosie.

It turned out I made a wrong assumption that if kmemleak is disabled by =
default,
there should be no memory reserved for kmemleak at all which is not the =
case.

CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=3D600000
CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=3Dy

Even without kmemleak=3Don in the kernel cmdline, it still reserve early =
log memory
which causes not enough memory for crashkernel.

Since there seems no way to turn kmemleak on later after boot, is there =
any
reasons for the current behavior?=20=
