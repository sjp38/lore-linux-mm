Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06F1FC32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4E1920C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:22:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4E1920C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 531B26B0003; Fri,  9 Aug 2019 14:22:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E26E6B0007; Fri,  9 Aug 2019 14:22:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D15C6B000C; Fri,  9 Aug 2019 14:22:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 059406B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:22:14 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y7so11098975pgq.3
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:22:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=LcV6V5yP+7/bxImRCG+SePtZnNFP4Ut8SFKw3Wlj1Ss=;
        b=gN7m5HIDtub5nCu1xYhegTHDc6V439tN/E9PJJx16nQf69YhxSmT7U04CRGDdlAPKq
         nrUAS7ijdkYzOWLRZy8uw2ixfMr9wMntzfXx5i7JckGKXRAVvbeLkVrYZwa+/+e8hxlL
         y+Bc7fI9UlkfdhKC/QBQ5zKsyYJU1g5hvOne6BMTQ5yOyJ0Dqgm65G5M1ZbgzJTRLG6L
         ptSwSKjufFBuLFDj8Gw3Kyuzvy29kK8NOLE5pEHYkrZu30eaKxMEreUqZmQ9laBBpqu6
         4anr6CWC3gPJCw1tYXgRrD6Jk+c70BOtt9O/VY8mL4KP1pLrn2mNnxdWz9g2RmWDXTri
         97gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU43SW8MYRHSZtdtnbvry5CeJJTTcDjIqGrgdSmTjthqlHNAamx
	3zAl7UBxIa82SOLf51rhiQ78sndN3v0XEAsG8Z6azvS1sP91x/xHD287KkiOd5J2G1qnJyh2WQs
	7h3HB7LkErIRltp7d7r0fSs6Kk3ZQ9cN3ZOFC8vVolcVzRDzwI+9Em2zyo+gcneW5RQ==
X-Received: by 2002:a17:902:223:: with SMTP id 32mr4315337plc.220.1565374933637;
        Fri, 09 Aug 2019 11:22:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIv3NNWIDkU6bO3F0hEahMBTyDwvS2krw/I9qxB0b5miiePSXwWXbMPbqNoL/mJG3LxRbK
X-Received: by 2002:a17:902:223:: with SMTP id 32mr4315294plc.220.1565374932754;
        Fri, 09 Aug 2019 11:22:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565374932; cv=none;
        d=google.com; s=arc-20160816;
        b=YMcg5r4uMcOd+bmKAn+9PCx2tKqMK4PyPlJEMmKJ46tOdhZQMOqJpyzosg9HIFi11o
         neKyQfCZAB+TPWmbFjP4EDLeiTniM7czOL8/bspry+H0k3BhBX/fBMpTNy+nXarzergy
         PX4k5rotZnyxLPfUaZD5s5WzuS/lYBtk/WK9wpwD51cxZydT5LnKPU5SLQMF0rWRdy9R
         JvgB9qXJepxDW5Gu7B31syo7hQ6Pogj5dZvK+XsmQOyOJkq8YSICcS+ECH7K78KARR05
         alTyskOtzOnqI3WYY34LQwmPDwjLn8cIN6dttLHYRESdW2hFBj3NMB90e3dovrIAriiC
         q3mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=LcV6V5yP+7/bxImRCG+SePtZnNFP4Ut8SFKw3Wlj1Ss=;
        b=gPlbm+1mD3sdYWa99rZZfnmIdhilgjUHEOs0Pu8V1troXbggmAfJEjrLVv3DGwryUh
         OyTsL+L7XXltCJI1taheEwC+mDNE97zBI7AT2YQyvUOjzIo821vSE+Zq9Gh/aWuSpHU9
         vYH3Jo6Fop7BVmnoh0VjtNWNKN/LbWxts8GoVVY2Z0WvQX/a2sLUdJccdQKmXxH0O0PE
         hMgdtZWc84G1Ueqqut2JTscjhUNqP6vFo/3OC0zHjnX/vye/djlm7xJVuz2bGiIlHGsi
         5M7lk4h81YznLm+lrNq1Rl52TehVSwofjCVtkyzflge5RMeXQUCiYD32rOcvolx9b4l9
         gIUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id bx21si4830237pjb.21.2019.08.09.11.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:22:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 11:22:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,366,1559545200"; 
   d="scan'208";a="186739728"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga002.jf.intel.com with ESMTP; 09 Aug 2019 11:22:10 -0700
Received: from fmsmsx102.amr.corp.intel.com (10.18.124.200) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 9 Aug 2019 11:22:10 -0700
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 FMSMSX102.amr.corp.intel.com (10.18.124.200) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 9 Aug 2019 11:22:10 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.115]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.51]) with mapi id 14.03.0439.000;
 Fri, 9 Aug 2019 12:22:08 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
CC: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "Williams, Dan J"
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, "Matthew
 Wilcox" <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
Subject: RE: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Thread-Topic: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Thread-Index: AQHVS9wAqKeuPoXzZkyLXp0tqoyMNKbv6+CAgADRpQCAAHJ+gIAAUE4AgACJIACAAD05gP//ln8AgAB54ICAAM5HUA==
Date: Fri, 9 Aug 2019 18:22:07 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79E7F453@CRSMSX101.amr.corp.intel.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <20190808234138.GA15908@iweiny-DESK2.sc.intel.com>
 <5713cc2b-b41c-142a-eb52-f5cda999eca7@nvidia.com>
In-Reply-To: <5713cc2b-b41c-142a-eb52-f5cda999eca7@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYmYwZDM5MDEtOTVmNS00YzJjLTk3OTMtNTgzN2EzOWFmOWE2IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiSHhuMlcydnYrT1htcHFmMllmYkFuREc0YU1BRVRSdHVlUjUxU0hydDk4SVZtY3dPYUZKdVloWUFCM0NQVVZYTiJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
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

PiANCj4gT24gOC84LzE5IDQ6NDEgUE0sIElyYSBXZWlueSB3cm90ZToNCj4gPiBPbiBUaHUsIEF1
ZyAwOCwgMjAxOSBhdCAwMzo1OToxNVBNIC0wNzAwLCBKb2huIEh1YmJhcmQgd3JvdGU6DQo+ID4+
IE9uIDgvOC8xOSAxMjoyMCBQTSwgSm9obiBIdWJiYXJkIHdyb3RlOg0KPiA+Pj4gT24gOC84LzE5
IDQ6MDkgQU0sIFZsYXN0aW1pbCBCYWJrYSB3cm90ZToNCj4gPj4+PiBPbiA4LzgvMTkgODoyMSBB
TSwgTWljaGFsIEhvY2tvIHdyb3RlOg0KPiA+Pj4+PiBPbiBXZWQgMDctMDgtMTkgMTY6MzI6MDgs
IEpvaG4gSHViYmFyZCB3cm90ZToNCj4gPj4+Pj4+IE9uIDgvNy8xOSA0OjAxIEFNLCBNaWNoYWwg
SG9ja28gd3JvdGU6DQo+ID4+Pj4+Pj4gT24gTW9uIDA1LTA4LTE5IDE1OjIwOjE3LCBqb2huLmh1
YmJhcmRAZ21haWwuY29tIHdyb3RlOg0KPiAuLi4NCj4gPj4gT2gsIGFuZCBtZWFud2hpbGUsIEkn
bSBsZWFuaW5nIHRvd2FyZCBhIGNoZWFwIGZpeDoganVzdCB1c2UNCj4gPj4gZ3VwX2Zhc3QoKSBp
bnN0ZWFkIG9mIGdldF9wYWdlKCksIGFuZCBhbHNvIGZpeCB0aGUgcmVsZWFzaW5nIGNvZGUuIFNv
DQo+ID4+IHRoaXMgaW5jcmVtZW50YWwgcGF0Y2gsIG9uIHRvcCBvZiB0aGUgZXhpc3Rpbmcgb25l
LCBzaG91bGQgZG8gaXQ6DQo+ID4+DQo+ID4+IGRpZmYgLS1naXQgYS9tbS9tbG9jay5jIGIvbW0v
bWxvY2suYw0KPiA+PiBpbmRleCBiOTgwZTYyNzBlOGEuLjJlYTI3MmM2ZmVlMyAxMDA2NDQNCj4g
Pj4gLS0tIGEvbW0vbWxvY2suYw0KPiA+PiArKysgYi9tbS9tbG9jay5jDQo+ID4+IEBAIC0zMTgs
MTggKzMxOCwxNCBAQCBzdGF0aWMgdm9pZCBfX211bmxvY2tfcGFnZXZlYyhzdHJ1Y3QgcGFnZXZl
Yw0KPiAqcHZlYywgc3RydWN0IHpvbmUgKnpvbmUpDQo+ID4+ICAgICAgICAgICAgICAgICAvKg0K
PiA+PiAgICAgICAgICAgICAgICAgICogV2Ugd29uJ3QgYmUgbXVubG9ja2luZyB0aGlzIHBhZ2Ug
aW4gdGhlIG5leHQgcGhhc2UNCj4gPj4gICAgICAgICAgICAgICAgICAqIGJ1dCB3ZSBzdGlsbCBu
ZWVkIHRvIHJlbGVhc2UgdGhlIGZvbGxvd19wYWdlX21hc2soKQ0KPiA+PiAtICAgICAgICAgICAg
ICAgICogcGluLiBXZSBjYW5ub3QgZG8gaXQgdW5kZXIgbHJ1X2xvY2sgaG93ZXZlci4gSWYgaXQn
cw0KPiA+PiAtICAgICAgICAgICAgICAgICogdGhlIGxhc3QgcGluLCBfX3BhZ2VfY2FjaGVfcmVs
ZWFzZSgpIHdvdWxkIGRlYWRsb2NrLg0KPiA+PiArICAgICAgICAgICAgICAgICogcGluLg0KPiA+
PiAgICAgICAgICAgICAgICAgICovDQo+ID4+IC0gICAgICAgICAgICAgICBwYWdldmVjX2FkZCgm
cHZlY19wdXRiYWNrLCBwdmVjLT5wYWdlc1tpXSk7DQo+ID4+ICsgICAgICAgICAgICAgICBwdXRf
dXNlcl9wYWdlKHBhZ2VzW2ldKTsNCj4gDQo+IGNvcnJlY3Rpb24sIG1ha2UgdGhhdDoNCj4gICAg
ICAgICAgICAgICAgICAgIHB1dF91c2VyX3BhZ2UocHZlYy0+cGFnZXNbaV0pOw0KPiANCj4gKFRo
aXMgaXMgbm90IGZ1bGx5IHRlc3RlZCB5ZXQuKQ0KPiANCj4gPj4gICAgICAgICAgICAgICAgIHB2
ZWMtPnBhZ2VzW2ldID0gTlVMTDsNCj4gPj4gICAgICAgICB9DQo+ID4+ICAgICAgICAgX19tb2Rf
em9uZV9wYWdlX3N0YXRlKHpvbmUsIE5SX01MT0NLLCBkZWx0YV9tdW5sb2NrZWQpOw0KPiA+PiAg
ICAgICAgIHNwaW5fdW5sb2NrX2lycSgmem9uZS0+em9uZV9wZ2RhdC0+bHJ1X2xvY2spOw0KPiA+
Pg0KPiA+PiAtICAgICAgIC8qIE5vdyB3ZSBjYW4gcmVsZWFzZSBwaW5zIG9mIHBhZ2VzIHRoYXQg
d2UgYXJlIG5vdCBtdW5sb2NraW5nICovDQo+ID4+IC0gICAgICAgcGFnZXZlY19yZWxlYXNlKCZw
dmVjX3B1dGJhY2spOw0KPiA+PiAtDQo+ID4NCj4gPiBJJ20gbm90IGFuIGV4cGVydCBidXQgdGhp
cyBza2lwcyBhIGNhbGwgdG8gbHJ1X2FkZF9kcmFpbigpLiAgSXMgdGhhdCBvaz8NCj4gDQo+IFll
czogdW5sZXNzIEknbSBtaXNzaW5nIHNvbWV0aGluZywgdGhlcmUgaXMgbm8gcmVhc29uIHRvIGdv
IHRocm91Z2gNCj4gbHJ1X2FkZF9kcmFpbiBpbiB0aGlzIGNhc2UuIFRoZXNlIGFyZSBndXAnZCBw
YWdlcyB0aGF0IGFyZSBub3QgZ29pbmcgdG8gZ2V0DQo+IGFueSBmdXJ0aGVyIHByb2Nlc3Npbmcu
DQo+IA0KPiA+DQo+ID4+ICAgICAgICAgLyogUGhhc2UgMjogcGFnZSBtdW5sb2NrICovDQo+ID4+
ICAgICAgICAgZm9yIChpID0gMDsgaSA8IG5yOyBpKyspIHsNCj4gPj4gICAgICAgICAgICAgICAg
IHN0cnVjdCBwYWdlICpwYWdlID0gcHZlYy0+cGFnZXNbaV07IEBAIC0zOTQsNiArMzkwLDgNCj4g
Pj4gQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgX19tdW5sb2NrX3BhZ2V2ZWNfZmlsbChzdHJ1Y3Qg
cGFnZXZlYyAqcHZlYywNCj4gPj4gICAgICAgICBzdGFydCArPSBQQUdFX1NJWkU7DQo+ID4+ICAg
ICAgICAgd2hpbGUgKHN0YXJ0IDwgZW5kKSB7DQo+ID4+ICAgICAgICAgICAgICAgICBzdHJ1Y3Qg
cGFnZSAqcGFnZSA9IE5VTEw7DQo+ID4+ICsgICAgICAgICAgICAgICBpbnQgcmV0Ow0KPiA+PiAr
DQo+ID4+ICAgICAgICAgICAgICAgICBwdGUrKzsNCj4gPj4gICAgICAgICAgICAgICAgIGlmIChw
dGVfcHJlc2VudCgqcHRlKSkNCj4gPj4gICAgICAgICAgICAgICAgICAgICAgICAgcGFnZSA9IHZt
X25vcm1hbF9wYWdlKHZtYSwgc3RhcnQsICpwdGUpOyBAQA0KPiA+PiAtNDExLDcgKzQwOSwxMyBA
QCBzdGF0aWMgdW5zaWduZWQgbG9uZyBfX211bmxvY2tfcGFnZXZlY19maWxsKHN0cnVjdA0KPiBw
YWdldmVjICpwdmVjLA0KPiA+PiAgICAgICAgICAgICAgICAgaWYgKFBhZ2VUcmFuc0NvbXBvdW5k
KHBhZ2UpKQ0KPiA+PiAgICAgICAgICAgICAgICAgICAgICAgICBicmVhazsNCj4gPj4NCj4gPj4g
LSAgICAgICAgICAgICAgIGdldF9wYWdlKHBhZ2UpOw0KPiA+PiArICAgICAgICAgICAgICAgLyoN
Cj4gPj4gKyAgICAgICAgICAgICAgICAqIFVzZSBnZXRfdXNlcl9wYWdlc19mYXN0KCksIGluc3Rl
YWQgb2YgZ2V0X3BhZ2UoKSBzbyB0aGF0IHRoZQ0KPiA+PiArICAgICAgICAgICAgICAgICogcmVs
ZWFzaW5nIGNvZGUgY2FuIHVuY29uZGl0aW9uYWxseSBjYWxsIHB1dF91c2VyX3BhZ2UoKS4NCj4g
Pj4gKyAgICAgICAgICAgICAgICAqLw0KPiA+PiArICAgICAgICAgICAgICAgcmV0ID0gZ2V0X3Vz
ZXJfcGFnZXNfZmFzdChzdGFydCwgMSwgMCwgJnBhZ2UpOw0KPiA+PiArICAgICAgICAgICAgICAg
aWYgKHJldCAhPSAxKQ0KPiA+PiArICAgICAgICAgICAgICAgICAgICAgICBicmVhazsNCj4gPg0K
PiA+IEkgbGlrZSB0aGUgaWRlYSBvZiBtYWtpbmcgdGhpcyBhIGdldC9wdXQgcGFpciBidXQgSSdt
IGZlZWxpbmcgdW5lYXN5DQo+ID4gYWJvdXQgaG93IHRoaXMgaXMgcmVhbGx5IHN1cHBvc2VkIHRv
IHdvcmsuDQo+ID4NCj4gPiBGb3Igc3VyZSB0aGUgR1VQL1BVUCB3YXMgc3VwcG9zZWQgdG8gYmUg
c2VwYXJhdGUgZnJvbSBbZ2V0fHB1dF1fcGFnZS4NCj4gPg0KPiANCj4gQWN0dWFsbHksIHRoZXkg
Ym90aCB0YWtlIHJlZmVyZW5jZXMgb24gdGhlIHBhZ2UuIEFuZCBpdCBpcyBhYnNvbHV0ZWx5IE9L
IHRvIGNhbGwNCj4gdGhlbSBib3RoIG9uIHRoZSBzYW1lIHBhZ2UuDQo+IA0KPiBCdXQgYW55d2F5
LCB3ZSdyZSBub3QgbWl4aW5nIHRoZW0gdXAgaGVyZS4gSWYgeW91IGZvbGxvdyB0aGUgY29kZSBw
YXRocywNCj4gZWl0aGVyIGd1cCBvciBmb2xsb3dfcGFnZV9tYXNrKCkgaXMgdXNlZCwgYW5kIHRo
ZW4gcHV0X3VzZXJfcGFnZSgpDQo+IHJlbGVhc2VzLg0KPiANCj4gU28uLi55b3UgaGF2ZW4ndCBh
Y3R1YWxseSBwb2ludGVkIHRvIGEgYnVnIGhlcmUsIHJpZ2h0PyA6KQ0KDQpOby4uLiAgbm8gYnVn
Lg0KDQpzb3JyeSB0aGlzIHdhcyBqdXN0IGEgZ2VuZXJhbCBjb21tZW50IG9uIHNlbWFudGljcy4g
IEJ1dCBpbiBrZWVwaW5nIHdpdGggdGhlIHNlbWFudGljcyBkaXNjdXNzaW9uIGl0IGlzIGZ1cnRo
ZXIgY29uZnVzaW5nIHRoYXQgZm9sbG93X3BhZ2VfbWFzaygpIGlzIGFsc28gbWl4ZWQgaW4gaGVy
ZS4uLg0KDQpXaGljaCBpcyB3aGVyZSBteSBjb21tZW50IHdhcyBkcml2aW5nIHRvd2FyZC4gIElm
IHlvdSBjYWxsIEdVUCB0aGVyZSBzaG91bGQgYmUgYSBQVVAuICBHZXRfcGFnZS9wdXRfcGFnZS4u
LiAgZm9sbG93X3BhZ2UvdW5mb2xsb3dfcGFnZS4uLiAgPz8/ICA7LSkgIE9rIG5vdyBJJ20gb2Zm
IHRoZSByYWlscy4uLiAgYnV0IHRoYXQgd2FzIHRoZSBwb2ludC4uLg0KDQpJIHRoaW5rIEphbiBh
bmQgTWljaGFsIGFyZSBvbnRvIHNvbWV0aGluZyBoZXJlIFdSVCBpbnRlcm5hbCB2cyBleHRlcm5h
bCBpbnRlcmZhY2VzLg0KDQpJcmENCg0K

