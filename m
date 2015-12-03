Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1906B0253
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:12:00 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so54564702pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:12:00 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id he9si7866004pac.102.2015.12.02.16.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:11:59 -0800 (PST)
Received: by pfu207 with SMTP id 207so2716865pfu.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:11:59 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <565F5CD9.9080301@suse.cz>
Date: Wed, 2 Dec 2015 16:11:58 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com>
References: <20151125143010.GI27283@dhcp22.suse.cz> <1448899821-9671-1-git-send-email-vbabka@suse.cz> <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com> <565F5CD9.9080301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>


> On Dec 2, 2015, at 13:04, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 12/02/2015 06:40 PM, yalin wang wrote:
>=20
> (please trim your reply next time, no need to quote whole patch here)
>=20
>> i am thinking why not make %pg* to be more generic ?
>> not restricted to only GFP / vma flags / page flags .
>> so could we change format like this ?
>> define a flag spec struct to include flag and trace_print_flags and =
some other option :
>> typedef struct {=20
>> unsigned long flag;
>> structtrace_print_flags *flags;
>> unsigned long option; } flag_sec;
>> flag_sec my_flag;
>> in printk we only pass like this :
>> printk(=E2=80=9C%pg\n=E2=80=9D, &my_flag) ;
>> then it can print any flags defined by user .
>> more useful for other drivers to use .
>=20
> I don't know, it sounds quite complicated given that we had no flags =
printing
> for years and now there's just three kinds of them. The extra struct =
flag_sec is
> IMHO nuissance. No other printk format needs such thing AFAIK? For =
example, if I
> were to print page flags from several places, each would have to =
define the
> struct flag_sec instance, or some header would have to provide it?
this can be avoided by provide a macro in header file .
we can add a new struct to declare trace_print_flags :
for example:
#define DECLARE_FLAG_PRINTK_FMT(name, flags_array)   flag_spec name =3D =
{ .flags =3D flags_array};
#define FLAG_PRINTK_FMT(name, flag) ({  name.flag =3D flag;  &name})

in source code :
DECLARE_FLAG_PRINTK_FMT(my_flag, vmaflags_names);
printk(=E2=80=9C%pg\n=E2=80=9D, FLAG_PRINTK_FMT(my_flag, vma->flag));

i am not if DECLARE_FLAG_PRINTK_FMT and FLAG_PRINTK_FMT macro=20
can be defined into one macro ?
maybe need some trick here .

is it possible ?


Thanks



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
