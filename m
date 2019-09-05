Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F45C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39CA6206DE
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 22:35:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="lgiWG62u";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="RfVbn7/U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39CA6206DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A85D6B0007; Thu,  5 Sep 2019 18:35:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6324F6B0008; Thu,  5 Sep 2019 18:35:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F9416B000A; Thu,  5 Sep 2019 18:35:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 270EF6B0007
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:35:02 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id AF2B4181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:35:01 +0000 (UTC)
X-FDA: 75902323602.06.paste83_830dfb75e8b44
X-HE-Tag: paste83_830dfb75e8b44
X-Filterd-Recvd-Size: 10386
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 22:35:00 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x85MYrsI023475;
	Thu, 5 Sep 2019 15:34:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=VY471la3L23Eltq2xlADCf9gAVZ6iQBEblPJizEYpEQ=;
 b=lgiWG62uqE6joB6UswrVyimddV9WAsC/9smtAbz6hCN1/CxiK+QeCzmICKCpJDOfHxOQ
 7ExPgBHU/g20E7Xoz7eoO2LbByKAcBwZeVpMBHVrs502hMdSUUJxsfBoQ8xpjnrAIxjq
 f69ApCr2vOeprzj+ESPqycj8Kpt0Bfy5dSc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uu3nb2b21-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 05 Sep 2019 15:34:54 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 5 Sep 2019 15:34:39 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 5 Sep 2019 15:34:39 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Rt2YPxKlVRFGeKkC07UZ3HXKdabTIRgE6MYwC+JKPjT9yqQbAYxDi7V6CDGoL3wzBHcPQxRtlv6zVOV7ZQfWZtphtUV9jvTiKFcx9X07miLklgdN/3mC4HicoH8Xd4TeyLPxG/GMsab2/6dPnogPh0GOpjC7rC+OG9A5qSeSnCP51MGfSNJXXkELsrd7ZMTtBumh010ISchoqvysFl7lVN+0o8qcYleUSOgpgwcWY4CCh62naWj81xkLOA4ntGFB1usLiF6bQsQFhHtIJ17HODM+t25RYfo/Plw34tNjH/Naf4TO+9OWP3qh0XqPQqz07knfeoTDIh8eqrMUgCPzgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VY471la3L23Eltq2xlADCf9gAVZ6iQBEblPJizEYpEQ=;
 b=HnXrnmZJuWx8nRLarRanoq5GhScdID6gJ78UFfurxExEsv5KKAU6G8rtvL3eDBU+dNeDwU2RpmPMmRaoiiQ3w/JPzntjDEjH3pb3DD/UT7gc0p7G+7d1P4tBL3hCEnWbNal3JOZLlwHUMwroR8pGqGUEQjb1aZcqP9/WbFNYkhY1BYocKfx+l7/VFCb+ONzeR4sAvNwytlcuXPz/qmqBtON+Eiec/2qXSWmtvR1hFPJHXE0t6SgcxETyLNab1XDMGVpfVaahOyphXSGCEwfpdiGoHy3scWI0oLlOHJYcCcaTLh3oM9WpyCvbjSlWIv9QNQ/3RIW7eqKJ6io6H9biFQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VY471la3L23Eltq2xlADCf9gAVZ6iQBEblPJizEYpEQ=;
 b=RfVbn7/UpD03INfd0lqblzOwN93JfP2IYmApfnJz/RTfk4DoWLEakcHZbK3xyzkq1xEVZBSzokpTOgnmDhP+xtYXNbtGnbPWuPPoE8Cvw8D6TuOFN0q69NvCEC1XoffQEqa4fDXD739G68He123EZcWQVAXVuuoTLhDgmvNBkXc=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2588.namprd15.prod.outlook.com (20.179.161.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2220.19; Thu, 5 Sep 2019 22:34:37 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2220.022; Thu, 5 Sep 2019
 22:34:37 +0000
From: Roman Gushchin <guro@fb.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH RFC 02/14] mm: memcg: introduce mem_cgroup_ptr
Thread-Topic: [PATCH RFC 02/14] mm: memcg: introduce mem_cgroup_ptr
Thread-Index: AQHVZDNrTEPuqgxSak+O+uxAJpftMqcdq8aA
Date: Thu, 5 Sep 2019 22:34:37 +0000
Message-ID: <20190905223433.GA5686@tower.DHCP.thefacebook.com>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-3-guro@fb.com>
In-Reply-To: <20190905214553.1643060-3-guro@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR03CA0031.namprd03.prod.outlook.com
 (2603:10b6:a02:a8::44) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:3ae5]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5b2a305e-9719-4004-a1c5-08d732513bcc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2588;
x-ms-traffictypediagnostic: DM6PR15MB2588:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB2588CD93349AB3028508B841BEBB0@DM6PR15MB2588.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2276;
x-forefront-prvs: 015114592F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(39860400002)(376002)(136003)(366004)(189003)(199004)(66446008)(6916009)(66946007)(99286004)(229853002)(66556008)(2351001)(478600001)(66476007)(2501003)(4326008)(8676002)(305945005)(102836004)(53936002)(14454004)(256004)(8936002)(81166006)(64756008)(46003)(386003)(6506007)(186003)(14444005)(7736002)(6116002)(2906002)(1076003)(6246003)(54906003)(316002)(52116002)(76176011)(446003)(9686003)(6512007)(86362001)(71200400001)(71190400001)(6486002)(25786009)(476003)(5640700003)(33656002)(5660300002)(11346002)(486006)(6436002)(81156014);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2588;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Ks7oYVBbmpox29+muoDTynV9N3+/wryPzrfHrpYkripb1/fncqgPjFYyUfoEZsBNHn2hmHxusu2PSIYeFyJQfNxv8SJ9pJAUUouZYFa9PQ01f3hRjS2IZOX5lFaMZaQtOzVe6OlT2aeC0grENyStFPH0UPitU1+nGxgXPhX0NN0bsDc9Ffhf1QVloIVgX0Fdla9yHq0/bMwZuFxuOJblataa4gH+FdCD474DFbEzvsSssrj7TIdJTFxuebNuXozutKzpn91kNiKpHkmRv8vmNDTMyx7JvQ8bKCD5ADRFCkimh0MMuazBcYacmHFqvywFd7ssWm2P56rMxxCqrS8kQ7EITY2WEWpvPQsa3Mh/rTUyjfzpqLAvlUJFpUCxcMlmtR1l2MjcvfhUB4Yz+LsMk5Snk6ANs5mm1xIx7xY3nWc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6463A4F811D7454BAA30EB4757C0A3E7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5b2a305e-9719-4004-a1c5-08d732513bcc
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Sep 2019 22:34:37.5289
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: W8HnaHiOgtPM0envqFx0M9aB8GS5Daw2c1gVEWxNSPGn0zvlCN/JjNE+iytWorX+
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2588
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-05_09:2019-09-04,2019-09-05 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 clxscore=1015 spamscore=0
 lowpriorityscore=0 mlxscore=0 malwarescore=0 bulkscore=0 adultscore=0
 mlxlogscore=964 priorityscore=1501 suspectscore=0 impostorscore=0
 phishscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909050210
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 05, 2019 at 02:45:46PM -0700, Roman Gushchin wrote:
> This commit introduces mem_cgroup_ptr structure and corresponding API.
> It implements a pointer to a memory cgroup with a built-in reference
> counter. The main goal of it is to implement reparenting efficiently.
>=20
> If a number of objects (e.g. slab pages) have to keep a pointer and
> a reference to a memory cgroup, they can use mem_cgroup_ptr instead.
> On reparenting, only one mem_cgroup_ptr->memcg pointer has to be
> changed, instead of walking over all accounted objects.
>=20
> mem_cgroup_ptr holds a single reference to the corresponding memory
> cgroup. Because it's initialized before the css reference counter,
> css's refcounter can't be bumped at allocation time. Instead, it's
> bumped on reparenting which happens during offlining. A cgroup is
> never released online, so it's fine.
>=20
> mem_cgroup_ptr is released using rcu, so memcg->kmem_memcg_ptr can
> be accessed in a rcu read section. On reparenting it's atomically
> switched to NULL. If the reader gets NULL, it can just read parent's
> kmem_memcg_ptr instead.
>=20
> Each memory cgroup contains a list of kmem_memcg_ptrs. On reparenting
> the list is spliced into the parent's list. The list is protected
> using the css set lock.
>=20
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  include/linux/memcontrol.h | 50 ++++++++++++++++++++++
>  mm/memcontrol.c            | 87 ++++++++++++++++++++++++++++++++++++--
>  2 files changed, 133 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 120d39066148..dd5ebfe5a86c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -23,6 +23,7 @@
>  #include <linux/page-flags.h>
> =20
>  struct mem_cgroup;
> +struct mem_cgroup_ptr;
>  struct page;
>  struct mm_struct;
>  struct kmem_cache;
> @@ -197,6 +198,22 @@ struct memcg_cgwb_frn {
>  	int memcg_id;			/* memcg->css.id of foreign inode */
>  	u64 at;				/* jiffies_64 at the time of dirtying */
>  	struct wb_completion done;	/* tracks in-flight foreign writebacks */
> +}

Oops, a semicolon has been lost during the final rebase.
I'll send a correct version of this patch separately.

Sorry for the mess.

