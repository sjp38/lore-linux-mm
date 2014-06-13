Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id E1C106B009F
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:12:09 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id va2so2506066obc.33
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:12:09 -0700 (PDT)
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
        by mx.google.com with ESMTPS id q11si4049405oey.29.2014.06.13.00.12.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 00:12:08 -0700 (PDT)
Received: by mail-ob0-f169.google.com with SMTP id wp18so2532121obc.28
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 00:12:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140612143916.GB8970@arm.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	<20140611173851.GA5556@MacBook-Pro.local>
	<CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
	<B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
	<CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
	<CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
	<20140612143916.GB8970@arm.com>
Date: Fri, 13 Jun 2014 11:12:08 +0400
Message-ID: <CAOJe8K3zN+fFWumKaGx3Tmv5JRZu10_FZ6R3Tjjc+nc-KVB0hg@mail.gmail.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
From: Denis Kirjanov <kda@linux-powerpc.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Thu, Jun 12, 2014 at 01:00:57PM +0100, Denis Kirjanov wrote:
>> On 6/12/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
>> > On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> >> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org>
>> >> wrote:
>> >>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> >>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
>> >>>>> I got a trace while running 3.15.0-08556-gdfb9454:
>> >>>>>
>> >>>>> [  104.534026] Unable to handle kernel paging request for data at
>> >>>>> address 0xc00000007f000000
>> >>>>
>> >>>> Were there any kmemleak messages prior to this, like "kmemleak
>> >>>> disabled"? There could be a race when kmemleak is disabled because
>> >>>> of
>> >>>> some fatal (for kmemleak) error while the scanning is taking place
>> >>>> (which needs some more thinking to fix properly).
>> >>>
>> >>> No. I checked for the similar problem and didn't find anything
>> >>> relevant.
>> >>> I'll try to bisect it.
>> >>
>> >> Does this happen soon after boot? I guess it=E2=80=99s the first scan
>> >> (scheduled at around 1min after boot). Something seems to be telling
>> >> kmemleak that there is a valid memory block at 0xc00000007f000000.
>> >
>> > Yeah, it happens after a while with a booted system so that's the
>> > first kmemleak scan.
>> >
>>
>> I've bisected to this commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92
>> "mm: add !pte_present() check on existing hugetlb_entry callbacks".
>> Reverting the commit fixes the issue
>
> I can't figure how this causes the problem but I have more questions. Is
> 0xc00000007f000000 address always the same in all crashes? If yes, you
> could comment out start_scan_thread() in kmemleak_late_init() to avoid
> the scanning thread starting. Once booted, you can run:
>
>   echo dump=3D0xc00000007f000000 > /sys/kernel/debug/kmemleak
>
> and check the dmesg for what kmemleak knows about that address, when it
> was allocated and whether it should be mapped or not.

The address is always the same.

[  179.466239] kmemleak: Object 0xc00000007f000000 (size 16777216):
[  179.466503] kmemleak:   comm "swapper/0", pid 0, jiffies 4294892300
[  179.466508] kmemleak:   min_count =3D 0
[  179.466512] kmemleak:   count =3D 0
[  179.466517] kmemleak:   flags =3D 0x1
[  179.466522] kmemleak:   checksum =3D 0
[  179.466526] kmemleak:   backtrace:
[  179.466531]      [<c000000000afc3dc>] .memblock_alloc_range_nid+0x68/0x8=
8
[  179.466544]      [<c000000000afc444>] .memblock_alloc_base+0x20/0x58
[  179.466553]      [<c000000000ae96cc>] .alloc_dart_table+0x5c/0xb0
[  179.466561]      [<c000000000aea300>] .pmac_probe+0x38/0xa0
[  179.466569]      [<000000000002166c>] 0x2166c
[  179.466579]      [<0000000000ae0e68>] 0xae0e68
[  179.466587]      [<0000000000009bc4>] 0x9bc4


> --
> Catalin
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
