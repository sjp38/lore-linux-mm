Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13DF9C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:16:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC2ED218A3
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:16:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC2ED218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A8448E0107; Mon, 11 Feb 2019 12:16:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62F828E0103; Mon, 11 Feb 2019 12:16:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D0F28E0107; Mon, 11 Feb 2019 12:16:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 064DA8E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:16:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so10275178pfb.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:16:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=PlIhuzF/t7nSXB3FSeACXtytr/gYoW1R1RTCXIfiSSo=;
        b=OW7RUjOqvpc87IuNmbYKu991XpdPOQJRRxUuKZrVTHJdvTV411x8i1QOkPG+Bu28hj
         L+FH+GEjFEwtTILKuThthoKsllqGraz6Ui8AOYy+pcmB6F13NbKZ55JXRuqvihBtYGiw
         HwdPUQ3FpS2U/3kOKIvSYa7wQT82S/uGKx2UTbFs5eOzM6hbtFMsc8nE3Bg9u9xLuelR
         efdUzvgWLfV83nvI3z57eltLCHVHSJvvglhwyN4n/SUIeA2A4paLwIAb35bPRLLAD5ye
         x2KPI1/8tkW80TtN6SGZxQsCtp4rYBxrTpvLYFyV3YuwEi47XIvYzI6twzP6MfcwheMG
         PLIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuar/DWIQH6P4hC3rVGOMiQUBUaJvAKPxJvaNqA4qzccSbI/jy9K
	VQ4QroXOjAoRBlyvMcO2b/ri+qftOoD10vkFzF30f1dEQdgP8wHUFj88BnBzvtHR+hv5jNA3j46
	Rf8mOOPrg7aL/2ez3jg9AD66WIKDs7qRFIbaKp8f+D/BV2Groj+2fWI36/lGo3oV/2A==
X-Received: by 2002:a63:6184:: with SMTP id v126mr6421871pgb.277.1549905371666;
        Mon, 11 Feb 2019 09:16:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IawWXqSWj5KK+TJkQ7zUwR2L6f1EWWCMMjkafD/bUt1jl/io2vUqn4RLeR6B3TXKPhFIxED
X-Received: by 2002:a63:6184:: with SMTP id v126mr6421750pgb.277.1549905370208;
        Mon, 11 Feb 2019 09:16:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549905370; cv=none;
        d=google.com; s=arc-20160816;
        b=hHwylNwjOX+3qmi2Sm88M4Io6Hjv5QF5WmBiu26Nv3995SCO+o4tTbEEIbj1vdqRtV
         oBKzN0BasoVC8Tqi5dLpFmRDX3V4tFndlEvd+sxugGfPhvt3D6r1IVzXVNghv4TaGm0l
         aJCG/rCyeSARnM5qNsq/o5Y5sPzlyr7TRHq0LNxt72n7idU/7UaSzhrv9USaLaUo9kSt
         qKH8TJmYbuV2UN2BPrClIS8egZaF68FO9M2N77jVA8k/0tFkVGJa/t6BwPrHnkAXRn2s
         +RhgvPzDgKIfstT2ElLIRUnDxQOJCAjEt1rdeth16amwPWFI2DdaYM40l6RxBe6sT69s
         fWfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=PlIhuzF/t7nSXB3FSeACXtytr/gYoW1R1RTCXIfiSSo=;
        b=0ch08nVUP1EMbtcr9RLJtdFA6iLv8cM6thmClbFKzC+shZH4ryjghy4k+CIIvA66zA
         uJFX54BqWNRmsPsAgMPAERDYqHVw+UusXXqDnbT95ZzT7C16h2o5ec2nkscjNWZuMTZM
         Quru7F54cCHUjTnEghTzYZzTvfug9vme6d1YdoiNgrvRByQtG0iaknysbrpNnANfk8hO
         OYbyw7A3C7lMKS+2hgqO8LyQvzsLjMXnzvorXsHdPrG5fe38L71lB7xag1TdOOZhCtH/
         MnlXsLG8Ujepg6bsQ/udkthTikWAtSyCxWJI7XMFmdYpUrPZiKbTYHcrWpitZjQKThCX
         PK7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 187si10944142pfb.41.2019.02.11.09.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:16:10 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 09:16:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="123625697"
Received: from fmsmsx108.amr.corp.intel.com ([10.18.124.206])
  by fmsmga008.fm.intel.com with ESMTP; 11 Feb 2019 09:16:09 -0800
Received: from FMSMSX109.amr.corp.intel.com (10.18.116.9) by
 FMSMSX108.amr.corp.intel.com (10.18.124.206) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 09:16:09 -0800
Received: from crsmsx151.amr.corp.intel.com (172.18.7.86) by
 fmsmsx109.amr.corp.intel.com (10.18.116.9) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 09:16:08 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX151.amr.corp.intel.com ([169.254.3.79]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 11:16:07 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>, Daniel Borkmann
	<daniel@iogearbox.net>
CC: =?utf-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>, Davidlohr Bueso
	<dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Linux MM
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "David S . Miller"
	<davem@davemloft.net>, "Topel, Bjorn" <bjorn.topel@intel.com>, "Karlsson,
 Magnus" <magnus.karlsson@intel.com>, Netdev <netdev@vger.kernel.org>,
	Davidlohr Bueso <dbueso@suse.de>
Subject: RE: [PATCH 1/2] xsk: do not use mmap_sem
Thread-Topic: [PATCH 1/2] xsk: do not use mmap_sem
Thread-Index: AQHUwh8y/Z/k25QyB0Oc2wm5pV76vqXbMI2A//+lm9A=
Date: Mon, 11 Feb 2019 17:16:06 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BCB3B9@CRSMSX101.amr.corp.intel.com>
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-2-dave@stgolabs.net>
 <CAJ+HfNg=Wikc_uY9W1QiVCONq3c1GyS44-xbrq-J4gqfth2kwQ@mail.gmail.com>
 <d92b7b49-81e6-1ac5-4ae4-4909f87bbea8@iogearbox.net>
 <CAPcyv4gjUmRdV1jZegLecocj155m7dpQLxQSnF_HQQErD8Gtag@mail.gmail.com>
In-Reply-To: <CAPcyv4gjUmRdV1jZegLecocj155m7dpQLxQSnF_HQQErD8Gtag@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYWY2Y2EwYjQtYTAxYi00Zjg0LWE5NmEtOTFkNDdlMjg4YjM4IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiak5rNERqakdyUE1oXC81Sm91RUFha0ZSRjBFXC85dE0ybEM1TFVaRUljUVRYdXp2dzRVTndJSW9UcUkzTXNBNkZOIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiA+ID4+IC0tLQ0KPiA+ID4+ICBuZXQveGRwL3hkcF91bWVtLmMgfCA2ICsrLS0tLQ0KPiA+ID4+
ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCA0IGRlbGV0aW9ucygtKQ0KPiA+ID4+
DQo+ID4gPj4gZGlmZiAtLWdpdCBhL25ldC94ZHAveGRwX3VtZW0uYyBiL25ldC94ZHAveGRwX3Vt
ZW0uYyBpbmRleA0KPiA+ID4+IDVhYjIzNmM1YzlhNS4uMjVlMWU3NjY1NGE4IDEwMDY0NA0KPiA+
ID4+IC0tLSBhL25ldC94ZHAveGRwX3VtZW0uYw0KPiA+ID4+ICsrKyBiL25ldC94ZHAveGRwX3Vt
ZW0uYw0KPiA+ID4+IEBAIC0yNjUsMTAgKzI2NSw4IEBAIHN0YXRpYyBpbnQgeGRwX3VtZW1fcGlu
X3BhZ2VzKHN0cnVjdA0KPiB4ZHBfdW1lbSAqdW1lbSkNCj4gPiA+PiAgICAgICAgIGlmICghdW1l
bS0+cGdzKQ0KPiA+ID4+ICAgICAgICAgICAgICAgICByZXR1cm4gLUVOT01FTTsNCj4gPiA+Pg0K
PiA+ID4+IC0gICAgICAgZG93bl93cml0ZSgmY3VycmVudC0+bW0tPm1tYXBfc2VtKTsNCj4gPiA+
PiAtICAgICAgIG5wZ3MgPSBnZXRfdXNlcl9wYWdlcyh1bWVtLT5hZGRyZXNzLCB1bWVtLT5ucGdz
LA0KPiA+ID4+IC0gICAgICAgICAgICAgICAgICAgICAgICAgICAgIGd1cF9mbGFncywgJnVtZW0t
PnBnc1swXSwgTlVMTCk7DQo+ID4gPj4gLSAgICAgICB1cF93cml0ZSgmY3VycmVudC0+bW0tPm1t
YXBfc2VtKTsNCj4gPiA+PiArICAgICAgIG5wZ3MgPSBnZXRfdXNlcl9wYWdlc19mYXN0KHVtZW0t
PmFkZHJlc3MsIHVtZW0tPm5wZ3MsDQo+ID4gPj4gKyAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBndXBfZmxhZ3MsICZ1bWVtLT5wZ3NbMF0pOw0KPiA+ID4+DQo+ID4gPg0KPiA+ID4g
VGhhbmtzIGZvciB0aGUgcGF0Y2ghDQo+ID4gPg0KPiA+ID4gVGhlIGxpZmV0aW1lIG9mIHRoZSBw
aW5uaW5nIGlzIHNpbWlsYXIgdG8gUkRNQSB1bWVtIG1hcHBpbmcsIHNvDQo+ID4gPiBpc24ndCBn
dXBfbG9uZ3Rlcm0gcHJlZmVycmVkPw0KPiA+DQo+ID4gU2VlbXMgcmVhc29uYWJsZSBmcm9tIHJl
YWRpbmcgd2hhdCBndXBfbG9uZ3Rlcm0gc2VlbXMgdG8gZG8uIERhdmlkbG9ocg0KPiA+IG9yIERh
biwgYW55IHRob3VnaHRzIG9uIHRoZSBhYm92ZT8NCj4gDQo+IFllcywgYW55IGd1cCB3aGVyZSB0
aGUgbGlmZXRpbWUgb2YgdGhlIGNvcnJlc3BvbmRpbmcgcHV0X3BhZ2UoKSBpcyB1bmRlcg0KPiBk
aXJlY3QgY29udHJvbCBvZiB1c2Vyc3BhY2Ugc2hvdWxkIGJlIHVzaW5nIHRoZSBfbG9uZ3Rlcm0g
Zmxhdm9yIHRvDQo+IGNvb3JkaW5hdGUgYmUgY2FyZWZ1bCBpbiB0aGUgcHJlc2VuY2Ugb2YgZGF4
LiBJbiB0aGUgZGF4IGNhc2UgdGhlcmUgaXMgbm8gcGFnZQ0KPiBjYWNoZSBpbmRpcmVjdGlvbiB0
byBjb29yZGluYXRlIHRydW5jYXRlIHZzIHBhZ2UgcGlucy4gSXJhIGlzIGxvb2tpbmcgdG8gYWRk
IGENCj4gImZhc3QgKyBsb25ndGVybSIgZmxhdm9yIGZvciBjYXNlcyBsaWtlIHRoaXMuDQoNClll
cyBJJ20ganVzdCBhYm91dCByZWFkeSB3aXRoIGEgc21hbGwgcGF0Y2ggc2V0IHRvIGFkZCBhIEdV
UCBmYXN0IGxvbmd0ZXJtLg0KDQpJIHRoaW5rIHRoaXMgc2hvdWxkIHdhaXQgZm9yIHRoYXQgc2Vy
aWVzLg0KDQpJcmENCiANCg==

