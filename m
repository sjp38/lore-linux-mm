Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1117C6B0258
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 13:38:08 -0500 (EST)
Received: by pfbg73 with SMTP id g73so12700032pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 10:38:07 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id v66si13396654pfi.67.2015.12.03.10.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 10:38:07 -0800 (PST)
Received: by pfnn128 with SMTP id n128so12395677pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 10:38:07 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <87a8psq7r6.fsf@rasmusvillemoes.dk>
Date: Thu, 3 Dec 2015 10:38:04 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
References: <20151125143010.GI27283@dhcp22.suse.cz> <1448899821-9671-1-git-send-email-vbabka@suse.cz> <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com> <565F5CD9.9080301@suse.cz> <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com> <87a8psq7r6.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>


> On Dec 3, 2015, at 00:03, Rasmus Villemoes <linux@rasmusvillemoes.dk> =
wrote:
>=20
> On Thu, Dec 03 2015, yalin wang <yalin.wang2010@gmail.com> wrote:
>=20
>>> On Dec 2, 2015, at 13:04, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>=20
>>> On 12/02/2015 06:40 PM, yalin wang wrote:
>>>=20
>>> (please trim your reply next time, no need to quote whole patch =
here)
>>>=20
>>>> i am thinking why not make %pg* to be more generic ?
>>>> not restricted to only GFP / vma flags / page flags .
>>>> so could we change format like this ?
>>>> define a flag spec struct to include flag and trace_print_flags and =
some other option :
>>>> typedef struct {=20
>>>> unsigned long flag;
>>>> structtrace_print_flags *flags;
>>>> unsigned long option; } flag_sec;
>>>> flag_sec my_flag;
>>>> in printk we only pass like this :
>>>> printk(=E2=80=9C%pg\n=E2=80=9D, &my_flag) ;
>>>> then it can print any flags defined by user .
>>>> more useful for other drivers to use .
>>>=20
>>> I don't know, it sounds quite complicated
>=20
> Agreed, I think this would be premature generalization. There's also
> some value in having the individual %pgX specifiers, as that allows
> individual tweaks such as the mask_out for page flags.
>=20
> given that we had no flags printing
>>=20
if we use this generic method, %pgX where X can be used to specify some =
flag to
mask out some thing .  it will be great .

>=20
> Compared to printk("%pgv\n", &vma->flag), I know which I'd prefer to =
read.
>=20
>> i am not if DECLARE_FLAG_PRINTK_FMT and FLAG_PRINTK_FMT macro=20
>> can be defined into one macro ?
>> maybe need some trick here .
>>=20
>> is it possible ?
>=20
> Technically, I think the answer is yes, at least in C99 (and I suppose
> gcc would accept it in gnu89 mode as well).
>=20
> printk("%pg\n", &(struct flag_printer){.flags =3D my_flags, .names =3D =
vmaflags_names});
>=20
> Not tested, and I still don't think it would be particularly readable
> even when macroized
>=20
> printk("%pg\n", PRINTF_VMAFLAGS(my_flags));
i test on gcc 4.9.3, it can work for this method,
so the final solution like this:
printk.h:
struct flag_fmt_spec {
	unsigned long flag;
	struct trace_print_flags *flags;
	int array_size;
	char delimiter; }

#define FLAG_FORMAT(flag, flag_array, delimiter) (&(struct =
flag_ft_spec){ .flag =3D flag, .flags =3D flag_array, .array_size =3D =
ARRAY_SIZE(flag_array), .delimiter =3D delimiter})
#define VMA_FLAG_FORMAT(flag)  FLAG_FORMAT(flag, vmaflags_names, =E2=80=98=
|')

source code:
printk("%pg\n", VMA_FLAG_FORMAT(my_flags));=20

that=E2=80=99s all, see cpumask_pr_args(masks) macro,
it also use macro and  %*pb  to print cpu mask .
i think this method is not very complex to use .

search source code ,
there is lots of printk to print flag into hex number :
$ grep -n  -r 'printk.*flag.*%x=E2=80=99  .
it will be great if this flag string print is generic.

Thanks









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
