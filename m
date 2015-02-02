Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4116B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 18:27:08 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so46607527oib.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:27:08 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id oq6si262861pab.148.2015.02.02.15.27.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 15:27:06 -0800 (PST)
Subject: Re: [PATCH 2/2] staging/lustre: use __vmalloc_node() to avoid __GFP_FS default
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <alpine.DEB.2.10.1502020945370.5117@chino.kir.corp.google.com>
Date: Mon, 2 Feb 2015 18:26:53 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <7C13E0D6-CFBD-4F32-8F66-B96A8D427E1A@linuxhacker.ru>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru> <1422846627-26890-3-git-send-email-green@linuxhacker.ru> <alpine.DEB.2.10.1502020945370.5117@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Bruno Faccini <bruno.faccini@intel.com>


On Feb 2, 2015, at 12:48 PM, David Rientjes wrote:

> On Sun, 1 Feb 2015, green@linuxhacker.ru wrote:
>=20
>> From: Bruno Faccini <bruno.faccini@intel.com>
>>=20
>> When possible, try to use of __vmalloc_node() instead of
>> vzalloc/vzalloc_node which allows for protection flag specification,
>> and particularly to not set __GFP_FS, which can cause some deadlock
>> situations in our code due to recursive calls.
> You're saying that all usage of OBD_ALLOC_LARGE() and=20
> OBD_CPT_ALLOC_LARGE() are in contexts where we need GFP_NOFS?  It =
would be=20

Most of them fore sure (hm, there's only one OBD_CPT_ALLOC_LARGE in the =
client
and I imagine it better be GFP_NOFS even though the condition for that =
is
very unlikely, but that's what happens when you have tens of thousands =
nodes
all doing the same code all the time - all sorts of unlikely things =
trigger a lot).

> much better to keep using vzalloc{,_node)() in contexts that permit=20
> __GFP_FS for a higher likelihood of being able to allocate the memory.

While it's certainly possible to go audit all the OBD_ALLOC_LARGE and
isolate the ones where __GFP_FS is not detrimential, I just found =
yesterday that
vmalloc possibly does GFP_KERNEL allocations in its guts no matter what.
I saw all the rants and stuff about that too (but somewhat old).
Yet I cannot help but ask too if perhaps something could be done about =
it now?

>=20
>> Additionally fixed a typo in the macro name: VEROBSE->VERBOSE
>>=20
>> Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
>> Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
>> Reviewed-on: http://review.whamcloud.com/11190
>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5349
>> ---
>> drivers/staging/lustre/lustre/include/obd_support.h | 18 =
++++++++++++------
>> 1 file changed, 12 insertions(+), 6 deletions(-)
>>=20
>> diff --git a/drivers/staging/lustre/lustre/include/obd_support.h =
b/drivers/staging/lustre/lustre/include/obd_support.h
>> index 2991d2e..c90a88e 100644
>> --- a/drivers/staging/lustre/lustre/include/obd_support.h
>> +++ b/drivers/staging/lustre/lustre/include/obd_support.h
>> @@ -655,11 +655,17 @@ do {							=
		      \
>> #define OBD_CPT_ALLOC_PTR(ptr, cptab, cpt)				 =
     \
>> 	OBD_CPT_ALLOC(ptr, cptab, cpt, sizeof(*(ptr)))
>>=20
>> -# define __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)			=
      \
>> +/* Direct use of __vmalloc_node() allows for protection flag =
specification
>> + * (and particularly to not set __GFP_FS, which is likely to cause =
some
>> + * deadlock situations in our code).
>> + */
>> +# define __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)			=
      \
>> do {									 =
     \
>> -	(ptr) =3D cptab =3D=3D NULL ?						=
      \
>> -		vzalloc(size) :						 =
     \
>> -		vzalloc_node(size, cfs_cpt_spread_node(cptab, cpt));	 =
     \
>> +	(ptr) =3D __vmalloc_node(size, 1, GFP_NOFS | __GFP_HIGHMEM | =
__GFP_ZERO,\
>> +			       PAGE_KERNEL,				 =
     \
>> +			       cptab =3D=3D NULL ? NUMA_NO_NODE :		=
      \
>> +					      cfs_cpt_spread_node(cptab, =
cpt),\
>> +			       __builtin_return_address(0));		 =
     \
>> 	if (unlikely((ptr) =3D=3D NULL)) {					=
\
>> 		CERROR("vmalloc of '" #ptr "' (%d bytes) failed\n",	 =
  \
>> 		       (int)(size));					 =
 \
>> @@ -671,9 +677,9 @@ do {							=
		      \
>> } while (0)
>>=20
>> # define OBD_VMALLOC(ptr, size)						=
      \
>> -	 __OBD_VMALLOC_VEROBSE(ptr, NULL, 0, size)
>> +	 __OBD_VMALLOC_VERBOSE(ptr, NULL, 0, size)
>> # define OBD_CPT_VMALLOC(ptr, cptab, cpt, size)				=
      \
>> -	 __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)
>> +	 __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)
>>=20
>>=20
>> /* Allocations above this size are considered too big and could not =
be done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
