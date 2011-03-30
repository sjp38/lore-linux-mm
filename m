Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6418D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 05:54:13 -0400 (EDT)
Received: by qyk2 with SMTP id 2so3176840qyk.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 02:54:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	<AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	<1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	<1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	<1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	<AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	<AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
	<1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
Date: Wed, 30 Mar 2011 12:54:11 +0300
Message-ID: <AANLkTi=YB+nBG7BYuuU+rB9TC-BbWcJ6mVfkxq0iUype@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Daniel Baluta <daniel.baluta@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>

>> unreferenced object 0x8f90d000 (size 4096):
>> =A0 comm "swapper", pid 1, jiffies 4294937330 (age 815.000s)
>> =A0 hex dump (first 32 bytes):
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.............=
...
>> =A0 =A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0.............=
...
>> =A0 backtrace:
>> =A0 =A0 [<80529644>] alloc_large_system_hash+0x2f8/0x410
>> =A0 =A0 [<805383b4>] udp_table_init+0x4c/0x158
>> =A0 =A0 [<805384dc>] udp_init+0x1c/0x94
>> =A0 =A0 [<8053889c>] inet_init+0x184/0x2a0
>> =A0 =A0 [<80100584>] do_one_initcall+0x174/0x1e0
>> =A0 =A0 [<8051f348>] kernel_init+0xe4/0x174
>> =A0 =A0 [<80103d4c>] kernel_thread_helper+0x10/0x18
>
> If you for the kmemleak scan (via echo) a few times, do you get more
> leaks? The udp_table_init() function looks like it could leak some
> memory but I haven't seen it before. I'm not sure whether this is a
> false positive or a real leak.

Looking again at udp_init_table it seem that a memory leak is possible.
Could you post your .config and the full output of dmesg after booting.

A situation where CONFIG_BASE_SMALL is 0, and
table->mask < UDP_HTABLE_SIZE_MIN - 1 would lead
to a memory leak.

Furthermore, you can add some printks inside udp_init_table
and check what is really happening there. ([1])

thanks,
Daniel.

[1] http://lxr.linux.no/linux+v2.6.38/net/ipv4/udp.c#L2125

thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
