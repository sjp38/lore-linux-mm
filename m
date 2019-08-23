Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 723E8C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:33:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08802082F
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 22:33:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="GJ7PT3GP";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="bfF7/nVK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08802082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842A86B04C0; Fri, 23 Aug 2019 18:33:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81CD86B04C1; Fri, 23 Aug 2019 18:33:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BBFD6B04C2; Fri, 23 Aug 2019 18:33:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 4A12E6B04C0
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 18:33:11 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DB781180AD7C1
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:33:10 +0000 (UTC)
X-FDA: 75855144540.07.bed04_55ddf45ccd93f
X-HE-Tag: bed04_55ddf45ccd93f
X-Filterd-Recvd-Size: 10325
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:33:09 +0000 (UTC)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7NMKCLe008316;
	Fri, 23 Aug 2019 15:33:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=lUetpbmexGZAW6qb5NvlTVkNwWoKvxtNjCFJWeC419E=;
 b=GJ7PT3GPyrwchQMWjvBgFAYdEaD01j3P/tGm9ovNRE17hveM/f0c9Ba538Cd+kRJCAvn
 CcrLcbEGW7XtG3YHzuG2wrX6yAh7m0PiiXFad0mxelXQTELJQNa+HAE5ZXz3wz5ozpO7
 ev/CALUuzE6uzpmnS9CbKS3Kvf2XRM2oWSk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ujmw3h5qs-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 23 Aug 2019 15:33:03 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 23 Aug 2019 15:33:02 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 23 Aug 2019 15:33:02 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 23 Aug 2019 15:33:02 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=cwbIeez2B5jzuL9tQtOSnsvyQ0IFrVnHJrviEcEUoArAbE2TV/gcSDV8Ircb7Op/ke81FMIaz6bloqoXw6v873JRrC0+W5U7A0vyc1zprQ69TTBOP47QWvH9DDM8VA8jyWyrzii5V3sVxx71uPtgCVLQl0HutL4i2HnyU8mPCLUy76L8MskcKcuP4LBrQxrxC+yEq2Tr1XanQqvDzBf96xM5/gEF4DqioxEVoLMWHeD01XZM13i7xiLXI6R4AlZ4pNXBq9F+Rgeyjih2NUHZ+QsLoPAFDHq+mJflKWeWysppbY7/m9OFWKfGBb1zembVhicXcA9TwTS5SsyAX+yc+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lUetpbmexGZAW6qb5NvlTVkNwWoKvxtNjCFJWeC419E=;
 b=oRVImUNfkOjeKvHrMLdS3eTwmYfL5h6OuUA4PD++aZDgSGGwyT/Ast+xZX/zLszQRir0QxN71QAYkC/J03QiFCwGjpsXTWEuagBs/9kUMZy2KhRXgFMfCvWIK9yoZQmr2jpDl4KctVhP2kMouSbZWk/NjoWgplsHzu9gVrDd6bs8bEm3lK/hmV0EQd1sDL5OkvFlIJMTSSd9AMJ9szWcY959tMn29NbAcJKxSS+OSjfoWBAnrVJdWtPE1Mb8lPD31HmZgY0hS3LtUcCk8/+RXxvvok+u28LRuHlFB4uWMpkflzSC88xGOFI13c2J/zPpfK2JwPF5yPcIcFhAAAXOUQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lUetpbmexGZAW6qb5NvlTVkNwWoKvxtNjCFJWeC419E=;
 b=bfF7/nVKJXaXPDiyshrZcSGXaApDbq+ikIy3XwO5hwr8FSdZduoZnf3v6YMES6SYQBZ32Sn0GITGLhoNMaRgak6E+l6VDvWeDmhyGASoxgvA5+S3+FPiX7/0T2PEmNvwP7DnBqA0JZHkB4NAMthe+DP7cEkdBb1M20dRw0AlcxA=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2745.namprd15.prod.outlook.com (20.179.163.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.21; Fri, 23 Aug 2019 22:33:01 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.020; Fri, 23 Aug 2019
 22:33:01 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>, Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM counters
 in sync with the hierarchical ones"
Thread-Topic: [PATCH] Partially revert "mm/memcontrol.c: keep local VM
 counters in sync with the hierarchical ones"
Thread-Index: AQHVVJVnJCTepTfXpE2m8ikuyJkTSKcJXEGA
Date: Fri, 23 Aug 2019 22:33:01 +0000
Message-ID: <20190823223257.GA22200@tower.DHCP.thefacebook.com>
References: <20190817004726.2530670-1-guro@fb.com>
In-Reply-To: <20190817004726.2530670-1-guro@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR21CA0008.namprd21.prod.outlook.com
 (2603:10b6:a03:114::18) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:a7ed]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c905d369-4a39-45ea-8c19-08d72819db19
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB2745;
x-ms-traffictypediagnostic: DM6PR15MB2745:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB274551CEFBEFE869E5DE9ACCBEA40@DM6PR15MB2745.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0138CD935C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(136003)(396003)(346002)(366004)(39860400002)(376002)(199004)(189003)(486006)(1076003)(76176011)(71200400001)(229853002)(8936002)(81166006)(316002)(6486002)(5660300002)(99286004)(4326008)(11346002)(2501003)(6246003)(476003)(33656002)(102836004)(446003)(52116002)(66946007)(66556008)(256004)(66476007)(7736002)(305945005)(386003)(64756008)(2906002)(6512007)(9686003)(25786009)(6116002)(81156014)(186003)(110136005)(14454004)(54906003)(478600001)(46003)(53936002)(71190400001)(8676002)(6436002)(86362001)(6506007)(66446008)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2745;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: dMVyv4pQNaGQyc88hF9G59a9d3p+SuMh0jQlyjAikJ5/2Tl8qPMq3i3GebJ3ydAOdB9wOiUNf9kZl6OthJu8VIWnu5hYyFuIP0QHRe/al7GEAm745ElQKYIcv61bNEyBzN1qVCCKoR9Bis4NukUzXm7hjNfyhv6mRDh0W1+qipCXfA5m0ZYzgA76v1EIjLabk7mPMjnBmnGbzxgsvVksSgvHnUxUDmKZXsbNn43sn3ZeRl6roOs6LCvHdgFD8Ji/D44px7B52ofDmVPfQCkC/DtG02ZtkXUx0Cj0XaRDc74S2RuvoybvOmoNLgRNwLDxsVBIpIIiBcXuHNxuNmprjyGzEX26Ns/yv14R5HbJ9GT9DkFVoPeUUMik9AFJgREOvSVHRMF/Y1axIoDeIFgWYGfH+LBvQolOouVXL2vwQPo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8DAE87D3646DAB46AC49BFB584993A74@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: c905d369-4a39-45ea-8c19-08d72819db19
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Aug 2019 22:33:01.2931
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fJdLFisKEouwkubPfC/rHJuoNJRM606PMkHM4PHcP6boNv8FdQ5cnuPl8jINPh09
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2745
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-23_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=851 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908230211
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 05:47:26PM -0700, Roman Gushchin wrote:
> Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync
> with the hierarchical ones") effectively decreased the precision of
> per-memcg vmstats_local and per-memcg-per-node lruvec percpu counters.
>=20
> That's good for displaying in memory.stat, but brings a serious regressio=
n
> into the reclaim process.
>=20
> One issue I've discovered and debugged is the following:
> lruvec_lru_size() can return 0 instead of the actual number of pages
> in the lru list, preventing the kernel to reclaim last remaining
> pages. Result is yet another dying memory cgroups flooding.
> The opposite is also happening: scanning an empty lru list
> is the waste of cpu time.
>=20
> Also, inactive_list_is_low() can return incorrect values, preventing
> the active lru from being scanned and freed. It can fail both because
> the size of active and inactive lists are inaccurate, and because
> the number of workingset refaults isn't precise. In other words,
> the result is pretty random.
>=20
> I'm not sure, if using the approximate number of slab pages in
> count_shadow_number() is acceptable, but issues described above
> are enough to partially revert the patch.
>=20
> Let's keep per-memcg vmstat_local batched (they are only used for
> displaying stats to the userspace), but keep lruvec stats precise.
> This change fixes the dead memcg flooding on my setup.
>=20
> Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync wit=
h the hierarchical ones")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Yafang Shao <laoar.shao@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Any other concerns/comments here?

I'd prefer to fix the regression: we're likely leaking several pages
of memory for each created and destroyed memory cgroup. Plus
all internal structures, which are measured in hundreds of kb.

Thanks!

