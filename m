Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E3E8C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:47:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B41D2084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:47:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="s2Uy7F2z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B41D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16228E0003; Tue, 18 Jun 2019 15:47:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7858E0001; Tue, 18 Jun 2019 15:47:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FC68E0003; Tue, 18 Jun 2019 15:47:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C02D8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 15:47:24 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r6so5307153oib.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:47:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KdzTI56/zG61CRTFghoJgUKFV1Q8B4zDnAoIv6r27HM=;
        b=ThKNXggq+10fqydWo8fwu495P94RE5PRYDzbUMo9QnSErqNkg3GgBDZow6u+Bcbz8o
         9g2YLoTfTd1JF5nzIIJ5Ci4pl3j0BPby5KG9195IAFsFd+TOwL0nCVk5ZGy+Mk0jfVUv
         LlusKGfA0l1zCAPYae7ei1i34TStn4IfnbrFn/8k1EXdVdi2ZX8H0OsBsFCu9Sw3Hlp4
         1Yk46g57dCXfA/y5L4Y6QLlcjHdzCaMimHEWg7Q03MBHgg1P0EHgA4yL8oY/UwUpd69Y
         sh1+ltjLC8HGST70IV0HvHYE9unOqqf+fIXB2nEGIjCR4Dich9kfGQzhGnJXjJ4s+PYW
         FOxQ==
X-Gm-Message-State: APjAAAVfcxNSVbS/fV7N0THz51FySb6hD/9JubCH0eL0GvPNhZLPTXz9
	qEUA993udgT7IbEjTIOFivYFx9IIkuZ9wN7upLz1Xbg4dUv/59Co6mItmYPHv6aH2ZoOJJtvFWW
	hZpB7FYHHTW+wG7hc6FDJlUY+nR5WA/epNTzei0bIN/CWN5EKURySwkGl7eII9D9TfQ==
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr19736772otf.210.1560887243673;
        Tue, 18 Jun 2019 12:47:23 -0700 (PDT)
X-Received: by 2002:a9d:3c5:: with SMTP id f63mr19736695otf.210.1560887242121;
        Tue, 18 Jun 2019 12:47:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560887242; cv=none;
        d=google.com; s=arc-20160816;
        b=YiOxL+r6y5pXNMWXtmuIMX8ZIY7APBXav56pvU2Q0qJzsy9PfGOkI8XwEWLgRy+5q4
         vwF5pmm9vx0MxSrldzksropYYs7CkXOms9Hp+WI3XVoelmT+P4s3540YykzWSMg2Mlyu
         sYMXnioxYN33aXRFl71e1gfkIxhI4O+xWJjwSlmCZFTpS2yFfazwNobvZ46wI00Z7YBj
         +5+Wxhp0wIekOKQ6I0+kwGv/IxjWsIbapSk8SZNxiPCuJIMF/2V2kYcoOTYyBg7a33ag
         /llxQqn0dQrzwc5MKR+fv5bWfPOfc86GPnbb54XPv+mIL6mPgXSEKUSSm7Z6gBRSfZdE
         Pw1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KdzTI56/zG61CRTFghoJgUKFV1Q8B4zDnAoIv6r27HM=;
        b=chSpfw6yh0n1+i/QZ2P8tFEfpfKFGf26tVdToymWvKhdKSiujn9EkrHc/EkqLEojKW
         MgEChfTNP+U9JXJqnsm6VEa7nVYUCT8xbaoU844oG0lqdBVQKshjymFfiIbBegXLFRxO
         dLvOZaRQ1D6neVH9qb42/QfWMs1u8W66s59Zs2sbFBDPM09+g9Mjz9leT/chH59u+4j3
         o2d3n4zSOqqTzB+vITKPtPwa4v/7Isu/+PRAjyVobRXMcLJ5+wYZK0iSiiyBh6AEXKYR
         0qLg3Z3xHaUN7FVwpJdrConhxhBxAya6ouZsxsmndOUhj01lEpJwDl9w34MPTFmK1F7o
         QS9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=s2Uy7F2z;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14sor7835284otq.71.2019.06.18.12.47.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 12:47:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=s2Uy7F2z;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KdzTI56/zG61CRTFghoJgUKFV1Q8B4zDnAoIv6r27HM=;
        b=s2Uy7F2zSbJmvMOmCMRUi/PHWSrNmkd+yGx8fJ35yqjrx0VA2g4YYc0V0vIwh56Z/0
         BKgsgx566zdN/soUBM+hoVSPg0Mh339pfKaZgnXQ9whOVS/VisWHxVN9WcoYYav3yECk
         Ij61J5BrFPqR+ChgqtjTrxSj+HZo/Wi3cxewVxCzA6SdioZEqsUUz0FjTzFcjq5+jDL3
         W2eJpXAWBAeQDuOHPPDjWTeepbZZcaK0bwqBN0lAn86Q+NQi6cXesdKLyg5ZhJ+PKQWL
         ILFMB95thwvXk8Yhg5TY/3cQLZfeRvv7FWwXv8GnfNwMUDdeT8DHF2iVNEmofRWm0l1+
         BWaw==
X-Google-Smtp-Source: APXvYqySF7rQ3CS5aYa5WUQws2eei8Wnpe7WRTBg73J6Btkx3UaxdRnRh4Rn6PBOGuhYC6vnCKHCnWzCQAn50NUniuI=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr6127462oto.207.1560887240878;
 Tue, 18 Jun 2019 12:47:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de>
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Jun 2019 12:47:10 -0700
Message-ID: <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups v2
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: multipart/mixed; boundary="000000000000872d5f058b9e614c"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000872d5f058b9e614c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 17, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Hi Dan, J=C3=A9r=C3=B4me and Jason,
>
> below is a series that cleans up the dev_pagemap interface so that
> it is more easily usable, which removes the need to wrap it in hmm
> and thus allowing to kill a lot of code
>
> Note: this series is on top of the rdma/hmm branch + the dev_pagemap
> releas fix series from Dan that went into 5.2-rc5.
>
> Git tree:
>
>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2
>
> Gitweb:
>
>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-d=
evmem-cleanup.2
>
> Changes since v1:
>  - rebase
>  - also switch p2pdma to the internal refcount
>  - add type checking for pgmap->type
>  - rename the migrate method to migrate_to_ram
>  - cleanup the altmap_valid flag
>  - various tidbits from the reviews

Attached is my incremental fixups on top of this series, with those
integrated you can add:

Tested-by: Dan Williams <dan.j.williams@intel.com>

...to the patches that touch kernel/memremap.c, drivers/dax, and drivers/nv=
dimm.

You can also add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

...for the series.

--000000000000872d5f058b9e614c
Content-Type: text/x-patch; charset="US-ASCII"; name="incremental.diff"
Content-Disposition: attachment; filename="incremental.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jx27x1rf0>
X-Attachment-Id: f_jx27x1rf0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvZGF4L2RldmljZS5jIGIvZHJpdmVycy9kYXgvZGV2aWNlLmMK
aW5kZXggYTlkN2M5MGVjZjFlLi4xYWY4MjNiMmZlNmIgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvZGF4
L2RldmljZS5jCisrKyBiL2RyaXZlcnMvZGF4L2RldmljZS5jCkBAIC00MjgsNiArNDI4LDcgQEAg
aW50IGRldl9kYXhfcHJvYmUoc3RydWN0IGRldmljZSAqZGV2KQogCQlyZXR1cm4gLUVCVVNZOwog
CX0KIAorCWRldl9kYXgtPnBnbWFwLnR5cGUgPSBNRU1PUllfREVWSUNFX0RFVkRBWDsKIAlhZGRy
ID0gZGV2bV9tZW1yZW1hcF9wYWdlcyhkZXYsICZkZXZfZGF4LT5wZ21hcCk7CiAJaWYgKElTX0VS
UihhZGRyKSkKIAkJcmV0dXJuIFBUUl9FUlIoYWRkcik7CmRpZmYgLS1naXQgYS9kcml2ZXJzL252
ZGltbS9LY29uZmlnIGIvZHJpdmVycy9udmRpbW0vS2NvbmZpZwppbmRleCA1NDUwMDc5OGYyM2Eu
LjU3ZDNhNmMzYWM3MCAxMDA2NDQKLS0tIGEvZHJpdmVycy9udmRpbW0vS2NvbmZpZworKysgYi9k
cml2ZXJzL252ZGltbS9LY29uZmlnCkBAIC0xMTgsNCArMTE4LDE1IEBAIGNvbmZpZyBOVkRJTU1f
S0VZUwogCWRlcGVuZHMgb24gRU5DUllQVEVEX0tFWVMKIAlkZXBlbmRzIG9uIChMSUJOVkRJTU09
RU5DUllQVEVEX0tFWVMpIHx8IExJQk5WRElNTT1tCiAKK2NvbmZpZyBOVkRJTU1fVEVTVF9CVUlM
RAorCWJvb2wgIkJ1aWxkIHRoZSB1bml0IHRlc3QgY29yZSIKKwlkZXBlbmRzIG9uIENPTVBJTEVf
VEVTVAorCWRlZmF1bHQgQ09NUElMRV9URVNUCisJaGVscAorCSAgQnVpbGQgdGhlIGNvcmUgb2Yg
dGhlIHVuaXQgdGVzdCBpbmZyYXN0cnVjdHVyZS4gIFRoZSByZXN1bHQgb2YKKwkgIHRoaXMgYnVp
bGQgaXMgbm9uLWZ1bmN0aW9uYWwgZm9yIHVuaXQgdGVzdCBleGVjdXRpb24sIGJ1dCBpdAorCSAg
b3RoZXJ3aXNlIGhlbHBzIGNhdGNoIGJ1aWxkIGVycm9ycyBpbmR1Y2VkIGJ5IGNoYW5nZXMgdG8g
dGhlCisJICBjb3JlIGRldm1fbWVtcmVtYXBfcGFnZXMoKSBpbXBsZW1lbnRhdGlvbiBhbmQgb3Ro
ZXIKKwkgIGluZnJhc3RydWN0dXJlLgorCiBlbmRpZgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9udmRp
bW0vTWFrZWZpbGUgYi9kcml2ZXJzL252ZGltbS9NYWtlZmlsZQppbmRleCA2ZjJhMDg4YWZhZDYu
LjQwMDgwYzEyMDM2MyAxMDA2NDQKLS0tIGEvZHJpdmVycy9udmRpbW0vTWFrZWZpbGUKKysrIGIv
ZHJpdmVycy9udmRpbW0vTWFrZWZpbGUKQEAgLTI4LDMgKzI4LDcgQEAgbGlibnZkaW1tLSQoQ09O
RklHX0JUVCkgKz0gYnR0X2RldnMubwogbGlibnZkaW1tLSQoQ09ORklHX05WRElNTV9QRk4pICs9
IHBmbl9kZXZzLm8KIGxpYm52ZGltbS0kKENPTkZJR19OVkRJTU1fREFYKSArPSBkYXhfZGV2cy5v
CiBsaWJudmRpbW0tJChDT05GSUdfTlZESU1NX0tFWVMpICs9IHNlY3VyaXR5Lm8KKworVE9PTFMg
Oj0gLi4vLi4vdG9vbHMKK1RFU1RfU1JDIDo9ICQoVE9PTFMpL3Rlc3RpbmcvbnZkaW1tL3Rlc3QK
K29iai0kKENPTkZJR19OVkRJTU1fVEVTVF9CVUlMRCkgOj0gJChURVNUX1NSQykvaW9tYXAubwpk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9tZW1yZW1hcC5oIGIvaW5jbHVkZS9saW51eC9tZW1y
ZW1hcC5oCmluZGV4IDdlMGYwNzJkZGNlNy4uNDcwZGU2OGRhYmQ2IDEwMDY0NAotLS0gYS9pbmNs
dWRlL2xpbnV4L21lbXJlbWFwLmgKKysrIGIvaW5jbHVkZS9saW51eC9tZW1yZW1hcC5oCkBAIC01
NSwxMiArNTUsMTkgQEAgc3RydWN0IHZtZW1fYWx0bWFwIHsKICAqIE1FTU9SWV9ERVZJQ0VfUENJ
X1AyUERNQToKICAqIERldmljZSBtZW1vcnkgcmVzaWRpbmcgaW4gYSBQQ0kgQkFSIGludGVuZGVk
IGZvciB1c2Ugd2l0aCBQZWVyLXRvLVBlZXIKICAqIHRyYW5zYWN0aW9ucy4KKyAqCisgKiBNRU1P
UllfREVWSUNFX0RFVkRBWDoKKyAqIEhvc3QgbWVtb3J5IHRoYXQgaGFzIHNpbWlsYXIgYWNjZXNz
IHNlbWFudGljcyBhcyBTeXN0ZW0gUkFNIGkuZS4gRE1BCisgKiBjb2hlcmVudCBhbmQgc3VwcG9y
dHMgcGFnZSBwaW5uaW5nLiBJbiBjb250cmFzdCB0bworICogTUVNT1JZX0RFVklDRV9GU19EQVgs
IHRoaXMgbWVtb3J5IGlzIGFjY2VzcyB2aWEgYSBkZXZpY2UtZGF4CisgKiBjaGFyYWN0ZXIgZGV2
aWNlLgogICovCiBlbnVtIG1lbW9yeV90eXBlIHsKIAlNRU1PUllfREVWSUNFX1BSSVZBVEUgPSAx
LAogCU1FTU9SWV9ERVZJQ0VfUFVCTElDLAogCU1FTU9SWV9ERVZJQ0VfRlNfREFYLAogCU1FTU9S
WV9ERVZJQ0VfUENJX1AyUERNQSwKKwlNRU1PUllfREVWSUNFX0RFVkRBWCwKIH07CiAKIHN0cnVj
dCBkZXZfcGFnZW1hcF9vcHMgewpkaWZmIC0tZ2l0IGEva2VybmVsL21lbXJlbWFwLmMgYi9rZXJu
ZWwvbWVtcmVtYXAuYwppbmRleCA2MDY5M2ExZThlOTIuLjUyYjQ5NjhlNjJjZCAxMDA2NDQKLS0t
IGEva2VybmVsL21lbXJlbWFwLmMKKysrIGIva2VybmVsL21lbXJlbWFwLmMKQEAgLTE3Myw2ICsx
NzMsNyBAQCB2b2lkICpkZXZtX21lbXJlbWFwX3BhZ2VzKHN0cnVjdCBkZXZpY2UgKmRldiwgc3Ry
dWN0IGRldl9wYWdlbWFwICpwZ21hcCkKIAl9OwogCXBncHJvdF90IHBncHJvdCA9IFBBR0VfS0VS
TkVMOwogCWludCBlcnJvciwgbmlkLCBpc19yYW07CisJYm9vbCBnZXRfb3BzID0gdHJ1ZTsKIAog
CXN3aXRjaCAocGdtYXAtPnR5cGUpIHsKIAljYXNlIE1FTU9SWV9ERVZJQ0VfUFJJVkFURToKQEAg
LTE5OSw2ICsyMDAsOCBAQCB2b2lkICpkZXZtX21lbXJlbWFwX3BhZ2VzKHN0cnVjdCBkZXZpY2Ug
KmRldiwgc3RydWN0IGRldl9wYWdlbWFwICpwZ21hcCkKIAkJfQogCQlicmVhazsKIAljYXNlIE1F
TU9SWV9ERVZJQ0VfUENJX1AyUERNQToKKwljYXNlIE1FTU9SWV9ERVZJQ0VfREVWREFYOgorCQln
ZXRfb3BzID0gZmFsc2U7CiAJCWJyZWFrOwogCWRlZmF1bHQ6CiAJCVdBUk4oMSwgIkludmFsaWQg
cGdtYXAgdHlwZSAlZFxuIiwgcGdtYXAtPnR5cGUpOwpAQCAtMjIyLDcgKzIyNSw3IEBAIHZvaWQg
KmRldm1fbWVtcmVtYXBfcGFnZXMoc3RydWN0IGRldmljZSAqZGV2LCBzdHJ1Y3QgZGV2X3BhZ2Vt
YXAgKnBnbWFwKQogCQl9CiAJfQogCi0JaWYgKHBnbWFwLT50eXBlICE9IE1FTU9SWV9ERVZJQ0Vf
UENJX1AyUERNQSkgeworCWlmIChnZXRfb3BzKSB7CiAJCWVycm9yID0gZGV2X3BhZ2VtYXBfZ2V0
X29wcyhkZXYsIHBnbWFwKTsKIAkJaWYgKGVycm9yKQogCQkJcmV0dXJuIEVSUl9QVFIoZXJyb3Ip
OwpkaWZmIC0tZ2l0IGEvdG9vbHMvdGVzdGluZy9udmRpbW0vdGVzdC9pb21hcC5jIGIvdG9vbHMv
dGVzdGluZy9udmRpbW0vdGVzdC9pb21hcC5jCmluZGV4IDhjZDliOTg3M2E3Zi4uOTAxOWRkOGFm
YmMxIDEwMDY0NAotLS0gYS90b29scy90ZXN0aW5nL252ZGltbS90ZXN0L2lvbWFwLmMKKysrIGIv
dG9vbHMvdGVzdGluZy9udmRpbW0vdGVzdC9pb21hcC5jCkBAIC0xMDYsNyArMTA2LDcgQEAgRVhQ
T1JUX1NZTUJPTChfX3dyYXBfZGV2bV9tZW1yZW1hcCk7CiAKIHN0YXRpYyB2b2lkIG5maXRfdGVz
dF9raWxsKHZvaWQgKl9wZ21hcCkKIHsKLQlXQVJOX09OKCFwZ21hcCB8fCAhcGdtYXAtPnJlZikK
KwlzdHJ1Y3QgZGV2X3BhZ2VtYXAgKnBnbWFwID0gX3BnbWFwOwogCiAJaWYgKHBnbWFwLT5vcHMg
JiYgcGdtYXAtPm9wcy0+a2lsbCkKIAkJcGdtYXAtPm9wcy0+a2lsbChwZ21hcCk7CkBAIC0xMjEs
MjAgKzEyMSw0NSBAQCBzdGF0aWMgdm9pZCBuZml0X3Rlc3Rfa2lsbCh2b2lkICpfcGdtYXApCiAJ
fQogfQogCitzdGF0aWMgdm9pZCBkZXZfcGFnZW1hcF9wZXJjcHVfcmVsZWFzZShzdHJ1Y3QgcGVy
Y3B1X3JlZiAqcmVmKQoreworCXN0cnVjdCBkZXZfcGFnZW1hcCAqcGdtYXAgPQorCQljb250YWlu
ZXJfb2YocmVmLCBzdHJ1Y3QgZGV2X3BhZ2VtYXAsIGludGVybmFsX3JlZik7CisKKwljb21wbGV0
ZSgmcGdtYXAtPmRvbmUpOworfQorCiB2b2lkICpfX3dyYXBfZGV2bV9tZW1yZW1hcF9wYWdlcyhz
dHJ1Y3QgZGV2aWNlICpkZXYsIHN0cnVjdCBkZXZfcGFnZW1hcCAqcGdtYXApCiB7CisJaW50IGVy
cm9yOwogCXJlc291cmNlX3NpemVfdCBvZmZzZXQgPSBwZ21hcC0+cmVzLnN0YXJ0OwogCXN0cnVj
dCBuZml0X3Rlc3RfcmVzb3VyY2UgKm5maXRfcmVzID0gZ2V0X25maXRfcmVzKG9mZnNldCk7CiAK
LQlpZiAobmZpdF9yZXMpIHsKLQkJaW50IHJjOworCWlmICghbmZpdF9yZXMpCisJCXJldHVybiBk
ZXZtX21lbXJlbWFwX3BhZ2VzKGRldiwgcGdtYXApOwogCi0JCXJjID0gZGV2bV9hZGRfYWN0aW9u
X29yX3Jlc2V0KGRldiwgbmZpdF90ZXN0X2tpbGwsIHBnbWFwKTsKLQkJaWYgKHJjKQotCQkJcmV0
dXJuIEVSUl9QVFIocmMpOwotCQlyZXR1cm4gbmZpdF9yZXMtPmJ1ZiArIG9mZnNldCAtIG5maXRf
cmVzLT5yZXMuc3RhcnQ7CisJcGdtYXAtPmRldiA9IGRldjsKKwlpZiAoIXBnbWFwLT5yZWYpIHsK
KwkJaWYgKHBnbWFwLT5vcHMgJiYgKHBnbWFwLT5vcHMtPmtpbGwgfHwgcGdtYXAtPm9wcy0+Y2xl
YW51cCkpCisJCQlyZXR1cm4gRVJSX1BUUigtRUlOVkFMKTsKKworCQlpbml0X2NvbXBsZXRpb24o
JnBnbWFwLT5kb25lKTsKKwkJZXJyb3IgPSBwZXJjcHVfcmVmX2luaXQoJnBnbWFwLT5pbnRlcm5h
bF9yZWYsCisJCQkJZGV2X3BhZ2VtYXBfcGVyY3B1X3JlbGVhc2UsIDAsIEdGUF9LRVJORUwpOwor
CQlpZiAoZXJyb3IpCisJCQlyZXR1cm4gRVJSX1BUUihlcnJvcik7CisJCXBnbWFwLT5yZWYgPSAm
cGdtYXAtPmludGVybmFsX3JlZjsKKwl9IGVsc2UgeworCQlpZiAoIXBnbWFwLT5vcHMgfHwgIXBn
bWFwLT5vcHMtPmtpbGwgfHwgIXBnbWFwLT5vcHMtPmNsZWFudXApIHsKKwkJCVdBUk4oMSwgIk1p
c3NpbmcgcmVmZXJlbmNlIGNvdW50IHRlYXJkb3duIGRlZmluaXRpb25cbiIpOworCQkJcmV0dXJu
IEVSUl9QVFIoLUVJTlZBTCk7CisJCX0KIAl9Ci0JcmV0dXJuIGRldm1fbWVtcmVtYXBfcGFnZXMo
ZGV2LCBwZ21hcCk7CisKKwllcnJvciA9IGRldm1fYWRkX2FjdGlvbl9vcl9yZXNldChkZXYsIG5m
aXRfdGVzdF9raWxsLCBwZ21hcCk7CisJaWYgKGVycm9yKQorCQlyZXR1cm4gRVJSX1BUUihlcnJv
cik7CisJcmV0dXJuIG5maXRfcmVzLT5idWYgKyBvZmZzZXQgLSBuZml0X3Jlcy0+cmVzLnN0YXJ0
OwogfQogRVhQT1JUX1NZTUJPTF9HUEwoX193cmFwX2Rldm1fbWVtcmVtYXBfcGFnZXMpOwogCg==
--000000000000872d5f058b9e614c--

