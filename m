Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A52AA8E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:36:12 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j5so8560181qtk.11
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:36:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6sor122443070qte.24.2019.01.24.15.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 15:36:11 -0800 (PST)
From: Blake Caldwell <blake.caldwell@colorado.edu>
Message-Id: <59078FED-5A1B-42D8-A501-975CE69CBC9B@colorado.edu>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_7EBEE743-E550-454D-8E83-825ED7FA06D5"
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 4/4] userfaultfd: change the direction for UFFDIO_REMAP to
 out
Date: Thu, 24 Jan 2019 18:36:08 -0500
In-Reply-To: <20190120210731.GC28141@rapoport-lnx>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
 <ab1b6be85254e111935104cf4a2293ab2fa4a8d6.1547251023.git.blake.caldwell@colorado.edu>
 <20190120210731.GC28141@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, aarcange@redhat.com


--Apple-Mail=_7EBEE743-E550-454D-8E83-825ED7FA06D5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Jan 20, 2019, at 4:07 PM, Mike Rapoport <rppt@linux.ibm.com> wrote:
>=20
> Hi,
>=20
> On Sat, Jan 12, 2019 at 12:36:29AM +0000, Blake Caldwell wrote:
>> Moving a page out of a userfaultfd registered region and into a =
userland
>> anonymous vma is needed by the use case of uncooperatively limiting =
the
>> resident size of the userfaultfd region. Reverse the direction of the
>> original userfaultfd_remap() to the out direction. Now after memory =
has
>> been removed, subsequent accesses will generate uffdio page fault =
events.
>=20
> It took me a while but better late then never :)
>=20
> Why did you keep this as a separate patch? If the primary use case for
> UFFDIO_REMAP to move pages out of userfaultfd region, why not make it =
so
> from the beginning?

Only to show what has changed since this was last proposed, but yes, =
that
change to fs/userfaultfd.c should be squashed with patch 3. The purpose =
of
patch 4 will only be documenting UFFDIO_REMAP.

I will make those changes for the next revision. Thanks for looking this =
over.

>=20
>> Signed-off-by: Blake Caldwell <blake.caldwell@colorado.edu>
>> ---
>> Documentation/admin-guide/mm/userfaultfd.rst | 10 ++++++++++
>> fs/userfaultfd.c                             |  6 +++---
>> 2 files changed, 13 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/Documentation/admin-guide/mm/userfaultfd.rst =
b/Documentation/admin-guide/mm/userfaultfd.rst
>> index 5048cf6..714af49 100644
>> --- a/Documentation/admin-guide/mm/userfaultfd.rst
>> +++ b/Documentation/admin-guide/mm/userfaultfd.rst
>> @@ -108,6 +108,16 @@ UFFDIO_COPY. They're atomic as in guaranteeing =
that nothing can see an
>> half copied page since it'll keep userfaulting until the copy has
>> finished.
>>=20
>> +To move pages out of a userfault registered region and into a user =
vma
>> +the UFFDIO_REMAP ioctl can be used. This is only possible for the
>> +"OUT" direction. For the "IN" direction, UFFDIO_COPY is preferred
>> +since UFFDIO_REMAP requires a TLB flush on the source range at a
>> +greater penalty than copying the page. With
>> +UFFDIO_REGISTER_MODE_MISSING set, subsequent accesses to the same
>> +region will generate a page fault event. This allows non-cooperative
>> +removal of memory in a userfaultfd registered vma, effectively
>> +limiting the amount of resident memory in such a region.
>> +
>> QEMU/KVM
>> =3D=3D=3D=3D=3D=3D=3D=3D
>>=20
>> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
>> index cf68cdb..8099da2 100644
>> --- a/fs/userfaultfd.c
>> +++ b/fs/userfaultfd.c
>> @@ -1808,10 +1808,10 @@ static int userfaultfd_remap(struct =
userfaultfd_ctx *ctx,
>> 			   sizeof(uffdio_remap)-sizeof(__s64)))
>> 		goto out;
>>=20
>> -	ret =3D validate_range(ctx->mm, uffdio_remap.dst, =
uffdio_remap.len);
>> +	ret =3D validate_range(current->mm, uffdio_remap.dst, =
uffdio_remap.len);
>> 	if (ret)
>> 		goto out;
>> -	ret =3D validate_range(current->mm, uffdio_remap.src, =
uffdio_remap.len);
>> +	ret =3D validate_range(ctx->mm, uffdio_remap.src, =
uffdio_remap.len);
>> 	if (ret)
>> 		goto out;
>> 	ret =3D -EINVAL;
>> @@ -1819,7 +1819,7 @@ static int userfaultfd_remap(struct =
userfaultfd_ctx *ctx,
>> 				  UFFDIO_REMAP_MODE_DONTWAKE))
>> 		goto out;
>>=20
>> -	ret =3D remap_pages(ctx->mm, current->mm,
>> +	ret =3D remap_pages(current->mm, ctx->mm,
>> 			  uffdio_remap.dst, uffdio_remap.src,
>> 			  uffdio_remap.len, uffdio_remap.mode);
>> 	if (unlikely(put_user(ret, &user_uffdio_remap->remap)))
>> --=20
>> 1.8.3.1
>>=20
>=20
> --=20
> Sincerely yours,
> Mike.


--Apple-Mail=_7EBEE743-E550-454D-8E83-825ED7FA06D5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D""><br =
class=3D""><div><blockquote type=3D"cite" class=3D""><div class=3D"">On =
Jan 20, 2019, at 4:07 PM, Mike Rapoport &lt;<a =
href=3D"mailto:rppt@linux.ibm.com" class=3D"">rppt@linux.ibm.com</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">Hi,</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">On Sat, Jan 12, 2019 at =
12:36:29AM +0000, Blake Caldwell wrote:</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D"">Moving a page out of a userfaultfd =
registered region and into a userland<br class=3D"">anonymous vma is =
needed by the use case of uncooperatively limiting the<br =
class=3D"">resident size of the userfaultfd region. Reverse the =
direction of the<br class=3D"">original userfaultfd_remap() to the out =
direction. Now after memory has<br class=3D"">been removed, subsequent =
accesses will generate uffdio page fault events.<br =
class=3D""></blockquote><br style=3D"caret-color: rgb(0, 0, 0); =
font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">It took me a while but better late then never =
:)</span></div></blockquote><blockquote type=3D"cite" class=3D""><div =
class=3D""><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><span style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none; float: none; display: inline !important;" class=3D"">Why did you =
keep this as a separate patch? If the primary use case for</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">UFFDIO_REMAP to move pages out =
of userfaultfd region, why not make it so</span><br style=3D"caret-color: =
rgb(0, 0, 0); font-family: Helvetica; font-size: 12px; font-style: =
normal; font-variant-caps: normal; font-weight: normal; letter-spacing: =
normal; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">from the beginning?</span><br style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""></div></blockquote><div><br =
class=3D""></div>Only to show what has changed since this was last =
proposed, but yes, that</div><div>change to fs/userfaultfd.c should be =
squashed with patch 3. The purpose of</div><div>patch 4 will only be =
documenting UFFDIO_REMAP.</div><div><br class=3D""></div><div>I will =
make those changes for the next revision. Thanks for looking this =
over.</div><div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D""><br style=3D"caret-color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;" class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto; =
-webkit-text-stroke-width: 0px; text-decoration: none;" =
class=3D"">Signed-off-by: Blake Caldwell &lt;<a =
href=3D"mailto:blake.caldwell@colorado.edu" =
class=3D"">blake.caldwell@colorado.edu</a>&gt;<br class=3D"">---<br =
class=3D"">Documentation/admin-guide/mm/userfaultfd.rst | 10 =
++++++++++<br class=3D"">fs/userfaultfd.c =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;| &nbsp;6 +++---<br class=3D"">2 files changed, 13 =
insertions(+), 3 deletions(-)<br class=3D""><br class=3D"">diff --git =
a/Documentation/admin-guide/mm/userfaultfd.rst =
b/Documentation/admin-guide/mm/userfaultfd.rst<br class=3D"">index =
5048cf6..714af49 100644<br class=3D"">--- =
a/Documentation/admin-guide/mm/userfaultfd.rst<br class=3D"">+++ =
b/Documentation/admin-guide/mm/userfaultfd.rst<br class=3D"">@@ -108,6 =
+108,16 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing =
can see an<br class=3D"">half copied page since it'll keep userfaulting =
until the copy has<br class=3D"">finished.<br class=3D""><br =
class=3D"">+To move pages out of a userfault registered region and into =
a user vma<br class=3D"">+the UFFDIO_REMAP ioctl can be used. This is =
only possible for the<br class=3D"">+"OUT" direction. For the "IN" =
direction, UFFDIO_COPY is preferred<br class=3D"">+since UFFDIO_REMAP =
requires a TLB flush on the source range at a<br class=3D"">+greater =
penalty than copying the page. With<br =
class=3D"">+UFFDIO_REGISTER_MODE_MISSING set, subsequent accesses to the =
same<br class=3D"">+region will generate a page fault event. This allows =
non-cooperative<br class=3D"">+removal of memory in a userfaultfd =
registered vma, effectively<br class=3D"">+limiting the amount of =
resident memory in such a region.<br class=3D"">+<br =
class=3D"">QEMU/KVM<br class=3D"">=3D=3D=3D=3D=3D=3D=3D=3D<br =
class=3D""><br class=3D"">diff --git a/fs/userfaultfd.c =
b/fs/userfaultfd.c<br class=3D"">index cf68cdb..8099da2 100644<br =
class=3D"">--- a/fs/userfaultfd.c<br class=3D"">+++ =
b/fs/userfaultfd.c<br class=3D"">@@ -1808,10 +1808,10 @@ static int =
userfaultfd_remap(struct userfaultfd_ctx *ctx,<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-converted-space">&nbsp;</span>&nbsp;&nbsp;sizeof(uffdio_rem=
ap)-sizeof(__s64)))<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span>goto out;<br class=3D""><br =
class=3D"">-<span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span>ret =3D validate_range(ctx-&gt;mm, uffdio_remap.dst, =
uffdio_remap.len);<br class=3D"">+<span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span>ret =3D =
validate_range(current-&gt;mm, uffdio_remap.dst, uffdio_remap.len);<br =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span>if (ret)<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span>goto out;<br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span>ret =3D =
validate_range(current-&gt;mm, uffdio_remap.src, uffdio_remap.len);<br =
class=3D"">+<span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span>ret =3D validate_range(ctx-&gt;mm, uffdio_remap.src, =
uffdio_remap.len);<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span>if (ret)<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span>goto =
out;<br class=3D""><span class=3D"Apple-tab-span" style=3D"white-space: =
pre;">	</span>ret =3D -EINVAL;<br class=3D"">@@ -1819,7 +1819,7 @@ =
static int userfaultfd_remap(struct userfaultfd_ctx *ctx,<br =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space: pre;">	=
</span><span =
class=3D"Apple-converted-space">&nbsp;</span>&nbsp;UFFDIO_REMAP_MODE_DONTW=
AKE))<br class=3D""><span class=3D"Apple-tab-span" style=3D"white-space: =
pre;">	</span><span class=3D"Apple-tab-span" style=3D"white-space: =
pre;">	</span>goto out;<br class=3D""><br class=3D"">-<span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span>ret =3D =
remap_pages(ctx-&gt;mm, current-&gt;mm,<br class=3D"">+<span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span>ret =3D =
remap_pages(current-&gt;mm, ctx-&gt;mm,<br class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space: pre;">	</span><span =
class=3D"Apple-converted-space">&nbsp;</span>&nbsp;uffdio_remap.dst, =
uffdio_remap.src,<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span><span =
class=3D"Apple-converted-space">&nbsp;</span>&nbsp;uffdio_remap.len, =
uffdio_remap.mode);<br class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space: pre;">	</span>if (unlikely(put_user(ret, =
&amp;user_uffdio_remap-&gt;remap)))<br class=3D"">--<span =
class=3D"Apple-converted-space">&nbsp;</span><br class=3D"">1.8.3.1<br =
class=3D""><br class=3D""></blockquote><br style=3D"caret-color: rgb(0, =
0, 0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none;" class=3D""><span style=3D"caret-color: rgb(0, 0, =
0); font-family: Helvetica; font-size: 12px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
text-decoration: none; float: none; display: inline !important;" =
class=3D"">--<span class=3D"Apple-converted-space">&nbsp;</span></span><br=
 style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" class=3D"">Sincerely yours,</span><br =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none;" class=3D""><span =
style=3D"caret-color: rgb(0, 0, 0); font-family: Helvetica; font-size: =
12px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; text-align: start; text-indent: 0px; =
text-transform: none; white-space: normal; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; text-decoration: none; float: none; =
display: inline !important;" =
class=3D"">Mike.</span></div></blockquote></div><br =
class=3D""></body></html>=

--Apple-Mail=_7EBEE743-E550-454D-8E83-825ED7FA06D5--
