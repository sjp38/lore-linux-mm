Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DD3C58D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 06:05:43 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oAEB5b1u025323
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 03:05:38 -0800
Received: from qyk12 (qyk12.prod.google.com [10.241.83.140])
	by wpaz21.hot.corp.google.com with ESMTP id oAEB5a6D011478
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 03:05:36 -0800
Received: by qyk12 with SMTP id 12so2801002qyk.5
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 03:05:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101114161059.BED5.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1010211259360.24115@router.home>
	<AANLkTinXftrp0NxGjsQAkoroMGDXozbA0XgUhSiOJ-xz@mail.gmail.com>
	<20101114161059.BED5.A69D9226@jp.fujitsu.com>
Date: Sun, 14 Nov 2010 03:05:36 -0800
Message-ID: <AANLkTi=xPYe6KVVNM7y+tnDAWcVOMb_6jKo5Hq8QNSC8@mail.gmail.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 13, 2010 at 11:10 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Oct 21, 2010 at 11:00 AM, Christoph Lameter <cl@linux.com> wrote=
:
>> > @@ -218,6 +218,7 @@ unsigned long shrink_slab(unsigned long
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long total_scan;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long max_pass;
>> >
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->node =3D node;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_pass =3D (*shrinker->shrink)(shrink=
er, 0, gfp_mask);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta =3D (4 * scanned) / shrinker->see=
ks;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta *=3D max_pass;
>>
>> Apologies for coming late to the party, but I have to ask - is there
>> anything protecting shrinker->node from concurrent modification if
>> several threads are trying to reclaim memory at once ?
>
> shrinker_rwsem? :)

Doesn't work - it protects shrink_slab() from concurrent modifications
of the shrinker_list in register_shrinker() or unregister_shrinker(),
but several shirnk_slab() calls can still execute in parallel since
they only grab shrinker_rwsem in shared (read) mode.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
