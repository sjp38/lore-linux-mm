Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B384C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:02:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B93FF21019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:02:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="uB51C6Ol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B93FF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1307A8E0003; Thu, 18 Jul 2019 13:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B8D86B000D; Thu, 18 Jul 2019 13:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4D008E0003; Thu, 18 Jul 2019 13:02:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD8E86B0008
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:02:13 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j81so23619230qke.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:02:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=y/6g0lbBmPe8icy0EOaITt7XapN2C0qB3+2KSYGqB7M=;
        b=S2lZPZFpRNh/LZK3mxz8x9TRcBOyMP16PdU0ep/EKS+xH23fYAqp13plt74KkYbHZY
         9b2LhwXeA+d5cTb6Ww3U9yOyhgCpNDH957Hcji5FwkG71bVcaNTSIAQtrQoTbTbtRbfG
         lrgiQnWuLRkRoFYG7SJlNkl9AanBpp3TKdfljwsn9GG4mTrCeuM9MCl8oV98KUjIGOt3
         cbfMuElpO1q38FelspKNSBq4F/JYbXsJ1DvVtYPE0Wwr0Z6aJoOhoCG+5rKCvyVrLuEi
         R5VEMY8PutcbdP11SLpwoBDO16xixat4ClW6COfA7CvaTnwccgirfcsZHzgbQ6/iKlL4
         S+DQ==
X-Gm-Message-State: APjAAAWZBKyb7U8f9zQmqgM01rXY7tIzvcTReFpKw7DLyMPp7mkBxVEi
	yf/xs9XbyG9d9s3nFoFa34az3NrgXS1PoSHV1wRBop3mJXZuZDi9kiNJXeLz0D0VAGkNEgUwA9e
	rhQbxM8t/W4bxmWAO28RSojyUyiflaGNeR8U0xdc789oUWGvglW5Y2/dgizG9Pfo8Jw==
X-Received: by 2002:a05:620a:12a9:: with SMTP id x9mr31887900qki.279.1563469333434;
        Thu, 18 Jul 2019 10:02:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpv4UzFXIcuQ3omjE8k3ZmWKNdDf2ded1aXFK+J/nUCVgO7aInlWwaLq1wsBYKTXGcDhO+
X-Received: by 2002:a05:620a:12a9:: with SMTP id x9mr31887850qki.279.1563469332802;
        Thu, 18 Jul 2019 10:02:12 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563469332; cv=pass;
        d=google.com; s=arc-20160816;
        b=Q3U4h6papRn35fkV8Cnf7cdCUZY0JVZWtHlHKdO6AvHUUhg+tFiE8oUNVDF9M2ed/4
         tZl6TC2cZLU/B5DhXvopGSE8PYybU5D6xfusUUh8TYL6Sx68YRYZXqwvrHKdSAKT3cHa
         uW4aA8KMlauqCs3Z3qWSTqxPBZsGIHt+9FziOj+BTlUbm4S7NQw4osWhKZD+PbyLkCSd
         jQduwuny+vJ6djPaNrtvYr5521WO3HAAalHw7E5enuHMu74iRhj1ksRCHCFU4eq4e5nf
         FaTNTtO4vt7wo/c/gl7s/iZmlXjJkecn1sfToVCaRfohJmRf4vJA4jXhyY8JIsxS33HW
         RMgw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=y/6g0lbBmPe8icy0EOaITt7XapN2C0qB3+2KSYGqB7M=;
        b=yiECJ2Pue1jFvDdE0g1lS/1bXPu4wGvM8YToT6UljH5MWFpvbO994aJU2AA3rl0vBL
         LgPE2OqZkW/cAgXISXq5QnsywneKl37UBwxGQcKN/YCS9xleb7Wmp4vdWvndOYDHWwOu
         QpmtTsqJUntT2Oztpwfg6vAzzXiwQEkt/y7bTU5dMiuyD8B8+t92yimqeq++oMzd9iZu
         g97cKyHo+r6WL5zuhrvLrvkIN0dFClCNf3bBy3KKDPwnBYzmNbt8TFzMEDQH4LJrAw8a
         sQ3IMIQiB9YNrHSF5na0WI2eiOUTR8amS/K1tu+lYFS5OpztluxEKMFMcsMrqNOdAchI
         bt5Q==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=uB51C6Ol;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.79 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740079.outbound.protection.outlook.com. [40.107.74.79])
        by mx.google.com with ESMTPS id d44si19020185qtk.34.2019.07.18.10.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jul 2019 10:02:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.74.79 as permitted sender) client-ip=40.107.74.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=uB51C6Ol;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.79 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=RXJqP2zcZ1mclGhasGKM7UWcP90cs62LtgspzhDEkOVwg2LLHrRQZoScJx2NvsZMOCYO8EM3gUR0zVOgT0W2Yr6ZxEuMaS5bY7XCdnYXYUAex0H2+SWa8wnNehGyjp8g6dL71k2GAcnrmiglKumO71ahvPzE1tORYdnIDFCSdKSiBlp5L+8o1tnZSnVlxzbbbZwlUiY6mfrLLAlVijdqX9/hsBgbaMs26WFIB68MiKssWTy+DUpdkD0COGpWDeaQ74C6mjlBbZ0zPv0OaUUhHW/yFAobf8tbEZ546mdWawMsdpO+T9DgCKFYbqvZoIhX96lMl+qEO4J+Gjgd93SdzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=y/6g0lbBmPe8icy0EOaITt7XapN2C0qB3+2KSYGqB7M=;
 b=N9pyho9BFf+BUiZaquvt1J3kbfN71Po2MoVfjL0vOCaNqaeV1G0Qb/9kDVekyZxin0sH8P/VTmK/YWNwsGq09S9SgtiNEcF17q5ZSTEd2FjFuaqkcY172PcMVwQzK8asYPyGGR9LOOZYvH/vXUxsAK6V8fUOyMbxoLYEgL52bsR5OCbF3rXUDrnmQcUqWEdGrr673pOfW6wyKChcE4AhMOZ4DVh40fwJF3n9b2QyEjgMuK6wmm0gnHZYCQyMaHnKEc7GkSB5p7Q647a0A1apRhiyVPiVGZAv7qoUBuAD82t4QMdruLTUUhEBbFjTbd3lDUmFOlwk/No1AoRHuxkkoA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=vmware.com;dmarc=pass action=none
 header.from=vmware.com;dkim=pass header.d=vmware.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=y/6g0lbBmPe8icy0EOaITt7XapN2C0qB3+2KSYGqB7M=;
 b=uB51C6OlNx5cFtbU8VL9xo0jBf8/GGwaFMWzDDdfkA6ZLdkz9ivFEwSl3/Wjv+i8tZD71//s6P5ONdYDps+8TjTFMdJ4eaiVPuM/ABaO7EWJyvtvCvJ0xgKaLBtZdj8ecvAoeZDJjmxHNkYwweILjixOkiy856O3gbmNKohQoL4=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4775.namprd05.prod.outlook.com (52.135.233.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.10; Thu, 18 Jul 2019 17:02:07 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e00b:cb41:8ed6:b718]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e00b:cb41:8ed6:b718%2]) with mapi id 15.20.2094.009; Thu, 18 Jul 2019
 17:02:07 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Wei Wang <wei.w.wang@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, Xavier
 Deguillard <xdeguillard@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, "pagupta@redhat.com" <pagupta@redhat.com>, Rik
 van Riel <riel@surriel.com>, Dave Hansen <dave.hansen@intel.com>, David
 Hildenbrand <david@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, "yang.zhang.wz@gmail.com"
	<yang.zhang.wz@gmail.com>, "nitesh@redhat.com" <nitesh@redhat.com>,
	"lcapitulino@redhat.com" <lcapitulino@redhat.com>, "aarcange@redhat.com"
	<aarcange@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>,
	"alexander.h.duyck@linux.intel.com" <alexander.h.duyck@linux.intel.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>
Subject: Re: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Thread-Topic: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Thread-Index: AQHVPVETq+d/PdgRAE68BsHO2xGkqabQTVWAgABNFwA=
Date: Thu, 18 Jul 2019 17:02:07 +0000
Message-ID: <4FC18511-DD19-4B10-BCAF-906E264B0411@vmware.com>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
 <20190718082535-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718082535-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8d8161b6-8a25-4510-6e31-08d70ba1aac1
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB4775;
x-ms-traffictypediagnostic: BYAPR05MB4775:
x-microsoft-antispam-prvs:
 <BYAPR05MB4775C2FD7924573D5C548257D0C80@BYAPR05MB4775.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 01026E1310
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(346002)(366004)(136003)(376002)(39860400002)(199004)(189003)(64756008)(76116006)(6512007)(66476007)(66446008)(25786009)(66946007)(68736007)(53936002)(33656002)(66556008)(6246003)(316002)(6116002)(7736002)(6486002)(36756003)(4326008)(2906002)(476003)(3846002)(305945005)(6436002)(6916009)(71200400001)(14454004)(8676002)(71190400001)(11346002)(446003)(86362001)(4744005)(486006)(26005)(66066001)(102836004)(76176011)(6506007)(5660300002)(53546011)(186003)(14444005)(99286004)(81156014)(81166006)(256004)(8936002)(478600001)(7416002)(54906003)(229853002)(2616005);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4775;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 3H4cEqrf76gadOEu7acGHaUp5c8KWfuWofhQDbzvWLRAvZr4mBBLwLrB38FfZRDHVUrYTIZsaiNJ+Ko9HGHdqkrxpWh7rGyqUT4hJNhjU23G/k4UBKejLBwgTMm7kZQ4Bycu6Wroo0fazmwvVkb0EQ+6tu9mCQqico1BmtbgQgrR3Sa8MD5bcYCnaYO/iIfm6gAF5jsRZ/rF+lh60OIgYDhZFuUX+1PtiZ4l7/otRhpZYCIJmJmPJTfzL4ZFKrFkjVLpljwe9sFEnWMvVivguzTFSKgNmbVYg7L9mskxGaDcBtHMfrzJnnXtBA8rE7aKFWvn0oSPs2wstUMkrCQlnimBbK47oGOHxcSQ/RFdzxC1gtcthRrr/0YrePNke9kIelCYcu+svH1aFNARBIOrr4e++fPWyl0QPZSq1JQwQvw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B3E1CA15BF28004E91F935580443763C@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8d8161b6-8a25-4510-6e31-08d70ba1aac1
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jul 2019 17:02:07.5889
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4775
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jul 18, 2019, at 5:26 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>=20
> On Thu, Jul 18, 2019 at 05:27:20PM +0800, Wei Wang wrote:
>> Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
>>=20
>> A #GP is reported in the guest when requesting balloon inflation via
>> virtio-balloon. The reason is that the virtio-balloon driver has
>> removed the page from its internal page list (via balloon_page_pop),
>> but balloon_page_enqueue_one also calls "list_del"  to do the removal.
>> This is necessary when it's used from balloon_page_enqueue_list, but
>> not from balloon_page_enqueue_one.
>>=20
>> So remove the list_del balloon_page_enqueue_one, and update some
>> comments as a reminder.
>>=20
>> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
>=20
>=20
> ok I posted v3 with typo fixes. 1/2 is this patch with comment changes. P=
ls take a look.

Thanks (Wei, Michael) for taking care of it. Please cc me on future
iterations of the patch.

Acked-by: Nadav Amit <namit@vmware.com>

