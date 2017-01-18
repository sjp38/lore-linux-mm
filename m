Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFCB6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:36:33 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id t56so6835qte.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 18:36:33 -0800 (PST)
Received: from sender163-mail.zoho.com (sender163-mail.zoho.com. [74.201.84.163])
        by mx.google.com with ESMTPS id s16si18004728qtc.290.2017.01.17.18.36.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 18:36:32 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] slab: add a check for the first kmem_cache not to be destroyed
From: kwon <kwon@toanyone.net>
In-Reply-To: <alpine.DEB.2.10.1701171452580.142998@chino.kir.corp.google.com>
Date: Wed, 18 Jan 2017 11:36:15 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <380AA0F8-58C6-4AC7-AE06-D3A326E5B396@toanyone.net>
References: <20170116070459.43540-1-kwon@toanyone.net> <20170117013300.GA25940@js1304-P5Q-DELUXE> <764E463A-F743-4BE6-8BFC-07D50FF57DDA@toanyone.net> <alpine.DEB.2.10.1701171452580.142998@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Jan 18, 2017, at 7:54 AM, David Rientjes <rientjes@google.com> =
wrote:
>=20
> On Tue, 17 Jan 2017, kwon wrote:
>=20
>>>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>>>> index 1dfc209..2d30ace 100644
>>>> --- a/mm/slab_common.c
>>>> +++ b/mm/slab_common.c
>>>> @@ -744,7 +744,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
>>>> 	bool need_rcu_barrier =3D false;
>>>> 	int err;
>>>>=20
>>>> -	if (unlikely(!s))
>>>> +	if (unlikely(!s) || s->refcount =3D=3D -1)
>>>> 		return;
>>>=20
>>> Hello, Kyunghwan.
>>>=20
>>> Few lines below, s->refcount is checked.
>>>=20
>>> if (s->refcount)
>>>       goto unlock;
>>>=20
>>> Am I missing something?
>>>=20
>>> Thanks.
>>=20
>> Hello, Joonsoo.
>>=20
>> In case it is called the number of int size times. refcount would =
finally reach
>> to 0 since decreased every time the function called.
>>=20
>=20
> The only thing using create_boot_cache() should be the slab =
implementation=20
> itself, so I don't think we need to protect ourselves from doing =
something=20
> like kmem_cache_destroy(kmem_cache) or=20
> kmem_cache_destroy(kmem_cache_node) even a single time.

Agreed. I was aware of that though, I thought it would make its logic =
firm not
giving performance disadvantages. Sorry for distraction.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
