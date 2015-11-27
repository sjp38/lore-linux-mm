Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8716B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:26:30 -0500 (EST)
Received: by lfdl133 with SMTP id l133so122086004lfd.2
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:26:29 -0800 (PST)
Received: from mail-lf0-x233.google.com (mail-lf0-x233.google.com. [2a00:1450:4010:c07::233])
        by mx.google.com with ESMTPS id uf10si20946980lbc.83.2015.11.27.01.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 01:26:28 -0800 (PST)
Received: by lfs39 with SMTP id 39so119979577lfs.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:26:28 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 27 Nov 2015 14:56:28 +0530
Message-ID: <CAB5gotttiJgbdCYV7GxeHqLoH4iekM+QU99kKZqj=M86XEY_7A@mail.gmail.com>
Subject: handling oz_ep_alloc() failure
From: Vaibhav Shinde <v.bhav.shinde@gmail.com>
Content-Type: multipart/alternative; boundary=001a11401b2e3f346605258249c7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--001a11401b2e3f346605258249c7
Content-Type: text/plain; charset=UTF-8

I got a failure for allocation of order 3 pages from oz_ep_alloc() function
under low memory situation, so while checking the code came across this
call for oz_ep_alloc() which may not be handled gracefully.
So do we need to have the below check ?

$ git diff
diff --git a/drivers/staging/ozwpan/ozhcd.c b/drivers/staging/ozwpan/ozhcd.c
index 565d873..867c3eb 100644
--- a/drivers/staging/ozwpan/ozhcd.c
+++ b/drivers/staging/ozwpan/ozhcd.c
@@ -722,6 +722,8 @@ void *oz_hcd_pd_arrived(void *hpd)
         * use for out endpoint 0.
         */
        ep = oz_ep_alloc(GFP_ATOMIC, 0);
+       if(!ep)
+               goto out;
        spin_lock_bh(&ozhcd->hcd_lock);
        if (ozhcd->conn_port >= 0) {
                spin_unlock_bh(&ozhcd->hcd_lock);

--001a11401b2e3f346605258249c7
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><span></span>I got a failure for allocation of order =
3 pages from oz_ep_alloc() function under low memory situation, so while ch=
ecking the code came across this call for oz_ep_alloc() which may not be ha=
ndled gracefully.<br>So do we need to have the below check ?<br><br>$ git d=
iff<br>diff --git a/drivers/staging/ozwpan/ozhcd.c b/drivers/staging/ozwpan=
/ozhcd.c<br>index 565d873..867c3eb 100644<br>--- a/drivers/staging/ozwpan/o=
zhcd.c<br>+++ b/drivers/staging/ozwpan/ozhcd.c<br>@@ -722,6 +722,8 @@ void =
*oz_hcd_pd_arrived(void *hpd)<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* use fo=
r out endpoint 0.<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 ep =3D oz_ep_alloc(GFP_ATOMIC, 0);<br>+ =C2=A0 =C2=A0 =C2=A0 =
if(!ep)<br>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_bh(&amp;ozhcd-&gt;hcd_lock);<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 if (ozhcd-&gt;conn_port &gt;=3D 0) {<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_bh(&amp;ozhcd-&gt=
;hcd_lock);<br></div></div>

--001a11401b2e3f346605258249c7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
