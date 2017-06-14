Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86E846B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:06:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u8so97176847pgo.11
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:06:01 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id a1si1557656plt.55.2017.06.13.23.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 23:06:00 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id f127so22220721pgc.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:06:00 -0700 (PDT)
Date: Wed, 14 Jun 2017 14:05:58 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RESEND PATCH] base/memory: pass the base_section in
 add_memory_block
Message-ID: <20170614060558.GA14009@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170614054550.14469-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="k+w/mQv8wyuph6w0"
Content-Disposition: inline
In-Reply-To: <20170614054550.14469-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: gregkh@linuxfoundation.org, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, Michael

I copied your reply here:

>[Sorry for a late response]
>
>On Wed 07-06-17 16:52:12, Wei Yang wrote:
>> The second parameter of init_memory_block() is used to calculate the
>> start_section_nr of this block, which means any section in the same block
>> would get the same start_section_nr.
>
>Could you be more specific what is the problem here?
>

There is no problem in this code. I just find a unnecessary calculation and
remove it in this patch.

>> This patch passes the base_section to init_memory_block(), so that to
>> reduce a local variable and a check in every loop.
>
>But then you are not handling a memblock which starts with a !present
>section. The code is quite hairy but I do not see why your change is any

I don't see the situation you pointed here.

In add_memory_block(), section_nr is used to record the first section which=
 is
present. And this variable is used to calculate the section which is passed=
 to
init_memory_block().

In init_memory_block(), the section got from add_memory_block(), is used to
calculate scn_nr, but finally transformed to "start_section_nr". That means=
 in
init_memory_block(), we just need the "start_section_nr" of a memory_block.=
 We
don't care about who is the first present section.

>more correct. This needs much better justification than what the above
>gives us. Maybe the whole thing about incomplete memblock is just
>overengineered piece of code, who knows this area is full of stuff that
>makes only little sense but again the changelog should be pretty verbose
>about all the consequences and focus on the high level rather than
>particular issues here and there.

There maybe other issues in memory_block, while for the code refine in this
patch, the change is straight and not see side effects.

The field memory_block->start_section_nr records the section number of the
first section in memory_block. No semantic change here and comply with the
high level view of memory_block hierarchy.

>
>Thanks
>

On Wed, Jun 14, 2017 at 01:45:50PM +0800, Wei Yang wrote:
>Based on Greg's comment, cc it to mm list.
>The original thread could be found https://lkml.org/lkml/2017/6/7/202
>
>The second parameter of init_memory_block() is used to calculate the
>start_section_nr of this block, which means any section in the same block
>would get the same start_section_nr.
>
>This patch passes the base_section to init_memory_block(), so that to
>reduce a local variable and a check in every loop.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> drivers/base/memory.c | 7 +++----
> 1 file changed, 3 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index cc4f1d0cbffe..1e903aba2aa1 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -664,21 +664,20 @@ static int init_memory_block(struct memory_block **m=
emory,
> static int add_memory_block(int base_section_nr)
> {
> 	struct memory_block *mem;
>-	int i, ret, section_count =3D 0, section_nr;
>+	int i, ret, section_count =3D 0;
>=20
> 	for (i =3D base_section_nr;
> 	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
> 	     i++) {
> 		if (!present_section_nr(i))
> 			continue;
>-		if (section_count =3D=3D 0)
>-			section_nr =3D i;
> 		section_count++;
> 	}
>=20
> 	if (section_count =3D=3D 0)
> 		return 0;
>-	ret =3D init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
>+	ret =3D init_memory_block(&mem, __nr_to_section(base_section_nr),
>+				MEM_ONLINE);
> 	if (ret)
> 		return ret;
> 	mem->section_count =3D section_count;
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--k+w/mQv8wyuph6w0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQNJGAAoJEKcLNpZP5cTdGOEP/3cyLb6u86ra+6L53omOxGgl
uJyQfyHzqKXlSPWl+N6oD0MEVXp6Qz+gFo+dmQe9aBeKiB68u8aiNknUrX4fojus
eSJIvHmYwzKo8x2IqkDZ04ZPk+hWHsu96Tp8kMqopWom9mtLneVY8ZOQsml23vYY
NCdTfiKVYNAfaKZSm8x0h35vHJwvR6wGIo9I+WCEDiEIsP9eYMeIfxb/yjtyjuDL
c9BqK1p2WRc9063GcahLwymtWtDJ5kmaZ/OJJihFjPQnbI2Mu4vjTofT3E1OXGG7
w7k75Ua5FJsDcg9TZ+5FAjRvO1IkwZlDRa8vBfJcmR4vicpBaRgP1QMizOdpwuu7
/Q+u2r+6vcii0ISk4QpK7m02Shv0x/Iej9IQbgdjyT85NKItC/Xl3V1TmGcFCsy8
G6zw7tCzlZfNuGVBJBXsW5SDGUHCkq5sekPatEEM2TPahLyxsdIk2V5xqQ93qXyD
hUfhAmdQn09N+S70vD+V8P/nwEyH3a+sXPV8y8Ryhbl8wtbJePNMqoglqkfPjDqZ
+7o9vNwE9ItJGVu7U/Dm1LAmjglqeN2PdUlMrbFJ8AcKnmLYPomXqOtw0/kN4iPz
0wAFiQ3qKywuFBTN4GuaG6ZNnsFcIZfU+sRJKy3pSs8zicCkQPMuDNSz9erXSNEt
ZyxhRc1875FwrcW5PPkW
=QI+A
-----END PGP SIGNATURE-----

--k+w/mQv8wyuph6w0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
