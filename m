Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5906B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:04:34 -0500 (EST)
Received: by pfu207 with SMTP id 207so17112747pfu.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:04:34 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 130si15428294pfb.52.2015.12.03.17.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 17:04:33 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so80034458pab.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:04:33 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
Date: Thu, 3 Dec 2015 17:04:30 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <CC1524EC-86F8-4450-A4EE-80D8D0E2EC08@gmail.com>
References: <20151125143010.GI27283@dhcp22.suse.cz> <1448899821-9671-1-git-send-email-vbabka@suse.cz> <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com> <565F5CD9.9080301@suse.cz> <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com> <87a8psq7r6.fsf@rasmusvillemoes.dk> <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>


>> Technically, I think the answer is yes, at least in C99 (and I =
suppose
>> gcc would accept it in gnu89 mode as well).
>>=20
>> printk("%pg\n", &(struct flag_printer){.flags =3D my_flags, .names =3D =
vmaflags_names});
>>=20
>> Not tested, and I still don't think it would be particularly readable
>> even when macroized
>>=20
>> printk("%pg\n", PRINTF_VMAFLAGS(my_flags));
> i test on gcc 4.9.3, it can work for this method,
> so the final solution like this:
> printk.h:
> struct flag_fmt_spec {
> 	unsigned long flag;
> 	struct trace_print_flags *flags;
> 	int array_size;
> 	char delimiter; }
>=20
> #define FLAG_FORMAT(flag, flag_array, delimiter) (&(struct =
flag_ft_spec){ .flag =3D flag, .flags =3D flag_array, .array_size =3D =
ARRAY_SIZE(flag_array), .delimiter =3D delimiter})
> #define VMA_FLAG_FORMAT(flag)  FLAG_FORMAT(flag, vmaflags_names, =
=E2=80=98|=E2=80=99)
a little change:
	#define VMA_FLAG_FORMAT(vma)  FLAG_FORMAT(vma->vm_flags, =
vmaflags_names, =E2=80=98|=E2=80=99)


> source code:
> printk("%pg\n", VMA_FLAG_FORMAT(my_flags));=20
a little change:
	printk("%pg\n", VMA_FLAG_FORMAT(vma));=20

>=20
> that=E2=80=99s all, see cpumask_pr_args(masks) macro,
> it also use macro and  %*pb  to print cpu mask .
> i think this method is not very complex to use .
>=20
> search source code ,
> there is lots of printk to print flag into hex number :
> $ grep -n  -r 'printk.*flag.*%x=E2=80=99  .
> it will be great if this flag string print is generic.
>=20
> Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
