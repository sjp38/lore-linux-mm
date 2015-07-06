Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0942802C2
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 13:23:38 -0400 (EDT)
Received: by lagc2 with SMTP id c2so163000848lag.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 10:23:37 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id y2si15784432lbp.38.2015.07.06.10.23.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 10:23:36 -0700 (PDT)
Received: by labgy5 with SMTP id gy5so11546591lab.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 10:23:35 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 6 Jul 2015 22:53:35 +0530
Message-ID: <CAOuPNLi56Eb5fVf86eHJtr6Q1jt1gSNqEMVZCEabrE=14ca25g@mail.gmail.com>
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
From: Pintu Kumar <pintu.ping@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu, Pintu Kumar <pintu.k@samsung.com>
Cc: corbet@lwn.net, akpm@linux-foundation.org, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, mgorman@suse.de, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, Pintu Kumar <pintu.ping@gmail.com>

Sorry, looks like some problem with the yahoo mail. Some emails are bouncin=
g.
Sending again with the gmail.


----- Original Message -----
> From: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>
> To: Pintu Kumar <pintu.k@samsung.com>
> Cc: corbet@lwn.net; akpm@linux-foundation.org; vbabka@suse.cz; gorcunov@o=
penvz.org; mhocko@suse.cz; emunson@akamai.com; kirill.shutemov@linux.intel.=
com; standby24x7@gmail.com; hannes@cmpxchg.org; vdavydov@parallels.com; hug=
hd@google.com; minchan@kernel.org; tj@kernel.org; rientjes@google.com; xypr=
on.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com; ebiederm@xmission.co=
m; rostedt@goodmis.org; uobergfe@redhat.com; paulmck@linux.vnet.ibm.com; ia=
mjoonsoo.kim@lge.com; ddstreet@ieee.org; sasha.levin@oracle.com; koct9i@gma=
il.com; mgorman@suse.de; cj@linux.com; opensource.ganesh@gmail.com; vinmeno=
n@codeaurora.org; linux-doc@vger.kernel.org; linux-kernel@vger.kernel.org; =
linux-mm@kvack.org; linux-pm@vger.kernel.org; cpgs@samsung.com; pintu_agarw=
al@yahoo.com; vishnu.ps@samsung.com; rohit.kr@samsung.com; iqbal.ams@samsun=
g.com
> Sent: Sunday, 5 July 2015 1:38 AM
> Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory =
feature
>
> On Fri, 03 Jul 2015 18:50:07 +0530, Pintu Kumar said:
>
>> This patch provides 2 things:
>
>> 2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
>> Currently, shrink_all_memory function is used only during hibernation.
>> With the new config we can make use of this API for non-hibernation case
>> also without disturbing the hibernation case.
>
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>
>> @@ -3571,12 +3571,17 @@ unsigned long shrink_all_memory(unsigned long
> nr_to_reclaim)
>>       struct reclaim_state reclaim_state;
>>       struct scan_control sc =3D {
>>           .nr_to_reclaim =3D nr_to_reclaim,
>> +#ifdef CONFIG_SHRINK_MEMORY
>> +        .gfp_mask =3D (GFP_HIGHUSER_MOVABLE | GFP_RECLAIM_MASK),
>> +        .hibernation_mode =3D 0,
>> +#else
>>           .gfp_mask =3D GFP_HIGHUSER_MOVABLE,
>> +        .hibernation_mode =3D 1,
>> +#endif
>
>
> That looks like a bug just waiting to happen.  What happens if we
> call an actual hibernation mode in a SHRINK_MEMORY=3Dy kernel, and it fin=
ds
> an extra gfp mask bit set, and hibernation_mode set to an unexpected valu=
e?
>
Ok, got it. Thanks for pointing this out.
I will handle HIBERNATION & SHRINK_MEMORY case and send again.
I will try to handle it using ifdefs. Do you have any special
suggestions on how this can be handled?
I verified only for the ARM case without hibernation. But, it is
likely that this feature can be enabled in laptop mode also. So we
should handle it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
