Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE216B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:32:56 -0500 (EST)
Received: by wwf10 with SMTP id 10so5237867wwf.26
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 19:32:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111118115955.410af035.akpm@linux-foundation.org>
References: <1321616630-28281-1-git-send-email-consul.kautuk@gmail.com>
	<20111118115955.410af035.akpm@linux-foundation.org>
Date: Fri, 18 Nov 2011 22:32:52 -0500
Message-ID: <CAFPAmTRU7=LyoEMWnAkm4ZDz9G6wwUsPr=iHP7rEkU1zJ_JDEQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/vmalloc.c: eliminate extra loop in
 pcpu_get_vm_areas error path
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joe Perches <joe@perches.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Oh yes, I missed that out. :)

We should also do that.

Do you need me to redo this patch with this change ?
Although, I do notice that you seem to have already accepted this patch.


On Fri, Nov 18, 2011 at 2:59 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 18 Nov 2011 17:13:50 +0530
> Kautuk Consul <consul.kautuk@gmail.com> wrote:
>
>> If either of the vas or vms arrays are not properly kzalloced,
>> then the code jumps to the err_free label.
>>
>> The err_free label runs a loop to check and free each of the array
>> members of the vas and vms arrays which is not required for this
>> situation as none of the array members have been allocated till this
>> point.
>>
>> Eliminate the extra loop we have to go through by introducing a new
>> label err_free2 and then jumping to it.
>>
>> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
>> ---
>> =A0mm/vmalloc.c | =A0 =A03 ++-
>> =A01 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index b669aa6..1a0d4e2 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -2352,7 +2352,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigne=
d long *offsets,
>> =A0 =A0 =A0 vms =3D kzalloc(sizeof(vms[0]) * nr_vms, GFP_KERNEL);
>> =A0 =A0 =A0 vas =3D kzalloc(sizeof(vas[0]) * nr_vms, GFP_KERNEL);
>> =A0 =A0 =A0 if (!vas || !vms)
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto err_free;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto err_free2;
>>
>> =A0 =A0 =A0 for (area =3D 0; area < nr_vms; area++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 vas[area] =3D kzalloc(sizeof(struct vmap_are=
a), GFP_KERNEL);
>> @@ -2455,6 +2455,7 @@ err_free:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vms)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vms[area]);
>> =A0 =A0 =A0 }
>> +err_free2:
>> =A0 =A0 =A0 kfree(vas);
>> =A0 =A0 =A0 kfree(vms);
>> =A0 =A0 =A0 return NULL;
>
> Which means we can also do the below, yes? =A0(please check my homework!)
>
> --- a/mm/vmalloc.c~mm-vmallocc-eliminate-extra-loop-in-pcpu_get_vm_areas-=
error-path-fix
> +++ a/mm/vmalloc.c
> @@ -2449,10 +2449,8 @@ found:
>
> =A0err_free:
> =A0 =A0 =A0 =A0for (area =3D 0; area < nr_vms; area++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vas)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vas[area]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vms)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vms[area]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vas[area]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(vms[area]);
> =A0 =A0 =A0 =A0}
> =A0err_free2:
> =A0 =A0 =A0 =A0kfree(vas);
> _
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
