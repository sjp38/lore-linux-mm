Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0280C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A20362148E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:35:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="XeJlXlZv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A20362148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 439976B0010; Mon,  8 Apr 2019 13:35:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 410306B0266; Mon,  8 Apr 2019 13:35:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3005A6B0269; Mon,  8 Apr 2019 13:35:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAB86B0010
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 13:35:10 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s184so11635828iod.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 10:35:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=jAQfi1uf9nlcY03MOAa0mD3o5jGz0a+BDKd+WEYUYWA=;
        b=XzxZPHuhYYnOps6VOiLeoSrlw4jpX3HjVgf/1v5RV7JLrk8WexQOP8fUxgEgkc8FSd
         wy7AyCoO4XUr5P+u8XhPhonbbTLsT20qRVBEEIoy93jZfNzqZTkuIQUy7NwAzTbgqiOK
         XS/pdmlAm50CePZNcqlnCGpsJ/tuA5m0/2sVDHEuhJDjC9ArRzthZeN6zznEG4u+FKod
         grGprKaZIYK+n9bcMgenYy6tjrGS0Dij/pIRbD42neMz7gnUqCxmzf1MrC49lW5lNp9Q
         dwDterDlrITAybXjjhmF50fZoAWU8lhnIGAUyhK1AHTxQM+Ella2473g7AhHzzb0zGDJ
         4pAQ==
X-Gm-Message-State: APjAAAXAv3BQxmAO5s/7GtnYDQhVHm+kVsSRaeQIEohA//XGe3iy/Ew6
	ZonfIroDF/WfyRznT8KukLVNgsru0SjP3JwHcouRc3sdK0T1jcOgwD0cMFQgdU3+74gcw0U0Qm8
	WOfpJfc0/6PhMogrTtRBvD8i0CidO/6qC1a6Q3qFOyQF5updzRMqgLFfVhnBnKw7NpQ==
X-Received: by 2002:a05:660c:78a:: with SMTP id h10mr21832768itk.157.1554744909867;
        Mon, 08 Apr 2019 10:35:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVr74VdQyjgY0+SeFW/52BB0SrcK3hpTw/21JD0jSMOSGPbrzKzcnbWtmI2eUCaP3U3X9b
X-Received: by 2002:a05:660c:78a:: with SMTP id h10mr21832734itk.157.1554744909255;
        Mon, 08 Apr 2019 10:35:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554744909; cv=none;
        d=google.com; s=arc-20160816;
        b=xuIeUBa9iBeH6xVXb4Vs2O8OlcOMcLPu8A2M1Z6fDa8nIF7If7EZibHv3kRyq/Q9LP
         07tyI+nc5MOypMty3Iev15bk/FvdZKfOQiDa9XDsjyDoaH10ON/xKpYz28DL5Hv9BvLQ
         kmQ3Vc38ctF0Xg0XWZZbkOyrz0gaBvbdsykyb/d4KBzsnt25t2UWh884sZWd+ZgtFPXI
         4yv6LyajjUm9JbAvmaq6ioMeLIgJUrbwxLorVSPmLugX+V0pc7Xp5E1tAhwaJSeSPM6z
         V7lAFtjfj5tr4m/M+2v8/ovstASRCE28YdpeZxObtC2HnG4ZLOZkWc1rwRtKs75sFUvN
         MmZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jAQfi1uf9nlcY03MOAa0mD3o5jGz0a+BDKd+WEYUYWA=;
        b=UWkyIYpz0jX2pAz/IZAaNzz99Ye/TM53bXwvaIi793HQWc45OB/GX8Xq+75rpy2Gqw
         SYF3sNaVDk2iYXenkbZbmz/lvGwRb4RCUVOAvNTjGnafLfeF/VMcRkkwC69jBeMotTDz
         n7WaFgXlQfKLXx/lPUvV+h5VGCXE3Yu5Ig2AYVPGD4xeqtYhBHFMbDvKVVu41mN7DiFk
         CFHGSfn14Pk/oId4au4WUi/PuTIkN9XPu/+LGDXjXnAhKqjdejQO/oQCx8dHosZbNCnx
         eSuwQlWLiITWmPDBLQl4VHrjT2hcTmdXaWQDo/OABnk4ffPOetW3Skh1CMFkTSCQJhN+
         cYcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=XeJlXlZv;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.68.65 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680065.outbound.protection.outlook.com. [40.107.68.65])
        by mx.google.com with ESMTPS id c4si15475852iot.150.2019.04.08.10.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 10:35:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.68.65 as permitted sender) client-ip=40.107.68.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=XeJlXlZv;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.68.65 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jAQfi1uf9nlcY03MOAa0mD3o5jGz0a+BDKd+WEYUYWA=;
 b=XeJlXlZv3xulQ2Yr4zy2gZC3dtPL2gb73Ha1oPD7xWXFPfex5KX8nh580yZx7WrY57KzuI2tFIapR1leUHjDFyPZYbw+VnQRtZlLHeLXRVTVIihDvu3Hz26fC1Hu6GyvU5IwdNVgXfkBw++JJV5kBZWAVJGcEbYfLMrbWE/TvIs=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5240.namprd05.prod.outlook.com (20.177.231.90) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.8; Mon, 8 Apr 2019 17:35:00 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1792.009; Mon, 8 Apr 2019
 17:35:00 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Pv-drivers
	<Pv-drivers@vmware.com>, Julien Freche <jfreche@vmware.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Topic: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Index: AQHU5L/fQHqTTJNOzkOghmdzHIOs1aYymUeA
Date: Mon, 8 Apr 2019 17:35:00 +0000
Message-ID: <679D6F11-07D7-4227-9D02-41F9F8901E61@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
 <20190328010718.2248-2-namit@vmware.com>
In-Reply-To: <20190328010718.2248-2-namit@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9c34b376-8f74-4cef-37cf-08d6bc488704
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB5240;
x-ms-traffictypediagnostic: BYAPR05MB5240:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB5240F2FA3DBBA7F7A637AFFFD02C0@BYAPR05MB5240.namprd05.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(366004)(136003)(376002)(346002)(189003)(199004)(5660300002)(486006)(53936002)(33656002)(6246003)(25786009)(53546011)(6506007)(229853002)(76176011)(11346002)(6116002)(3846002)(6512007)(66066001)(476003)(446003)(82746002)(6486002)(316002)(305945005)(4326008)(2616005)(6436002)(7736002)(2906002)(256004)(71200400001)(71190400001)(81166006)(6916009)(106356001)(36756003)(83716004)(8936002)(68736007)(186003)(81156014)(8676002)(99286004)(478600001)(86362001)(4744005)(54906003)(14454004)(102836004)(105586002)(97736004)(26005);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5240;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mH91q6AQ0GhnZ2PSC6QH7gXuC8+Qbt9fHvuYhNxDpd8U69Sc2mWXMaDh1SqLIJqD1Tj+eo+13ncY/GtofcJBXvK1hGsZasEes/jAVd35OsLa5G60JKpY92NcBG+9xAbMcE2RuYMlBjEbpjUYtKWwQI3YL8KfF9yNgBDoCFactv+iEgx8vHyY6NE25Gu1kf5ScoxRkkP0GfXgczKKSsv+JJKV0nYp1KQB8IzxeMlV8SBingiNNtpPQf1MoLSiYJ4U0Ez9VJDKkCSBpdYHWQovzfhF1Zd2u7BclerQ3iiQtdU3EaATEEI6EJ71xdcXNzgM9S28Pih5ilLpCNfcbbu0rWbgzk2EpEldetNC2wgds/f2hnHKun+UjQgAtJUfkrAXhhc5tBpMaTSev0cPLttHpOnzXVLUSdG8wfT48VdWraQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <49C9D19A64CC2A4D9009D73284BA2801@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9c34b376-8f74-4cef-37cf-08d6bc488704
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 17:35:00.6520
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5240
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mar 27, 2019, at 6:07 PM, Nadav Amit <namit@vmware.com> wrote:
>=20
> Introduce interfaces for ballooning enqueueing and dequeueing of a list
> of pages. These interfaces reduce the overhead of storing and restoring
> IRQs by batching the operations. In addition they do not panic if the
> list of pages is empty.
>=20
> Cc: "Michael S. Tsirkin" <mst@redhat.com>

Michael, may I ping for your ack?

