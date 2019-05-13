Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B01A3C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6271720989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 09:21:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="1xs1l8ip"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6271720989
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2CA16B0275; Mon, 13 May 2019 05:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDD976B0276; Mon, 13 May 2019 05:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA56A6B0277; Mon, 13 May 2019 05:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5E76B0275
	for <linux-mm@kvack.org>; Mon, 13 May 2019 05:21:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so17034995edm.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 02:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=wpQenlchEVhV4euQXTFLGGQfIy3VwdfKzHdbshG8Jls=;
        b=Iup4q934B50V/7CKtnGvVDIsNb3uKpqA1AWPLiIpEz1cqYihSMdW+ShqrtOqAyfsyj
         XnWfkIpjSZcre9FVkHsnI7IA/j86t+6PNIf5tgH1wVUlDp3yv9cVcmBkT9L9YF8pJlfT
         r1lBPUWQB3LZJIikePnwNw9wxxWeLF8hzdOOmG9Q05xF2uAu74jCE4Sk7qkRXXR7e6/J
         YK0rYveec9B2qqUY2iw4E23AJwwtQv9E9gCr2OWNfzbqIK5eQETphfRQqlHJL8SiVOTt
         7gMODs73qeRCEUE/O4sMlDfwOFF/IuqN7U3RXAvmSKuV/LpEM+eT2WfMaAloNc3ggJCf
         MH1A==
X-Gm-Message-State: APjAAAXqQ91imeztmHDTC8Try5rGudMIf1i3EaM+HN2Tl4P9gUbLFa7w
	Q0iV5TAGFbzE1KB1xwe5q3M/RqYlMsItzTpZbQ4gfYWMqI0iYJVv9GUpaI/O7IEKKxspsNNqC1o
	fM/p3sMm0aG8TDUizetJUP3VkVD8vAIJdDqtb7we99oFf7QvHAi+5IO4DlYtiSDOwaQ==
X-Received: by 2002:a17:906:6556:: with SMTP id u22mr19638628ejn.180.1557739266136;
        Mon, 13 May 2019 02:21:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwieJS3U6M8XD6CuH1rGNAIBwFTJ5Tkr2gIudLduzU/mqlNlsszoLoVDCFTblsDC+EVoP0F
X-Received: by 2002:a17:906:6556:: with SMTP id u22mr19638582ejn.180.1557739265279;
        Mon, 13 May 2019 02:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557739265; cv=none;
        d=google.com; s=arc-20160816;
        b=JjNgxWUnQhiEndS5g2LL/pB2G5mZ+snuVSX46oQwlH+2s72yagEUzIAEmeR+Ize0sm
         x2UTp4qCwMPnEFEOyon65btfq6uktfVXustWeOaa2CURPOL2XbY+glUpgoqLNgZtu737
         yFA+fkr72pxK5XaEPumVjxcTlxmNHqHgK9JBlqgqO7Uk/X8PvFVmQALGy2izlI4tdWyZ
         HS0XThDqF7d8VVuFeKZ/+CFLejMs6BISuC7eUDBYtZ5jh17cXToCbDYlCtLGVtb/7SM3
         enGYEuQX+f4aecRMhNtVKGBSgtX/xFpMRQSov3IEqAG5JM2/HcFehnBG9KavmlI4LOxP
         NyWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=wpQenlchEVhV4euQXTFLGGQfIy3VwdfKzHdbshG8Jls=;
        b=PkG9c7pYUs+nUc5xAw3xZYSh1pcic4BEggLnkoRmbDuykK8dsFDrrZt+JhzBTXLA1w
         074hGBe5J0vF/X/5XjGgVRZPwl0/jDnDOluv9jzEU87qAza6+COvs3ob/uaL8IqLMXn3
         fDx/8mtW3bxPMObTa1LnTtyE7FuXWTccWb6gwHNZ2jAQLWx+S8M4ZlniCclHX75onuNY
         6nqzc5G2tSlhIr49JcW/K2+VE0VraRVJf+10rKBS/kjFQ0rQuQYRTiiuxIMpDzgLBBwE
         FoGJOSLNvfjH9lP6ffDJUJRbpoocggQGFolGCvOrTvCG6FDHzgtWs1XU31ea9Gy7g48h
         rjnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=1xs1l8ip;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.70.86 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700086.outbound.protection.outlook.com. [40.107.70.86])
        by mx.google.com with ESMTPS id b6si935629edi.407.2019.05.13.02.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 May 2019 02:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.70.86 as permitted sender) client-ip=40.107.70.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=1xs1l8ip;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.70.86 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wpQenlchEVhV4euQXTFLGGQfIy3VwdfKzHdbshG8Jls=;
 b=1xs1l8ip9XgGIbHrmiGznrt9OZMVA/nh7iinXKABA16dyA0aN6U17aRDSDBO+Ybv3g5rA3GsWTP47t1Bj9vOKj6M4zTKQ2guM6+7ncuevfCoGg4V8Bi+RStWfOHTfcnSIPzFCxio3OFGxxymaMUfdo6Y02NtqdpjCEq6DGNtbfM=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4360.namprd05.prod.outlook.com (52.135.202.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.14; Mon, 13 May 2019 09:21:01 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1900.010; Mon, 13 May 2019
 09:21:01 +0000
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: Yang Shi <yang.shi@linux.alibaba.com>, "jstancek@redhat.com"
	<jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Aneesh Kumar K .
 V" <aneesh.kumar@linux.vnet.ibm.com>, Nick Piggin <npiggin@gmail.com>,
	Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Will Deacon
	<will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Topic: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Index:
 AQHVBlNcdgyGQHvMg0ymTH6Y7O8srKZjDs8AgAANcoCAAAcZgIAABfcAgAAkYwCABXN1AIAACg2AgAACfYA=
Date: Mon, 13 May 2019 09:21:01 +0000
Message-ID: <847D4C2F-BD26-4BE0-A5BA-3C690D11BF77@vmware.com>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
 <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
 <20190513083606.GL2623@hirez.programming.kicks-ass.net>
 <20190513091205.GO2650@hirez.programming.kicks-ass.net>
In-Reply-To: <20190513091205.GO2650@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [50.204.119.4]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8037cc0d-71c9-443a-c2a0-08d6d78450e8
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB4360;
x-ms-traffictypediagnostic: BYAPR05MB4360:
x-microsoft-antispam-prvs:
 <BYAPR05MB4360448DF978D529BCC10D81D00F0@BYAPR05MB4360.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0036736630
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(979002)(396003)(346002)(376002)(39860400002)(136003)(366004)(189003)(199004)(53546011)(14454004)(6246003)(305945005)(8676002)(186003)(8936002)(6506007)(82746002)(68736007)(53936002)(81156014)(66066001)(4326008)(81166006)(102836004)(478600001)(3846002)(66446008)(66556008)(316002)(91956017)(2906002)(6116002)(76116006)(86362001)(73956011)(64756008)(6916009)(7736002)(66476007)(99286004)(66946007)(7416002)(5660300002)(54906003)(25786009)(76176011)(33656002)(83716004)(26005)(71200400001)(71190400001)(14444005)(256004)(229853002)(6512007)(446003)(11346002)(6436002)(476003)(2616005)(6486002)(36756003)(486006)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4360;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 CelJo98N5BTvgBiCtmSEwR3SSuriFAV1AWdPS3GaWiwjgig3EQhZ3CyoLcbcj5z1hi5TD3MxaK+7aqwEGdasae4pADNL8lhEd6eB4jMrlCHoEVPe+xu27n5H1l2NdmTEXZTDSFAxePnHQ3/QgLyDcRJOFN/ZMHaxB4FrnZAIb5CpZRjz5ItTTSmWTweJXQYhNJE/XfMEuFj9Y3GrpzVzD4JAh92A5NHs5IVLzu+SXf8cciyV+nMFQfcK6ggYHs0dzSHfkTnUkOItkfH/oY4/s2YFf7OHevdw/R7rmnKK5NKBVJGcX8s1RUBurbwJnrGOBdG1vHRs1wSwHGizXfmlM1+fiO7Uw2iSu+Hm7k0IMy4YV6blEKppgyf3g8DzcDsUQ6vsELtdi8EDvarBfHdIhoLO6xa1WZg4R914HApNMXo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2D5CBDD523036D4CB25AC81AC9005E04@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8037cc0d-71c9-443a-c2a0-08d6d78450e8
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 May 2019 09:21:01.0171
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4360
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On May 13, 2019, at 2:12 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Mon, May 13, 2019 at 10:36:06AM +0200, Peter Zijlstra wrote:
>> On Thu, May 09, 2019 at 09:21:35PM +0000, Nadav Amit wrote:
>>> It may be possible to avoid false-positive nesting indications (when th=
e
>>> flushes do not overlap) by creating a new struct mmu_gather_pending, wi=
th
>>> something like:
>>>=20
>>>  struct mmu_gather_pending {
>>> 	u64 start;
>>> 	u64 end;
>>> 	struct mmu_gather_pending *next;
>>>  }
>>>=20
>>> tlb_finish_mmu() would then iterate over the mm->mmu_gather_pending
>>> (pointing to the linked list) and find whether there is any overlap. Th=
is
>>> would still require synchronization (acquiring a lock when allocating a=
nd
>>> deallocating or something fancier).
>>=20
>> We have an interval_tree for this, and yes, that's how far I got :/
>>=20
>> The other thing I was thinking of is trying to detect overlap through
>> the page-tables themselves, but we have a distinct lack of storage
>> there.
>=20
> We might just use some state in the pmd, there's still 2 _pt_pad_[12] in
> struct page to 'use'. So we could come up with some tlb generation
> scheme that would detect conflict.

It is rather easy to come up with a scheme (and I did similar things) if yo=
u
flush the table while you hold the page-tables lock. But if you batch acros=
s
page-tables it becomes harder.

Thinking about it while typing, perhaps it is simpler than I think - if you
need to flush range that runs across more than a single table, you are very
likely to flush a range of more than 33 entries, so anyhow you are likely t=
o
do a full TLB flush.

So perhaps just avoiding the batching if only entries from a single table
are flushed would be enough.

