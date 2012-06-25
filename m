Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id F18476B037B
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:23:40 -0400 (EDT)
Received: by lbok6 with SMTP id k6so9067402lbo.18
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:23:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206241345060.13297@chino.kir.corp.google.com>
References: <CAJ7qFSdiGw1krDbWg6HvwBymp2gwrYKb8UuA00wSP0rgZi-EMw@mail.gmail.com>
	<alpine.DEB.2.00.1206241345060.13297@chino.kir.corp.google.com>
Date: Mon, 25 Jun 2012 22:53:32 +0530
Message-ID: <CAJ7qFSdZpXq=s8Kq6x6QxPjYOK6jp-OrPHY_TLJd9tgOuSTRfQ@mail.gmail.com>
Subject: Re: Crash with VMALLOC api
From: "R, Sricharan" <r.sricharan@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-omap@vger.kernel.org

Hi David,

On Mon, Jun 25, 2012 at 2:17 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Sat, 23 Jun 2012, R, Sricharan wrote:
>
>> Hi,
>> =A0 I am observing a below crash with VMALLOC call on mainline kernel.
>> =A0 The issue happens when there is insufficent vmalloc space.
>> =A0 Isn't it expected that the API should return a NULL instead of crash=
ing when
>> =A0 there is not enough memory?.
>
> Yes.
>
>> =A0 This can be reproduced with succesive vmalloc
>> =A0 calls for a size of about say 10MB, without a vfree, thus exhausting
>> the memory.
>>
>> =A0Strangely when vmalloc is requested for a large chunk, then at that t=
ime API
>> =A0does not crash instead returns a NULL correctly.
>>
>> =A0 Please correct me if my understanding is not correct..
>>
>> ------------------------------------------------------------------------=
--------------
>>
>> [ =A0345.059841] Unable to handle kernel paging request at virtual
>> address 90011000
>> [ =A0345.067063] pgd =3D ebc34000
>> [ =A0345.069793] [90011000] *pgd=3D00000000
>> [ =A0345.073383] Internal error: Oops: 5 [#1] PREEMPT SMP ARM
>> [ =A0345.078685] Modules linked in: bcmdhd cfg80211 inv_mpu_ak8975
>> inv_mpu_kxtf9 mpu3050
>> [ =A0345.086380] CPU: 0 =A0 =A0Tainted: G =A0 =A0 =A0 =A0W =A0 =A0 (3.4.=
0-rc1-05660-g0d4b175 #1)
>> [ =A0345.093351] PC is at vmap_page_range_noflush+0xf0/0x200
>> [ =A0345.098569] LR is at vmap_page_range+0x14/0x50
>> [ =A0345.103005] pc : [<c01091c8>] =A0 =A0lr : [<c01092ec>] =A0 =A0psr: =
80000013
>> [ =A0345.103009] sp : ebc41e38 =A0ip : fe000fff =A0fp : 00002000
>> [ =A0345.114472] r10: c0a78480 =A0r9 : 90011000 =A0r8 : c096e2ac
>> [ =A0345.119685] r7 : 90011000 =A0r6 : 00000000 =A0r5 : fe000000 =A0r4 :=
 00000000
>> [ =A0345.126198] r3 : 50011452 =A0r2 : f385c400 =A0r1 : fe000fff =A0r0 :=
 f385c400
>> [ =A0345.132713] Flags: Nzcv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0ISA=
 ARM =A0Segment user
>> [ =A0345.139835] Control: 10c5387d =A0Table: abc3404a =A0DAC: 00000015
>
> Couple requests:
>
> =A0- since you're already running an -rc kernel, would it be possible to
> =A0 try 3.5-rc4, which was released today, instead?
>
> =A0- could you disassemble vmap_page_range_noflush and post the output or
> =A0 map the offset back to the line in the code?

      Thanks a lot for the response.

      Debugged this further and the real issue was because of
      static mapping for a 1MB io page and the vmalloc mapping for a
     1MB dram page falling in to one PGD entry (PGDIR_SHIFT is 0x21).

     While trying to setup the pagetables for the dram page,
     the PGD entry of static io map is used, resulting in the paging fault.

     This was because of a recent change that brought the static io mapping=
s
    under the vmalloc space.

Thanks,
 Sricharan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
