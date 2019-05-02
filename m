Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97CEAC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EE922081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE922081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64E1F6B0003; Thu,  2 May 2019 16:50:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FF326B0005; Thu,  2 May 2019 16:50:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C63B6B0007; Thu,  2 May 2019 16:50:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 137776B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 16:50:36 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a141so1881335pfa.13
        for <linux-mm@kvack.org>; Thu, 02 May 2019 13:50:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=qDf30bIvq8ayX+22zXPw/qLIDX7FJDGPW1bA5jqbT9o=;
        b=ad78xHVVC9HT3S32CmDsE2KixcXesxWfdHOTq3qWwkoReFIUYRcsZPwPm9AoAle2YC
         TuDK0TIaPv+MT5DQOV7Nu1QVC+hWLREC5VO2NVsTS6aeLlSiKo3QVDQC1H4ChDGNj26H
         NpOP9ToxF6OOdwAV7ixcBJ28OScyfJ05e4PKLyrABRpuZ7VdDErsbaaY0a4fqr/EMP4u
         VoHosc9arU1v9vVnDlPAWCA9oiAVtQVDYQa6Wqt3TLaP/bvA1kCHX0dXlF07SdNCaPgk
         bnO1Foot6yjzHQJ0GG03GRHX4o2JYKxweF2rvAISk5s8jee9q91twXRj/pVUVBWzzABR
         sxjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX6JEslqi8CeRyb5xGQgbmiYIEObc6Z142MDXiIveKDWlfXBbJR
	cINs69OrN3Qzk0NbJ3XxV+yY/cfNGzkOnZslJnVmpki0fEPXQ4d+7+SQidSRVCbnv0ZroM82fcH
	Vfx9pLrVSLsLmSfyUSa5S+xC0f0LRxQvVZTEr14SnJJYUnZZ74MHS3Z1ol4l6P2tESA==
X-Received: by 2002:aa7:80d0:: with SMTP id a16mr6549182pfn.206.1556830235636;
        Thu, 02 May 2019 13:50:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCk0zZHWptfgGpS+oLlKkDxcdIlzDW4cha5Xzf3Io9M7UEdsuMgLuxfb43TpYIxC5Fihl9
X-Received: by 2002:aa7:80d0:: with SMTP id a16mr6549098pfn.206.1556830234270;
        Thu, 02 May 2019 13:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556830234; cv=none;
        d=google.com; s=arc-20160816;
        b=NDC5IpxPu4Bs5GLGQmpAQ3L4G4osfKiTkRw+9cku8KdmqDEx5f6ue/80+eDmXfvGn4
         LsB7NHa7JTl49ULqZxulsDrf/N5IVIN4LFawYcOBPImDQjcdsbWdNWisf80GztZDMEtD
         RiO/RZ2hBqQc/qspPKWr6WCBZy48lLdx+4aaj6uD5yCT5PZItO9Z58iZ4Xm3ZK1K5WoG
         L/ssNg5/UDpeKpVXva3WsTxbRTRxkfXtkMz4KOWL8YLMTmtREH8Zj7MCyWO8PdfR31qE
         h8belmTwxwLYXOqG+QVB3tWnt0vbgYqbAs37fRuUaRnGxnPbL9c4c6R9+19Eptamid62
         +dJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:to:from;
        bh=qDf30bIvq8ayX+22zXPw/qLIDX7FJDGPW1bA5jqbT9o=;
        b=aPv4Izwg+qz5aNjvxJapsZslM+W0I/hPINqvnYMlcdMuxGb9eXn9MNHYNAn8C+bVAj
         sq/GXSK7Ic5kyuoT+bABeEaX5Kwu0yexHt0E7O4cErwnAq2VFlgBYY3FH4V0/YJ0Sic7
         P4Mob/GFSwG9fVdveyaSyxGer4lq+gum0t9MYosrDpPKHBELyKLq7cyw2InGGQkwBFZv
         5sreuW4Ux2jfwb8zmBsOVAcd7WuByO/3Vo3K8tFsrKJklio5fwywBmVGuAyJ9p78lFzJ
         Tnd1Jwdxu8hys8VnKC9AxtmdGBz5ls/gx7zmv3ThJ5BKkN7x0hlvuTC2BMR9X+4fzJST
         ULiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j12si126374pgp.118.2019.05.02.13.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 13:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 May 2019 13:50:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,423,1549958400"; 
   d="scan'208";a="140790498"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by orsmga006.jf.intel.com with ESMTP; 02 May 2019 13:50:31 -0700
Received: from fmsmsx155.amr.corp.intel.com (10.18.116.71) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 2 May 2019 13:50:31 -0700
Received: from fmsmsx113.amr.corp.intel.com ([169.254.13.30]) by
 FMSMSX155.amr.corp.intel.com ([169.254.5.71]) with mapi id 14.03.0415.000;
 Thu, 2 May 2019 13:50:30 -0700
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>, "tiwai@suse.de" <tiwai@suse.de>,
	"sashal@kernel.org" <sashal@kernel.org>, "pasha.tatashin@soleen.com"
	<pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"david@redhat.com" <david@redhat.com>, "bp@suse.de" <bp@suse.de>, "Williams,
 Dan J" <dan.j.williams@intel.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>,
	"zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com"
	<mhocko@suse.com>, "Jiang, Dave" <dave.jiang@intel.com>,
	"bhelgaas@google.com" <bhelgaas@google.com>, "Busch, Keith"
	<keith.busch@intel.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>,
	"Huang, Ying" <ying.huang@intel.com>, "Wu, Fengguang"
	<fengguang.wu@intel.com>, "baiyaowei@cmss.chinamobile.com"
	<baiyaowei@cmss.chinamobile.com>
Subject: Re: [v5 0/3] "Hotremove" persistent memory
Thread-Topic: [v5 0/3] "Hotremove" persistent memory
Thread-Index: AQHVARb3UO0Lxl+oRESN1JIk0+ExN6ZYxIMA
Date: Thu, 2 May 2019 20:50:30 +0000
Message-ID: <76dfe7943f2a0ceaca73f5fd23e944dfdc0309d1.camel@intel.com>
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
In-Reply-To: <20190502184337.20538-1-pasha.tatashin@soleen.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.5 (3.30.5-1.fc29) 
x-originating-ip: [10.232.112.185]
Content-Type: text/plain; charset="utf-8"
Content-ID: <66CC36D5F7E4B44EB689D71200F1FBD1@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA1LTAyIGF0IDE0OjQzIC0wNDAwLCBQYXZlbCBUYXRhc2hpbiB3cm90ZToN
Cj4gVGhlIHNlcmllcyBvZiBvcGVyYXRpb25zIGxvb2sgbGlrZSB0aGlzOg0KPiANCj4gMS4gQWZ0
ZXIgYm9vdCByZXN0b3JlIC9kZXYvcG1lbTAgdG8gcmFtZGlzayB0byBiZSBjb25zdW1lZCBieSBh
cHBzLg0KPiAgICBhbmQgZnJlZSByYW1kaXNrLg0KPiAyLiBDb252ZXJ0IHJhdyBwbWVtMCB0byBk
ZXZkYXgNCj4gICAgbmRjdGwgY3JlYXRlLW5hbWVzcGFjZSAtLW1vZGUgZGV2ZGF4IC0tbWFwIG1l
bSAtZSBuYW1lc3BhY2UwLjAgLWYNCj4gMy4gSG90YWRkIHRvIFN5c3RlbSBSQU0NCj4gICAgZWNo
byBkYXgwLjAgPiAvc3lzL2J1cy9kYXgvZHJpdmVycy9kZXZpY2VfZGF4L3VuYmluZA0KPiAgICBl
Y2hvIGRheDAuMCA+IC9zeXMvYnVzL2RheC9kcml2ZXJzL2ttZW0vbmV3X2lkDQo+ICAgIGVjaG8g
b25saW5lX21vdmFibGUgPiAvc3lzL2RldmljZXMvc3lzdGVtL21lbW9yeVhYWC9zdGF0ZQ0KPiA0
LiBCZWZvcmUgcmVib290IGhvdHJlbW92ZSBkZXZpY2UtZGF4IG1lbW9yeSBmcm9tIFN5c3RlbSBS
QU0NCj4gICAgZWNobyBvZmZsaW5lID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9tZW1vcnlYWFgvc3Rh
dGUNCj4gICAgZWNobyBkYXgwLjAgPiAvc3lzL2J1cy9kYXgvZHJpdmVycy9rbWVtL3VuYmluZA0K
DQpIaSBQYXZlbCwNCg0KSSBhbSB3b3JraW5nIG9uIGFkZGluZyB0aGlzIHNvcnQgb2YgYSB3b3Jr
ZmxvdyBpbnRvIGEgbmV3IGRheGN0bCBjb21tYW5kDQooZGF4Y3RsLXJlY29uZmlndXJlLWRldmlj
ZSktIHRoaXMgd2lsbCBhbGxvdyBjaGFuZ2luZyB0aGUgJ21vZGUnIG9mIGENCmRheCBkZXZpY2Ug
dG8ga21lbSwgb25saW5lIHRoZSByZXN1bHRpbmcgbWVtb3J5LCBhbmQgd2l0aCB5b3VyIHBhdGNo
ZXMsDQphbHNvIGF0dGVtcHQgdG8gb2ZmbGluZSB0aGUgbWVtb3J5LCBhbmQgY2hhbmdlIGJhY2sg
dG8gZGV2aWNlLWRheC4NCg0KSW4gcnVubmluZyB3aXRoIHRoZXNlIHBhdGNoZXMsIGFuZCB0ZXN0
aW5nIHRoZSBvZmZsaW5pbmcgcGFydCwgSSByYW4NCmludG8gdGhlIGZvbGxvd2luZyBsb2NrZGVw
IGJlbG93Lg0KDQpUaGlzIGlzIHdpdGgganVzdCB0aGVzZSB0aHJlZSBwYXRjaGVzIG9uIHRvcCBv
ZiAtcmM3Lg0KDQoNClsgICswLjAwNDg4Nl0gPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09DQpbICArMC4wMDE1NzZdIFdBUk5JTkc6IHBvc3NpYmxl
IGNpcmN1bGFyIGxvY2tpbmcgZGVwZW5kZW5jeSBkZXRlY3RlZA0KWyAgKzAuMDAxNTA2XSA1LjEu
MC1yYzcrICMxMyBUYWludGVkOiBHICAgICAgICAgICBPICAgICANClsgICswLjAwMDkyOV0gLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQpbICAr
MC4wMDA3MDhdIGRheGN0bC8yMjk1MCBpcyB0cnlpbmcgdG8gYWNxdWlyZSBsb2NrOg0KWyAgKzAu
MDAwNTQ4XSAwMDAwMDAwMGY0ZDM5N2Y3IChrbi0+Y291bnQjNDI0KXsrKysrfSwgYXQ6IGtlcm5m
c19yZW1vdmVfYnlfbmFtZV9ucysweDQwLzB4ODANClsgICswLjAwMDkyMl0gDQogICAgICAgICAg
ICAgIGJ1dCB0YXNrIGlzIGFscmVhZHkgaG9sZGluZyBsb2NrOg0KWyAgKzAuMDAwNjU3XSAwMDAw
MDAwMDJhYTUyYTlmIChtZW1fc3lzZnNfbXV0ZXgpeysuKy59LCBhdDogdW5yZWdpc3Rlcl9tZW1v
cnlfc2VjdGlvbisweDIyLzB4YTANClsgICswLjAwMDk2MF0gDQogICAgICAgICAgICAgIHdoaWNo
IGxvY2sgYWxyZWFkeSBkZXBlbmRzIG9uIHRoZSBuZXcgbG9jay4NCg0KWyAgKzAuMDAxMDAxXSAN
CiAgICAgICAgICAgICAgdGhlIGV4aXN0aW5nIGRlcGVuZGVuY3kgY2hhaW4gKGluIHJldmVyc2Ug
b3JkZXIpIGlzOg0KWyAgKzAuMDAwODM3XSANCiAgICAgICAgICAgICAgLT4gIzMgKG1lbV9zeXNm
c19tdXRleCl7Ky4rLn06DQpbICArMC4wMDA2MzFdICAgICAgICBfX211dGV4X2xvY2srMHg4Mi8w
eDlhMA0KWyAgKzAuMDAwNDc3XSAgICAgICAgdW5yZWdpc3Rlcl9tZW1vcnlfc2VjdGlvbisweDIy
LzB4YTANClsgICswLjAwMDU4Ml0gICAgICAgIF9fcmVtb3ZlX3BhZ2VzKzB4ZTkvMHg1MjANClsg
ICswLjAwMDQ4OV0gICAgICAgIGFyY2hfcmVtb3ZlX21lbW9yeSsweDgxLzB4YzANClsgICswLjAw
MDUxMF0gICAgICAgIGRldm1fbWVtcmVtYXBfcGFnZXNfcmVsZWFzZSsweDE4MC8weDI3MA0KWyAg
KzAuMDAwNjMzXSAgICAgICAgcmVsZWFzZV9ub2RlcysweDIzNC8weDI4MA0KWyAgKzAuMDAwNDgz
XSAgICAgICAgZGV2aWNlX3JlbGVhc2VfZHJpdmVyX2ludGVybmFsKzB4ZjQvMHgxZDANClsgICsw
LjAwMDcwMV0gICAgICAgIGJ1c19yZW1vdmVfZGV2aWNlKzB4ZmMvMHgxNzANClsgICswLjAwMDUy
OV0gICAgICAgIGRldmljZV9kZWwrMHgxNmEvMHgzODANClsgICswLjAwMDQ1OV0gICAgICAgIHVu
cmVnaXN0ZXJfZGV2X2RheCsweDIzLzB4NTANClsgICswLjAwMDUyNl0gICAgICAgIHJlbGVhc2Vf
bm9kZXMrMHgyMzQvMHgyODANClsgICswLjAwMDQ4N10gICAgICAgIGRldmljZV9yZWxlYXNlX2Ry
aXZlcl9pbnRlcm5hbCsweGY0LzB4MWQwDQpbICArMC4wMDA2NDZdICAgICAgICB1bmJpbmRfc3Rv
cmUrMHg5Yi8weDEzMA0KWyAgKzAuMDAwNDY3XSAgICAgICAga2VybmZzX2ZvcF93cml0ZSsweGYw
LzB4MWEwDQpbICArMC4wMDA1MTBdICAgICAgICB2ZnNfd3JpdGUrMHhiYS8weDFjMA0KWyAgKzAu
MDAwNDM4XSAgICAgICAga3N5c193cml0ZSsweDVhLzB4ZTANClsgICswLjAwMDUyMV0gICAgICAg
IGRvX3N5c2NhbGxfNjQrMHg2MC8weDIxMA0KWyAgKzAuMDAwNDg5XSAgICAgICAgZW50cnlfU1lT
Q0FMTF82NF9hZnRlcl9od2ZyYW1lKzB4NDkvMHhiZQ0KWyAgKzAuMDAwNjM3XSANCiAgICAgICAg
ICAgICAgLT4gIzIgKG1lbV9ob3RwbHVnX2xvY2sucndfc2VtKXsrKysrfToNClsgICswLjAwMDcx
N10gICAgICAgIGdldF9vbmxpbmVfbWVtcysweDNlLzB4ODANClsgICswLjAwMDQ5MV0gICAgICAg
IGttZW1fY2FjaGVfY3JlYXRlX3VzZXJjb3B5KzB4MmUvMHgyNzANClsgICswLjAwMDYwOV0gICAg
ICAgIGttZW1fY2FjaGVfY3JlYXRlKzB4MTIvMHgyMA0KWyAgKzAuMDAwNTA3XSAgICAgICAgcHRs
b2NrX2NhY2hlX2luaXQrMHgyMC8weDI4DQpbICArMC4wMDA1MDZdICAgICAgICBzdGFydF9rZXJu
ZWwrMHgyNDAvMHg0ZDANClsgICswLjAwMDQ4MF0gICAgICAgIHNlY29uZGFyeV9zdGFydHVwXzY0
KzB4YTQvMHhiMA0KWyAgKzAuMDAwNTM5XSANCiAgICAgICAgICAgICAgLT4gIzEgKGNwdV9ob3Rw
bHVnX2xvY2sucndfc2VtKXsrKysrfToNClsgICswLjAwMDc4NF0gICAgICAgIGNwdXNfcmVhZF9s
b2NrKzB4M2UvMHg4MA0KWyAgKzAuMDAwNTExXSAgICAgICAgb25saW5lX3BhZ2VzKzB4MzcvMHgz
MTANClsgICswLjAwMDQ2OV0gICAgICAgIG1lbW9yeV9zdWJzeXNfb25saW5lKzB4MzQvMHg2MA0K
WyAgKzAuMDAwNjExXSAgICAgICAgZGV2aWNlX29ubGluZSsweDYwLzB4ODANClsgICswLjAwMDYx
MV0gICAgICAgIHN0YXRlX3N0b3JlKzB4NjYvMHhkMA0KWyAgKzAuMDAwNTUyXSAgICAgICAga2Vy
bmZzX2ZvcF93cml0ZSsweGYwLzB4MWEwDQpbICArMC4wMDA2NDldICAgICAgICB2ZnNfd3JpdGUr
MHhiYS8weDFjMA0KWyAgKzAuMDAwNDg3XSAgICAgICAga3N5c193cml0ZSsweDVhLzB4ZTANClsg
ICswLjAwMDQ1OV0gICAgICAgIGRvX3N5c2NhbGxfNjQrMHg2MC8weDIxMA0KWyAgKzAuMDAwNDgy
XSAgICAgICAgZW50cnlfU1lTQ0FMTF82NF9hZnRlcl9od2ZyYW1lKzB4NDkvMHhiZQ0KWyAgKzAu
MDAwNjQ2XSANCiAgICAgICAgICAgICAgLT4gIzAgKGtuLT5jb3VudCM0MjQpeysrKyt9Og0KWyAg
KzAuMDAwNjY5XSAgICAgICAgbG9ja19hY3F1aXJlKzB4OWUvMHgxODANClsgICswLjAwMDQ3MV0g
ICAgICAgIF9fa2VybmZzX3JlbW92ZSsweDI2YS8weDMxMA0KWyAgKzAuMDAwNTE4XSAgICAgICAg
a2VybmZzX3JlbW92ZV9ieV9uYW1lX25zKzB4NDAvMHg4MA0KWyAgKzAuMDAwNTgzXSAgICAgICAg
cmVtb3ZlX2ZpbGVzLmlzcmEuMSsweDMwLzB4NzANClsgICswLjAwMDU1NV0gICAgICAgIHN5c2Zz
X3JlbW92ZV9ncm91cCsweDNkLzB4ODANClsgICswLjAwMDUyNF0gICAgICAgIHN5c2ZzX3JlbW92
ZV9ncm91cHMrMHgyOS8weDQwDQpbICArMC4wMDA1MzJdICAgICAgICBkZXZpY2VfcmVtb3ZlX2F0
dHJzKzB4NDIvMHg4MA0KWyAgKzAuMDAwNTIyXSAgICAgICAgZGV2aWNlX2RlbCsweDE2Mi8weDM4
MA0KWyAgKzAuMDAwNDY0XSAgICAgICAgZGV2aWNlX3VucmVnaXN0ZXIrMHgxNi8weDYwDQpbICAr
MC4wMDA1MDVdICAgICAgICB1bnJlZ2lzdGVyX21lbW9yeV9zZWN0aW9uKzB4NmUvMHhhMA0KWyAg
KzAuMDAwNTkxXSAgICAgICAgX19yZW1vdmVfcGFnZXMrMHhlOS8weDUyMA0KWyAgKzAuMDAwNDky
XSAgICAgICAgYXJjaF9yZW1vdmVfbWVtb3J5KzB4ODEvMHhjMA0KWyAgKzAuMDAwNTY4XSAgICAg
ICAgdHJ5X3JlbW92ZV9tZW1vcnkrMHhiYS8weGQwDQpbICArMC4wMDA1MTBdICAgICAgICByZW1v
dmVfbWVtb3J5KzB4MjMvMHg0MA0KWyAgKzAuMDAwNDgzXSAgICAgICAgZGV2X2RheF9rbWVtX3Jl
bW92ZSsweDI5LzB4NTcgW2ttZW1dDQpbICArMC4wMDA2MDhdICAgICAgICBkZXZpY2VfcmVsZWFz
ZV9kcml2ZXJfaW50ZXJuYWwrMHhlNC8weDFkMA0KWyAgKzAuMDAwNjM3XSAgICAgICAgdW5iaW5k
X3N0b3JlKzB4OWIvMHgxMzANClsgICswLjAwMDQ2NF0gICAgICAgIGtlcm5mc19mb3Bfd3JpdGUr
MHhmMC8weDFhMA0KWyAgKzAuMDAwNjg1XSAgICAgICAgdmZzX3dyaXRlKzB4YmEvMHgxYzANClsg
ICswLjAwMDU5NF0gICAgICAgIGtzeXNfd3JpdGUrMHg1YS8weGUwDQpbICArMC4wMDA0NDldICAg
ICAgICBkb19zeXNjYWxsXzY0KzB4NjAvMHgyMTANClsgICswLjAwMDQ4MV0gICAgICAgIGVudHJ5
X1NZU0NBTExfNjRfYWZ0ZXJfaHdmcmFtZSsweDQ5LzB4YmUNClsgICswLjAwMDYxOV0gDQogICAg
ICAgICAgICAgIG90aGVyIGluZm8gdGhhdCBtaWdodCBoZWxwIHVzIGRlYnVnIHRoaXM6DQoNClsg
ICswLjAwMDg4OV0gQ2hhaW4gZXhpc3RzIG9mOg0KICAgICAgICAgICAgICAgIGtuLT5jb3VudCM0
MjQgLS0+IG1lbV9ob3RwbHVnX2xvY2sucndfc2VtIC0tPiBtZW1fc3lzZnNfbXV0ZXgNCg0KWyAg
KzAuMDAxMjY5XSAgUG9zc2libGUgdW5zYWZlIGxvY2tpbmcgc2NlbmFyaW86DQoNClsgICswLjAw
MDY1Ml0gICAgICAgIENQVTAgICAgICAgICAgICAgICAgICAgIENQVTENClsgICswLjAwMDUwNV0g
ICAgICAgIC0tLS0gICAgICAgICAgICAgICAgICAgIC0tLS0NClsgICswLjAwMDUyM10gICBsb2Nr
KG1lbV9zeXNmc19tdXRleCk7DQpbICArMC4wMDA0MjJdICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBsb2NrKG1lbV9ob3RwbHVnX2xvY2sucndfc2VtKTsNClsgICswLjAwMDkwNV0gICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgIGxvY2sobWVtX3N5c2ZzX211dGV4KTsNClsgICsw
LjAwMDc5M10gICBsb2NrKGtuLT5jb3VudCM0MjQpOw0KWyAgKzAuMDAwMzk0XSANCiAgICAgICAg
ICAgICAgICoqKiBERUFETE9DSyAqKioNCg0KWyAgKzAuMDAwNjY1XSA3IGxvY2tzIGhlbGQgYnkg
ZGF4Y3RsLzIyOTUwOg0KWyAgKzAuMDAwNDU4XSAgIzA6IDAwMDAwMDAwNWY2ZDNjMTMgKHNiX3dy
aXRlcnMjNCl7LisuK30sIGF0OiB2ZnNfd3JpdGUrMHgxNTkvMHgxYzANClsgICswLjAwMDk0M10g
ICMxOiAwMDAwMDAwMGU0Njg4MjVkICgmb2YtPm11dGV4KXsrLisufSwgYXQ6IGtlcm5mc19mb3Bf
d3JpdGUrMHhiZC8weDFhMA0KWyAgKzAuMDAwODk1XSAgIzI6IDAwMDAwMDAwY2FhMTdkYmIgKCZk
ZXYtPm11dGV4KXsuLi4ufSwgYXQ6IGRldmljZV9yZWxlYXNlX2RyaXZlcl9pbnRlcm5hbCsweDFh
LzB4MWQwDQpbICArMC4wMDEwMTldICAjMzogMDAwMDAwMDAyMTE5YjIyYyAoZGV2aWNlX2hvdHBs
dWdfbG9jayl7Ky4rLn0sIGF0OiByZW1vdmVfbWVtb3J5KzB4MTYvMHg0MA0KWyAgKzAuMDAwOTQy
XSAgIzQ6IDAwMDAwMDAwMTUwYzhlZmUgKGNwdV9ob3RwbHVnX2xvY2sucndfc2VtKXsrKysrfSwg
YXQ6IHRyeV9yZW1vdmVfbWVtb3J5KzB4MmUvMHhkMA0KWyAgKzAuMDAxMDE5XSAgIzU6IDAwMDAw
MDAwM2Q2YjJhMGYgKG1lbV9ob3RwbHVnX2xvY2sucndfc2VtKXsrKysrfSwgYXQ6IHBlcmNwdV9k
b3duX3dyaXRlKzB4MjUvMHgxMjANClsgICswLjAwMTExOF0gICM2OiAwMDAwMDAwMDJhYTUyYTlm
IChtZW1fc3lzZnNfbXV0ZXgpeysuKy59LCBhdDogdW5yZWdpc3Rlcl9tZW1vcnlfc2VjdGlvbisw
eDIyLzB4YTANClsgICswLjAwMTAzM10gDQogICAgICAgICAgICAgIHN0YWNrIGJhY2t0cmFjZToN
ClsgICswLjAwMDUwN10gQ1BVOiA1IFBJRDogMjI5NTAgQ29tbTogZGF4Y3RsIFRhaW50ZWQ6IEcg
ICAgICAgICAgIE8gICAgICA1LjEuMC1yYzcrICMxMw0KWyAgKzAuMDAwODk2XSBIYXJkd2FyZSBu
YW1lOiBRRU1VIFN0YW5kYXJkIFBDIChpNDQwRlggKyBQSUlYLCAxOTk2KSwgQklPUyByZWwtMS4x
MS4xLTAtZzA1NTFhNGJlMmMtcHJlYnVpbHQucWVtdS1wcm9qZWN0Lm9yZyAwNC8wMS8yMDE0DQpb
ICArMC4wMDEzNjBdIENhbGwgVHJhY2U6DQpbICArMC4wMDAyOTNdICBkdW1wX3N0YWNrKzB4ODUv
MHhjMA0KWyAgKzAuMDAwMzkwXSAgcHJpbnRfY2lyY3VsYXJfYnVnLmlzcmEuNDEuY29sZC42MCsw
eDE1Yy8weDE5NQ0KWyAgKzAuMDAwNjUxXSAgY2hlY2tfcHJldl9hZGQuY29uc3Rwcm9wLjUwKzB4
NWZkLzB4YmUwDQpbICArMC4wMDA1NjNdICA/IGNhbGxfcmN1X3phcHBlZCsweDgwLzB4ODANClsg
ICswLjAwMDQ0OV0gIF9fbG9ja19hY3F1aXJlKzB4Y2VlLzB4ZmQwDQpbICArMC4wMDA0MzddICBs
b2NrX2FjcXVpcmUrMHg5ZS8weDE4MA0KWyAgKzAuMDAwNDI4XSAgPyBrZXJuZnNfcmVtb3ZlX2J5
X25hbWVfbnMrMHg0MC8weDgwDQpbICArMC4wMDA1MzFdICBfX2tlcm5mc19yZW1vdmUrMHgyNmEv
MHgzMTANClsgICswLjAwMDQ1MV0gID8ga2VybmZzX3JlbW92ZV9ieV9uYW1lX25zKzB4NDAvMHg4
MA0KWyAgKzAuMDAwNTI5XSAgPyBrZXJuZnNfbmFtZV9oYXNoKzB4MTIvMHg4MA0KWyAgKzAuMDAw
NDYyXSAga2VybmZzX3JlbW92ZV9ieV9uYW1lX25zKzB4NDAvMHg4MA0KWyAgKzAuMDAwNTEzXSAg
cmVtb3ZlX2ZpbGVzLmlzcmEuMSsweDMwLzB4NzANClsgICswLjAwMDQ4M10gIHN5c2ZzX3JlbW92
ZV9ncm91cCsweDNkLzB4ODANClsgICswLjAwMDQ1OF0gIHN5c2ZzX3JlbW92ZV9ncm91cHMrMHgy
OS8weDQwDQpbICArMC4wMDA0NzddICBkZXZpY2VfcmVtb3ZlX2F0dHJzKzB4NDIvMHg4MA0KWyAg
KzAuMDAwNDYxXSAgZGV2aWNlX2RlbCsweDE2Mi8weDM4MA0KWyAgKzAuMDAwMzk5XSAgZGV2aWNl
X3VucmVnaXN0ZXIrMHgxNi8weDYwDQpbICArMC4wMDA0NDJdICB1bnJlZ2lzdGVyX21lbW9yeV9z
ZWN0aW9uKzB4NmUvMHhhMA0KWyAgKzAuMDAxMjMyXSAgX19yZW1vdmVfcGFnZXMrMHhlOS8weDUy
MA0KWyAgKzAuMDAwNDQzXSAgYXJjaF9yZW1vdmVfbWVtb3J5KzB4ODEvMHhjMA0KWyAgKzAuMDAw
NDU5XSAgdHJ5X3JlbW92ZV9tZW1vcnkrMHhiYS8weGQwDQpbICArMC4wMDA0NjBdICByZW1vdmVf
bWVtb3J5KzB4MjMvMHg0MA0KWyAgKzAuMDAwNDYxXSAgZGV2X2RheF9rbWVtX3JlbW92ZSsweDI5
LzB4NTcgW2ttZW1dDQpbICArMC4wMDA2MDNdICBkZXZpY2VfcmVsZWFzZV9kcml2ZXJfaW50ZXJu
YWwrMHhlNC8weDFkMA0KWyAgKzAuMDAwNTkwXSAgdW5iaW5kX3N0b3JlKzB4OWIvMHgxMzANClsg
ICswLjAwMDQwOV0gIGtlcm5mc19mb3Bfd3JpdGUrMHhmMC8weDFhMA0KWyAgKzAuMDAwNDQ4XSAg
dmZzX3dyaXRlKzB4YmEvMHgxYzANClsgICswLjAwMDM5NV0gIGtzeXNfd3JpdGUrMHg1YS8weGUw
DQpbICArMC4wMDAzODJdICBkb19zeXNjYWxsXzY0KzB4NjAvMHgyMTANClsgICswLjAwMDQxOF0g
IGVudHJ5X1NZU0NBTExfNjRfYWZ0ZXJfaHdmcmFtZSsweDQ5LzB4YmUNClsgICswLjAwMDU3M10g
UklQOiAwMDMzOjB4N2ZkMWY3NDQyZmE4DQpbICArMC4wMDA0MDddIENvZGU6IDg5IDAyIDQ4IGM3
IGMwIGZmIGZmIGZmIGZmIGViIGIzIDBmIDFmIDgwIDAwIDAwIDAwIDAwIGYzIDBmIDFlIGZhIDQ4
IDhkIDA1IDc1IDc3IDBkIDAwIDhiIDAwIDg1IGMwIDc1IDE3IGI4IDAxIDAwIDAwIDAwIDBmIDA1
IDw0OD4gM2QgMDAgZjAgZmYgZmYgNzcgNTggYzMgMGYgMWYgODAgMDAgMDAgMDAgMDAgNDEgNTQg
NDkgODkgZDQgNTUNClsgICswLjAwMjExOV0gUlNQOiAwMDJiOjAwMDA3ZmZkNDhmNThlMjggRUZM
QUdTOiAwMDAwMDI0NiBPUklHX1JBWDogMDAwMDAwMDAwMDAwMDAwMQ0KWyAgKzAuMDAwODMzXSBS
QVg6IGZmZmZmZmZmZmZmZmZmZGEgUkJYOiAwMDAwMDAwMDAyMTBjODE3IFJDWDogMDAwMDdmZDFm
NzQ0MmZhOA0KWyAgKzAuMDAwNzk1XSBSRFg6IDAwMDAwMDAwMDAwMDAwMDcgUlNJOiAwMDAwMDAw
MDAyMTBjODE3IFJESTogMDAwMDAwMDAwMDAwMDAwMw0KWyAgKzAuMDAwODE2XSBSQlA6IDAwMDAw
MDAwMDAwMDAwMDcgUjA4OiAwMDAwMDAwMDAyMTBjN2QwIFIwOTogMDAwMDdmZDFmNzRkNGU4MA0K
WyAgKzAuMDAwODA4XSBSMTA6IDAwMDAwMDAwMDAwMDAwMDAgUjExOiAwMDAwMDAwMDAwMDAwMjQ2
IFIxMjogMDAwMDAwMDAwMDAwMDAwMw0KWyAgKzAuMDAwODE5XSBSMTM6IDAwMDA3ZmQxZjcyYjlj
ZTggUjE0OiAwMDAwMDAwMDAwMDAwMDAwIFIxNTogMDAwMDdmZmQ0OGY1OGU3MA0K

