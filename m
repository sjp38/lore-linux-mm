Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DCCEC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:26:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B82202171F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:26:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RRhMYeIA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B82202171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61FE26B0007; Thu,  8 Aug 2019 10:26:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D1096B0008; Thu,  8 Aug 2019 10:26:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 498A46B000A; Thu,  8 Aug 2019 10:26:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3A8B6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 10:26:34 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j10so2290435wrb.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 07:26:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fj4z8W6cdsh45vekjTO59hBeNsl3ptwt6rJ4Cmg/whI=;
        b=nSrexgC806wWmYpeDS9Ue9UdaRgNSn1C/a/cLehNBWjnYJ+NpjfZnnEr1LpzDUcIDy
         Nl8VnpTeh8DruY9HANXdD2+ZI2cOgJN0dCVGI08HhzVas54IvCQpIV+vGOmoxFX6j2wp
         6KXUKcYzLEmkYr+5RxeD6wNG7jYFoCOlx9UNB3lvYbxgLkAVQkD29avlJmt5pcfqjZ5O
         9r06hq75kj2GM64oYTYybq1vyhphSNu/jvpx1aX3H5VBRzTyg/F2wYeUMXwWpeJ8dlyC
         xz2TtSIf+RPakpH0LNZEf0dYG1HL4XqHKba+1l/UF/4h0ODs9RXda17qOT+zRbXXrOkj
         nrIA==
X-Gm-Message-State: APjAAAWopWStXlLoOoBZ3YHDDG1Ky11RysKgYBlkEqg4fAvDttIrKmyR
	U1Hllx/2f5n2loqRB+4i3pC0HJEAO/HDdAymQoVlmDdzV8cHVdlxeWRXjiVOI7bfpefiKOmaXEr
	3syASJa0ggBsSONINbOkZOK9jR6gvLmBb0hV3a8DGFtQg1xWfSXuSF1h1vNDZQwnCjw==
X-Received: by 2002:adf:cd81:: with SMTP id q1mr18014317wrj.16.1565274394488;
        Thu, 08 Aug 2019 07:26:34 -0700 (PDT)
X-Received: by 2002:adf:cd81:: with SMTP id q1mr18014174wrj.16.1565274393593;
        Thu, 08 Aug 2019 07:26:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565274393; cv=none;
        d=google.com; s=arc-20160816;
        b=daokLpItAw20TOXT1zySi6DYQD3uewTC7mlL1a5Ftv2f5/Yq0Xz2rozi9Ur5/jI7lh
         rzsBLpgtmEpCn5NcLGL5v3VTKCqRBNq6TQjRlpUV5+WO5DWQqq+Z0+xP0RWCLsQ62CIB
         W9dxVztT6YoNY0+lGWIYgY1p3cbUTVYDfKtl3m8qxaDZKzjW1vyZ2JQRefpWEwPsMMWf
         qK2O9goldRIL0AqTDAR52JRq5uNXLcRQ8u9/KCuyMefP1u4ptViaZXiWVzaz9Toz16Lk
         OCdJBPmjY6B2rhAG7h9FCeU25mINuEZBx64BPeKA4kkb6/1foX5NQBG6rZ8atWqJap+z
         IkgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fj4z8W6cdsh45vekjTO59hBeNsl3ptwt6rJ4Cmg/whI=;
        b=RwXz9DNaLO40j/bIWg6ex76wI2MAvG3M89zfrzNIX6msZZkBb/GOt+pZm8cCbzFRjZ
         tPihDfzKyOCmawXiwR0OrMm5BEtI1MgESRtvrdSddrj+Nyy3oioCOHbjxK30mCy6B+1I
         MFmXONZGbhcR4KT1npOAQzdxFtOxWDn1kJeZwudjtcq1xTiJf9OyuIlXqzM3vCS0vSd8
         kxsQMhyutW9dgiwAJrPyERLnKPOahOcTN0q7/TbUKW5IFfOiUYT0YCoKu4xjv7TTQHqi
         expMaIEg2FtVc/N1rv8r7w3AksrwRC74SKsW6Su1GugMrAgxWkvXP/Kk53KihVGQdEf/
         bUAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RRhMYeIA;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l6sor73528885wrm.27.2019.08.08.07.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 07:26:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RRhMYeIA;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fj4z8W6cdsh45vekjTO59hBeNsl3ptwt6rJ4Cmg/whI=;
        b=RRhMYeIA7cCQUcGs45JixmTtly34i8plV+jX6oGViZMW4eL2Ijzb1AzcvVEJggHCkM
         B/TP2QGUWVE9E5bYd4lyzrnf6B6MTxk/tB/T9h5v2ECCq+utUeNQbMSBIW2O+xWY4T29
         G8aIgsfuSNkjcEDWsSkJvLkBUVIR+F39sZlFvCPgOAFtGn+O9i7lonpqCbBMljV5eGwy
         r2DrKDVQ/8hhr4E43auR8B9PuN0Vml515UZP4VW9Q4UEaa4cInjOo2snNLRahUyBlcHy
         CfFitbZ8HKj7EDAbpBzLzpIKRib/oEDwr0j3LC83Ij2YojhZfbQenOo6Pk6AYYAg6wcb
         7/Ww==
X-Google-Smtp-Source: APXvYqz8UZ005WObjnpvvUlwMyJ+M+pW0lN58RILDMrzqJs48bBb4psl0QdHA4tRVfPepBkzMTIl6iz4vtMFsvd3YHU=
X-Received: by 2002:adf:f94a:: with SMTP id q10mr16172298wrr.341.1565274393148;
 Thu, 08 Aug 2019 07:26:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190806014830.7424-1-hdanton@sina.com> <CABXGCsMRGRpd9AoJdvZqdpqCP3QzVGzfDPiX=PzVys6QFBLAvA@mail.gmail.com>
 <CADnq5_O08v3_NUZ_zUZJFYwv_tUY7TFFz2GGudqgWEX6nh5LFA@mail.gmail.com> <6d5110ab-6539-378d-f643-0a1d4cf0ff73@daenzer.net>
In-Reply-To: <6d5110ab-6539-378d-f643-0a1d4cf0ff73@daenzer.net>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Thu, 8 Aug 2019 10:26:20 -0400
Message-ID: <CADnq5_P=gtz_8vNyV7At73PngbNS_-cyAnpd3aKGPUFyrK64EA@mail.gmail.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
To: =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel@daenzer.net>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Hillf Danton <hdanton@sina.com>, 
	Dave Airlie <airlied@gmail.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, Harry Wentland <harry.wentland@amd.com>, 
	"Koenig, Christian" <Christian.Koenig@amd.com>
Content-Type: multipart/mixed; boundary="0000000000002e1b8c058f9bd85e"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000002e1b8c058f9bd85e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 8, 2019 at 4:13 AM Michel D=C3=A4nzer <michel@daenzer.net> wrot=
e:
>
> On 2019-08-08 7:31 a.m., Alex Deucher wrote:
> > On Wed, Aug 7, 2019 at 11:49 PM Mikhail Gavrilov
> > <mikhail.v.gavrilov@gmail.com> wrote:
> >>
> >> Unfortunately error "gnome-shell: page allocation failure: order:4,
> >> mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> >> nodemask=3D(null),cpuset=3D/,mems_allowed=3D0" still happens even with
> >> applying this patch.
> >
> > I think we can just drop the kmalloc altogether.  How about this patch?
>
> Memory allocated by kvz/malloc needs to be freed with kvfree.
>

Yup, good catch.  Updated patch attached.

Alex

--0000000000002e1b8c058f9bd85e
Content-Type: text/x-patch; charset="US-ASCII"; 
	name="0001-drm-amd-display-use-kvmalloc-for-dc_state-v2.patch"
Content-Disposition: attachment; 
	filename="0001-drm-amd-display-use-kvmalloc-for-dc_state-v2.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jz2ry4ps0>
X-Attachment-Id: f_jz2ry4ps0

RnJvbSA1YzI3YzI1Y2U3OWFjMmIxOGEzN2JjZDdkYzZmYTBiZDNkODczM2QzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbGV4IERldWNoZXIgPGFsZXhhbmRlci5kZXVjaGVyQGFtZC5j
b20+CkRhdGU6IFRodSwgOCBBdWcgMjAxOSAwMDoyOToyMyAtMDUwMApTdWJqZWN0OiBbUEFUQ0hd
IGRybS9hbWQvZGlzcGxheTogdXNlIGt2bWFsbG9jIGZvciBkY19zdGF0ZSAodjIpCgpJdCdzIGxh
cmdlIGFuZCBkb2Vzbid0IG5lZWQgY29udGlndW91cyBtZW1vcnkuCgp2Mjoga3ZmcmVlIHRoZSBt
ZW1vcnkuCgpTaWduZWQtb2ZmLWJ5OiBBbGV4IERldWNoZXIgPGFsZXhhbmRlci5kZXVjaGVyQGFt
ZC5jb20+Ci0tLQogZHJpdmVycy9ncHUvZHJtL2FtZC9kaXNwbGF5L2RjL2NvcmUvZGMuYyB8IDEx
ICsrKysrKy0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCA1IGRlbGV0aW9u
cygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvZGlzcGxheS9kYy9jb3JlL2Rj
LmMgYi9kcml2ZXJzL2dwdS9kcm0vYW1kL2Rpc3BsYXkvZGMvY29yZS9kYy5jCmluZGV4IDI1MmI2
MjFkOTNhOS4uMjFmYjdlZTE3YzljIDEwMDY0NAotLS0gYS9kcml2ZXJzL2dwdS9kcm0vYW1kL2Rp
c3BsYXkvZGMvY29yZS9kYy5jCisrKyBiL2RyaXZlcnMvZ3B1L2RybS9hbWQvZGlzcGxheS9kYy9j
b3JlL2RjLmMKQEAgLTIzLDYgKzIzLDcgQEAKICAqLwogCiAjaW5jbHVkZSA8bGludXgvc2xhYi5o
PgorI2luY2x1ZGUgPGxpbnV4L21tLmg+CiAKICNpbmNsdWRlICJkbV9zZXJ2aWNlcy5oIgogCkBA
IC0xMTgzLDggKzExODQsOCBAQCBib29sIGRjX3Bvc3RfdXBkYXRlX3N1cmZhY2VzX3RvX3N0cmVh
bShzdHJ1Y3QgZGMgKmRjKQogCiBzdHJ1Y3QgZGNfc3RhdGUgKmRjX2NyZWF0ZV9zdGF0ZShzdHJ1
Y3QgZGMgKmRjKQogewotCXN0cnVjdCBkY19zdGF0ZSAqY29udGV4dCA9IGt6YWxsb2Moc2l6ZW9m
KHN0cnVjdCBkY19zdGF0ZSksCi0JCQkJCSAgIEdGUF9LRVJORUwpOworCXN0cnVjdCBkY19zdGF0
ZSAqY29udGV4dCA9IGt2emFsbG9jKHNpemVvZihzdHJ1Y3QgZGNfc3RhdGUpLAorCQkJCQkgICAg
R0ZQX0tFUk5FTCk7CiAKIAlpZiAoIWNvbnRleHQpCiAJCXJldHVybiBOVUxMOwpAQCAtMTIwNCwx
MSArMTIwNSwxMSBAQCBzdHJ1Y3QgZGNfc3RhdGUgKmRjX2NyZWF0ZV9zdGF0ZShzdHJ1Y3QgZGMg
KmRjKQogc3RydWN0IGRjX3N0YXRlICpkY19jb3B5X3N0YXRlKHN0cnVjdCBkY19zdGF0ZSAqc3Jj
X2N0eCkKIHsKIAlpbnQgaSwgajsKLQlzdHJ1Y3QgZGNfc3RhdGUgKm5ld19jdHggPSBrbWVtZHVw
KHNyY19jdHgsCi0JCQlzaXplb2Yoc3RydWN0IGRjX3N0YXRlKSwgR0ZQX0tFUk5FTCk7CisJc3Ry
dWN0IGRjX3N0YXRlICpuZXdfY3R4ID0ga3ZtYWxsb2Moc2l6ZW9mKHN0cnVjdCBkY19zdGF0ZSks
IEdGUF9LRVJORUwpOwogCiAJaWYgKCFuZXdfY3R4KQogCQlyZXR1cm4gTlVMTDsKKwltZW1jcHko
bmV3X2N0eCwgc3JjX2N0eCwgc2l6ZW9mKHN0cnVjdCBkY19zdGF0ZSkpOwogCiAJZm9yIChpID0g
MDsgaSA8IE1BWF9QSVBFUzsgaSsrKSB7CiAJCQlzdHJ1Y3QgcGlwZV9jdHggKmN1cl9waXBlID0g
Jm5ld19jdHgtPnJlc19jdHgucGlwZV9jdHhbaV07CkBAIC0xMjQyLDcgKzEyNDMsNyBAQCBzdGF0
aWMgdm9pZCBkY19zdGF0ZV9mcmVlKHN0cnVjdCBrcmVmICprcmVmKQogewogCXN0cnVjdCBkY19z
dGF0ZSAqY29udGV4dCA9IGNvbnRhaW5lcl9vZihrcmVmLCBzdHJ1Y3QgZGNfc3RhdGUsIHJlZmNv
dW50KTsKIAlkY19yZXNvdXJjZV9zdGF0ZV9kZXN0cnVjdChjb250ZXh0KTsKLQlrZnJlZShjb250
ZXh0KTsKKwlrdmZyZWUoY29udGV4dCk7CiB9CiAKIHZvaWQgZGNfcmVsZWFzZV9zdGF0ZShzdHJ1
Y3QgZGNfc3RhdGUgKmNvbnRleHQpCi0tIAoyLjIwLjEKCg==
--0000000000002e1b8c058f9bd85e--

