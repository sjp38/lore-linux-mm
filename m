Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 712FAC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:44:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 135D02084B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 19:44:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="HBM18VPX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 135D02084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955CE6B000C; Tue, 18 Jun 2019 15:44:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906CE8E0002; Tue, 18 Jun 2019 15:44:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81C678E0001; Tue, 18 Jun 2019 15:44:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9DA6B000C
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 15:44:13 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d62so6805213otb.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:44:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lWeoQffD9ULTiTlyWHRUgEl3LLxJ/1SEB3UmhnFdNVc=;
        b=L61TK3oYUrN6EHmTR70ec/aHgyLJp6qMlCmnaR4LQWmdX8KwJBKmfGatob3psiFW2G
         T7XPgOaWkSRFzpJH2wQHe5lGEu4DTID3YFkibbpmAOqftD2HHJQVLxCvLDyxyEDaKhw9
         dXT/g4r7Cg9FLxVavElljNjK+izCqM6gJRXIPq8Axk9Itcwm+O0oZQkgZH/1DdvK60HK
         avhchNYGOL93QsZdXCYGgnym7q+8q6PmEvliY4ADOr1AXQtroqrAmUdDIlV991NNd/js
         2yQePdjI/LhwbVT+4l7cgsYq/CmW/kPuAo25SC9dCT0C93QVZetdo7SdwQ4gHzp4gZXX
         cz1g==
X-Gm-Message-State: APjAAAWDyTPPHwjVGXiYZVpL/7V2ovdKIJgzfWdsZoWMP/K8ef2TkX0V
	A0qjVFzhr/Sy6YvOCX+MEKmwkpO6IQR+Um3ZvkvhOqhOhpWviYl5LUThqutgVtzbTeF4SDhUItZ
	GkRP5nq19t/7Z/+MbvAOSIHTjTGYAzLuVXDeZ6Xl5tuUGiRUWVCVlFfasMbF1lUVDgA==
X-Received: by 2002:a05:6830:1389:: with SMTP id d9mr25648710otq.315.1560887052935;
        Tue, 18 Jun 2019 12:44:12 -0700 (PDT)
X-Received: by 2002:a05:6830:1389:: with SMTP id d9mr25648657otq.315.1560887051871;
        Tue, 18 Jun 2019 12:44:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560887051; cv=none;
        d=google.com; s=arc-20160816;
        b=LCQJn5F4SJnNwzdZ+6aonv1hjt33RCoq2d0oj7G+HIze4UM4jxZxwgh5j49uvYqeQx
         tWBl3XFCfHGj/RIfrcT3k3S90GfnlS7kkyXqzRIS2tjnFO5IRvEMnIDwdo1+XMeTn8pK
         NR99JOsJSmuDfriLNaK0jiKY0gm9OS2wRczcMgraNUB2Q8s0QNvp2myfSODc2UUOwBui
         sOkd9OJhU/Sx9SqB5ZiSjKw/Ai3iPk41LbzMDAVWpZWAL73pzqWQpWh1n0OFNdM5n1Q7
         KEKPTqjnecrXnbsiPaghVyA4ezs2AGU4mG0afiKLvFuYTJYgKFeguvzuSa5YujNP+P/o
         pFog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lWeoQffD9ULTiTlyWHRUgEl3LLxJ/1SEB3UmhnFdNVc=;
        b=UpjonU3Ndn7UDHeODBRbWsrf8x+PwjfC7MYlk7iVOOgXyka9qihyVfV5uNjR5igGGk
         Av++4/8RoRVorGRxdVIcDCzmGrkTL9is8UsZGH+4YUuWxPwXCny7QX8DXzt5OG0FBBKh
         0hJmr0CPlm0WdiRdpiKMCUl4ds6x77UWDBfo6n55V9R70g/WqNvnNNzFC6rfYUlMSLD9
         zumkK6sOagE1IoBplmTd8TEPddUXZePUGCieD1ysVGXnzFyBe0uscyrfzrqRt0Z8vBth
         nOFd3NJCErUCR++rBrzkclQH27ntfkVesieaW3DED40QBT545mbZW+OHH0oqpn9S3mzf
         jstg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HBM18VPX;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor7188339otk.82.2019.06.18.12.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 12:44:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=HBM18VPX;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lWeoQffD9ULTiTlyWHRUgEl3LLxJ/1SEB3UmhnFdNVc=;
        b=HBM18VPXHIC97mbLA+LtY3CIlBwNWPFZh/XoVx5V3O56HGcLOwYjjgGO1PCDnbVpDc
         WuU8ZDq2UjT5VxR4klcAB/lbVRwJ0Z9ei+7ASbtZTF9eoDvBooNqgG4Cn7b0fuW7CjTF
         tjaPfRs8CiVIRv+lH1b32DeFE6GrR8lZUQVBLu7ROfno0v4YRmMIO57Ecxyn/H1ZBXWv
         x5WqNsR4Y/xpS8+RU0wqIjPMvyzhezRAZFOBqwNX2yAIZCUzqW7J36ZwySrmdeosgciw
         9qQOkEYFUoFGBQz/HfT+wqA9YYfTgjxDdiIQfwbk3QkFIUp0slBDktARnSOPSBIAzdUu
         VMdw==
X-Google-Smtp-Source: APXvYqzvEbAUxmiQsuBWOyCSPoJJ82/NJ4V945yWJ3d7PH0Xyc52nRxuIrMvp5YF3AqD0GfjC1CQKPjmX1N5IlCt5jk=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr817279otn.247.1560887051616;
 Tue, 18 Jun 2019 12:44:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-16-hch@lst.de>
In-Reply-To: <20190617122733.22432-16-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Jun 2019 12:43:59 -0700
Message-ID: <CAPcyv4iwawKnG4jQtcNWNtXQeH3PYG6iWc6JV59DnyixmwDEcg@mail.gmail.com>
Subject: Re: [PATCH 15/25] device-dax: use the dev_pagemap internal refcount
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: multipart/mixed; boundary="0000000000003f3c23058b9e5615"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000003f3c23058b9e5615
Content-Type: text/plain; charset="UTF-8"

On Mon, Jun 17, 2019 at 5:28 AM Christoph Hellwig <hch@lst.de> wrote:
>
> The functionality is identical to the one currently open coded in
> device-dax.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/dax/dax-private.h |  4 ----
>  drivers/dax/device.c      | 43 ---------------------------------------
>  2 files changed, 47 deletions(-)

This needs the mock devm_memremap_pages() to setup the common
percpu_ref. Incremental patch attached:

--0000000000003f3c23058b9e5615
Content-Type: text/x-patch; charset="US-ASCII"; 
	name="0001-tools-testing-nvdimm-Support-the-internal-ref-of-dev.patch"
Content-Disposition: attachment; 
	filename="0001-tools-testing-nvdimm-Support-the-internal-ref-of-dev.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jx27u7050>
X-Attachment-Id: f_jx27u7050

RnJvbSA4NzVlNzE0ODljODQ4NTQ0OGE1YjdkZjJkOGE4YjJlZDc3ZDJiNTU1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxpYW1zQGludGVsLmNv
bT4KRGF0ZTogVHVlLCAxOCBKdW4gMjAxOSAxMTo1ODoyNCAtMDcwMApTdWJqZWN0OiBbUEFUQ0hd
IHRvb2xzL3Rlc3RpbmcvbnZkaW1tOiBTdXBwb3J0IHRoZSAnaW50ZXJuYWwnIHJlZiBvZgogZGV2
X3BhZ2VtYXAKCkZvciB1c2VycyBvZiB0aGUgY29tbW9uIHBlcmNwdS1yZWYgaW1wbGVtZW50YXRp
b24sIGxpa2UgZGV2aWNlLWRheCwKYXJyYW5nZSBmb3IgbmZpdF90ZXN0IHRvIGluaXRpYWxpemUg
dGhlIGNvbW1vbiBwYXJhbWV0ZXJzLgoKU2lnbmVkLW9mZi1ieTogRGFuIFdpbGxpYW1zIDxkYW4u
ai53aWxsaWFtc0BpbnRlbC5jb20+Ci0tLQogdG9vbHMvdGVzdGluZy9udmRpbW0vdGVzdC9pb21h
cC5jIHwgNDEgKysrKysrKysrKysrKysrKysrKysrKysrLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQs
IDMyIGluc2VydGlvbnMoKyksIDkgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvdG9vbHMvdGVz
dGluZy9udmRpbW0vdGVzdC9pb21hcC5jIGIvdG9vbHMvdGVzdGluZy9udmRpbW0vdGVzdC9pb21h
cC5jCmluZGV4IDNiYzFjMTZjNGVmOS4uOTAxOWRkOGFmYmMxIDEwMDY0NAotLS0gYS90b29scy90
ZXN0aW5nL252ZGltbS90ZXN0L2lvbWFwLmMKKysrIGIvdG9vbHMvdGVzdGluZy9udmRpbW0vdGVz
dC9pb21hcC5jCkBAIC0xMDgsOCArMTA4LDYgQEAgc3RhdGljIHZvaWQgbmZpdF90ZXN0X2tpbGwo
dm9pZCAqX3BnbWFwKQogewogCXN0cnVjdCBkZXZfcGFnZW1hcCAqcGdtYXAgPSBfcGdtYXA7CiAK
LQlXQVJOX09OKCFwZ21hcCB8fCAhcGdtYXAtPnJlZik7Ci0KIAlpZiAocGdtYXAtPm9wcyAmJiBw
Z21hcC0+b3BzLT5raWxsKQogCQlwZ21hcC0+b3BzLT5raWxsKHBnbWFwKTsKIAllbHNlCkBAIC0x
MjMsMjAgKzEyMSw0NSBAQCBzdGF0aWMgdm9pZCBuZml0X3Rlc3Rfa2lsbCh2b2lkICpfcGdtYXAp
CiAJfQogfQogCitzdGF0aWMgdm9pZCBkZXZfcGFnZW1hcF9wZXJjcHVfcmVsZWFzZShzdHJ1Y3Qg
cGVyY3B1X3JlZiAqcmVmKQoreworCXN0cnVjdCBkZXZfcGFnZW1hcCAqcGdtYXAgPQorCQljb250
YWluZXJfb2YocmVmLCBzdHJ1Y3QgZGV2X3BhZ2VtYXAsIGludGVybmFsX3JlZik7CisKKwljb21w
bGV0ZSgmcGdtYXAtPmRvbmUpOworfQorCiB2b2lkICpfX3dyYXBfZGV2bV9tZW1yZW1hcF9wYWdl
cyhzdHJ1Y3QgZGV2aWNlICpkZXYsIHN0cnVjdCBkZXZfcGFnZW1hcCAqcGdtYXApCiB7CisJaW50
IGVycm9yOwogCXJlc291cmNlX3NpemVfdCBvZmZzZXQgPSBwZ21hcC0+cmVzLnN0YXJ0OwogCXN0
cnVjdCBuZml0X3Rlc3RfcmVzb3VyY2UgKm5maXRfcmVzID0gZ2V0X25maXRfcmVzKG9mZnNldCk7
CiAKLQlpZiAobmZpdF9yZXMpIHsKLQkJaW50IHJjOworCWlmICghbmZpdF9yZXMpCisJCXJldHVy
biBkZXZtX21lbXJlbWFwX3BhZ2VzKGRldiwgcGdtYXApOwogCi0JCXJjID0gZGV2bV9hZGRfYWN0
aW9uX29yX3Jlc2V0KGRldiwgbmZpdF90ZXN0X2tpbGwsIHBnbWFwKTsKLQkJaWYgKHJjKQotCQkJ
cmV0dXJuIEVSUl9QVFIocmMpOwotCQlyZXR1cm4gbmZpdF9yZXMtPmJ1ZiArIG9mZnNldCAtIG5m
aXRfcmVzLT5yZXMuc3RhcnQ7CisJcGdtYXAtPmRldiA9IGRldjsKKwlpZiAoIXBnbWFwLT5yZWYp
IHsKKwkJaWYgKHBnbWFwLT5vcHMgJiYgKHBnbWFwLT5vcHMtPmtpbGwgfHwgcGdtYXAtPm9wcy0+
Y2xlYW51cCkpCisJCQlyZXR1cm4gRVJSX1BUUigtRUlOVkFMKTsKKworCQlpbml0X2NvbXBsZXRp
b24oJnBnbWFwLT5kb25lKTsKKwkJZXJyb3IgPSBwZXJjcHVfcmVmX2luaXQoJnBnbWFwLT5pbnRl
cm5hbF9yZWYsCisJCQkJZGV2X3BhZ2VtYXBfcGVyY3B1X3JlbGVhc2UsIDAsIEdGUF9LRVJORUwp
OworCQlpZiAoZXJyb3IpCisJCQlyZXR1cm4gRVJSX1BUUihlcnJvcik7CisJCXBnbWFwLT5yZWYg
PSAmcGdtYXAtPmludGVybmFsX3JlZjsKKwl9IGVsc2UgeworCQlpZiAoIXBnbWFwLT5vcHMgfHwg
IXBnbWFwLT5vcHMtPmtpbGwgfHwgIXBnbWFwLT5vcHMtPmNsZWFudXApIHsKKwkJCVdBUk4oMSwg
Ik1pc3NpbmcgcmVmZXJlbmNlIGNvdW50IHRlYXJkb3duIGRlZmluaXRpb25cbiIpOworCQkJcmV0
dXJuIEVSUl9QVFIoLUVJTlZBTCk7CisJCX0KIAl9Ci0JcmV0dXJuIGRldm1fbWVtcmVtYXBfcGFn
ZXMoZGV2LCBwZ21hcCk7CisKKwllcnJvciA9IGRldm1fYWRkX2FjdGlvbl9vcl9yZXNldChkZXYs
IG5maXRfdGVzdF9raWxsLCBwZ21hcCk7CisJaWYgKGVycm9yKQorCQlyZXR1cm4gRVJSX1BUUihl
cnJvcik7CisJcmV0dXJuIG5maXRfcmVzLT5idWYgKyBvZmZzZXQgLSBuZml0X3Jlcy0+cmVzLnN0
YXJ0OwogfQogRVhQT1JUX1NZTUJPTF9HUEwoX193cmFwX2Rldm1fbWVtcmVtYXBfcGFnZXMpOwog
Ci0tIAoyLjIwLjEKCg==
--0000000000003f3c23058b9e5615--

