Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2795C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB81C206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB81C206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45A376B0006; Mon, 20 May 2019 15:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40B236B0008; Mon, 20 May 2019 15:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9806B000A; Mon, 20 May 2019 15:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF7606B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 15:13:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g11so10514246pfq.7
        for <linux-mm@kvack.org>; Mon, 20 May 2019 12:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=+BnloVV/KgLBCi5Xj6RsaxGY+4nu9/nFZGsfY1xo0is=;
        b=YGFYt6IgYxV+/cgMDf5xYXZMyuVqMVw5jvUMenQ25pjLUfozA4TNjRBym6K8BZLaM9
         Svn18L175sGb4OJ83z5eiI0Bx7JWCONMVnc/oDcOc4ntioLZqcTZ81gzAEHnUSBT19JS
         Ce6sFVNEzwwpDmvXtSo5oKVxHuogpddG6pT4nJ16lpum84UIItFh4dxKcob4mu//pwfd
         2bm5zlMJpttcfRUpwPjlvZCl1D8CmdCYGUh6lkXB5opgFqdYYr6LDNiKp19MQpl2YMZG
         ZUdZSt623LjdNHU+jpdWMoCf5EsQDH9IWCc0o0RvGbX5rcSDTdVgRfSNcFLo5O1NlU1c
         vddQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXHZazjV4F0ZL8YU47UvBXme4LjbcbDVG9Ld7TAMjy3J+SP2BC4
	nbDHdyQF5yIndBKg5+oqtiZZ/hNK20Aq0/2WZceNba+zppvaM6G6RhcrY8o22tFr2oF2Dotp3GM
	oI3wAxr+C+MarmXubeABLUmSPLLfA9TkX/l4fpyWtasUW/ZKtEKb9Uf5ftDywLb5FhQ==
X-Received: by 2002:a62:2e46:: with SMTP id u67mr83475565pfu.206.1558379632648;
        Mon, 20 May 2019 12:13:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySqXJ4KNyInw/ii6ynsqJSy1Z0f+XUPHoASvfQ7lgGOTXDr5m2Td220ZQ1l0CIVgTK/EkJ
X-Received: by 2002:a62:2e46:: with SMTP id u67mr83475366pfu.206.1558379629985;
        Mon, 20 May 2019 12:13:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558379629; cv=none;
        d=google.com; s=arc-20160816;
        b=ohduebaxucATwIafkoQWqN8rtdNO95rvvpFdqngeB5FoHgFsU3mPOl042PXQB2/952
         GM95d6cZdGO3/eVl8J+MCl2dS5r6if0xZ5WBM62OnolQB47+NEnMKLgja/LB417BcuIi
         u4utADQLmQLXGsjlrazcFRugCir/mf5AmbE1D6I2t9+hfT70u2zy+IKHj0urZ7p8aP5s
         MKQswNlDgtU2RUsHntYBPX0yBdl+RXAfAzZ5d5AwQ+uGFe+i8a9/OWExe5m7pMkj/GYJ
         QpMxN8ylcm4VanEupK2lLyAgzILF7a/HKexm/9p3zFZ0PwZWteY1dJUdChXgRg9/K5cv
         PI9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=+BnloVV/KgLBCi5Xj6RsaxGY+4nu9/nFZGsfY1xo0is=;
        b=PdTrMyXMB4I7i7GtZihZDH8lA4Xz5hB59gp9MGHSme1YmSpEeoy27kkfkkXi1EFEsq
         MUBuI/33K0n7bPtre7tlwgCn+Mca4E5G2/R2ucV9YGvZ2c+QDRK0mD86OmK1Au4xaEdD
         vJS8pUt4OfLcde0PTT3Zt5x2MxECZDXpUpHkO44aZBhPCrXGDCMaO6E4krnp2/+Z+3Nr
         ONGxlmScH7oPMYLhOhb2yKh7JnTdCf+yfy4i0ah1t8gwcbP8pkA8tAmxl88/lHNw1mp+
         inAKUMCU3gfr/kGZttdoWwBFrfTJMBj2VT4XWjqU3ZtePq7TxpVBPtED1+AdLOfHRbfJ
         0aCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id h186si17791525pge.184.2019.05.20.12.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 12:13:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 12:13:49 -0700
X-ExtLoop1: 1
Received: from orsmsx108.amr.corp.intel.com ([10.22.240.6])
  by FMSMGA003.fm.intel.com with ESMTP; 20 May 2019 12:13:48 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX108.amr.corp.intel.com ([169.254.2.171]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 12:13:48 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "peterz@infradead.org"
	<peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"bpf@vger.kernel.org" <bpf@vger.kernel.org>
CC: "bp@alien8.de" <bp@alien8.de>, "davem@davemloft.net"
	<davem@davemloft.net>, "mroos@linux.ee" <mroos@linux.ee>, "luto@kernel.org"
	<luto@kernel.org>, "namit@vmware.com" <namit@vmware.com>, "Hansen, Dave"
	<dave.hansen@intel.com>, "mingo@redhat.com" <mingo@redhat.com>
Subject: Re: [PATCH 1/1] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH 1/1] vmalloc: Fix issues with flush flag
Thread-Index: AQHVDPQ89Mk/2ntUo0SzbjfhLaw0JaZ027yA
Date: Mon, 20 May 2019 19:13:48 +0000
Message-ID: <174b6e4b5891394ee1695b898d72949d53ff6c98.camel@intel.com>
References: <20190517210123.5702-1-rick.p.edgecombe@intel.com>
	 <20190517210123.5702-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20190517210123.5702-2-rick.p.edgecombe@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <BA0B2387AB9936459A251CEF9F13FCB0@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA1LTE3IGF0IDE0OjAxIC0wNzAwLCBSaWNrIEVkZ2Vjb21iIGUgd3JvdGU6
DQo+IE1lZWxpcyBSb29zIHJlcG9ydGVkIGlzc3VlcyB3aXRoIHRoZSBuZXcgVk1fRkxVU0hfUkVT
RVRfUEVSTVMgZmxhZyBvbg0KPiB0aGUNCj4gc3BhcmMgYXJjaGl0ZWN0dXJlLg0KPiANCkFyZ2gs
IHRoaXMgcGF0Y2ggaXMgbm90IGNvcnJlY3QgaW4gdGhlIGZsdXNoIHJhbmdlIGZvciBub24teDg2
LiBJJ2xsDQpzZW5kIGEgcmV2aXNpb24uDQoNCg==

