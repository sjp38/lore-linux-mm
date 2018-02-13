Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 216C86B0005
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 17:17:36 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j3so9845426pld.0
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:17:36 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c2-v6si320768plb.439.2018.02.13.14.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 14:17:34 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1DM762K045681
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 22:17:32 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2g47uf89te-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 22:17:32 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1DMHVXO017658
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 22:17:32 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1DMHVR8032011
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 22:17:31 GMT
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Content-Type: multipart/alternative;
 boundary="Apple-Mail=_D41F1BDE-9F21-4024-A123-106AC5A24843"
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Filesystem write pages going directly to Active
Message-Id: <74626D68-D9FC-470A-9694-C2DB1D771BD2@oracle.com>
Date: Tue, 13 Feb 2018 14:17:25 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--Apple-Mail=_D41F1BDE-9F21-4024-A123-106AC5A24843
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

Hi Folks,

It is my understanding that pages always begin life on the Inactive LRU =
list and are=20
only promoted to the Active list after they have been referenced a =
second time. It was=20
recently called to my attention that this is not the case for writes.

I checked and sure enough, filesystem writes go straight to Active in =
the 4.x kernel
until that behavior was =E2=80=9Cfixed=E2=80=9D in 4.7 (see commit =
below). As far as I can tell, this
bug was fixed on accident.

I tested kernels going back to 3.16.53, and they all have this behavior. =
I just want
to make sure ... does everyone agree this was a bug?

=E2=80=94Buddy



[buddy@buddy-test linux]$ git log -p -1 =
bbddabe2e436aa7869b3ac5248df5c14ddde0cbf
commit bbddabe2e436aa7869b3ac5248df5c14ddde0cbf
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Fri May 20 16:56:28 2016 -0700

    mm: filemap: only do access activations on reads
   =20
    Andres observed that his database workload is struggling with the
    transaction journal creating pressure on frequently read pages.
   =20
    Access patterns like transaction journals frequently write the same
    pages over and over, but in the majority of cases those pages are =
never
    read back.  There are no caching benefits to be had for those pages, =
so
    activating them and having them put pressure on pages that do =
benefit
    from caching is a bad choice.
   =20
    Leave page activations to read accesses and don't promote pages =
based on
    writes alone.
   =20
    It could be said that partially written pages do contain =
cache-worthy
    data, because even if *userspace* does not access the unwritten =
part,
    the kernel still has to read it from the filesystem for correctness.
    However, a counter argument is that these pages enjoy at least =
*some*
    protection over other inactive file pages through the writeback =
cache,
    in the sense that dirty pages are written back with a delay and =
cache
    reclaim leaves them alone until they have been written back to disk.
    Should that turn out to be insufficient and we see increased read IO
    from partial writes under memory pressure, we can always go back and
    update grab_cache_page_write_begin() to take (pos, len) so that it =
can
    tell partial writes from pages that don't need partial reads.  But =
for
    now, keep it simple.
   =20
    Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
    Reported-by: Andres Freund <andres@anarazel.de>
    Cc: Rik van Riel <riel@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/mm/filemap.c b/mm/filemap.c
index beba6bd..8f48599 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2578,7 +2578,7 @@ struct page *grab_cache_page_write_begin(struct =
address_space *mapping,
                                        pgoff_t index, unsigned flags)
 {
        struct page *page;
-       int fgp_flags =3D FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;
+       int fgp_flags =3D FGP_LOCK|FGP_WRITE|FGP_CREAT;
=20
        if (flags & AOP_FLAG_NOFS)
                fgp_flags |=3D FGP_NOFS;


--Apple-Mail=_D41F1BDE-9F21-4024-A123-106AC5A24843
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D"">Hi Folks,</div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><br class=3D""></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D"">It is my understanding =
that pages always begin life on the Inactive LRU list and =
are&nbsp;</div><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D"">only promoted to the Active list after they have been =
referenced a second time. It was&nbsp;</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D"">recently called to my =
attention that this is not the case for writes.</div><div style=3D"margin:=
 0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><br =
class=3D""></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D"">I checked and sure enough, filesystem writes go =
straight to Active in the 4.x kernel</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D"">until that behavior =
was =E2=80=9Cfixed=E2=80=9D in 4.7 (see commit below). As far as I can =
tell, this</div><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D"">bug was fixed on accident.</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><br =
class=3D""></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D"">I tested kernels going back to 3.16.53, and they all =
have this behavior. I just want</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D"">to make sure ... does =
everyone agree this was a bug?</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><br =
class=3D""></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D"">=E2=80=94Buddy</div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><br =
class=3D""></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><br class=3D""></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D""><br =
class=3D""></span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">[buddy@buddy-test linux]$ git log -p -1 =
bbddabe2e436aa7869b3ac5248df5c14ddde0cbf</span></div><div style=3D"margin:=
 0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">commit =
bbddabe2e436aa7869b3ac5248df5c14ddde0cbf</span></div><div style=3D"margin:=
 0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">Author: =
Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org" =
class=3D"">hannes@cmpxchg.org</a>&gt;</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">Date: =
&nbsp; Fri May 20 16:56:28 2016 -0700</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255); min-height: 13px;" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D""></span><br class=3D""></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; mm: filemap: only do access activations on reads</span></div><p =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255); min-height: 13px;" =
class=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp;&nbsp; &nbsp;</span><br =
class=3D"webkit-block-placeholder"></p><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Andres observed that his database workload is struggling with =
the</span></div><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp; &nbsp; transaction journal creating pressure on =
frequently read pages.</span></div><p style=3D"margin: 0px; font-size: =
11px; line-height: normal; font-family: Menlo; background-color: =
rgb(255, 255, 255); min-height: 13px;" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp;&nbsp; &nbsp;</span><br =
class=3D"webkit-block-placeholder"></p><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Access patterns like transaction journals frequently write the =
same</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; pages over and over, but =
in the majority of cases those pages are never</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; read back.&nbsp; There are no caching benefits to be had for =
those pages, so</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; activating them and having =
them put pressure on pages that do benefit</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; from caching is a bad choice.</span></div><p style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255); min-height: 13px;" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp;&nbsp; &nbsp;</span><br =
class=3D"webkit-block-placeholder"></p><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Leave page activations to read accesses and don't promote pages =
based on</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; writes =
alone.</span></div><p style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255); min-height: 13px;" class=3D""><span style=3D"font-variant-ligatures:=
 no-common-ligatures" class=3D"">&nbsp;&nbsp; &nbsp;</span><br =
class=3D"webkit-block-placeholder"></p><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; It could be said that partially written pages do contain =
cache-worthy</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; data, because even if =
*userspace* does not access the unwritten part,</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; the kernel still has to read it from the filesystem for =
correctness.</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; However, a counter =
argument is that these pages enjoy at least *some*</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; protection over other inactive file pages through the writeback =
cache,</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; in the sense that dirty =
pages are written back with a delay and cache</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; reclaim leaves them alone until they have been written back to =
disk.</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; Should that turn out to be =
insufficient and we see increased read IO</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; from partial writes under memory pressure, we can always go back =
and</span></div><div style=3D"margin: 0px; font-size: 11px; line-height: =
normal; font-family: Menlo; background-color: rgb(255, 255, 255);" =
class=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp; &nbsp; update grab_cache_page_write_begin() to take =
(pos, len) so that it can</span></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; tell partial writes from pages that don't need partial =
reads.&nbsp; But for</span></div><div style=3D"margin: 0px; font-size: =
11px; line-height: normal; font-family: Menlo; background-color: =
rgb(255, 255, 255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp; &nbsp; now, keep it =
simple.</span></div><p style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255); min-height: 13px;" class=3D""><span style=3D"font-variant-ligatures:=
 no-common-ligatures" class=3D"">&nbsp;&nbsp; &nbsp;</span><br =
class=3D"webkit-block-placeholder"></p><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Signed-off-by: Johannes Weiner &lt;<a =
href=3D"mailto:hannes@cmpxchg.org" =
class=3D"">hannes@cmpxchg.org</a>&gt;</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Reported-by: Andres Freund &lt;<a =
href=3D"mailto:andres@anarazel.de" =
class=3D"">andres@anarazel.de</a>&gt;</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Cc: Rik van Riel &lt;<a href=3D"mailto:riel@redhat.com" =
class=3D"">riel@redhat.com</a>&gt;</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Signed-off-by: Andrew Morton &lt;<a =
href=3D"mailto:akpm@linux-foundation.org" =
class=3D"">akpm@linux-foundation.org</a>&gt;</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; Signed-off-by: Linus Torvalds &lt;<a =
href=3D"mailto:torvalds@linux-foundation.org" =
class=3D"">torvalds@linux-foundation.org</a>&gt;</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255); min-height: 13px;" =
class=3D""><span style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D""></span><br class=3D""></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">diff =
--git a/mm/filemap.c b/mm/filemap.c</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">index =
beba6bd..8f48599 100644</span></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">--- =
a/mm/filemap.c</span></div><div style=3D"margin: 0px; font-size: 11px; =
line-height: normal; font-family: Menlo; background-color: rgb(255, 255, =
255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">+++ b/mm/filemap.c</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">@@ =
-2578,7 +2578,7 @@ struct page *grab_cache_page_write_begin(struct =
address_space *mapping,</span></div><div style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pgoff_t =
index, unsigned flags)</span></div><div style=3D"margin: 0px; font-size: =
11px; line-height: normal; font-family: Menlo; background-color: =
rgb(255, 255, 255);" class=3D""><span style=3D"font-variant-ligatures: =
no-common-ligatures" class=3D"">&nbsp;{</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; struct page *page;</span></div><div style=3D"margin: =
0px; font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">- =
&nbsp; &nbsp; &nbsp; int fgp_flags =3D =
FGP_LOCK|FGP_ACCESSED|FGP_WRITE|FGP_CREAT;</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">+ =
&nbsp; &nbsp; &nbsp; int fgp_flags =3D =
FGP_LOCK|FGP_WRITE|FGP_CREAT;</span></div><p style=3D"margin: 0px; =
font-size: 11px; line-height: normal; font-family: Menlo; =
background-color: rgb(255, 255, 255); min-height: 13px;" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" =
class=3D"">&nbsp;</span><br class=3D"webkit-block-placeholder"></p><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; if (flags &amp; AOP_FLAG_NOFS)</span></div><div =
style=3D"margin: 0px; font-size: 11px; line-height: normal; font-family: =
Menlo; background-color: rgb(255, 255, 255);" class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; fgp_flags |=3D =
FGP_NOFS;</span></div><div class=3D""><span =
style=3D"font-variant-ligatures: no-common-ligatures" class=3D""><br =
class=3D""></span></div><div dir=3D"auto" style=3D"word-wrap: =
break-word; -webkit-nbsp-mode: space; -webkit-line-break: =
after-white-space;" class=3D""></div>
</body></html>=

--Apple-Mail=_D41F1BDE-9F21-4024-A123-106AC5A24843--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
