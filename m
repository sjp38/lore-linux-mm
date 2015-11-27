Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1AE6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 22:40:51 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so104815554pab.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 19:40:50 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id n88si1418654pfb.56.2015.11.26.19.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 19:40:50 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so101693936pac.3
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 19:40:50 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH v2 6/9] mm, debug: introduce dump_gfpflag_names() for symbolic printing of gfp_flags
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <56558D4C.3060902@suse.cz>
Date: Fri, 27 Nov 2015 11:40:40 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <DE6F06A1-8E6E-474F-9CDF-E267955BA0A9@gmail.com>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz> <1448368581-6923-7-git-send-email-vbabka@suse.cz> <20151125081645.GC10494@js1304-P5Q-DELUXE> <56558D4C.3060902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>


> On Nov 25, 2015, at 18:28, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 11/25/2015 09:16 AM, Joonsoo Kim wrote:
>> On Tue, Nov 24, 2015 at 01:36:18PM +0100, Vlastimil Babka wrote:
>>> --- a/include/trace/events/gfpflags.h
>>> +++ b/include/trace/events/gfpflags.h
>>> @@ -8,8 +8,8 @@
>>>  *
>>>  * Thus most bits set go first.
>>>  */
>>> -#define show_gfp_flags(flags)						=
\
>>> -	(flags) ? __print_flags(flags, "|",				=
\
>>> +
>>> +#define __def_gfpflag_names						=
\
>>> 	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	=
\
>>> 	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, =
\
>>> 	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	=
\
>>> @@ -19,9 +19,13 @@
>>> 	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		=
\
>>> 	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		=
\
>>> 	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		=
\
>>> +	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		=
\
>>> +	{(unsigned long)__GFP_DMA,		"GFP_DMA"},		=
\
>>> +	{(unsigned long)__GFP_DMA32,		"GFP_DMA32"},		=
\
>>> 	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		=
\
>>> 	{(unsigned long)__GFP_ATOMIC,		"GFP_ATOMIC"},		=
\
>>> 	{(unsigned long)__GFP_IO,		"GFP_IO"},		=
\
>>> +	{(unsigned long)__GFP_FS,		"GFP_FS"},		=
\
>>> 	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		=
\
>>> 	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		=
\
>>> 	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		=
\
>>> @@ -36,8 +40,12 @@
>>> 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	=
\
>>> 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		=
\
>>> 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		=
\
>>> +	{(unsigned long)__GFP_WRITE,		"GFP_WRITE"},		=
\
>>> 	{(unsigned long)__GFP_DIRECT_RECLAIM,	"GFP_DIRECT_RECLAIM"},	=
\
>>> 	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"GFP_KSWAPD_RECLAIM"},	=
\
>>> 	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	=
\
>>> -	) : "GFP_NOWAIT"
>>>=20
>>> +#define show_gfp_flags(flags)						=
\
>>> +	(flags) ? __print_flags(flags, "|",				=
\
>>> +	__def_gfpflag_names						=
\
>>> +	) : "none"
>>=20
>> How about moving this to gfp.h or something?
>> Now, we use it in out of tracepoints so there is no need to keep it
>> in include/trace/events/xxx.
>=20
> Hm I didn't want to pollute such widely included header with such =
defines. And
> show_gfp_flags shouldn't be there definitely as it depends on =
__print_flags.
> What do others think?
how about add this into standard printk()  format ?
like cpu mask print in printk use %*pb[l]  ,
it define a macro cpumask_pr_args  to print cpumask .

we can also define a new format like %pG  means print flag ,
then it will be useful for other code to use , like dump vma /  mm  =
flags ..

Thanks





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
