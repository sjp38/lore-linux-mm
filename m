Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A364DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:55:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C04C20644
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:55:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qsRNUSIb";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="IdLMvyf4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C04C20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B53FC6B0005; Fri,  2 Aug 2019 12:55:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B03516B0006; Fri,  2 Aug 2019 12:55:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CB276B0008; Fri,  2 Aug 2019 12:55:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA036B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 12:55:35 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q196so57462177ybg.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 09:55:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=iUhUuzw3YIfxtI+SNqzxf6KCLahYA51v0Iob5/+AsdQ=;
        b=KULYoZ62JJPb2IfWSuBp6whAn00ahva/X+5fqUpy4n5wZAss5lIOm9Uw4gYIeBmzSG
         8jaVDNtLSwXWxuIDk0mzbWqhPSx8TYmwD/e4Z3xm+dBlE16o30TzTkFghJVx8CEGP6fJ
         WCAJOqSo4DpvyzxzKhhWiuzvQWQ2pYGGxtqNf1G2LD7F3W/Z1UfPN0IRk7W6wyqw1IWJ
         gEWXCpR8eNoA115MJBHSNu15wTK8YvhH7UIZgR1tEzX65czWsXiwvgxZLf2TrOKOJ00V
         XLP0LnbhultkTXp/vV5J59/dODLQsQSpr79p0eGVQ6IYxVfeME5qNZ1EHNzGae3y3E+W
         m7QA==
X-Gm-Message-State: APjAAAX+NHkWizDavXC4uLs50NoAkQypC2YpbLbGF/A/80inbxcP0i4X
	xgAfn9FiLvraTsknxwG97DSfRPcFJG9v0bV6qMhIQUsdm2C0VEJ1rp57Px2HAs6slfPfyGqRnb6
	P5Rbv/7t22ZbLVM7Q+UZm3PCEASGWYBBop3yR+2TV54BMJQxln9eXnKWlGCXp5fRDzw==
X-Received: by 2002:a81:5905:: with SMTP id n5mr81257864ywb.295.1564764935258;
        Fri, 02 Aug 2019 09:55:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8JB+yKGTkS9BShWsR20R6DdP9iS6+5SuG4rX3Fpc+opKJ3gu0WrbkYSWRH4EYLS0AKJZQ
X-Received: by 2002:a81:5905:: with SMTP id n5mr81257843ywb.295.1564764934660;
        Fri, 02 Aug 2019 09:55:34 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564764934; cv=pass;
        d=google.com; s=arc-20160816;
        b=NSkTFX3El1cau35bxRLuifZV0/h3DBhEYKBkyiMrGeUvQVTmxBms3zfBEThM7lHz1r
         4lJUa/NrXeDmuTjBh4YgquiIjv1Hw5sxlKaSL2dZimws2FWRQrlEaLkCUJBKhKG3TIOL
         3L7kCh0N9bRoQRFkDzguQ0gWSqx5YV3ZB7CLUnJNfMGe/AkV3LXeDTAz4TwrLXlOBCU1
         EhoLezrpXnatMAbS2DB4oMxuuoO6TTFzwtTsRwdXzgImCjKtr9M8Q7m/rUWVIQBFu05r
         rcjLX7Vmbfllzl8jbAZUN7PG1u8slTLqqdqFR33RV4jkDNows7wo6BocBOzxV7VWHRzC
         mHGw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=iUhUuzw3YIfxtI+SNqzxf6KCLahYA51v0Iob5/+AsdQ=;
        b=DN0z2YuYbTLAINoxZM9wiX5OnHkTlEsffDja8Q9ZCf5/yz91yTqVS5OP+xB2mLgF2V
         3G1l4gb8Qzt5Y4QlDrjZJ2WDhJ8vWu2YXkDQ2Edi2xgjb7Up0xH+ugqusSUh0+mEVdAM
         +lw1bOzP1Oqt5DShfHdEVa8De6xhgJ2bZQlUAELbQWjXtkiXQR3zsz157k8f96JRXlXG
         U6X7mbCmBm9Nw14z/G3P9bZD9i/nJSj0pw3DGYOsxiAvsIE8/yFTDnJbX3E9BZTsOkIk
         PCCOKeeWSXnNsA07zVdnRLpZHzQPnJK4H9jWW6zmo//Mz3k7wOHqGkdzYex0xFG9XlnT
         OIyw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qsRNUSIb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=IdLMvyf4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176506d8=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i188si30733902ybg.353.2019.08.02.09.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 09:55:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qsRNUSIb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=IdLMvyf4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176506d8=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72Go0jP018090;
	Fri, 2 Aug 2019 09:55:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=iUhUuzw3YIfxtI+SNqzxf6KCLahYA51v0Iob5/+AsdQ=;
 b=qsRNUSIbQ9lZAQLdyGXw80x0aeqKVP9L2TIl64vqqd6thzW6zPxO9Y/awxoxYNmN8Mmh
 Pa+2es02tdyPklWvdMbrP+6U6vRLaHrgeF8W/FBwGkK51b0BrYR7CAw+JYDznbluU/XI
 bKGeTlBQm2WwShL647sHmjPvw5q90u2PTak= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u4hgdskx6-13
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 02 Aug 2019 09:55:29 -0700
Received: from prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 2 Aug 2019 09:55:27 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 2 Aug 2019 09:55:27 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 2 Aug 2019 09:55:27 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Y226r5CWR5rzsXo4t0Jv/9ObW+sC1Zqj82HuV5uXj854iSvEi2ueBl7gJXqQyhzhoJ/+1udPEHWul6VlVdo5D2f3fbW2Sv46rbTwS87KftrAK9b9MnMaSaD4GkMWlmUep839gAgfmzfKY8/+jmcT6Dqw/DgIspBYtXnxBfppaKwisC+uPspV67UkOOWe3OxJcqas2XWhI3borNl/EImnlz+3UzRCxikdsJP3tCvMGzE3haIyFAynoi3eCNI2Uu1rjT2BbJaOeSUprNYYtBFU94bGoiQjlYJ9dLxwnU6JpW01A2mXA7CJi/6TrbfpXhSgbKDpdq3wbYXsMo2d6L7qDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iUhUuzw3YIfxtI+SNqzxf6KCLahYA51v0Iob5/+AsdQ=;
 b=Z/ByxJQKr0LO0nSv3kY/HTWK9QzHG/rHknwG2Lzp7bCix8ZsFJQmfvQT0mXl7tSH6IuKQvw8AixrCa6CO8Oz5c9TL2/p1Abu0B1nKfeAuZgAp6Wco743AXsXuHt6ODOkhUKB5eqaoj66jbCUR+uNcSCLphrRBaZBwEZQalmd8RpeYD8gCN0jFOZvTahupDcNE4rmoDqr54qLy6uafl3mztdV9ZHT8pD1kW/bV+ZN1bXd9uoYyNjhfAofMjh/kI8/hG2MlQLe+QHjPK7iw6MkXsbs1EA0j5pVrAy5CjIxu82lFCChj56wCmiwzwDz8jX4R8yUKsUxMwTzwQbf8mXUng==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iUhUuzw3YIfxtI+SNqzxf6KCLahYA51v0Iob5/+AsdQ=;
 b=IdLMvyf4HO3cLt7Ad46S1HJfffELBOCorhv9ii+4UzhovTq0Rr2nTcpG7giVdAEPC3pIBUnYLYhT1toLtQGp7tsnJsSec7+efZCgOwBoWblBIbscypW0582Bfq4G7HKPxidak9aW31Mm7Koj0aCUm3x9myLW8yTgdHVBjUkj6o8=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2873.namprd15.prod.outlook.com (20.178.230.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.13; Fri, 2 Aug 2019 16:55:25 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053%3]) with mapi id 15.20.2136.010; Fri, 2 Aug 2019
 16:55:25 +0000
From: Roman Gushchin <guro@fb.com>
To: Hillf Danton <hdanton@sina.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Michal Hocko <mhocko@kernel.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>, "Michal
 Hocko" <mhocko@suse.com>
Subject: Re: [PATCH] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Thread-Topic: [PATCH] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Thread-Index: AQHVSMHRid8xy6v2VESi4846kGYnRKboFKCA
Date: Fri, 2 Aug 2019 16:55:24 +0000
Message-ID: <20190802165521.GA28431@tower.DHCP.thefacebook.com>
References: <20190801233513.137917-1-guro@fb.com>
In-Reply-To: <20190801233513.137917-1-guro@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR13CA0016.namprd13.prod.outlook.com
 (2603:10b6:300:16::26) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::a1bd]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 76f52506-952d-4c0c-bfa5-08d7176a36ad
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2873;
x-ms-traffictypediagnostic: DM6PR15MB2873:
x-microsoft-antispam-prvs: <DM6PR15MB287325E514D88DD28691E1F7BED90@DM6PR15MB2873.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 011787B9DD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(346002)(396003)(136003)(39860400002)(199004)(189003)(6506007)(53936002)(86362001)(4326008)(6246003)(8936002)(81166006)(81156014)(76176011)(5660300002)(6916009)(6116002)(25786009)(229853002)(316002)(6486002)(14454004)(99286004)(52116002)(2906002)(256004)(478600001)(14444005)(6436002)(186003)(66446008)(1076003)(8676002)(7736002)(66946007)(66476007)(54906003)(476003)(71200400001)(486006)(102836004)(305945005)(6512007)(9686003)(64756008)(71190400001)(446003)(386003)(11346002)(66556008)(46003)(68736007)(33656002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2873;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8eGy4UsWnVebsY4S4RfDU5sQcf/kySJuCHu+mgxbOd2ICzE03ExrZgEIdgGgOH3bbVo495Gp9UtjKTpjw31GJDs9ufpvuXqgAPwzbWqEokfLM48m1ErlzFxcWIKKAcTvZzu3A7f5nPtvaw1Nmw4DA4PJpMkaWpb0PtepKIJ8xxapzWbkRnk0bd4Z8krmDSj++s37bMjOW/sZPe6lYrGUvsICmzH7d/MseVJPv60p6DMr3JnllPm5ILnouu3fmG78+Vq6FT+VI+NaC0kAm0gzMQTBqWoG1uJRSuns9ge/ldFrAo2LMaVl+S6jXcmW6NDItffJ6GGTBXkVs5jPjyAAg4hPElvSF19xBDT/OrmameJI7ZDrxQjcsfq1CrW3dWtAgPz2YQwsoEiKsN/DjKRsC1PtDmPlzLUyJlYv8E7MjmU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A40747C58454C54BA33B646AF4E0F7FA@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 76f52506-952d-4c0c-bfa5-08d7176a36ad
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Aug 2019 16:55:25.0841
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2873
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020174
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 11:33:33AM +0800, Hillf Danton wrote:
>=20
> On Thu, 1 Aug 2019 16:35:13 -0700 Roman Gushchin wrote:
> >=20
> > Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge=
")
> > introduced css_tryget()/css_put() calls in drain_all_stock(),
> > which are supposed to protect the target memory cgroup from being
> > released during the mem_cgroup_is_descendant() call.
> >=20
> > However, it's not completely safe. In theory, memcg can go away
> > between reading stock->cached pointer and calling css_tryget().
>=20
> Good catch!
> >=20
> > So, let's read the stock->cached pointer and evaluate the memory
> > cgroup inside a rcu read section, and get rid of
> > css_tryget()/css_put() calls.
>=20
> You need to either adjust the boundry of the rcu-protected section, or
> retain the call pairs, as the memcg cache is dereferenced again in
> drain_stock().

Not really. drain_stock() is always accessing the local percpu stock, and
stock->cached memcg pointer is protected by references of stocked pages.
Pages are stocked and drained only locally, so they can't go away.
So if (stock->nr_pages > 0), the memcg has at least stock->nr_pages referen=
ces.

Also, because stocks on other cpus are drained via scheduled work,
neither rcu_read_lock(), not css_tryget()/css_put() protects it.

That's exactly the reason why I think this code is worth changing: it
looks confusing. It looks like css_tryget()/css_put() protect stock
draining, however it's not true.

Thanks!

> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/memcontrol.c | 17 +++++++++--------
> >  1 file changed, 9 insertions(+), 8 deletions(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 5c7b9facb0eb..d856b64426b7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2235,21 +2235,22 @@ static void drain_all_stock(struct mem_cgroup *=
root_memcg)
> >  	for_each_online_cpu(cpu) {
> >  		struct memcg_stock_pcp *stock =3D &per_cpu(memcg_stock, cpu);
> >  		struct mem_cgroup *memcg;
> > +		bool flush =3D false;
> > =20
> > +		rcu_read_lock();
> >  		memcg =3D stock->cached;
> > -		if (!memcg || !stock->nr_pages || !css_tryget(&memcg->css))
> > -			continue;
> > -		if (!mem_cgroup_is_descendant(memcg, root_memcg)) {
> > -			css_put(&memcg->css);
> > -			continue;
> > -		}
> > -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> > +		if (memcg && stock->nr_pages &&
> > +		    mem_cgroup_is_descendant(memcg, root_memcg))
> > +			flush =3D true;
> > +		rcu_read_unlock();
> > +
> > +		if (flush &&
> > +		    !test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> >  			if (cpu =3D=3D curcpu)
> >  				drain_local_stock(&stock->work);
> >  			else
> >  				schedule_work_on(cpu, &stock->work);
> >  		}
> > -		css_put(&memcg->css);
> >  	}
> >  	put_cpu();
> >  	mutex_unlock(&percpu_charge_mutex);
> > --=20
> > 2.21.0
> >=20
>=20
>=20

