Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71EFCC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 00:30:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 021F62067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 00:30:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ty87d9bO";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="I0ZBRgjn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 021F62067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690816B0007; Mon, 12 Aug 2019 20:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 641C86B0008; Mon, 12 Aug 2019 20:30:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 508EF6B000A; Mon, 12 Aug 2019 20:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 301A66B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:30:16 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B376C8248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 00:30:15 +0000 (UTC)
X-FDA: 75815522790.15.game69_1f48569792b1d
X-HE-Tag: game69_1f48569792b1d
X-Filterd-Recvd-Size: 9261
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 00:30:14 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7D0T2A2018299;
	Mon, 12 Aug 2019 17:30:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=OJdFUMuGCy9ny5x/pIXKc2ddPq8O6p3lJyTW+St83K4=;
 b=Ty87d9bOFWIACbaYUljUAM8EN5CkNbQctY9yivNz2LAn8W7O7T/5LaGg48DxwfjMFrlU
 XeBXVxdfssDyhlM94iG4krm7tsfDxPVoZQfHvfyRW8av8WuK50PCRDe/411AXGXfUW+p
 JNc+Y1dXE8AZWnfBYtZuJxuaXIu5B7YOyqA= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ubecv90q1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 12 Aug 2019 17:30:12 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 12 Aug 2019 17:30:11 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 12 Aug 2019 17:30:11 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 12 Aug 2019 17:30:10 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ux4ZvDe1W9itFe8ecdWAxAohgZhLxVtXFa6gqh43u5lFi+mMzxJy33wj7MqbdgA3nX41eFKINvqT3xG0sliAhTDX1i5sgGUn4CcaqZBLDfeVAoov7rV7N65YsUnkid5R/UU0FpkxGXg5a7rJj8ypMCIoC2FLuD4CHXOf2SjRSiJoT25mhRUjD9YVPwwosYPGL0ZfCVaqnAGR5fT2tzldb/frd1YAoWBj0HaQjA0uWNKfHRrlUr2qS4xcLosl/mZtBP3Tl7aoYgKAZVYaQ+APma5eI9DLSuNYoqTCuTQYcdGX0bGc/usiamPz+BKNKcDjyNo5BVhwMQpgBxqnVt//xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OJdFUMuGCy9ny5x/pIXKc2ddPq8O6p3lJyTW+St83K4=;
 b=GUKmaAT+xfwg77l+nLEOvvXVLL66GxOr00EMnaCGF8/X6OiaImockzHilDZWCt2ouHkamvLqFxHanRd2o08wmHzncJGDE+QlWV/xGD6vNZwW0SINVnis5JrJbFEBlq34/xv1XTX+OllZnCeMMcJmXKCg7Qf6PCrzSieGFshmAOyA3k/KqZ2R134Nr/I2wfkWm8zE58TKmEVHYvIHJ5qOnl/3i0+Id1Pw9QLfHYSeMk12YrciZ6d4JWjyknb1hnss2haEbdEQntw1R7WKDiOJ7yF7B30tz/KRLY5w6IJzaeRu3q3pEHNWXn2LCVykqbFAetnjD0CuBKvNLjP6FqGajg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OJdFUMuGCy9ny5x/pIXKc2ddPq8O6p3lJyTW+St83K4=;
 b=I0ZBRgjnA1OW8mXHDxvPrfLuSd1QdfDQDRxTrAFvS+RaR1w7AraG+nAK3QoT+yNVrZU3ObgJYrYuX5ZlMM8W4RZGIrhphff/9Bxe9ndagM33aaELdwfq0PgPGatgOpwxdU42NUtN3mjwnP6h6lJDIXIt2ZawfvKvNjw/wB6Ncns=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3339.namprd15.prod.outlook.com (20.179.50.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Tue, 13 Aug 2019 00:30:10 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2157.022; Tue, 13 Aug 2019
 00:30:10 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: flush percpu vmevents before releasing
 memcg
Thread-Topic: [PATCH] mm: memcontrol: flush percpu vmevents before releasing
 memcg
Thread-Index: AQHVUWcJo041kAovIUqPQ99aFT9BKqb4ObQA
Date: Tue, 13 Aug 2019 00:30:09 +0000
Message-ID: <20190813003006.GA2146@tower.dhcp.thefacebook.com>
References: <20190812233754.2570543-1-guro@fb.com>
In-Reply-To: <20190812233754.2570543-1-guro@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR05CA0032.namprd05.prod.outlook.com
 (2603:10b6:a03:c0::45) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:ee94]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 508b7880-1240-4852-be0e-08d71f8565f9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3339;
x-ms-traffictypediagnostic: DM6PR15MB3339:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB3339BA1B02222A7C0C559D41BED20@DM6PR15MB3339.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01283822F8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(396003)(39860400002)(346002)(136003)(199004)(189003)(52314003)(186003)(8936002)(46003)(4326008)(476003)(229853002)(6486002)(11346002)(446003)(256004)(25786009)(4744005)(6512007)(2501003)(9686003)(5660300002)(86362001)(102836004)(33656002)(1076003)(386003)(71190400001)(71200400001)(76176011)(53936002)(6436002)(6246003)(52116002)(316002)(66946007)(66476007)(66446008)(54906003)(66556008)(64756008)(6506007)(2906002)(305945005)(8676002)(478600001)(81156014)(81166006)(14454004)(110136005)(486006)(99286004)(7736002)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3339;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 51moVEEcat8EiazeK2mi4AUnslWV8fVSjzm8pdG4qX7zRzJGZ2GhaITCLSazwftbqAhkyV/TryHVV2f6qJu2YMVZnZMkcwb5n6DlWLkm3xp4HcbNZHtJJh7h5LTa2kooGmgvjnExFowODNw7I/8W9DZMIwkVtqTTj0JHPgmuwk7x/Z6qm4Y/bbcmGsvRPuKQ4OgHHj0F6VRuNmEKJyZ1WoKkY4+I9+Cm6hZr3DBiu2JeKz+Dh02z5ZYPYzq02xgB0Gafx4p3eLH0eynZ4EVBp7PnSakpcTQvAC54D9KZhxxsposKJU4Ftr2NPp9k9zhvr2PmWlQf9dtJoJLtfztDm7U1+csuwHcFJShAPR9ToIDXwAUNP+IpRs3eQbnmUwmv0GxTFwAmk92LQwO5Hy6CEyNPRurdd4gqEwOpub4t2BY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <320C88B52CE1B3408C22FE36DF00648C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 508b7880-1240-4852-be0e-08d71f8565f9
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Aug 2019 00:30:09.9960
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: rdM22WiZt7FbNtHjvHeGOy7XEwd/Ig8gQUcPcal+HF6ppF5TmQWX4pLEPZ+VU6oi
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3339
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=979 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130001
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 04:37:54PM -0700, Roman Gushchin wrote:
> Similar to vmstats, percpu caching of local vmevents leads to an
> accumulation of errors on non-leaf levels. This happens because
> some leftovers may remain in percpu caches, so that they are
> never propagated up by the cgroup tree and just disappear into
> nonexistence with on releasing of the memory cgroup.
>=20
> To fix this issue let's accumulate and propagate percpu vmevents
> values before releasing the memory cgroup similar to what we're
> doing with vmstats.
>=20
> Since on cpu hotplug we do flush percpu vmstats anyway, we can
> iterate only over online cpus.

Just to clarify: this patch should be placed on top of two other
patches, which I sent a bit earlier today:

1) mm: memcontrol: flush percpu slab vmstats on kmem offlining
2) mm: memcontrol: flush percpu vmstats before releasing memcg

Sorry for the inconvenience, I forgot about vmevents during
working on the final version, and remembered too late.

Thanks!

