Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21CF2C4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC1B207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:00:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC1B207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E91C6B026B; Mon, 10 Jun 2019 14:00:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 699D06B026C; Mon, 10 Jun 2019 14:00:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B0236B026D; Mon, 10 Jun 2019 14:00:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24B676B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:00:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so6158982plr.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=GUizFaAbRtGn58sPkPJQSI8JiHY6LbxuekU4vIduCrE=;
        b=uTZOR2YDaIdMaCYvTX+w3KDRd7fL22fkOt2o4QUlrLF9lrdcnDkCscDLpWBTFCRL82
         9vBv8ewfjXD+nNP36GWU90WElPUDQaN5QjFkS6wwAL14k0vlLY+COf+eQGWB19pmudzk
         hp6WYkzSGCPchuT+LMPqPWsX40e21l5dsJn6N39COdwIsObwzVPtGIrClj/NJMyCECfW
         i4gaxheaayS2ttfzjrRwB6O5PoDkqE7BgSAXTz7f/y7wPdKFq2gYGSlqqPTTSE1UGXj1
         H/mBmpC7zQ6SCqMQo8VOfZdCYXLRMJjxulxFRzT1rUdoSw/Vf5zp8ffIJiIJQw5MyEu2
         Bftw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkbjcSoa8Ll7+TIwyRIRXv4NvaI1DjOMzQIbcIUGY185NZNNAv
	GowGU1MU7VLdke8moi9nQq/t1IjNi57K7qoz/VNmlZN04mkF0qZQWyGEMmPiN3zIQ6c8y9SK0R2
	NV+QNDNZJSTXzVRktyYZrv6MgLpdiWvJSQvdfEFDxUa47kyS0PKqXwvE80bGroQzmUQ==
X-Received: by 2002:a63:6b08:: with SMTP id g8mr17412425pgc.106.1560189645747;
        Mon, 10 Jun 2019 11:00:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXYg3LA2o/CEtqXFu6cV2PHNTeEnEAR44iwHZdvspfVnf/dwFPPdwYwFgvBK857CIL5R6u
X-Received: by 2002:a63:6b08:: with SMTP id g8mr17412309pgc.106.1560189644216;
        Mon, 10 Jun 2019 11:00:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560189644; cv=none;
        d=google.com; s=arc-20160816;
        b=ZQV0VWYX9nh1xRc2sQvA3dyX03UPTSFnXJEfs2/gi4cx4TqqN+0cUF/pMfOpOOd4Kw
         n7NA1rEheoyomesP/vNKHOpMlQYM2zQB9vpOexk6kXkrkOVScLr1h/MZope2QZbnNCXB
         Pqix4rhhhYF3fcLx06YnaBvwqcfBjo69H3jHFfKQDCpwd5s6eYewCTWBz00gUZCws6MC
         sOgkU7Tqd7nhUWAsYK7/xs37hyv3RVDZBatiOdzpLaxYVVNGojtHMHQMKk8LQ8ghxsT6
         jSaDThXhoMr+rMifOe1OfMaW9wMBmGEl00l3dhaiU51eFstpLFDA0UdcRXY7TheZMZeD
         elcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=GUizFaAbRtGn58sPkPJQSI8JiHY6LbxuekU4vIduCrE=;
        b=l9kLXcyfrWBteG8q+rhJ1f7Qc+gEKPU0pGOTTMV0wzcCY2T8C/Q2vkAhp6DIVhh98F
         Slzr3CnhnShEd8yodAqYLRbWBPnzKU377y/Dx9sdk0AJHs+/WM5bEWSmVEP8N7Mf3DVO
         lmBcquAt/NvM+b3KYsSGU4QK+nBFJKgpYSEkyRCIf1xFdJeYT2bNtROzg+DPT8h6psZF
         RtkUCrETIc9mfAEYEkKwXHcnejkpcsn0Oq1COhK8adA3YkAh84VS08Qhzq8HXxAcBXg/
         orNiXpWs3c1OfWCtKm+HaolVzVFbxkNI61jhji6rhZ5GBI5eiaEmz0zW3t/O5vT1RYKW
         ZNYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o3si10685951pld.102.2019.06.10.11.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 11:00:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 11:00:43 -0700
X-ExtLoop1: 1
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by FMSMGA003.fm.intel.com with ESMTP; 10 Jun 2019 11:00:43 -0700
Received: from fmsmsx153.amr.corp.intel.com (10.18.125.6) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 10 Jun 2019 11:00:43 -0700
Received: from fmsmsx113.amr.corp.intel.com ([169.254.13.221]) by
 FMSMSX153.amr.corp.intel.com ([169.254.9.44]) with mapi id 14.03.0415.000;
 Mon, 10 Jun 2019 11:00:42 -0700
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
To: "aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>, "Williams, Dan
 J" <dan.j.williams@intel.com>
CC: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: =?utf-8?B?UmU6IFtQQVRDSF0gbW0vbnZkaW1tOiBGaXggZW5kaWFuIGNvbnZlcnNpb24g?=
 =?utf-8?B?aXNzdWVzwqA=?=
Thread-Topic: =?utf-8?B?W1BBVENIXSBtbS9udmRpbW06IEZpeCBlbmRpYW4gY29udmVyc2lvbiBpc3N1?=
 =?utf-8?B?ZXPCoA==?=
Thread-Index: AQHVHPzvNVRBYBN6b0uXWFFw88SJnqaVqDUA
Date: Mon, 10 Jun 2019 18:00:42 +0000
Message-ID: <1ec64d511af872df7b0597895622eb196ac4dbc9.camel@intel.com>
References: <20190607064732.30384-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190607064732.30384-1-aneesh.kumar@linux.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.5 (3.30.5-1.fc29) 
x-originating-ip: [10.232.112.185]
Content-Type: text/plain; charset="utf-8"
Content-ID: <41D4EB0C81964E4BB929D8F7CE095E4A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA2LTA3IGF0IDEyOjE3ICswNTMwLCBBbmVlc2ggS3VtYXIgSy5WIHdyb3Rl
Og0KPiBuZF9sYWJlbC0+ZHBhIGlzc3VlIHdhcyBvYnNlcnZlZCB3aGVuIHRyeWluZyB0byBlbmFi
bGUgdGhlIG5hbWVzcGFjZSBjcmVhdGVkDQo+IHdpdGggbGl0dGxlLWVuZGlhbiBrZXJuZWwgb24g
YSBiaWctZW5kaWFuIGtlcm5lbC4gVGhhdCBtYWRlIG1lIHJ1bg0KPiBgc3BhcnNlYCBvbiB0aGUg
cmVzdCBvZiB0aGUgY29kZSBhbmQgb3RoZXIgY2hhbmdlcyBhcmUgdGhlIHJlc3VsdCBvZiB0aGF0
Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQW5lZXNoIEt1bWFyIEsuViA8YW5lZXNoLmt1bWFyQGxp
bnV4LmlibS5jb20+DQo+IC0tLQ0KPiAgZHJpdmVycy9udmRpbW0vYnR0LmMgICAgICAgICAgICB8
IDggKysrKy0tLS0NCj4gIGRyaXZlcnMvbnZkaW1tL25hbWVzcGFjZV9kZXZzLmMgfCA3ICsrKyst
LS0NCj4gIDIgZmlsZXMgY2hhbmdlZCwgOCBpbnNlcnRpb25zKCspLCA3IGRlbGV0aW9ucygtKQ0K
DQpUaGUgdHdvIEJUVCBmaXhlcyBzZWVtIGxpa2UgdGhleSBtYXkgYXBwbHkgdG8gc3RhYmxlIGFz
IHdlbGwsIHRoZQ0KcHJvYmxlbWF0aWMgY29kZSB3YXMgaW50cm9kdWNlZCBpbiByZWxhdGl2ZWx5
IHJlY2VudCByZXdvcmtzL2ZpeGVzLg0KUGVyaGFwcyAtDQoNCkZpeGVzOiBkOWI4M2M3NTY5NTMg
KCJsaWJudmRpbW0sIGJ0dDogcmV3b3JrIGVycm9yIGNsZWFyaW5nIikNCkZpeGVzOiA5ZGVkYzcz
YTQ2NTggKCJsaWJudmRpbW0vYnR0OiBGaXggTEJBIG1hc2tpbmcgZHVyaW5nICdmcmVlIGxpc3Qn
IHBvcHVsYXRpb24iKQ0KDQpPdGhlciB0aGFuIHRoYXQsIHRoZXNlIGxvb2sgZ29vZCB0byBtZS4N
ClJldmlld2VkLWJ5OiBWaXNoYWwgVmVybWEgPHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbT4NCg0K
PiANCj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbnZkaW1tL2J0dC5jIGIvZHJpdmVycy9udmRpbW0v
YnR0LmMNCj4gaW5kZXggNDY3MTc3NmY1NjIzLi40YWMwZjVkZGU0NjcgMTAwNjQ0DQo+IC0tLSBh
L2RyaXZlcnMvbnZkaW1tL2J0dC5jDQo+ICsrKyBiL2RyaXZlcnMvbnZkaW1tL2J0dC5jDQo+IEBA
IC00MDAsOSArNDAwLDkgQEAgc3RhdGljIGludCBidHRfZmxvZ193cml0ZShzdHJ1Y3QgYXJlbmFf
aW5mbyAqYXJlbmEsIHUzMiBsYW5lLCB1MzIgc3ViLA0KPiAgCWFyZW5hLT5mcmVlbGlzdFtsYW5l
XS5zdWIgPSAxIC0gYXJlbmEtPmZyZWVsaXN0W2xhbmVdLnN1YjsNCj4gIAlpZiAoKysoYXJlbmEt
PmZyZWVsaXN0W2xhbmVdLnNlcSkgPT0gNCkNCj4gIAkJYXJlbmEtPmZyZWVsaXN0W2xhbmVdLnNl
cSA9IDE7DQo+IC0JaWYgKGVudF9lX2ZsYWcoZW50LT5vbGRfbWFwKSkNCj4gKwlpZiAoZW50X2Vf
ZmxhZyhsZTMyX3RvX2NwdShlbnQtPm9sZF9tYXApKSkNCj4gIAkJYXJlbmEtPmZyZWVsaXN0W2xh
bmVdLmhhc19lcnIgPSAxOw0KPiAtCWFyZW5hLT5mcmVlbGlzdFtsYW5lXS5ibG9jayA9IGxlMzJf
dG9fY3B1KGVudF9sYmEoZW50LT5vbGRfbWFwKSk7DQo+ICsJYXJlbmEtPmZyZWVsaXN0W2xhbmVd
LmJsb2NrID0gZW50X2xiYShsZTMyX3RvX2NwdShlbnQtPm9sZF9tYXApKTsNCj4gIA0KPiAgCXJl
dHVybiByZXQ7DQo+ICB9DQo+IEBAIC01NjgsOCArNTY4LDggQEAgc3RhdGljIGludCBidHRfZnJl
ZWxpc3RfaW5pdChzdHJ1Y3QgYXJlbmFfaW5mbyAqYXJlbmEpDQo+ICAJCSAqIEZJWE1FOiBpZiBl
cnJvciBjbGVhcmluZyBmYWlscyBkdXJpbmcgaW5pdCwgd2Ugd2FudCB0byBtYWtlDQo+ICAJCSAq
IHRoZSBCVFQgcmVhZC1vbmx5DQo+ICAJCSAqLw0KPiAtCQlpZiAoZW50X2VfZmxhZyhsb2dfbmV3
Lm9sZF9tYXApICYmDQo+IC0JCQkJIWVudF9ub3JtYWwobG9nX25ldy5vbGRfbWFwKSkgew0KPiAr
CQlpZiAoZW50X2VfZmxhZyhsZTMyX3RvX2NwdShsb2dfbmV3Lm9sZF9tYXApKSAmJg0KPiArCQkg
ICAgIWVudF9ub3JtYWwobGUzMl90b19jcHUobG9nX25ldy5vbGRfbWFwKSkpIHsNCj4gIAkJCWFy
ZW5hLT5mcmVlbGlzdFtpXS5oYXNfZXJyID0gMTsNCj4gIAkJCXJldCA9IGFyZW5hX2NsZWFyX2Zy
ZWVsaXN0X2Vycm9yKGFyZW5hLCBpKTsNCj4gIAkJCWlmIChyZXQpDQo+IGRpZmYgLS1naXQgYS9k
cml2ZXJzL252ZGltbS9uYW1lc3BhY2VfZGV2cy5jIGIvZHJpdmVycy9udmRpbW0vbmFtZXNwYWNl
X2RldnMuYw0KPiBpbmRleCBjNGM1YTE5MWIxZDYuLjUwMGMzN2RiNDk2YSAxMDA2NDQNCj4gLS0t
IGEvZHJpdmVycy9udmRpbW0vbmFtZXNwYWNlX2RldnMuYw0KPiArKysgYi9kcml2ZXJzL252ZGlt
bS9uYW1lc3BhY2VfZGV2cy5jDQo+IEBAIC0xOTk1LDcgKzE5OTUsNyBAQCBzdGF0aWMgc3RydWN0
IGRldmljZSAqY3JlYXRlX25hbWVzcGFjZV9wbWVtKHN0cnVjdCBuZF9yZWdpb24gKm5kX3JlZ2lv
biwNCj4gIAkJbmRfbWFwcGluZyA9ICZuZF9yZWdpb24tPm1hcHBpbmdbaV07DQo+ICAJCWxhYmVs
X2VudCA9IGxpc3RfZmlyc3RfZW50cnlfb3JfbnVsbCgmbmRfbWFwcGluZy0+bGFiZWxzLA0KPiAg
CQkJCXR5cGVvZigqbGFiZWxfZW50KSwgbGlzdCk7DQo+IC0JCWxhYmVsMCA9IGxhYmVsX2VudCA/
IGxhYmVsX2VudC0+bGFiZWwgOiAwOw0KPiArCQlsYWJlbDAgPSBsYWJlbF9lbnQgPyBsYWJlbF9l
bnQtPmxhYmVsIDogTlVMTDsNCj4gIA0KPiAgCQlpZiAoIWxhYmVsMCkgew0KPiAgCQkJV0FSTl9P
TigxKTsNCj4gQEAgLTIzMzAsOCArMjMzMCw5IEBAIHN0YXRpYyBzdHJ1Y3QgZGV2aWNlICoqc2Nh
bl9sYWJlbHMoc3RydWN0IG5kX3JlZ2lvbiAqbmRfcmVnaW9uKQ0KPiAgCQkJY29udGludWU7DQo+
ICANCj4gIAkJLyogc2tpcCBsYWJlbHMgdGhhdCBkZXNjcmliZSBleHRlbnRzIG91dHNpZGUgb2Yg
dGhlIHJlZ2lvbiAqLw0KPiAtCQlpZiAobmRfbGFiZWwtPmRwYSA8IG5kX21hcHBpbmctPnN0YXJ0
IHx8IG5kX2xhYmVsLT5kcGEgPiBtYXBfZW5kKQ0KPiAtCQkJY29udGludWU7DQo+ICsJCWlmIChf
X2xlNjRfdG9fY3B1KG5kX2xhYmVsLT5kcGEpIDwgbmRfbWFwcGluZy0+c3RhcnQgfHwNCj4gKwkJ
ICAgIF9fbGU2NF90b19jcHUobmRfbGFiZWwtPmRwYSkgPiBtYXBfZW5kKQ0KPiArCQkJCWNvbnRp
bnVlOw0KPiAgDQo+ICAJCWkgPSBhZGRfbmFtZXNwYWNlX3Jlc291cmNlKG5kX3JlZ2lvbiwgbmRf
bGFiZWwsIGRldnMsIGNvdW50KTsNCj4gIAkJaWYgKGkgPCAwKQ0KDQo=

