Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 229D1C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B570A20989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:31:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B570A20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DC126B0003; Mon, 13 May 2019 15:31:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28DEE6B0006; Mon, 13 May 2019 15:31:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17DB86B0007; Mon, 13 May 2019 15:31:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E35F06B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:31:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o1so9804356pgv.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 12:31:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=Z/fOz/9IGokK8xZ/1PtPFnjPREbbznbayKNrEuWpRoU=;
        b=jrkN4Rct7KilXkCx62INPE1mtSzJGyScoO+oFI48J3T3ReVIHrPqVYXu6P/BNbca8g
         BFa6nMg48FQHPbQim1CCB31WDRZbG4l6m8pioHHGglUTGzrHPM8IC6+o53AWcH1HRHHE
         q4nDphTnGZiQZ+cozU2Tx0UZgVkF/wudxgGbS+RR7JUgF2QTuy/EjrqliPcv5FBtLgM9
         k1k7UPbDB1a4rzLD5wyco7FkuP2rW1BOSKXP+uHQ7EhNbYcPuQFLnLwrU8uQ8nBc/JOv
         s6pFuASAxJe+0VPWDrFg9fOMU5aSN6Av/szKmcey7MdFG096GDPovJr0u1yB1SOP3FSA
         9dQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXEjpOLzDQp4uLSzB0HbTGEP3LIiOlm9EQ44Ls1o3GvIN7Y1pAC
	Dx4/an0Wt9BVvA0jCvDDb51gWLzdixU1QnmCTMz1kmM7OyKhSp1Sh2+V+uQMSBPHqKWNDHCR+Ys
	s8VfyK/P7o1EUyzsdDOlb2nYeo1jy+SiRlR041p5Ij3WrWpbGflgVxFaLqRLTx/qmAg==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr35855701pfc.119.1557775873548;
        Mon, 13 May 2019 12:31:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7ExLO522Ku4lCjV7FGXVoy2pfUACkyZZTZz7FTUAaUsyteabO2F8BZvaXvUG9T+VK22qN
X-Received: by 2002:a62:69c2:: with SMTP id e185mr35855560pfc.119.1557775872560;
        Mon, 13 May 2019 12:31:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557775872; cv=none;
        d=google.com; s=arc-20160816;
        b=aDujQIjwCk0eeXODnR3MDv8ECDUuWQ/kHm+8RGTqyiPdjg8YcEDJtHsFqeG+dWIaFx
         WcuW9sSfWdWEgsGpt7PJE+YLogEu/JqZBxpmPClm7gBPdCd9d471hGVFuJk14rRQriRT
         Gw9ljXC5YOg7bj2u3D1gUEeSEx4PS/lf6GI8deS/GM3JtKWZnz2DmNAuwFe5FDv61LmB
         e6+sRk8cFnvUzmsxtdGXRE7w8P2NVLuRsTqSGLs6p5cyfJhyXvs/T0Ao3sIuFbVG+Skx
         7Hcwxk1zIb2a2hltlIcJpkgGkB2wZAL7eckCR0ulTr2FP0a3tuF+Lmsxoedzny0b5n6s
         TGAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=Z/fOz/9IGokK8xZ/1PtPFnjPREbbznbayKNrEuWpRoU=;
        b=WC9aQf+0mRvnHzeb9tI0rV9A297XtY4MQX4Qs3JxAF70TCKheGUTwEjSTtHUZ7Blhe
         6LPGGFGtrfo5guJUmFIZGwz+oQ1ABguZuxZI7MvanPsV1npVFz1P/dBo+BWFG98oVM9L
         trXz0gwgWU6TlEKd6q4Wb0W9LUnLrRU5cltP0TrDbJSO8/WHMhMuGlgwFtqF/bk8ypA+
         BEByd+1E4L2gZqmccZy67/M1NMfAewf5ZDgQf+3LPh8beKtDh+vFNxqbmjTJPpKUXL1f
         vytbl6bYDbfC8SbK5Vwak06UfuqYmj2KoJDIvwczg6mmKuY4KdIXOhuFFa1EIm9EQfH2
         qg8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v9si17170172pgs.17.2019.05.13.12.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 12:31:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 12:31:12 -0700
X-ExtLoop1: 1
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by orsmga003.jf.intel.com with ESMTP; 13 May 2019 12:31:11 -0700
Received: from fmsmsx113.amr.corp.intel.com (10.18.116.7) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 13 May 2019 12:31:10 -0700
Received: from fmsmsx101.amr.corp.intel.com ([169.254.1.164]) by
 FMSMSX113.amr.corp.intel.com ([169.254.13.130]) with mapi id 14.03.0415.000;
 Mon, 13 May 2019 12:31:10 -0700
From: "Nakajima, Jun" <jun.nakajima@intel.com>
To: Alexandre Chartre <alexandre.chartre@oracle.com>, "pbonzini@redhat.com"
	<pbonzini@redhat.com>, "rkrcmar@redhat.com" <rkrcmar@redhat.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com"
	<mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "hpa@zytor.com"
	<hpa@zytor.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"luto@kernel.org" <luto@kernel.org>, "peterz@infradead.org"
	<peterz@infradead.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jan.setjeeilers@oracle.com" <jan.setjeeilers@oracle.com>,
	"liran.alon@oracle.com" <liran.alon@oracle.com>, "jwadams@google.com"
	<jwadams@google.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
Thread-Topic: [RFC KVM 00/27] KVM Address Space Isolation
Thread-Index: AQHVCZo0+3UN0P2FyECwVvtVyp68J6ZpcaEA
Date: Mon, 13 May 2019 19:31:10 +0000
Message-ID: <11F6D766-EC47-4283-8797-68A1405511B0@intel.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Microsoft-MacOutlook/10.19.0.190422
x-originating-ip: [10.254.35.195]
Content-Type: text/plain; charset="utf-8"
Content-ID: <9C5C1C4608577B4480BA83F49FC274F0@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gNS8xMy8xOSwgNzo0MyBBTSwgImt2bS1vd25lckB2Z2VyLmtlcm5lbC5vcmcgb24gYmVoYWxm
IG9mIEFsZXhhbmRyZSBDaGFydHJlIiB3cm90ZToNCg0KICAgIFByb3Bvc2FsDQogICAgPT09PT09
PT0NCiAgICANCiAgICBUbyBoYW5kbGUgYm90aCB0aGVzZSBwb2ludHMsIHRoaXMgc2VyaWVzIGlu
dHJvZHVjZSB0aGUgbWVjaGFuaXNtIG9mIEtWTQ0KICAgIGFkZHJlc3Mgc3BhY2UgaXNvbGF0aW9u
LiBOb3RlIHRoYXQgdGhpcyBtZWNoYW5pc20gY29tcGxldGVzIChhKSsoYikgYW5kDQogICAgZG9u
J3QgY29udHJhZGljdC4gSW4gY2FzZSB0aGlzIG1lY2hhbmlzbSBpcyBhbHNvIGFwcGxpZWQsIChh
KSsoYikgc2hvdWxkDQogICAgc3RpbGwgYmUgYXBwbGllZCB0byB0aGUgZnVsbCB2aXJ0dWFsIGFk
ZHJlc3Mgc3BhY2UgYXMgYSBkZWZlbmNlLWluLWRlcHRoKS4NCiAgICANCiAgICBUaGUgaWRlYSBp
cyB0aGF0IG1vc3Qgb2YgS1ZNICNWTUV4aXQgaGFuZGxlcnMgY29kZSB3aWxsIHJ1biBpbiBhIHNw
ZWNpYWwNCiAgICBLVk0gaXNvbGF0ZWQgYWRkcmVzcyBzcGFjZSB3aGljaCBtYXBzIG9ubHkgS1ZN
IHJlcXVpcmVkIGNvZGUgYW5kIHBlci1WTQ0KICAgIGluZm9ybWF0aW9uLiBPbmx5IG9uY2UgS1ZN
IG5lZWRzIHRvIGFyY2hpdGVjdHVhbGx5IGFjY2VzcyBvdGhlciAoc2Vuc2l0aXZlKQ0KICAgIGRh
dGEsIGl0IHdpbGwgc3dpdGNoIGZyb20gS1ZNIGlzb2xhdGVkIGFkZHJlc3Mgc3BhY2UgdG8gZnVs
bCBzdGFuZGFyZA0KICAgIGhvc3QgYWRkcmVzcyBzcGFjZS4gQXQgdGhpcyBwb2ludCwgS1ZNIHdp
bGwgYWxzbyBuZWVkIHRvIGtpY2sgYWxsIHNpYmxpbmcNCiAgICBoeXBlcnRocmVhZHMgdG8gZ2V0
IG91dCBvZiBndWVzdCAobm90ZSB0aGF0IGtpY2tpbmcgYWxsIHNpYmxpbmcgaHlwZXJ0aHJlYWRz
DQogICAgaXMgbm90IGltcGxlbWVudGVkIGluIHRoaXMgc2VyaWUpLg0KICAgIA0KICAgIEJhc2lj
YWxseSwgd2Ugd2lsbCBoYXZlIHRoZSBmb2xsb3dpbmcgZmxvdzoNCiAgICANCiAgICAgIC0gcWVt
dSBpc3N1ZXMgS1ZNX1JVTiBpb2N0bA0KICAgICAgLSBLVk0gaGFuZGxlcyB0aGUgaW9jdGwgYW5k
IGNhbGxzIHZjcHVfcnVuKCk6DQogICAgICAgIC4gS1ZNIHN3aXRjaGVzIGZyb20gdGhlIGtlcm5l
bCBhZGRyZXNzIHRvIHRoZSBLVk0gYWRkcmVzcyBzcGFjZQ0KICAgICAgICAuIEtWTSB0cmFuc2Zl
cnMgY29udHJvbCB0byBWTSAoVk1MQVVOQ0gvVk1SRVNVTUUpDQogICAgICAgIC4gVk0gcmV0dXJu
cyB0byBLVk0NCiAgICAgICAgLiBLVk0gaGFuZGxlcyBWTS1FeGl0Og0KICAgICAgICAgIC4gaWYg
aGFuZGxpbmcgbmVlZCBmdWxsIGtlcm5lbCB0aGVuIHN3aXRjaCB0byBrZXJuZWwgYWRkcmVzcyBz
cGFjZQ0KICAgICAgICAgIC4gZWxzZSBjb250aW51ZXMgd2l0aCBLVk0gYWRkcmVzcyBzcGFjZQ0K
ICAgICAgICAuIEtWTSBsb29wcyBpbiB2Y3B1X3J1bigpIG9yIHJldHVybg0KICAgICAgLSBLVk1f
UlVOIGlvY3RsIHJldHVybnMNCiAgICANCiAgICBTbywgdGhlIEtWTV9SVU4gY29yZSBmdW5jdGlv
biB3aWxsIG1haW5seSBiZSBleGVjdXRlZCB1c2luZyB0aGUgS1ZNIGFkZHJlc3MNCiAgICBzcGFj
ZS4gVGhlIGhhbmRsaW5nIG9mIGEgVk0tRXhpdCBjYW4gcmVxdWlyZSBhY2Nlc3MgdG8gdGhlIGtl
cm5lbCBzcGFjZQ0KICAgIGFuZCwgaW4gdGhhdCBjYXNlLCB3ZSB3aWxsIHN3aXRjaCBiYWNrIHRv
IHRoZSBrZXJuZWwgYWRkcmVzcyBzcGFjZS4NCiAgICANCk9uY2UgYWxsIHNpYmxpbmcgaHlwZXJ0
aHJlYWRzIGFyZSBpbiB0aGUgaG9zdCAoZWl0aGVyIHVzaW5nIHRoZSBmdWxsIGtlcm5lbCBhZGRy
ZXNzIHNwYWNlIG9yIHVzZXIgYWRkcmVzcyBzcGFjZSksIHdoYXQgaGFwcGVucyB0byB0aGUgb3Ro
ZXIgc2libGluZyBoeXBlcnRocmVhZHMgaWYgb25lIG9mIHRoZW0gdHJpZXMgdG8gZG8gVk0gZW50
cnk/IFRoYXQgVkNQVSB3aWxsIHN3aXRjaCB0byB0aGUgS1ZNIGFkZHJlc3Mgc3BhY2UgcHJpb3Ig
dG8gVk0gZW50cnksIGJ1dCBvdGhlcnMgY29udGludWUgdG8gcnVuPyBEbyB5b3UgdGhpbmsgKGEp
ICsgKGIpIHdvdWxkIGJlIHN1ZmZpY2llbnQgZm9yIHRoYXQgY2FzZT8NCiANCi0tLQ0KSnVuDQpJ
bnRlbCBPcGVuIFNvdXJjZSBUZWNobm9sb2d5IENlbnRlcg0KICAgIA0KDQo=

