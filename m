Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 449F3C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:49:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B134420663
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 16:49:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="lL4pTzRg";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="EwOwEhl/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B134420663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 193D68E0003; Fri,  1 Mar 2019 11:49:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 144E48E0001; Fri,  1 Mar 2019 11:49:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00DD78E0003; Fri,  1 Mar 2019 11:49:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0798E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 11:49:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k21so7385651eds.19
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 08:49:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=qV1F0vgMFNiiNI3jBfb9NzxZ+UBd1KUqKhR7Izbz/CE=;
        b=fDm8oBBi60hs07YhcfekGQ5mF327HGiwZn1X+aCAXQtbA2Fm/1bzzPvuQfLyVBuuch
         NtA6w7OxgN1YJR1YNmFD5qGKYlg5jHf1xoklIE0NXXlIzjof7mnw2p7ZpgjHprvcwrvF
         JCHUW19JeFyO5P1GBfE+a7YryeeILNvfw9qT1h4slUgVAIud16tj7RlimCk/zryLpVkx
         KF5D0rRRfeKUZU/SZu+IcbpNdTORJ/o9wIWg2NAevgNnLKl5cXMP8iJSotwJN7BPPZ1u
         vZTx1kmkY4P0J15Cn0Nhf0d/ZDTN4mtsfJhyn5iL+RYrQTd9Z7dLoLl9i3nkGaRuVs8B
         4mtg==
X-Gm-Message-State: APjAAAUfCVP3v5D7vUSIiSKo48O/9PUM9wPsesQeysSgR1HN9lyGlnwa
	oMpxCaKOQ1Nth7YhR22sT3qWetUKWvSj46naPRVAOMdASgPuE153kQfVesF3QeknaWKSztitLxZ
	sn0h1oDn65t/xKVT4HGS13NwjpmcpCVHDkIN54EUIoHmd9mertQP6GEn7kQJDkuKJqg==
X-Received: by 2002:a50:8b9c:: with SMTP id m28mr4892067edm.141.1551458939965;
        Fri, 01 Mar 2019 08:48:59 -0800 (PST)
X-Google-Smtp-Source: APXvYqx1oaX+LHXyfGuZIcppL5dDCZD0jB6fbVgKEjKPybJzB2GjehbLVHXQsChWHkUYp1ekoZUn
X-Received: by 2002:a50:8b9c:: with SMTP id m28mr4892008edm.141.1551458938826;
        Fri, 01 Mar 2019 08:48:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551458938; cv=none;
        d=google.com; s=arc-20160816;
        b=cmMA2f37m1uR7SvJC1W2eKs7rYkA/S60WVORZ5goY+nppmyhz1fipPzBxoQt2eYF4B
         PbeMdh0xu4Wsce7q14sXxkXLg7rTJuzsL5Phgt5CQ9zbXll+6kaN8gaZlhL6fKk5qY5A
         YxX/BEXck7sZ3B440ZqUQpcUkD+a7dknoydgNQzSzF5VdepIRZD4TB3a0Nucjqzh3J00
         EObDHHLTldA6Bt6oW0ByAE5mKuTFRcp78HT9wBoG8GDifD2utVaTbeXrYQMc0B/W5xZa
         do831i83620c3NbhTHaRwiukqVxqn00E1/flBfcASl1MIBqtlEtxVHeApVBR8i8Xgnl+
         D70g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=qV1F0vgMFNiiNI3jBfb9NzxZ+UBd1KUqKhR7Izbz/CE=;
        b=i/WzlNJrKgqtJJEsdAl9HOTykp/+VIjThVa4g51VwUkRUC0huq2uGwouhMWDFgjs48
         Pmda+BjVu0k9BD2lSgVtj+fZzTRoFH/oBhr8WrjL7NS2ZWyRTJyZN2uD/cBcx6o+R2H4
         WiH1/4QDLbddPb2AK/Ts8pE+8bMAh6Cwo0tbgWBRvMnMkvwQYHKZ2PfR6FsFr0cwCOkn
         RaC/hYe9EmyD9a3NxM0TyxLQGFwDnzLdXFTjgvAIznZhmoqQgf+EHD2gjPt8je96h1FZ
         gonsHojwkcmKJ6wjEAyXNDQylN08I04QGSSNWa43aMl/wtBJdTOKobsZFY1K+EBcpb2L
         sA1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lL4pTzRg;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="EwOwEhl/";
       spf=pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=8963d4cd73=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o19si3069795ejb.320.2019.03.01.08.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 08:48:58 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lL4pTzRg;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="EwOwEhl/";
       spf=pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=8963d4cd73=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x21Gkq1E006723;
	Fri, 1 Mar 2019 08:48:46 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=qV1F0vgMFNiiNI3jBfb9NzxZ+UBd1KUqKhR7Izbz/CE=;
 b=lL4pTzRgql0Ey81W1fMZVQCxk+R2l5A76/vmcyhaGr2A9qFPDiabL0DPzlMNmj4fBdq0
 qKIGcdAPSqeBR435n43cdk1JUpMCIcy22AEBV8cGz7GuNLvZgrfvNErD3piM1AFHOITR
 NFJ4JtkVCO5pKLYtittNGuKFGPndNv0Kz5E= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2qy7c3g8c1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 01 Mar 2019 08:48:45 -0800
Received: from prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 1 Mar 2019 08:48:44 -0800
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 1 Mar 2019 08:48:43 -0800
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 1 Mar 2019 08:48:43 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qV1F0vgMFNiiNI3jBfb9NzxZ+UBd1KUqKhR7Izbz/CE=;
 b=EwOwEhl/rbQII3jNiRACDn0MM2NCvKcll5XHJiFMBkr/SodfRAyRpxTqPEpZado55sK6v7c43KDyv9c+tUfBhK/BPzYWW8wHHwiMRkvh5HVvKao6ajpb5UpTWoteWsNR1Vjej5oQLs3OOwJvP3HcXx4CWopXJd9vsFQyOJybVQo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2869.namprd15.prod.outlook.com (20.178.206.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.15; Fri, 1 Mar 2019 16:48:41 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.015; Fri, 1 Mar 2019
 16:48:41 +0000
From: Roman Gushchin <guro@fb.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Matthew Wilcox <willy@infradead.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH 2/3] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Thread-Topic: [PATCH 2/3] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Thread-Index: AQHUzUkHvmEZiK9g+UuhGR24XSYfTqX236aAgAAjAQA=
Date: Fri, 1 Mar 2019 16:48:41 +0000
Message-ID: <20190301164834.GA3154@tower.DHCP.thefacebook.com>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-3-guro@fb.com>
 <db6b9745-7e64-6eb9-6b2b-da9d157a779b@suse.cz>
In-Reply-To: <db6b9745-7e64-6eb9-6b2b-da9d157a779b@suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR12CA0039.namprd12.prod.outlook.com
 (2603:10b6:301:2::25) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:7a0f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0aedf333-3195-4c5e-9076-08d69e65c244
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2869;
x-ms-traffictypediagnostic: BYAPR15MB2869:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2869;20:pZqoy77TZneKHPbZWFPsf1hffR/n97bXgdLEGOawnn76ZG/N/QXUTam3Xai2uyhTwhOTsheYklmiY80v28hLRNJmdgPyriAEtfVQLLmEzxeiyNQUSiMB/VxMPYKFHIDxZlCfovoucCfZ7U9ny7BBog32lHQDlkac1rvpft+0G9o=
x-microsoft-antispam-prvs: <BYAPR15MB28699704F17D8024FD9EC0E6BE760@BYAPR15MB2869.namprd15.prod.outlook.com>
x-forefront-prvs: 09634B1196
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(346002)(376002)(39860400002)(396003)(199004)(189003)(6916009)(476003)(446003)(316002)(11346002)(486006)(7736002)(1076003)(33656002)(54906003)(97736004)(46003)(81156014)(102836004)(8936002)(186003)(386003)(81166006)(53546011)(6506007)(99286004)(106356001)(8676002)(52116002)(14454004)(105586002)(6116002)(478600001)(53936002)(4326008)(25786009)(6436002)(5660300002)(305945005)(76176011)(6486002)(6512007)(9686003)(68736007)(2906002)(6246003)(14444005)(256004)(71190400001)(229853002)(86362001)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2869;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Gd016rsieWHZhRa6i464bFw38vIBLldCVt0T/TK8VaKbsJjmZQOK+H7jIdWqbVbgXdEMB9TjIkq9aJxxDPP1/uyzXlyCEX33MP4hpLDWjcU6tomdvhKw1RlWDOUg3fKGlSdre3Hnnq0m5nvvo7kbIEEgZPP8wDy++oVmTJTWNFlK1vRuKCkhe3sEFzWqeomvTx2ZNqI+TeQ6oFJL7qpMpEOGk2vhTpPIsLMjAyhLLdWfiK0h1q8faaL94iE7LjpYuJOmu8q9bjNU4+OxPxOpgy/IRTL/VjA2ZOr/uF/BFVPR8Lrvp6RNEzh2OMIanhXQfNg0w5n8wMp72HsWE7oe+q+l8+o0suRssx7D/LXt/gLjBOJTRwI7MLjH8/v10yPap0u32iCNBjDV8hYeNMuniHJu3P5phV/UqYFbDtkQod0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <03383EF3FB7B234EA2B739C4591BB3F0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0aedf333-3195-4c5e-9076-08d69e65c244
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Mar 2019 16:48:41.1645
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2869
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-01_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 03:43:19PM +0100, Vlastimil Babka wrote:
> On 2/25/19 9:30 PM, Roman Gushchin wrote:
> > alloc_vmap_area() is allocating memory for the vmap_area, and
> > performing the actual lookup of the vm area and vmap_area
> > initialization.
> >=20
> > This prevents us from using a pre-allocated memory for the map_area
> > structure, which can be used in some cases to minimize the number
> > of required memory allocations.
>=20
> Hmm, but that doesn't happen here or in the later patch, right? The only
> caller of init_vmap_area() is alloc_vmap_area(). What am I missing?

So initially the patch was a part of a bigger patchset, which
tried to minimize the number of separate allocations during vmalloc(),
e.g. by inlining vm_struct->pages into vm_struct for small areas.

I temporarily dropped the rest of the patchset for some rework,
but decided to leave this patch, because it looks like a nice refactoring
in any case, and also it has been already reviewed and acked by Matthew
and Johannes.

Thank you for looking into it!

