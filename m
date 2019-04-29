Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C477C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:58:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDC0E2087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 16:58:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDC0E2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7EBC6B0010; Mon, 29 Apr 2019 12:58:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2E016B0266; Mon, 29 Apr 2019 12:58:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944996B0269; Mon, 29 Apr 2019 12:58:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB376B0010
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:58:13 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e128so7535570pfc.22
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:58:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=9qAkDO1RCNBG4eZ+0iC96z5lxEkGnKRGUjbMisi9De4=;
        b=EEvDwT+FaN32dBWSngB1h7yiYhHkMn4D5LAAJRkC4kQl5XGM+NJDC/eG0Lr/BOP2Ij
         4BwK2jvBajlTAXd5OC0LHJ07AQgnB/aRqngwzATJacFjAlIE08Le71G6UzhxX/YJWkqc
         X1HuidZTxxWsiU+HhT9A2SvUSQAimX/Wo/E9nS9MUVWkNy3Mi3o5Lvh1ZcqamwaAQXTb
         H281RaTishVXaJm6RYQyID0SzT7oKeavgXbNcV1T3YneDdnlxny78xwR75Dowq5OBFK7
         cq4tL+lIqQhHQ67bxs5GfygL0VD1jU7Kcnof0jTTAtAQntXzXdRzju2alP+6+r8vUI8e
         akzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tony.luck@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=tony.luck@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWWmZv/Z+0nHdqW3CKXe56JyEPSbap8MOK3LNkoAN3eX0o26mZX
	GNU3KyVgkpLZeCn0NRnWTHYW5Qw36IRlm9ggG76P+NaiR6Ss8PhVKIiqD4oJ6ZK4ytSbeWY+pBF
	vMAl/P3Kr0r9XU4zJuBCJ7R/u3ydBU/nok+M7gho/eapnIQ024Yfi02mrovE6W6M7Wg==
X-Received: by 2002:a65:64d3:: with SMTP id t19mr25114585pgv.57.1556557092988;
        Mon, 29 Apr 2019 09:58:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvIBkLNZvyS/AY7GPNuU7rjtvWM3a5xuL2b5qVIicPfbJRcxUyeCTfR8HvBv88IVbT53US
X-Received: by 2002:a65:64d3:: with SMTP id t19mr25114473pgv.57.1556557091990;
        Mon, 29 Apr 2019 09:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556557091; cv=none;
        d=google.com; s=arc-20160816;
        b=aldIbyfK7mQzrJdhm/snppwE7Z3qNVdbuyn288CYhgqJXiilkgb1S5vx8FXEW5kUG3
         fG0V6KFMsbRxrj/ZigQwCNVWquQpcWrdh6IY3t8xpShDZGUXu0lbBNd4y7ChjUcMSQF7
         m8Sw0viLBkYxDBGbcveXfsiOr+xabyQQoAQvka7eVxjeUHLcTRo/uCTaJ7cSo2FE4cyf
         TdfaBWHmfKJNwbauDb9EM9VAZszq3EbY1cCiRdKPNuAicriO/Fp6ZqyVW0yCwGirLV0F
         Uw9pUT/1mkJbJ9kIW4AaNfMDiLUNmL66WeHT7Abj2FOxVc3QY5bb4U4Fs39OujMBPOXJ
         QvWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=9qAkDO1RCNBG4eZ+0iC96z5lxEkGnKRGUjbMisi9De4=;
        b=kcHNcs4cD0zHLMiIsPTg+b1BAR7Xn2YuqPUd+M6pFfsm1GK/BnGbKURsFSrWMTFSr6
         tB0X386c3+OJh/EL1czu5Hqp3iH595NBB7Hi0jNx657sEzchtWfhUlb4VG6nPLkexg4C
         tassLVQKSzETJXXfsy/IcoPSWLGmOGLK8n4qshpSGdIOvUVt5J8hRH0kaCxBmvkNlInd
         E+UF1uEtfAawVlQyL93wJWOLpI9K9CItM2vxVFubm+QBK5UWixXXWjqqUde042b/B3gT
         dtCkD9T5S/cYSMjTTDsmP3Re/RDWOeY/xHA/bhz2H6MyXTv1Qk1Roi9/ryPKQTpvRNrn
         hGNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tony.luck@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=tony.luck@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u125si35063826pfb.112.2019.04.29.09.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 09:58:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of tony.luck@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tony.luck@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=tony.luck@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Apr 2019 09:58:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,410,1549958400"; 
   d="scan'208";a="169009686"
Received: from orsmsx109.amr.corp.intel.com ([10.22.240.7])
  by fmsmga001.fm.intel.com with ESMTP; 29 Apr 2019 09:58:10 -0700
Received: from orsmsx104.amr.corp.intel.com ([169.254.4.183]) by
 ORSMSX109.amr.corp.intel.com ([169.254.11.52]) with mapi id 14.03.0415.000;
 Mon, 29 Apr 2019 09:58:09 -0700
From: "Luck, Tony" <tony.luck@intel.com>
To: Christoph Hellwig <hch@infradead.org>, Meelis Roos <mroos@linux.ee>
CC: Christopher Lameter <cl@linux.com>, Mel Gorman
	<mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>, James Bottomley
	<James.Bottomley@hansenpartnership.com>, "linux-parisc@vger.kernel.org"
	<linux-parisc@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "Yu, Fenghua"
	<fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org"
	<linux-ia64@vger.kernel.org>
Subject: RE: DISCONTIGMEM is deprecated
Thread-Topic: DISCONTIGMEM is deprecated
Thread-Index: AQHU/ZpXmcVCt4ADQUqjpwA1uPgMxaZTXO4w
Date: Mon, 29 Apr 2019 16:58:09 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F7E9140BA@ORSMSX104.amr.corp.intel.com>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <0100016a461809ed-be5bd8fc-9925-424d-9624-4a325a7a8860-000000@email.amazonses.com>
 <25cabb7c-9602-2e09-2fe0-cad3e54595fa@linux.ee>
 <20190428081353.GB30901@infradead.org>
In-Reply-To: <20190428081353.GB30901@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZDZlMGYwOWMtYjMxNC00ZDg2LWI2OTMtNDI5NjUwZDU1NzllIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiR3gxdGpVSlhOVlhRSWZVOExpNUk0emx1dkVMZzdGZ3QrK21zNE95d2g0a0VGR0tvWTVQY1lRUDBuMjkwVWNEZiJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.22.254.140]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> ia64 has a such a huge number of memory model choices.  Maybe we
> need to cut it down to a small set that actually work.

SGI systems had extremely discontiguous memory (they used some high
order physical address bits in the tens/hundreds of terabyte range for the
node number ... so there would be a few GBytes of actual memory then
a huge gap before the next node had a few more Gbytes).

I don't know of anyone still booting upstream on an SN2, so if we start doi=
ng
serious hack and slash the chances are high that SN2 will be broken (if it =
isn't
already).

-Tony

