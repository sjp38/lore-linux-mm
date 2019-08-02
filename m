Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62831C41514
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4F642087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:09:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4F642087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 693D66B0006; Fri,  2 Aug 2019 12:09:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 644406B0008; Fri,  2 Aug 2019 12:09:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4980D6B000D; Fri,  2 Aug 2019 12:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12C5F6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 12:09:50 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so48554754pff.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 09:09:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=LPCMYAL9J/0iBdkZNuzBqBYIM2wA9HqAOi3OoU2C+HY=;
        b=GSNNa4UYupHJBcsI1QYyz/Hb7Sy8NgJPvaL/xrbUCPvFmQV+8aeX8ioRG+0z6YMWDd
         FDeVWYh0S+ttqnQ1y46/DmlBF220hGDQnjDEluia0mOsoM/2hYgL4FbaV30lI3ebWMi9
         URmwy3Ht4fVbf7YLN3EbKXfkCf7BRGCVCfEaXqOjIPSixey+Ccm4To9Xp83ByuAW3M4L
         tusDaikju9SZBuH1KbcKRxSVXd7wKyNmNY4wTmtoIRa1z5C0z+frreOyhVuhK8F2N0rX
         vNeAXMThWqeEbYPs0DFwSY4abNPIViL9Jl2He2PrVyLzQsaQbxVBU3aRFoBiLuz97z7M
         VB3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX9Y+W343CQhGHnTNzrq90tRt57YY7MxoJDzDHXukpqFrNAmVZy
	WeAV1P+IzL5h6wzKH+pFIPdAGMYRt3OowZmxOcBQTtkHkycpbtQZfn2dWta3HpJWgkaDWSeVuHI
	m2O6U0qc1/cKBb2L2XJMrCNZ1ErUeNGK8TmOXDZ4KVzc63yDu3DBDlv9GrKWZeVlhIA==
X-Received: by 2002:a65:6294:: with SMTP id f20mr128389405pgv.349.1564762189611;
        Fri, 02 Aug 2019 09:09:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKEfWYBdYx30f4v/yS9Cb4uS2PyZ5Hdic/WIgWOuF5RKoOPx9vxayKMM8Cb+vlsdjypNb2
X-Received: by 2002:a65:6294:: with SMTP id f20mr128389343pgv.349.1564762188745;
        Fri, 02 Aug 2019 09:09:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564762188; cv=none;
        d=google.com; s=arc-20160816;
        b=t3Stjprro5yPUXRsuIcHc3gSHXrIJmnVttSgsVNOR2SMt1VajMnh6RwHSfyC/nPTtH
         mGYEqxyRtTbcGq2DP3+Zve4bXw7SyFk/pDZK6SKHA6tInv8QGh2CShEBmDG0nqOdbV86
         qIeCm4eOxwe4zgph+0H+yu4Q2i2eBOrDy60ZqT+6+WdFmyA0RAih3NqtlAKhwpR8fCRT
         2QbA3Oms46u7NJHDT0fRgavNQ+Iuog3vNXpomkiMUPq+REr4KIQLkwZqUTCgUYSO1e3a
         lU2DH7RhB4y7TdkmCIzTQfydv97dRWhqsofAl2D14zkU48Zj6wGW3w/K0qhUTwa6470P
         USug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=LPCMYAL9J/0iBdkZNuzBqBYIM2wA9HqAOi3OoU2C+HY=;
        b=V5LiOv1LWT+kjFFggzS7GN8VXAstZABhbomsnFnSiny6zIbpTCKYrn5D5CRBzzD1Gz
         0mBPfRmupig8G64abQcyi/t8c+r6LcqehH06A3+dENfz+GC+6T32H7fv1X9MB1RaETHx
         hTXETzCu5YhwgiDmvOGTid8etLnTvpHmH/S4AwAhEnQjjRc642vsHUwGF/nXCaAT1Yea
         oq3ftul+GJzcXdZOrkG4MtQvUJYIgnPU6mVuvgGX1JO22kjaeuJ00Gf99UlfDuabg5qj
         0+D+ay8Q9ISzs0Cfh/RzVQagaszULzNgmqrBlSzukqOzwujSxFzoho0znUtr476bviwe
         TWUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o2si11136897pfg.136.2019.08.02.09.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 09:09:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 09:09:47 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,338,1559545200"; 
   d="scan'208";a="372996055"
Received: from fmsmsx108.amr.corp.intel.com ([10.18.124.206])
  by fmsmga006.fm.intel.com with ESMTP; 02 Aug 2019 09:09:47 -0700
Received: from fmsmsx122.amr.corp.intel.com (10.18.125.37) by
 FMSMSX108.amr.corp.intel.com (10.18.124.206) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 2 Aug 2019 09:09:48 -0700
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 fmsmsx122.amr.corp.intel.com (10.18.125.37) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 2 Aug 2019 09:09:47 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.115]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.51]) with mapi id 14.03.0439.000;
 Fri, 2 Aug 2019 10:09:45 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Juergen Gross <jgross@suse.com>, John Hubbard <jhubbard@nvidia.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Dave Chinner
	<david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Williams, Dan
 J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Hansen
	<dave.hansen@linux.intel.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "devel@lists.orangefs.org"
	<devel@lists.orangefs.org>, "xen-devel@lists.xenproject.org"
	<xen-devel@lists.xenproject.org>, Boris Ostrovsky
	<boris.ostrovsky@oracle.com>, "rds-devel@oss.oracle.com"
	<rds-devel@oss.oracle.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "ceph-devel@vger.kernel.org"
	<ceph-devel@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
Subject: RE: [PATCH 20/34] xen: convert put_page() to put_user_page*()
Thread-Topic: [PATCH 20/34] xen: convert put_page() to put_user_page*()
Thread-Index: AQHVSNjlYWPmavKIo0aaO/eIo60VTqbnqrGAgAAT84CAAAYcgIAAQruQ
Date: Fri, 2 Aug 2019 16:09:44 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79E66216@CRSMSX101.amr.corp.intel.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-21-jhubbard@nvidia.com>
 <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
 <d5140833-e9ee-beb5-ff0a-2d13a4fe819f@nvidia.com>
 <d4931311-db01-e8c3-0f8c-d64685dc2143@suse.com>
In-Reply-To: <d4931311-db01-e8c3-0f8c-d64685dc2143@suse.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZTRmN2E3MTYtMGM4Yi00ZWFmLTk2Y2YtNDU3NGNhMWI3OGZmIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoicmZLd2FNcXRLU2Rkc2k3dFluUytKTjZ2XC9UUlFtczVETG53ZjA3V1hcL0FrcFBtWE5EdUh2U1dwRnZrV1dScDdtIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
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

PiANCj4gT24gMDIuMDguMTkgMDc6NDgsIEpvaG4gSHViYmFyZCB3cm90ZToNCj4gPiBPbiA4LzEv
MTkgOTozNiBQTSwgSnVlcmdlbiBHcm9zcyB3cm90ZToNCj4gPj4gT24gMDIuMDguMTkgMDQ6MTks
IGpvaG4uaHViYmFyZEBnbWFpbC5jb20gd3JvdGU6DQo+ID4+PiBGcm9tOiBKb2huIEh1YmJhcmQg
PGpodWJiYXJkQG52aWRpYS5jb20+DQo+ID4gLi4uDQo+ID4+PiBkaWZmIC0tZ2l0IGEvZHJpdmVy
cy94ZW4vcHJpdmNtZC5jIGIvZHJpdmVycy94ZW4vcHJpdmNtZC5jIGluZGV4DQo+ID4+PiAyZjVj
ZTcyMzBhNDMuLjI5ZTQ2MWRiZWUyZCAxMDA2NDQNCj4gPj4+IC0tLSBhL2RyaXZlcnMveGVuL3By
aXZjbWQuYw0KPiA+Pj4gKysrIGIvZHJpdmVycy94ZW4vcHJpdmNtZC5jDQo+ID4+PiBAQCAtNjEx
LDE1ICs2MTEsMTAgQEAgc3RhdGljIGludCBsb2NrX3BhZ2VzKA0KPiA+Pj4gwqAgc3RhdGljIHZv
aWQgdW5sb2NrX3BhZ2VzKHN0cnVjdCBwYWdlICpwYWdlc1tdLCB1bnNpZ25lZCBpbnQNCj4gPj4+
IG5yX3BhZ2VzKQ0KPiA+Pj4gwqAgew0KPiA+Pj4gLcKgwqDCoCB1bnNpZ25lZCBpbnQgaTsNCj4g
Pj4+IC0NCj4gPj4+IMKgwqDCoMKgwqAgaWYgKCFwYWdlcykNCj4gPj4+IMKgwqDCoMKgwqDCoMKg
wqDCoCByZXR1cm47DQo+ID4+PiAtwqDCoMKgIGZvciAoaSA9IDA7IGkgPCBucl9wYWdlczsgaSsr
KSB7DQo+ID4+PiAtwqDCoMKgwqDCoMKgwqAgaWYgKHBhZ2VzW2ldKQ0KPiA+Pj4gLcKgwqDCoMKg
wqDCoMKgwqDCoMKgwqAgcHV0X3BhZ2UocGFnZXNbaV0pOw0KPiA+Pj4gLcKgwqDCoCB9DQo+ID4+
PiArwqDCoMKgIHB1dF91c2VyX3BhZ2VzKHBhZ2VzLCBucl9wYWdlcyk7DQo+ID4+DQo+ID4+IFlv
dSBhcmUgbm90IGhhbmRsaW5nIHRoZSBjYXNlIHdoZXJlIHBhZ2VzW2ldIGlzIE5VTEwgaGVyZS4g
T3IgYW0gSQ0KPiA+PiBtaXNzaW5nIGEgcGVuZGluZyBwYXRjaCB0byBwdXRfdXNlcl9wYWdlcygp
IGhlcmU/DQo+ID4+DQo+ID4NCj4gPiBIaSBKdWVyZ2VuLA0KPiA+DQo+ID4gWW91IGFyZSBjb3Jy
ZWN0LS10aGlzIG5vIGxvbmdlciBoYW5kbGVzIHRoZSBjYXNlcyB3aGVyZSBwYWdlc1tpXSBpcw0K
PiA+IE5VTEwuIEl0J3MgaW50ZW50aW9uYWwsIHRob3VnaCBwb3NzaWJseSB3cm9uZy4gOikNCj4g
Pg0KPiA+IEkgc2VlIHRoYXQgSSBzaG91bGQgaGF2ZSBhZGRlZCBteSBzdGFuZGFyZCBibHVyYiB0
byB0aGlzIGNvbW1pdA0KPiA+IGRlc2NyaXB0aW9uLiBJIG1pc3NlZCB0aGlzIG9uZSwgYnV0IHNv
bWUgb2YgdGhlIG90aGVyIHBhdGNoZXMgaGF2ZSBpdC4NCj4gPiBJdCBtYWtlcyB0aGUgZm9sbG93
aW5nLCBwb3NzaWJseSBpbmNvcnJlY3QgY2xhaW06DQo+ID4NCj4gPiAiVGhpcyBjaGFuZ2VzIHRo
ZSByZWxlYXNlIGNvZGUgc2xpZ2h0bHksIGJlY2F1c2UgZWFjaCBwYWdlIHNsb3QgaW4gdGhlDQo+
ID4gcGFnZV9saXN0W10gYXJyYXkgaXMgbm8gbG9uZ2VyIGNoZWNrZWQgZm9yIE5VTEwuIEhvd2V2
ZXIsIHRoYXQgY2hlY2sNCj4gPiB3YXMgd3JvbmcgYW55d2F5LCBiZWNhdXNlIHRoZSBnZXRfdXNl
cl9wYWdlcygpIHBhdHRlcm4gb2YgdXNhZ2UgaGVyZQ0KPiA+IG5ldmVyIGFsbG93ZWQgZm9yIE5V
TEwgZW50cmllcyB3aXRoaW4gYSByYW5nZSBvZiBwaW5uZWQgcGFnZXMuIg0KPiA+DQo+ID4gVGhl
IHdheSBJJ3ZlIHNlZW4gdGhlc2UgcGFnZSBhcnJheXMgdXNlZCB3aXRoIGdldF91c2VyX3BhZ2Vz
KCksIHRoaW5ncw0KPiA+IGFyZSBlaXRoZXIgZG9uZSBzaW5nbGUgcGFnZSwgb3Igd2l0aCBhIGNv
bnRpZ3VvdXMgcmFuZ2UuIFNvIHVubGVzcyBJJ20NCj4gPiBtaXNzaW5nIGEgY2FzZSB3aGVyZSBz
b21lb25lIGlzIGVpdGhlcg0KPiA+DQo+ID4gYSkgcmVsZWFzaW5nIGluZGl2aWR1YWwgcGFnZXMg
d2l0aGluIGEgcmFuZ2UgKGFuZCB0aHVzIGxpa2VseSBtZXNzaW5nDQo+ID4gdXAgdGhlaXIgY291
bnQgb2YgcGFnZXMgdGhleSBoYXZlKSwgb3INCj4gPg0KPiA+IGIpIGFsbG9jYXRpbmcgdHdvIGd1
cCByYW5nZXMgd2l0aGluIHRoZSBzYW1lIHBhZ2VzW10gYXJyYXksIHdpdGggYSBnYXANCj4gPiBi
ZXR3ZWVuIHRoZSBhbGxvY2F0aW9ucywNCj4gPg0KPiA+IC4uLnRoZW4gaXQgc2hvdWxkIGJlIGNv
cnJlY3QuIElmIHNvLCB0aGVuIEknbGwgYWRkIHRoZSBhYm92ZSBibHVyYiB0bw0KPiA+IHRoaXMg
cGF0Y2gncyBjb21taXQgZGVzY3JpcHRpb24uDQo+ID4NCj4gPiBJZiB0aGF0J3Mgbm90IHRoZSBj
YXNlIChib3RoIGhlcmUsIGFuZCBpbiAzIG9yIDQgb3RoZXIgcGF0Y2hlcyBpbiB0aGlzDQo+ID4g
c2VyaWVzLCB0aGVuIGFzIHlvdSBzYWlkLCBJIHNob3VsZCBhZGQgTlVMTCBjaGVja3MgdG8gcHV0
X3VzZXJfcGFnZXMoKQ0KPiA+IGFuZCBwdXRfdXNlcl9wYWdlc19kaXJ0eV9sb2NrKCkuDQo+IA0K
PiBJbiB0aGlzIGNhc2UgaXQgaXMgbm90IGNvcnJlY3QsIGJ1dCBjYW4gZWFzaWx5IGJlIGhhbmRs
ZWQuIFRoZSBOVUxMIGNhc2UgY2FuDQo+IG9jY3VyIG9ubHkgaW4gYW4gZXJyb3IgY2FzZSB3aXRo
IHRoZSBwYWdlcyBhcnJheSBmaWxsZWQgcGFydGlhbGx5IG9yIG5vdCBhdCBhbGwuDQo+IA0KPiBJ
J2QgcHJlZmVyIHNvbWV0aGluZyBsaWtlIHRoZSBhdHRhY2hlZCBwYXRjaCBoZXJlLg0KDQpJJ20g
bm90IGFuIGV4cGVydCBpbiB0aGlzIGNvZGUgYW5kIGhhdmUgbm90IGxvb2tlZCBhdCBpdCBjYXJl
ZnVsbHkgYnV0IHRoYXQgcGF0Y2ggZG9lcyBzZWVtIHRvIGJlIHRoZSBiZXR0ZXIgZml4IHRoYW4g
Zm9yY2luZyBOVUxMIGNoZWNrcyBvbiBldmVyeW9uZS4NCg0KSXJhDQoNCg==

