Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A02EC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B58C20693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:02:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B58C20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5AE18E0003; Tue, 16 Jul 2019 11:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0ADE6B000C; Tue, 16 Jul 2019 11:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95E368E0003; Tue, 16 Jul 2019 11:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8026B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:02:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x19so12790008pgx.1
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=IKQ7dlHI8KfBPHZ2kvLr3PpcXOG2JKu5ybc8hM19ams=;
        b=OJXaxzEGm1+P8u3NIs8/lVlWD4vZlvsDVxM3/DiplQgWmZ4gWz2RFJeQYJ6ZhZdkpx
         FpE+f8pvY87Il19wXOx3k+x/u/7BfNmQE6sNXAhaZbIa1lAiNxwpV3+d9rR3qS0wiyrF
         2/pu1ukz9pjsDZall4jEnxL8qb8GWx6gVUtbWQNE5QxmnBwjkTYFOhqGkbN6pirfeSx9
         SCsN+IqzIVA7NnTa5JdO89+3geTJ4TKPwHe0+cz9JV3KhcYqpFgkT1xIjI2QTNfnxb2a
         wLcOyz3OZ2s6kW/Mf1POuLz+e0xnZLVc82O8luB2IvUVtS/OLz358UbTFurCx+zaINp+
         V9KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXnXIchyt8wpXRw4K8vWZGOi2SbA9hVxk6Xbhr3iAFtKXbRXmBx
	wcmaLx+cUOX+ECZEbhOONuxYoz9SXNue7+xH1BylU96t6zy+NyMq5IJrpYm+BpveMVoyo0A0A1g
	SckD3pyNduvvhViPU87J0CprgOy4L63HOxolipe3to/itoPQGJYsf1sRhIdtU3YWpnQ==
X-Received: by 2002:a63:c64b:: with SMTP id x11mr34327818pgg.319.1563289340967;
        Tue, 16 Jul 2019 08:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlDgBPPCOG2sDTAOnHWEStfHd42hGqqmV6A4fRMEf4oIVcC0OSq7A8IB+3QqRzcy6cdxTT
X-Received: by 2002:a63:c64b:: with SMTP id x11mr34327660pgg.319.1563289339796;
        Tue, 16 Jul 2019 08:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563289339; cv=none;
        d=google.com; s=arc-20160816;
        b=isHmB4DvnvWYWJtoFqx72baTitSPftqaqCWfv9WT/GjmP1j4+JZr5pfZqbckSUzXaT
         Afs2QuqxQLbdXB2YsKezbRV2DPBv/zGqO2VhYQDlcvIC3y3sPcwJn8kAyKCyh7zYgVGL
         IBXqMDLgx9zX8sKrWS2sjai6oenYR41iGwnD1cg5Fiwgw/WlK05aDvE4zQO00elJaK9o
         mxk06h6lM95mg5cOo32EcAcI8C7p6ZS69IkmGeHuzPqnTZ4mEg6kmk9L/8KTmI7a06+u
         YXC2Iv4D2cgmqa0hr+ZK1q14smosozzF8TomiYgOtOrDPe04nzHDMPp5B9qrEO19jdRa
         2jLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=IKQ7dlHI8KfBPHZ2kvLr3PpcXOG2JKu5ybc8hM19ams=;
        b=xysrzbTKjCpXX+L5LyhZHfxC+CoTPCLEAP3NY1tFlRrsG5ERzP/4hYSs8Rf9KdOQc2
         kTOB+ZHgqWXT8SY/haNXkMYjdfynAd2mwb4NRHy5/TV9Gr6ZHB02gAcvsh/LpQJOZJRX
         yi/q7D7OXSe4z9R/vUVOl0RuJ0vESVq+Ygsy9WARlpLfsVurzFu3yWCD+8eILQRQ4SaM
         ZYZlfQiFYsOicxF/9Gz/5sdgWk/NRJzNLRG3duKqrb4Xwu5CWkEYs9Cx8WMmOQ9gtDq2
         XVyLZXIuCp45b42wYXZVecCjAoyAFtG9zNAqGfsxoU/kFsfTj2Ghq+wPdly4+jivbW1Q
         xtUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z62si20381159pgd.472.2019.07.16.08.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 08:02:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Jul 2019 08:02:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,498,1557212400"; 
   d="scan'208";a="172567023"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by orsmga006.jf.intel.com with ESMTP; 16 Jul 2019 08:02:15 -0700
Received: from fmsmsx154.amr.corp.intel.com (10.18.116.70) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 16 Jul 2019 08:01:55 -0700
Received: from shsmsx107.ccr.corp.intel.com (10.239.4.96) by
 FMSMSX154.amr.corp.intel.com (10.18.116.70) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 16 Jul 2019 08:01:54 -0700
Received: from shsmsx102.ccr.corp.intel.com ([169.254.2.3]) by
 SHSMSX107.ccr.corp.intel.com ([169.254.9.162]) with mapi id 14.03.0439.000;
 Tue, 16 Jul 2019 23:01:53 +0800
From: "Wang, Wei W" <wei.w.wang@intel.com>
To: "Hansen, Dave" <dave.hansen@intel.com>, David Hildenbrand
	<david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	<alexander.duyck@gmail.com>
CC: "nitesh@redhat.com" <nitesh@redhat.com>, "kvm@vger.kernel.org"
	<kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "pagupta@redhat.com"
	<pagupta@redhat.com>, "riel@surriel.com" <riel@surriel.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "lcapitulino@redhat.com"
	<lcapitulino@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>,
	"pbonzini@redhat.com" <pbonzini@redhat.com>, "Williams, Dan J"
	<dan.j.williams@intel.com>, "alexander.h.duyck@linux.intel.com"
	<alexander.h.duyck@linux.intel.com>
Subject: RE: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Thread-Topic: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Thread-Index: AQHVJu8N4NsmOWYgsECNUD5FmiWYMqbMpTqAgABEaICAAANlAIAAB/cAgACHiYA=
Date: Tue, 16 Jul 2019 15:01:52 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73E16AB21@shsmsx102.ccr.corp.intel.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
 <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
In-Reply-To: <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNWRjOTlkMGQtNWY3NS00ZmFiLTg2MmQtYzE4NGNjZTcxNDA5IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiRFBDUXE2ZGhIUmg3UlwvaHNkeGxlVmVnR3BJSmF3SG05WkNCMlwvemR2R2ZEcEJHdmY0RjdIOGpCM3NWRTRGKzMzIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlc2RheSwgSnVseSAxNiwgMjAxOSAxMDo0MSBQTSwgSGFuc2VuLCBEYXZlIHdyb3RlOg0K
PiBXaGVyZSBpcyB0aGUgcGFnZSBhbGxvY2F0b3IgaW50ZWdyYXRpb24/ICBUaGUgc2V0IHlvdSBs
aW5rZWQgdG8gaGFzIDUgcGF0Y2hlcywNCj4gYnV0IG9ubHkgNCB3ZXJlIG1lcmdlZC4gIFRoaXMg
b25lIGlzIG1pc3Npbmc6DQo+IA0KPiAJaHR0cHM6Ly9sb3JlLmtlcm5lbC5vcmcvcGF0Y2h3b3Jr
L3BhdGNoLzk2MTAzOC8NCg0KRm9yIHNvbWUgcmVhc29uLCB3ZSB1c2VkIHRoZSByZWd1bGFyIHBh
Z2UgYWxsb2NhdGlvbiB0byBnZXQgcGFnZXMNCmZyb20gdGhlIGZyZWUgbGlzdCBhdCB0aGF0IHN0
YWdlLiBUaGlzIHBhcnQgY291bGQgYmUgaW1wcm92ZWQgYnkgQWxleA0Kb3IgTml0ZXNoJ3MgYXBw
cm9hY2guDQoNClRoZSBwYWdlIGFkZHJlc3MgdHJhbnNtaXNzaW9uIGZyb20gdGhlIGJhbGxvb24g
ZHJpdmVyIHRvIHRoZSBob3N0DQpkZXZpY2UgY291bGQgcmV1c2Ugd2hhdCdzIHVwc3RyZWFtZWQg
dGhlcmUuIEkgdGhpbmsgeW91IGNvdWxkIGFkZCBhDQpuZXcgVklSVElPX0JBTExPT05fQ01EX3h4
IGZvciB5b3VyIHVzYWdlcy4NCg0KQmVzdCwNCldlaQ0K

