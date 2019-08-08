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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B43AAC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:32:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39BF7217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:32:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bd/6MShz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39BF7217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 961A26B0003; Thu,  8 Aug 2019 01:32:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90FD46B0006; Thu,  8 Aug 2019 01:32:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF7B6B0007; Thu,  8 Aug 2019 01:32:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 304FF6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 01:32:04 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id k10so1886841wru.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 22:32:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VnFHzRjF2xpQkvpgxIv833AGZ8y7ivoh6PhkIV/Ft14=;
        b=SwZC/jL/gR6JhtYW+xl/6MOZw7f/qm59DMzunyw3jNr0vI9WQE4VmiPLZZ0CroPrT1
         Jmwyn6JKXc5k9XDnm34CV/QKZX/vHtXbSg2jfNCGsMDk+KHelNdGLS8b5CKR/tPTr+yu
         36R9r/xk+BfKHrgmgHPptHgbVnWvIQ/OefbYW/BiPSKT9QpE1qUNUzAM9n+4oS8ei30D
         VLJftZn8xGticSw+CLRsxd2Zdr45s2va4w6decqzTDZITvxTe0bTakmVcBeamtZvKay6
         bKj9K96kTQPXvRirafv/y4A8vAReJ6qS8J4o4gpeOXAvoInH92PBblHAEjfaqwwztX32
         2LtQ==
X-Gm-Message-State: APjAAAUmzG16mLc8/KsLDkzxkwcGQpg+DHOgFpb6pbT1UOMDzbONQi0i
	Z55yC5Z1rWsfKMb+JnGfE6SdQnbuEou8+hkB8vbuU6wktrHqQ0jAHketyqBneLbTsjpCRNa3V7I
	S4Ry221JNI1Jztu8xXUy64G92AGf04ye70PAyVX7rR5malUkVjtAB1kZSogpVX+i1ig==
X-Received: by 2002:adf:f008:: with SMTP id j8mr57480wro.129.1565242323607;
        Wed, 07 Aug 2019 22:32:03 -0700 (PDT)
X-Received: by 2002:adf:f008:: with SMTP id j8mr57384wro.129.1565242322479;
        Wed, 07 Aug 2019 22:32:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565242322; cv=none;
        d=google.com; s=arc-20160816;
        b=fzJhs4Jex1xxEKCrHaNaeLSqxFDXzMPNVIHGTay+ldV5D5NvgiNPxuGU0C5T3UBBZy
         dQCKzhHVtA2zCJMXeTMkaUZ+4HnmEeDgtb5bpShq357hxGPLKch42C9gnjrWXX/Xy0RC
         TIb7M5ZXg9ao93ksSGBSoG1SR0zWMV9c+J2IP+0PaxbCFKjAtu7POB3cvxti8RJDOQR8
         TMNN0uNmhhFesQ50n6ybrNSFxffs1uATL71hX8QxcziOEStckz4Isz9flHeGLWF/7nir
         DNwMnrQitcQzFrKFTeA86CzvR2Sfwdax+q3dFKSK2gMRPu3rMxXU72I72cdgc59TESKK
         lfQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VnFHzRjF2xpQkvpgxIv833AGZ8y7ivoh6PhkIV/Ft14=;
        b=oLJGxZ8WtNlJtaEFWgOV1yG15fHyhYcj8bNrWCW+eDJZGa9HRSstQ8k8aVtjw0waM0
         MIZ1nKC8PhdYHtgKmZPN/wiRkZQKEQXNG7J33z43hPPiD3YhmZjvfHepyrQ/hIPzbX1t
         goszh5suO1BtjYyenOK9yrFGqcj9yCxadyRss8hM6FpYLoZfH3QmF/gAkDv4B9hOoIlI
         iweYSpszQajKPjaawvs+g0QMdTCwzzyLqjbW5JgJo8/1EvyUCIvtfznF54skUhMzNt1J
         ezDwesOWQRx+8GTb+Tn4hbGBhfGeCmuEmB8WWt4GV0yYYDOPFAH1DVLBCOWE7bx3alO9
         3MsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bd/6MShz";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i126sor736765wmg.5.2019.08.07.22.32.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 22:32:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bd/6MShz";
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VnFHzRjF2xpQkvpgxIv833AGZ8y7ivoh6PhkIV/Ft14=;
        b=bd/6MShzzpiecQAhFBAuSWXr5ibrQqhz9pYZ4qECaGNwmne2qCZAuyO20gkWEm7Alt
         9R2w4z9i3gomswnz8J3IcEq4kvirvItHH6XoRzIayj07nB1imdDu236PAuvOq43GY3J6
         jpYQs11Tn6g4wVWexHUCg7mZx+8eDqlTJZx5CU+DMqN7Imsf4d5LjGXcNvco/H2p/EW4
         6mbZCbXj6mmGIy5LwnHlxNCQmv2qVfLJQv8MY7z9e40453R5C0lqqnUK+KhJPPni4q9j
         cTFnBTQs9zY+GTiDq8qFKYo8rMVaG2lWHSCyQEufd+AiKI1TEDwEVoETgJuob4BMl5k+
         D2YQ==
X-Google-Smtp-Source: APXvYqzW+HFnOuJ9Z79OuqJC6DbO9RKLaFVy/c8lavnL0WaspOeHTZHPqSe3R46tKRBIfsisfMpapeNQUHITCyKt2KM=
X-Received: by 2002:a7b:c751:: with SMTP id w17mr2011547wmk.127.1565242322005;
 Wed, 07 Aug 2019 22:32:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190806014830.7424-1-hdanton@sina.com> <CABXGCsMRGRpd9AoJdvZqdpqCP3QzVGzfDPiX=PzVys6QFBLAvA@mail.gmail.com>
In-Reply-To: <CABXGCsMRGRpd9AoJdvZqdpqCP3QzVGzfDPiX=PzVys6QFBLAvA@mail.gmail.com>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Thu, 8 Aug 2019 01:31:50 -0400
Message-ID: <CADnq5_O08v3_NUZ_zUZJFYwv_tUY7TFFz2GGudqgWEX6nh5LFA@mail.gmail.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Hillf Danton <hdanton@sina.com>, Dave Airlie <airlied@gmail.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, Harry Wentland <harry.wentland@amd.com>, 
	"Koenig, Christian" <Christian.Koenig@amd.com>
Content-Type: multipart/mixed; boundary="00000000000097c52f058f94601e"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000097c52f058f94601e
Content-Type: text/plain; charset="UTF-8"

On Wed, Aug 7, 2019 at 11:49 PM Mikhail Gavrilov
<mikhail.v.gavrilov@gmail.com> wrote:
>
> On Tue, 6 Aug 2019 at 06:48, Hillf Danton <hdanton@sina.com> wrote:
> >
> > My bad, respin with one header file added.
> >
> > Hillf
> > -----8<---
> >
> > --- a/drivers/gpu/drm/amd/display/dc/core/dc.c
> > +++ b/drivers/gpu/drm/amd/display/dc/core/dc.c
> > @@ -23,6 +23,7 @@
> >   */
> >
> >  #include <linux/slab.h>
> > +#include <linux/mm.h>
> >
> >  #include "dm_services.h"
> >
> > @@ -1174,8 +1175,12 @@ struct dc_state *dc_create_state(struct
> >         struct dc_state *context = kzalloc(sizeof(struct dc_state),
> >                                            GFP_KERNEL);
> >
> > -       if (!context)
> > -               return NULL;
> > +       if (!context) {
> > +               context = kvzalloc(sizeof(struct dc_state),
> > +                                          GFP_KERNEL);
> > +               if (!context)
> > +                       return NULL;
> > +       }
> >         /* Each context must have their own instance of VBA and in order to
> >          * initialize and obtain IP and SOC the base DML instance from DC is
> >          * initially copied into every context
> > @@ -1195,8 +1200,13 @@ struct dc_state *dc_copy_state(struct dc
> >         struct dc_state *new_ctx = kmemdup(src_ctx,
> >                         sizeof(struct dc_state), GFP_KERNEL);
> >
> > -       if (!new_ctx)
> > -               return NULL;
> > +       if (!new_ctx) {
> > +               new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
> > +               if (new_ctx)
> > +                       *new_ctx = *src_ctx;
> > +               else
> > +                       return NULL;
> > +       }
> >
> >         for (i = 0; i < MAX_PIPES; i++) {
> >                         struct pipe_ctx *cur_pipe = &new_ctx->res_ctx.pipe_ctx[i];
> > @@ -1230,7 +1240,7 @@ static void dc_state_free(struct kref *k
> >  {
> >         struct dc_state *context = container_of(kref, struct dc_state, refcount);
> >         dc_resource_state_destruct(context);
> > -       kfree(context);
> > +       kvfree(context);
> >  }
> >
> >  void dc_release_state(struct dc_state *context)
> > --
> >
>
> Unfortunately error "gnome-shell: page allocation failure: order:4,
> mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
> nodemask=(null),cpuset=/,mems_allowed=0" still happens even with
> applying this patch.

I think we can just drop the kmalloc altogether.  How about this patch?

Alex

>
> Thanks.
>
>
> --
> Best Regards,
> Mike Gavrilov.
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx

--00000000000097c52f058f94601e
Content-Type: text/x-patch; charset="US-ASCII"; 
	name="0001-drm-amd-display-use-kvmalloc-for-dc_state.patch"
Content-Disposition: attachment; 
	filename="0001-drm-amd-display-use-kvmalloc-for-dc_state.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jz28unhl0>
X-Attachment-Id: f_jz28unhl0

RnJvbSBjM2JhNmYwNWNhM2UwMzcxMjU0ZmJmYjFhOGMwNjI3NGUzY2RiOTZlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbGV4IERldWNoZXIgPGFsZXhhbmRlci5kZXVjaGVyQGFtZC5j
b20+CkRhdGU6IFRodSwgOCBBdWcgMjAxOSAwMDoyOToyMyAtMDUwMApTdWJqZWN0OiBbUEFUQ0hd
IGRybS9hbWQvZGlzcGxheTogdXNlIGt2bWFsbG9jIGZvciBkY19zdGF0ZQoKSXQncyBsYXJnZSBh
bmQgZG9lc24ndCBuZWVkIGNvbnRpZ3VvdXMgbWVtb3J5LgoKU2lnbmVkLW9mZi1ieTogQWxleCBE
ZXVjaGVyIDxhbGV4YW5kZXIuZGV1Y2hlckBhbWQuY29tPgotLS0KIGRyaXZlcnMvZ3B1L2RybS9h
bWQvZGlzcGxheS9kYy9jb3JlL2RjLmMgfCA5ICsrKysrLS0tLQogMSBmaWxlIGNoYW5nZWQsIDUg
aW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9k
cm0vYW1kL2Rpc3BsYXkvZGMvY29yZS9kYy5jIGIvZHJpdmVycy9ncHUvZHJtL2FtZC9kaXNwbGF5
L2RjL2NvcmUvZGMuYwppbmRleCAyNTJiNjIxZDkzYTkuLmVmNzgwYTRlNDg0YSAxMDA2NDQKLS0t
IGEvZHJpdmVycy9ncHUvZHJtL2FtZC9kaXNwbGF5L2RjL2NvcmUvZGMuYworKysgYi9kcml2ZXJz
L2dwdS9kcm0vYW1kL2Rpc3BsYXkvZGMvY29yZS9kYy5jCkBAIC0yMyw2ICsyMyw3IEBACiAgKi8K
IAogI2luY2x1ZGUgPGxpbnV4L3NsYWIuaD4KKyNpbmNsdWRlIDxsaW51eC9tbS5oPgogCiAjaW5j
bHVkZSAiZG1fc2VydmljZXMuaCIKIApAQCAtMTE4Myw4ICsxMTg0LDggQEAgYm9vbCBkY19wb3N0
X3VwZGF0ZV9zdXJmYWNlc190b19zdHJlYW0oc3RydWN0IGRjICpkYykKIAogc3RydWN0IGRjX3N0
YXRlICpkY19jcmVhdGVfc3RhdGUoc3RydWN0IGRjICpkYykKIHsKLQlzdHJ1Y3QgZGNfc3RhdGUg
KmNvbnRleHQgPSBremFsbG9jKHNpemVvZihzdHJ1Y3QgZGNfc3RhdGUpLAotCQkJCQkgICBHRlBf
S0VSTkVMKTsKKwlzdHJ1Y3QgZGNfc3RhdGUgKmNvbnRleHQgPSBrdnphbGxvYyhzaXplb2Yoc3Ry
dWN0IGRjX3N0YXRlKSwKKwkJCQkJICAgIEdGUF9LRVJORUwpOwogCiAJaWYgKCFjb250ZXh0KQog
CQlyZXR1cm4gTlVMTDsKQEAgLTEyMDQsMTEgKzEyMDUsMTEgQEAgc3RydWN0IGRjX3N0YXRlICpk
Y19jcmVhdGVfc3RhdGUoc3RydWN0IGRjICpkYykKIHN0cnVjdCBkY19zdGF0ZSAqZGNfY29weV9z
dGF0ZShzdHJ1Y3QgZGNfc3RhdGUgKnNyY19jdHgpCiB7CiAJaW50IGksIGo7Ci0Jc3RydWN0IGRj
X3N0YXRlICpuZXdfY3R4ID0ga21lbWR1cChzcmNfY3R4LAotCQkJc2l6ZW9mKHN0cnVjdCBkY19z
dGF0ZSksIEdGUF9LRVJORUwpOworCXN0cnVjdCBkY19zdGF0ZSAqbmV3X2N0eCA9IGt2bWFsbG9j
KHNpemVvZihzdHJ1Y3QgZGNfc3RhdGUpLCBHRlBfS0VSTkVMKTsKIAogCWlmICghbmV3X2N0eCkK
IAkJcmV0dXJuIE5VTEw7CisJbWVtY3B5KG5ld19jdHgsIHNyY19jdHgsIHNpemVvZihzdHJ1Y3Qg
ZGNfc3RhdGUpKTsKIAogCWZvciAoaSA9IDA7IGkgPCBNQVhfUElQRVM7IGkrKykgewogCQkJc3Ry
dWN0IHBpcGVfY3R4ICpjdXJfcGlwZSA9ICZuZXdfY3R4LT5yZXNfY3R4LnBpcGVfY3R4W2ldOwot
LSAKMi4yMC4xCgo=
--00000000000097c52f058f94601e--

