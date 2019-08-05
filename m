Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 107F6C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CEA8208C3
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:51:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="K5WSkhlQ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="QryImEVv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CEA8208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21F4B6B0007; Mon,  5 Aug 2019 15:51:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CFA46B0008; Mon,  5 Aug 2019 15:51:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 097B66B000A; Mon,  5 Aug 2019 15:51:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id D27736B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 15:50:59 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i132so32432944oif.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:50:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=5D0B1p/iIxkANtFxql5oXN6PNtQxj87D6xNdrBoLP5w=;
        b=W6bSOgH8okdKNJbjCDJuwuqeAGSCeXGqnYXDT73/3hbm10tEQGLVG0YFhavYCNBjq1
         GxZBvjuUO1J51IceZOxsEbhiZNoSV4AX9UakKKuOm2Rme0kLQqe2qHh3tA/V115ncj+t
         SSGIlg83oaPPwfvb40962ygkZLioIbOQlUnKvE3dmgEO20r6B3qmz4gLOQioMH6l+N4l
         4L3ie5te5ETqz5GZIZsSpR8flJKPXxsO+wIueMKKv45qXgscfV93PHgYEwTFlX1Xy0DB
         4gvPP8Z0wZzH2JRy0z78eLHsiO0bcPCwXiR3aH6Q2AWndEHbXcz3rcKZ1uslaqIs4Hwa
         CVRA==
X-Gm-Message-State: APjAAAWrDn++5qq40HBLEPvU0c779lRwwAb2ac2GTtNF2Vw4/IE8utM/
	S4+WoMm849GtODbWwwMxQOvSC0KpK3xXLtbELvzQuH560Bwmr+//dD7qCcquDSlaN4dRGOc6b/l
	hva5hh1BIxeuZRy+6/tt0f6KtMSJrEcWzJ2zGxHPtjxfnZiyFXNMvhI5KGbVKbUcBVA==
X-Received: by 2002:a6b:b593:: with SMTP id e141mr14726400iof.203.1565034659466;
        Mon, 05 Aug 2019 12:50:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoGE4GepMOhMSIDmjA1NBvwpAjq66RX0xLvX5Ju62B2JdjhklFJL8u7xb6YtrmStwbxZ/P
X-Received: by 2002:a6b:b593:: with SMTP id e141mr14726343iof.203.1565034658768;
        Mon, 05 Aug 2019 12:50:58 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565034658; cv=pass;
        d=google.com; s=arc-20160816;
        b=ph1M4zf3hYJf4hp92ozL1hTvt0paRWtSWaP/k+zb7Iq6PZGgjQwmRqwa0WnlP60UVo
         DIAVK96z7i93aAdA2LTMF5AKStHLpUQW5HJfBGVGegRgldu+sNk2iQMFljQ1haIhZWOp
         LSwqR9lALLiqrWX+MKPoSVgSlx9RSFJPL+1AEXr0dg9OiiPX/sfE6+kOCWlUqn7rBsnz
         8NCRY4cRCDGyli+P7Afx9BEKn5qb7T5lSO42yVHmYpnfYhg1CC7pCpMZZpU/g2BUNcrP
         fMP3xyeGHZLqBWmadPfoAEwNCKl59/7m7aijdGM6tIV5LF8A1ZTaVg8tx8DidbJ1UZV+
         QO7A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=5D0B1p/iIxkANtFxql5oXN6PNtQxj87D6xNdrBoLP5w=;
        b=is7/aUAxyg/FBx5BU5K3PPSIh0g9PuZZgbAyqwF5diimuFXEJWbFv/cXWcd3faeIdA
         2/nakEEIHh0E4DD3zSxPQy/KyOcEts4ByMTNbX4GIty03w2RMInxjWPTFkicBv32Ybud
         oXUGj/JLQwoh0Pwemp3rkX8wlOXxlGJIBTfNAo9d6tN47IR9RziLLiMAL++iv4MXlDBV
         wiMyT4EahMRNmBlFrWSnWMJWb7a/mPeTXBLm025WcdEXBU5Ld/NIzuP7rze6XbogfcGR
         +bqB80HIA/jtaUTMwCqSewfJaDX8hAqtAgzIf+eZqx/MEF4y2lL+lgHlvtZed/Sxt/MW
         /e4g==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K5WSkhlQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=QryImEVv;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31208fef99=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31208fef99=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g15si117445086jaq.96.2019.08.05.12.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 12:50:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31208fef99=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K5WSkhlQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=QryImEVv;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31208fef99=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31208fef99=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x75JoNd5022742;
	Mon, 5 Aug 2019 12:50:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=5D0B1p/iIxkANtFxql5oXN6PNtQxj87D6xNdrBoLP5w=;
 b=K5WSkhlQm06CVtqu2TPG6hoCCIlf+AWyIDttiR9St2cUoz9NJ6huF12yy5tQShvpdWW+
 z0B6kak6WvQs1ch4T+/vXOMtIH6/3IpOQ6D2OTsdjvvcHMPxp/ncLxu5AxItRzy4oniB
 mrYmhQh0d2ic5p5Afs7yBxbbMvkShZ8VlOw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u6n54hefv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 05 Aug 2019 12:50:55 -0700
Received: from prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 5 Aug 2019 12:50:54 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 5 Aug 2019 12:50:54 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 5 Aug 2019 12:50:54 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=EfncesKShHC9uZ7fgEAMUHwwcgu38DjC4DZWRWd2UibPNgxAuxLRjZyo3sS92HsZfoL5jxPSQ1LwSPe4NpLswV7UQGyX01YVw3+JmXPPvp4Hppxcz7fthIKY+z8B6D1xCgb2fkZ97fBF8+Mq2oLZYrFWFNmGGDGgYgD1V4hJTIzru5zTYVjy99zYWTtLntmPTPbD7gJBFMwdkmLriKHi/jHxYTb3MvGeUS8arTOUcKZYehWd0Q2bPaTSrc/8y/7nZeHvXZQTSNZ9zyNdtp4DR0jpbC+JHDaVDkj1PWfbnwGwqRUQqitieTewTOt5TpeeWVkEUEFU6gTXLWlX6QzgUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5D0B1p/iIxkANtFxql5oXN6PNtQxj87D6xNdrBoLP5w=;
 b=afWORuhPqFQs/zFQiHeEN/l3neku6XStJAOCVoSFtH/fzK4O8VyMtSQi9+folGjHwXbsTOi8ZBle8Ht5YnjgEUZ6WYUNwVNNwxfWBxETAJjRBWNwrS0VFrNChEhPvLOGOlUvmafEH+RvqGvQ7o0JVhIyfZxmUE1JhIg+1Y4VqD3P0Mxr7IeVSXSmLGGgcyJm0xtpopxwyoA4oGOJKxHYRR3ANmkidkEbDNTVbaDcvLy3SQvLPUT+BZdhfMr3gk6I77DZvpkxE76HuON1yfCkPfYuHBqkpPv73n6OxP86lD939S2nwNtztf9HOkwGC+VYRDh4ETG5gmbkF5x7aA9RHw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5D0B1p/iIxkANtFxql5oXN6PNtQxj87D6xNdrBoLP5w=;
 b=QryImEVviZlL5Q5qQZoerV/+cK2kd8Prue4DFNYgYX6v9Uym+6cAVuIRHoY+wAxAuWupJx2rDBB08p7Kto9o6kB1/GQHA3vCEbMC/MYmSuSt5rFVZ802Fjk0oONJSf1kWACAWTsuPgySfyBz8tGfw3Ly0+EFWcrcvW0xXbPfP5w=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2603.namprd15.prod.outlook.com (20.179.161.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.20; Mon, 5 Aug 2019 19:50:52 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053%3]) with mapi id 15.20.2136.018; Mon, 5 Aug 2019
 19:50:52 +0000
From: Roman Gushchin <guro@fb.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>, Hillf Danton <hdanton@sina.com>
Subject: Re: [PATCH v2] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Thread-Topic: [PATCH v2] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Thread-Index: AQHVSWe95NlTDGyLyE2eOxgDGjbby6bsakaAgACREIA=
Date: Mon, 5 Aug 2019 19:50:52 +0000
Message-ID: <20190805195047.GA16917@tower.DHCP.thefacebook.com>
References: <20190802192241.3253165-1-guro@fb.com>
 <20190805111135.GE7597@dhcp22.suse.cz>
In-Reply-To: <20190805111135.GE7597@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0054.namprd21.prod.outlook.com
 (2603:10b6:300:db::16) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::e44]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: caf2e730-89cb-4a00-039a-08d719de3888
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2603;
x-ms-traffictypediagnostic: DM6PR15MB2603:
x-microsoft-antispam-prvs: <DM6PR15MB2603468CB4C2CEAE2A1A7A12BEDA0@DM6PR15MB2603.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01208B1E18
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(136003)(376002)(346002)(39860400002)(199004)(189003)(229853002)(46003)(102836004)(8676002)(66946007)(14454004)(68736007)(81166006)(81156014)(476003)(446003)(6436002)(6486002)(99286004)(11346002)(478600001)(76176011)(54906003)(25786009)(33656002)(486006)(386003)(186003)(6506007)(7736002)(305945005)(4326008)(256004)(316002)(9686003)(1076003)(6512007)(71190400001)(71200400001)(5660300002)(8936002)(6116002)(6916009)(52116002)(66446008)(53936002)(66556008)(66476007)(64756008)(6246003)(86362001)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2603;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: i3uJRM6hsh9zoBJKLaZJVGd6/4P7JjtVim5j0R+sEJ6wN0YvLr+4qV0B8B4dMlqgZNQAxwUQsZmiBz4darD/l2d5Yl/xG1hQjnUFo/ZxXhdwgY7M8qYZprOIf9Ho60tuVJ/Ps+5mkqmXJr2oyOggCfxQjdV+ZYIx2Ut+3EOqmUwbvf3pzqKf2Ewl4ahUq3QS5hyqh6LiqWWRJtMHr8F6rrplMevNoTokftBhoNR6x/9pHdjHV8umOOCcKsR7kG0uwqc8k/UPJnlZDceZxUGoJmgilYb0AMtlBZpG0h01EEj055NsQPDzFBpVksxNErlIuh0z6/JGvnT6KuKSL69ASLBTCW10JSwH3YhfhCPg2yXqeio7TNJOMYahD1euyKHou1eE5ppw0qsM9gh4zjWO6P5yVYkv61HcL34WdqAVB9I=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <509D1DD3ADE9FD4788650A59BC9C7997@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: caf2e730-89cb-4a00-039a-08d719de3888
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Aug 2019 19:50:52.2813
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2603
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-05_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908050198
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 01:11:35PM +0200, Michal Hocko wrote:
> On Fri 02-08-19 12:22:41, Roman Gushchin wrote:
> > Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge=
")
> > introduced css_tryget()/css_put() calls in drain_all_stock(),
> > which are supposed to protect the target memory cgroup from being
> > released during the mem_cgroup_is_descendant() call.
> >=20
> > However, it's not completely safe. In theory, memcg can go away
> > between reading stock->cached pointer and calling css_tryget().
> >=20
> > This can happen if drain_all_stock() races with drain_local_stock()
> > performed on the remote cpu as a result of a work, scheduled
> > by the previous invocation of drain_all_stock().
>=20
> Maybe I am still missing something but I do not see how 72f0184c8a00
> changed the existing race. get_online_cpus doesn't prevent the same race
> right? If this is the case then it would be great to clarify that. I
> know that you are mostly after clarifying that css_tryget is
> insufficient but the above sounds like 72f0184c8a00 has introduced a
> regression.

Yeah, I'm not blaming 72f0184c8a00 for the race, which as I said,
is barely reproducible at all. There is no "Fixes" tag, and I don't think
we need to backport it to stable.
Let's think about this patch as a refactoring patch, which makes the code
cleaner.

>=20
> > The race is a bit theoretical and there are few chances to trigger
> > it, but the current code looks a bit confusing, so it makes sense
> > to fix it anyway. The code looks like as if css_tryget() and
> > css_put() are used to protect stocks drainage. It's not necessary
> > because stocked pages are holding references to the cached cgroup.
> > And it obviously won't work for works, scheduled on other cpus.
> >=20
> > So, let's read the stock->cached pointer and evaluate the memory
> > cgroup inside a rcu read section, and get rid of
> > css_tryget()/css_put() calls.
> >=20
> > v2: added some explanations to the commit message, no code changes
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Hillf Danton <hdanton@sina.com>
>=20
> Other than that.
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

