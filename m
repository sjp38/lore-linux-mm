Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E76F76B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 03:07:19 -0500 (EST)
Received: by obbta7 with SMTP id ta7so1336445obb.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 00:07:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326558605.19951.7.camel@lappy>
	<1326561043.5287.24.camel@edumazet-laptop>
	<1326632384.11711.3.camel@lappy>
	<1326648305.5287.78.camel@edumazet-laptop>
	<alpine.DEB.2.00.1201170910130.4800@router.home>
	<1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170927020.4800@router.home>
	<1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Date: Wed, 1 Feb 2012 10:07:18 +0200
Message-ID: <CAOJsxLFLkQDxYq9nuM91q8DB99gSuz9DBfXktNGpS4Ss63GHdA@mail.gmail.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

On Tue, Jan 17, 2012 at 5:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> Le mardi 17 janvier 2012 =E0 09:27 -0600, Christoph Lameter a =E9crit :
>
>> Subject: slub: Do not hold slub_lock when calling sysfs_slab_add()
>>
>> sysfs_slab_add() calls various sysfs functions that actually may
>> end up in userspace doing all sorts of things.
>>
>> Release the slub_lock after adding the kmem_cache structure to the list.
>> At that point the address of the kmem_cache is not known so we are
>> guaranteed exlusive access to the following modifications to the
>> kmem_cache structure.
>>
>> If the sysfs_slab_add fails then reacquire the slub_lock to
>> remove the kmem_cache structure from the list.
>>
>> Reported-by: Sasha Levin <levinsasha928@gmail.com>
>> Signed-off-by: Christoph Lameter <cl@linux.com>
>>
>> ---
>> =A0mm/slub.c | =A0 =A03 ++-
>> =A01 file changed, 2 insertions(+), 1 deletion(-)
>>
>> Index: linux-2.6/mm/slub.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.orig/mm/slub.c =A02012-01-17 03:07:11.140010438 -0600
>> +++ linux-2.6/mm/slub.c =A0 =A0 =A0 2012-01-17 03:26:06.799986908 -0600
>> @@ -3929,13 +3929,14 @@ struct kmem_cache *kmem_cache_create(con
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kmem_cache_open(s, n,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size, align,=
 flags, ctor)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&s->list, &slab_cac=
hes);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_write(&slub_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sysfs_slab_add(s)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 down_write(&sl=
ub_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&s-=
>list);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(n);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(s);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_write(&slub_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return s;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(n);
>
> Thanks !
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'm planning to queue this for v3.4 and tagging it for -stable for
v3.3. Do we need this for older versions as well?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
