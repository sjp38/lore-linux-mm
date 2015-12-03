Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 323F96B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 03:03:15 -0500 (EST)
Received: by lffu14 with SMTP id u14so81812062lff.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:03:14 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id vo10si4800268lbb.137.2015.12.03.00.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 00:03:13 -0800 (PST)
Received: by lfdl133 with SMTP id l133so81364827lfd.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 00:03:13 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
	<1448899821-9671-1-git-send-email-vbabka@suse.cz>
	<4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com>
	<565F5CD9.9080301@suse.cz>
	<1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com>
Date: Thu, 03 Dec 2015 09:03:09 +0100
In-Reply-To: <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com> (yalin wang's
	message of "Wed, 2 Dec 2015 16:11:58 -0800")
Message-ID: <87a8psq7r6.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Thu, Dec 03 2015, yalin wang <yalin.wang2010@gmail.com> wrote:

>> On Dec 2, 2015, at 13:04, Vlastimil Babka <vbabka@suse.cz> wrote:
>>=20
>> On 12/02/2015 06:40 PM, yalin wang wrote:
>>=20
>> (please trim your reply next time, no need to quote whole patch here)
>>=20
>>> i am thinking why not make %pg* to be more generic ?
>>> not restricted to only GFP / vma flags / page flags .
>>> so could we change format like this ?
>>> define a flag spec struct to include flag and trace_print_flags and som=
e other option :
>>> typedef struct {=20
>>> unsigned long flag;
>>> structtrace_print_flags *flags;
>>> unsigned long option; } flag_sec;
>>> flag_sec my_flag;
>>> in printk we only pass like this :
>>> printk(=E2=80=9C%pg\n=E2=80=9D, &my_flag) ;
>>> then it can print any flags defined by user .
>>> more useful for other drivers to use .
>>=20
>> I don't know, it sounds quite complicated

Agreed, I think this would be premature generalization. There's also
some value in having the individual %pgX specifiers, as that allows
individual tweaks such as the mask_out for page flags.

 given that we had no flags printing
>> for years and now there's just three kinds of them. The extra struct fla=
g_sec is
>> IMHO nuissance. No other printk format needs such thing AFAIK? For examp=
le, if I
>> were to print page flags from several places, each would have to define =
the
>> struct flag_sec instance, or some header would have to provide it?
> this can be avoided by provide a macro in header file .
> we can add a new struct to declare trace_print_flags :
> for example:
> #define DECLARE_FLAG_PRINTK_FMT(name, flags_array)   flag_spec name =3D {=
 .flags =3D flags_array};
> #define FLAG_PRINTK_FMT(name, flag) ({  name.flag =3D flag;  &name})
>
> in source code :
> DECLARE_FLAG_PRINTK_FMT(my_flag, vmaflags_names);
> printk(=E2=80=9C%pg\n=E2=80=9D, FLAG_PRINTK_FMT(my_flag, vma->flag));
>

Compared to printk("%pgv\n", &vma->flag), I know which I'd prefer to read.

> i am not if DECLARE_FLAG_PRINTK_FMT and FLAG_PRINTK_FMT macro=20
> can be defined into one macro ?
> maybe need some trick here .
>
> is it possible ?

Technically, I think the answer is yes, at least in C99 (and I suppose
gcc would accept it in gnu89 mode as well).

printk("%pg\n", &(struct flag_printer){.flags =3D my_flags, .names =3D vmaf=
lags_names});

Not tested, and I still don't think it would be particularly readable
even when macroized

printk("%pg\n", PRINTF_VMAFLAGS(my_flags));

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
