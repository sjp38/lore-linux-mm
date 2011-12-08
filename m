Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E93796B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:13:34 -0500 (EST)
Received: by wgbds13 with SMTP id ds13so2305098wgb.26
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:13:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1112072304010.28419@chino.kir.corp.google.com>
References: <1323327732-30817-1-git-send-email-consul.kautuk@gmail.com>
	<alpine.DEB.2.00.1112072304010.28419@chino.kir.corp.google.com>
Date: Thu, 8 Dec 2011 12:43:32 +0530
Message-ID: <CAFPAmTSJDXD1KNVBUz75yN_CeCT9f_+W9CaRNN467LSyCD+WXg@mail.gmail.com>
Subject: Re: [PATCH 1/1] vmalloc: purge_fragmented_blocks: Acquire spinlock
 before reading vmap_block
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 8, 2011 at 12:37 PM, David Rientjes <rientjes@google.com> wrote=
:
> On Thu, 8 Dec 2011, Kautuk Consul wrote:
>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 3231bf3..2228971 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -855,11 +855,14 @@ static void purge_fragmented_blocks(int cpu)
>>
>> =A0 =A0 =A0 rcu_read_lock();
>> =A0 =A0 =A0 list_for_each_entry_rcu(vb, &vbq->free, free_list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&vb->lock);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!(vb->free + vb->dirty =3D=3D VMAP_BBMAP_B=
ITS && vb->dirty !=3D VMAP_BBMAP_BITS))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!(vb->free + vb->dirty =3D=3D VMAP_BBMAP_B=
ITS &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vb->dirty !=3D VMAP_BBMAP_=
BITS)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&vb->lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&vb->lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vb->free + vb->dirty =3D=3D VMAP_BBMAP_B=
ITS && vb->dirty !=3D VMAP_BBMAP_BITS) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vb->free =3D 0; /* prevent f=
urther allocs after releasing lock */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vb->dirty =3D VMAP_BBMAP_BIT=
S; /* prevent purging it again */
>
> Nack, this is wrong because the if-clause you're modifying isn't the
> criteria that is used to determine whether the purge occurs or not. =A0It=
's
> merely an optimization to prevent doing exactly what your patch is doing:
> taking vb->lock unnecessarily.

I agree.

>
> In the original code, if the if-clause fails, the lock is only then taken
> and the exact same test occurs again while protected. =A0If the test now
> fails, the lock is immediately dropped. =A0A branch here is faster than a
> contented spinlock.

But, if there is some concurrent change happening to vb->free and
vb->dirty, dont you think
that it will continue and then go to the next vmap_block ?

If yes, then it will not be put into the purge list.


So, can we make a change where we simply remove the first check ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
