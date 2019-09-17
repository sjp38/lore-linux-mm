Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05F5FC49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:27:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 971E2206A1
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:27:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="laz5u8iM";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="aO67i24w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971E2206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30FDB6B0003; Mon, 16 Sep 2019 22:27:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 298EC6B0005; Mon, 16 Sep 2019 22:27:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 113DC6B0006; Mon, 16 Sep 2019 22:27:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0136.hostedemail.com [216.40.44.136])
	by kanga.kvack.org (Postfix) with ESMTP id DD4356B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:27:29 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6D84C1F10
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:27:29 +0000 (UTC)
X-FDA: 75942826218.01.crate80_242f021e15457
X-HE-Tag: crate80_242f021e15457
X-Filterd-Recvd-Size: 10989
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:27:28 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8H2OImb022344;
	Mon, 16 Sep 2019 19:27:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=JnbI16lLNpQNm+wYFUFRgRfUsit9DfGWMyaoz9kcDN4=;
 b=laz5u8iM+8ZgcI9tZ8SJr7Bz9bw27yyO1fmSU44Qi+u1m+EeDWp3rdcBlLHX4IHHhigT
 xdIa3QnEFfpqBtda3/WnbmZl05Svg6EtdKkL6qsIr7sIUl/Uwm/PVWMedS1Gn2xwlvVz
 T4eBD5RmMFZWYkClavog9rYDMo9xmKVdYkQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2v2p6t839s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 16 Sep 2019 19:27:24 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 16 Sep 2019 19:27:23 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 16 Sep 2019 19:27:23 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BOX3fUIu8UoV3Njn/2DBdkis6Nm8r0JOEmFP8RU2sLDi96PWV24G7OikNQgUgzbA/X+X9X/udPmnMuFAPGvpST37u5rAqeLozeERdsW9tPiZllWWHF5rq/McUXk9iX2BWSFtQrXOLInZpxv8dhjJhwA3RnuwTIeebPfCRPyYylxFuKX5VxGZGHSeRrLaUnolGBXayi6JoOMxZHkLznqcgRdmcgi9QclC/rxDJvbYMno6QNSsKtN8I+b3QrSRSYaI98dh3oYJLK6d3jQ/E1hxF4EWE9wpD1oq3BF1g0xsFl+UplRgG1gLA5oBFEtoJB0PS8T1xoleRzbaOLIKDt49BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JnbI16lLNpQNm+wYFUFRgRfUsit9DfGWMyaoz9kcDN4=;
 b=ZtW9xYYNEiK492pYpQanFzafccmkpZqt/nKiEsoQdXJ60KFZDhPohfAIr3gkCXWhMiL4Wl2t4ltUXy9MkSFVeq9pyx5XovzXabTEtINw2JQ0oT8d7NdHnp1W7L2GUItxTs6cq+OF+ej3YBCBfmqRNq5Qupo6AELXjsQeSIae5PsxbtB3Dec4Lw6L5CEzb0pvMXMQrqD/0c+Hg4WdzPusRQIwmH+am/jY6iRNrSym+SY9oib9A/Qhiy4T0envfPc2UyDYL7ztPaGJOZNfUlwZAPrK6cm1ZTKvnaJ1Tz9DhKCzlZju9qpH/hL9SP/gvGa02tTrGYP92/PZnCFq3+NhaA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JnbI16lLNpQNm+wYFUFRgRfUsit9DfGWMyaoz9kcDN4=;
 b=aO67i24wRxg34+Fb7bgJojZVMw/YEijgUA/CdyYZrOO729LS8l27qwmueRd/rHXGxALUC9yjiIyobRi9Owgs8x1s8qP9+Rdyo6Y36hxvSQuXCpgrKg5NJRQIFASRho1tscH6xxU6d48VDfgPsecAM6hlqwX2OsoIWzzBLT8L8uo=
Received: from BYASPR01MB0023.namprd15.prod.outlook.com (20.177.126.93) by
 BYAPR15MB3270.namprd15.prod.outlook.com (20.179.57.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.13; Tue, 17 Sep 2019 02:27:21 +0000
Received: from BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961]) by BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961%5]) with mapi id 15.20.2263.023; Tue, 17 Sep 2019
 02:27:20 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Shakeel
 Butt" <shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        "Waiman Long" <longman@redhat.com>
Subject: Re: [PATCH RFC 01/14] mm: memcg: subpage charging API
Thread-Topic: [PATCH RFC 01/14] mm: memcg: subpage charging API
Thread-Index: AQHVZDNmLHUfmxN6PU+s0PWXiLpdV6cuU9OAgADimoA=
Date: Tue, 17 Sep 2019 02:27:19 +0000
Message-ID: <20190917022713.GB8073@castle.DHCP.thefacebook.com>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-2-guro@fb.com> <20190916125611.GB29985@cmpxchg.org>
In-Reply-To: <20190916125611.GB29985@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR18CA0052.namprd18.prod.outlook.com
 (2603:10b6:104:2::20) To BYASPR01MB0023.namprd15.prod.outlook.com
 (2603:10b6:a03:72::29)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::f4fb]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9cee9a43-2d5e-411a-faed-08d73b168fa2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3270;
x-ms-traffictypediagnostic: BYAPR15MB3270:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB327027A6F2A3F254413E6A13BE8F0@BYAPR15MB3270.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01630974C0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(39860400002)(376002)(346002)(396003)(199004)(189003)(71190400001)(6436002)(476003)(446003)(46003)(256004)(478600001)(14444005)(386003)(6506007)(6916009)(316002)(52116002)(71200400001)(76176011)(99286004)(6486002)(33656002)(186003)(102836004)(6512007)(6246003)(229853002)(7736002)(305945005)(81166006)(54906003)(14454004)(11346002)(6116002)(5660300002)(8676002)(81156014)(4326008)(25786009)(66946007)(66446008)(86362001)(8936002)(9686003)(2906002)(66476007)(66556008)(64756008)(1076003)(486006);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3270;H:BYASPR01MB0023.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 5rEVywGbj+F/PcDJV6aI+IJ4PFo087E/zyQVjiu9lQSjqGt7YWTW/CBEKaD/ohHQp40Z9wXFOvooCqAHMSQK1N+fCMSwXS9VvCNuacUuphW+AASooiYuiTy2lKhRS7uxIjqT7raQzfmC3ePxFhg03pX9ZA5QXo5FIpc9O/C9vuZSN/YTzBD+EeL94LI31/RNxchDrS19lVpMGZtwqItEhNQV7zxrFBlCGS29js+pkEPk/abUXH1kxc8hdjPVWQ4uP381BzsZayU3SnQAV8FgCXkUtMUR8u9rAzK1lAjTXrxc7oo3vzBKM13Q+N4HkX0X3wh+H/WgIBWo7EwX8qFDxMcysIxJk6kOZpOSvmhDroGpLWaP+iaw/Xq5J1xxEbHO8fJd7SRRj/MqoQGDQWKZHZyWEO0KNAmg/tf6uSpocNg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D1B9D466394C5F4994BD39812EE0C5F9@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9cee9a43-2d5e-411a-faed-08d73b168fa2
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Sep 2019 02:27:20.5802
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: j/SiwhMxuYf9qn/16GbQbt2nlSB2I5DVkj4cFFTfx0zxvx7C4m4Ms7EVAYlAoQ5t
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3270
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-17_01:2019-09-11,2019-09-17 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 bulkscore=0
 mlxlogscore=999 malwarescore=0 spamscore=0 clxscore=1015 impostorscore=0
 mlxscore=0 lowpriorityscore=0 phishscore=0 priorityscore=1501 adultscore=0
 suspectscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909170026
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 02:56:11PM +0200, Johannes Weiner wrote:
> On Thu, Sep 05, 2019 at 02:45:45PM -0700, Roman Gushchin wrote:
> > Introduce an API to charge subpage objects to the memory cgroup.
> > The API will be used by the new slab memory controller. Later it
> > can also be used to implement percpu memory accounting.
> > In both cases, a single page can be shared between multiple cgroups
> > (and in percpu case a single allocation is split over multiple pages),
> > so it's not possible to use page-based accounting.
> >=20
> > The implementation is based on percpu stocks. Memory cgroups are still
> > charged in pages, and the residue is stored in perpcu stock, or on the
> > memcg itself, when it's necessary to flush the stock.
>=20
> Did you just implement a slab allocator for page_counter to track
> memory consumed by the slab allocator?

:)

>=20
> > @@ -2500,8 +2577,9 @@ void mem_cgroup_handle_over_high(void)
> >  }
> > =20
> >  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > -		      unsigned int nr_pages)
> > +		      unsigned int amount, bool subpage)
> >  {
> > +	unsigned int nr_pages =3D subpage ? ((amount >> PAGE_SHIFT) + 1) : am=
ount;
> >  	unsigned int batch =3D max(MEMCG_CHARGE_BATCH, nr_pages);
> >  	int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
> >  	struct mem_cgroup *mem_over_limit;
> > @@ -2514,7 +2592,9 @@ static int try_charge(struct mem_cgroup *memcg, g=
fp_t gfp_mask,
> >  	if (mem_cgroup_is_root(memcg))
> >  		return 0;
> >  retry:
> > -	if (consume_stock(memcg, nr_pages))
> > +	if (subpage && consume_subpage_stock(memcg, amount))
> > +		return 0;
> > +	else if (!subpage && consume_stock(memcg, nr_pages))
> >  		return 0;
>=20
> The layering here isn't clean. We have an existing per-cpu cache to
> batch-charge the page counter. Why does the new subpage allocator not
> sit on *top* of this, instead of wedged in between?
>=20
> I think what it should be is a try_charge_bytes() that simply gets one
> page from try_charge() and then does its byte tracking, regardless of
> how try_charge() chooses to implement its own page tracking.
>=20
> That would avoid the awkward @amount + @subpage multiplexing, as well
> as annotating all existing callsites of try_charge() with a
> non-descript "false" parameter.
>=20
> You can still reuse the stock data structures, use the lower bits of
> stock->nr_bytes for a different cgroup etc., but the charge API should
> really be separate.

Hm, I kinda like the idea, however there is a complication: for the subpage
accounting the css reference management is done in a different way, so that
all existing code should avoid changing the css refcounter. So I'd need
to pass a boolean argument anyway.

But let me try to write this down, hopefully v2 will be cleaner.

Thank you!

