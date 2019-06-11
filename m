Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1F90C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:29:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8240120866
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 16:29:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8240120866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF896B0008; Tue, 11 Jun 2019 12:29:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196706B000A; Tue, 11 Jun 2019 12:29:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ACDA6B000C; Tue, 11 Jun 2019 12:29:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAC036B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:29:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u7so9943438pfh.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:29:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=gVewo6rKXcRiSTRElzaSFvOFz90B2wZ8AfNM+CxmlRU=;
        b=J7DoiYKLdrlki/DOjc5EUabhkdtvVUF2eNBYGRJdUGqnPI9JuuitcMGcxaj9wNhSC5
         +gQ01qrsghITz06JnJJoc5aO83UN14JX4IIIsNV+kt8QVnCa16GUy+XEWzDRbwU6qrfT
         U+KmJELWRAKDx2YoqfbKp5weSD1o7SGFpuXBzyPZojRP5Pv+gnWKEs97HzirDkh5FgPG
         vJj0o6F9Gk94ilhPLPzSisuVaD2BBF5U7fRgHc3UDEKhwAs4x8HPJz1E6Yzcd1lsDBcN
         vDCwUdQSuSbL0HOCIaRzLw1TyHWN1xkW+zAuuKT+wkgeL6uPl+cqaDmfb72PoGb+ctNh
         c6+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1J1wJWh/StJObTg4ncn/UCf4aMT3DoqtKqmqb7eLPRHu1xuYN
	wqr33+QnjG2x5qyQpGTtez6QBnfK6XVxjbB/aRZo7mzBRBvv5pNdJ5OcVeEwch8oQiMlJTjT1Z7
	KJXl7wvpeDofp7yRYemOZlsheUOg1t4LAccgRH8nL1PcG8m6cheY0kWTNaUZOqFxxYg==
X-Received: by 2002:a63:6cc3:: with SMTP id h186mr20739030pgc.292.1560270556449;
        Tue, 11 Jun 2019 09:29:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6jhFCQM27k5smf+43T52TD2EQaVuqBswmJRsshIF64iHF4m/dp6YizEQnp7/gxBVvAguY
X-Received: by 2002:a63:6cc3:: with SMTP id h186mr20738983pgc.292.1560270555639;
        Tue, 11 Jun 2019 09:29:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560270555; cv=none;
        d=google.com; s=arc-20160816;
        b=LF6gnvebFEHD6yVCanJnDfxoH3UGBKKeTjqY45Var6z29f/5WKvx/AJpyfehl5/5iA
         xV1+aJLvZujnmrw4pr61J/fj5u/xNQd4hAtB4YuKqp9nc8zBQMwjFBKQRpO4N+eJ2eNl
         1oQueggvyzMZ4FYFNxyl3JdiRvBg+3Di2upovOMJp8mBlvcucx0tDKwJNOFUCxYI5Zdw
         3e0aWqtiGhDTy4bNkJK1blopobON/FBqj1v8Zu24y2LksmVlz7pw/nSRYFVfJc7uLrrZ
         PHQHfStlgpUy+3foQa6djx09E3ycgKgcZZTR6M8fApeE/DvNMHzbSjdrdInKWMdYksPG
         VQwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=gVewo6rKXcRiSTRElzaSFvOFz90B2wZ8AfNM+CxmlRU=;
        b=LnKiPtZ35ouXsu+j9ftgH89KO+dJk7DsJgSTZMdMWSQnAf6ta5XCWv7SpYoAlan2lq
         dtry2n/OOBlbbhNOn+CEymcbL/JGrL4YTZ5BuSR9RI6m9RSveTz45G0ZPeT0bpBtDO5H
         Ou/5yaLPo8vHLo5oSqH6fKwE/V6xLmdUn+o+2Yk++19s9K67WnqqbBGeAXZMqF35rily
         Tl9mHJqIWjJ7XHjzZFiJmtyaCChRXgPRsztjBEO6a9plPvsa7Uw7KeEp1r/b14Z6baJv
         5dYVI44MPXiPPzTRPXlVZhBDfs4uKGdDZHH8bP1YB5a7clfIapCb6aJjT2FckwgY5Sw8
         qgqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d3si2768676pju.18.2019.06.11.09.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 09:29:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 09:29:14 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,362,1557212400"; 
   d="scan'208";a="183854146"
Received: from fmsmsx108.amr.corp.intel.com ([10.18.124.206])
  by fmsmga002.fm.intel.com with ESMTP; 11 Jun 2019 09:29:14 -0700
Received: from fmsmsx151.amr.corp.intel.com (10.18.125.4) by
 FMSMSX108.amr.corp.intel.com (10.18.124.206) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Tue, 11 Jun 2019 09:29:14 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX151.amr.corp.intel.com (10.18.125.4) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Tue, 11 Jun 2019 09:29:14 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.187]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.113]) with mapi id 14.03.0439.000;
 Tue, 11 Jun 2019 10:29:12 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Pingfan Liu
	<kernelfans@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, "Williams,
 Dan J" <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>,
	"John Hubbard" <jhubbard@nvidia.com>, "Busch, Keith" <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Thread-Topic: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM
 in get_user_pages_fast()
Thread-Index: AQHVG36TF7XX0SZE6EiYxwAZNS2AbKaXD1+A//+c5MA=
Date: Tue, 11 Jun 2019 16:29:11 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79D8D79B@CRSMSX101.amr.corp.intel.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <87tvcwhzdo.fsf@linux.ibm.com>
In-Reply-To: <87tvcwhzdo.fsf@linux.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiY2Q4MmE1NjQtYTAzMy00MGQxLTgwZGQtMTBiZTlhNmI3YjBkIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoicWI4RzJnMmVJWXFjWlp5UUpjRWt0M3A2VURCbHRxY1J3eG5vSkxYRWxjUDkzb092QkxZbjdjQ0ZpSWhZVzd3TyJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Pingfan Liu <kernelfans@gmail.com> writes:
>=20
> > As for FOLL_LONGTERM, it is checked in the slow path
> > __gup_longterm_unlocked(). But it is not checked in the fast path,
> > which means a possible leak of CMA page to longterm pinned requirement
> > through this crack.
>=20
> Shouldn't we disallow FOLL_LONGTERM with get_user_pages fastpath? W.r.t
> dax check we need vma to ensure whether a long term pin is allowed or not=
.
> If FOLL_LONGTERM is specified we should fallback to slow path.

Yes, the fastpath bails to the slowpath if FOLL_LONGTERM _and_ DAX.  But it=
 does this while walking the page tables.  I missed the CMA case and Pingfa=
n's patch fixes this.  We could check for CMA pages while walking the page =
tables but most agreed that it was not worth it.  For DAX we already had ch=
ecks for *_devmap() so it was easier to put the FOLL_LONGTERM checks there.

Ira

