Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE9AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:58:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06D2120657
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:58:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="D4A9+Cb2";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Quey626e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06D2120657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4E9C6B000C; Wed,  3 Apr 2019 13:58:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3B86B027C; Wed,  3 Apr 2019 13:58:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8501C6B027D; Wed,  3 Apr 2019 13:58:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6A06B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:58:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so7946230edb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:58:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=szVyQXzqNWFLz55J/ZpIrcml3NcRugE0hUK+gSoqhVQ=;
        b=WOHW6cB5+DQCMAQChjBo//Y3UeAGyEbfPdiQ3Nt9o1Ll1XAUiZLuKLCiPHShHlPn9s
         kraSESAtTN0/BsJ17gcHwoCbQYsn/cGXLiBYUZJoS2i40TIYXPvIML5v0EUvqApPHuCL
         1zqVgqTGX7OB52x/oEKYtNJY9hY/9YNQ3qBnzZcAF/abexkCYhXkl+ermn3sxbIIhXjY
         eOA+tSANiZBuSxUx7z7y8yFA9qWUOiHHvd6mp5Jdl7/4CCC67KUBWznTO96qOsQGcLtc
         5d28jrd9XCEOAvVuOH51GvNr0gn+bbHmfowq10LPAndqDBV74CPFKllVbfiYY1oDM+2B
         +fxA==
X-Gm-Message-State: APjAAAVL0d5/uVocSnibv0aJy8VW/tsa7iv3O+BOlqW0xF/Bq15/ImrQ
	WW2mEhHT1stgsorlBadqaJd6EIaHlpORaXJH/bWKsLRS9+aYvMq4DT3y2K53FwbABaNGqanmkKH
	INS+al/Y+CZw2fK1TkU075Ij6SJ++2zYRYb3V8O+dyD+nfmQ8/co1rBCi+BDWOSazJA==
X-Received: by 2002:a17:906:b6c8:: with SMTP id ec8mr637325ejb.89.1554314294748;
        Wed, 03 Apr 2019 10:58:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBWE7/k4yCiauGwDIZ0SmTkiuwNGZzirxQHl6rpbZKAjSVuEaHEPPVc+uE2DuklyEYl8X2
X-Received: by 2002:a17:906:b6c8:: with SMTP id ec8mr637288ejb.89.1554314293918;
        Wed, 03 Apr 2019 10:58:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314293; cv=none;
        d=google.com; s=arc-20160816;
        b=m9imeGWlvTGXxpYVzTZw9mElDC6n7qbFhxqsaYoT4Ap5pjbSaIxgG24Gwj3AFJlOt4
         cXoH+2relu5gr+Ph+ox2+72sj5dc3VjwPKKbclJKqSvEkDdIpoxKuCzRczQRQQQJsSOW
         q/8Bab525GUWiTXYwHJH6PTJ9dxYuDKd7ALl174QA14EDy0rAM6IaedSGpgjydPky4K7
         k8crBBmkq0uaO+Hj1ATN4pWZ7ozesZNISIxZ2vFTXs2Xk6Y7YZJCXJYR/Lrok+Hk2swG
         tar8uj6gN6DELrYB0wej3Ze+GcmL2V5CoESp3n4mzrRVBhbHMkRkn51WFInCc4C8aZ0q
         spSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=szVyQXzqNWFLz55J/ZpIrcml3NcRugE0hUK+gSoqhVQ=;
        b=Y71wjEDC3z+c3U+cdFto84U22E31WTpl6nAeL1SMKRIRc1dLx6LKwDh0rPHPIntkXF
         6jAWNw5cO3IDecH7fdwxiLSdwVnESLWtjAazTFtSRuGKQSbzlXPG7clBMSyasV3KhZDs
         3VquC4jEKBTA7gwnjgNJ3tcNczbI2imRH3HJOJxnKV5yDbnALXdJHr4LZRRSuZ91/ndB
         R83EnKh3/QD/bchNtwK9KekjwzsohwKtHm/KS1JdbVJ2lDWT7EeKcdbPu92hkVTt9Rsp
         BVpDB4qBag2Nc/b3mBd4DfSoox6IGwEZUejGMAX+95C8Xn5uPprXovBsigGk7l/j34yt
         c5+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=D4A9+Cb2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Quey626e;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d27si856314edb.436.2019.04.03.10.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:58:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=D4A9+Cb2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Quey626e;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33Hqpow001589;
	Wed, 3 Apr 2019 10:57:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=szVyQXzqNWFLz55J/ZpIrcml3NcRugE0hUK+gSoqhVQ=;
 b=D4A9+Cb2q+yHlJw+MNGM50mCNehKtmxAFZ2rDBqYP6i/widC0ggiZ0+ENI1HSFxpAPm9
 fa9LfN0/8sEe4z48uRRgSfEKLmjLs99UWnM6T/ldsNv5hpsuBRyAw9xLSibszMxotRm4
 IVAnhrh8LP1b5oCELhQ9N0UjDf51zw3oLcc= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rn1hvg1dv-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 10:57:57 -0700
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 10:57:53 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 10:57:45 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 10:57:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=szVyQXzqNWFLz55J/ZpIrcml3NcRugE0hUK+gSoqhVQ=;
 b=Quey626ebiTBxmyhI0+PVUiCsNnGs/iLpDJVZr+fr3cqDhMianAKQiPpX19z5Xe0ULVy74LZwcdCMEdKEOs5ktNwx7EdcohGJFQybiiUmVTQNvxYX49xkDCf9eFMh1lcxMszypEv50Dnywo/8yMLP+GwvLkEJW/OWJjIj6Hxh4E=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2231.namprd15.prod.outlook.com (52.135.196.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.20; Wed, 3 Apr 2019 17:57:43 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 17:57:43 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter
	<cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David Rientjes
	<rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Matthew Wilcox
	<willy@infradead.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 1/7] list: Add function list_rotate_to_front()
Thread-Topic: [PATCH v5 1/7] list: Add function list_rotate_to_front()
Thread-Index: AQHU6ai/hRRVJsHCh0Ws9dfflaiJBKYquiKA
Date: Wed, 3 Apr 2019 17:57:42 +0000
Message-ID: <20190403175739.GB6778@tower.DHCP.thefacebook.com>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-2-tobin@kernel.org>
In-Reply-To: <20190402230545.2929-2-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO1PR15CA0085.namprd15.prod.outlook.com
 (2603:10b6:101:20::29) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a106cac7-85a9-43f6-e12a-08d6b85dde9d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2231;
x-ms-traffictypediagnostic: BYAPR15MB2231:
x-microsoft-antispam-prvs: <BYAPR15MB2231D9DC7E65A43F17277132BE570@BYAPR15MB2231.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39860400002)(346002)(136003)(376002)(199004)(189003)(6246003)(86362001)(25786009)(46003)(486006)(81166006)(186003)(81156014)(2906002)(305945005)(6512007)(7736002)(6436002)(1076003)(102836004)(6506007)(76176011)(9686003)(105586002)(6116002)(386003)(6916009)(8936002)(106356001)(14444005)(8676002)(4326008)(53936002)(99286004)(6486002)(14454004)(478600001)(52116002)(5660300002)(71190400001)(71200400001)(256004)(33656002)(68736007)(446003)(476003)(229853002)(11346002)(316002)(97736004)(54906003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2231;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: sHSjdRnrnJck4csKcNDUt05UUmEkRZ6JRXUpgdY2ivdycWiocae+N18jlYYUVTPJNIdPt9z0w7fBdt8e2ZFLrE6zGgPi7EOATv0wRDhO2T0M8kAMDnMs2/pYU9hCh9//+cB3N+fd/pAhiX0s501CcJyHirdawEG7vRs+qfkviGzjIa/SB9gm9IwQZOcRm3CxhevQGRRwrz+EeP3kl8zxlWCetSMUg3/9QZnO9mWiLlueRccKIbTjspYHWaxLPaRpTivCDDMeiDu6Hx+L8/WorhIIvfNZ4ZvoMmDCpeEJGeNdg2RtSr2BFDGmbiyydC/tDS6eUCwaeNAFVijXvlPKe+PNYrigEo883wbv1/po9Jxe7OwoowJaElcTNAKZx4HqvsMiAu90rol/KqYXWDTOq+JZids4bGNbB4q4XcvKnqA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <088A820733D4244DA401E5CE186B29A6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a106cac7-85a9-43f6-e12a-08d6b85dde9d
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 17:57:42.9005
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2231
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:05:39AM +1100, Tobin C. Harding wrote:
> Currently if we wish to rotate a list until a specific item is at the
> front of the list we can call list_move_tail(head, list).  Note that the
> arguments are the reverse way to the usual use of list_move_tail(list,
> head).  This is a hack, it depends on the developer knowing how the
> list_head operates internally which violates the layer of abstraction
> offered by the list_head.  Also, it is not intuitive so the next
> developer to come along must study list.h in order to fully understand
> what is meant by the call, while this is 'good for' the developer it
> makes reading the code harder.  We should have an function appropriately
> named that does this if there are users for it intree.
>=20
> By grep'ing the tree for list_move_tail() and list_tail() and attempting
> to guess the argument order from the names it seems there is only one
> place currently in the tree that does this - the slob allocatator.
>=20
> Add function list_rotate_to_front() to rotate a list until the specified
> item is at the front of the list.
>=20
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Roman Gushchin <guro@fb.com>

