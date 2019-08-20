Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A279C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 21:40:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D86AF22D6D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 21:40:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Gh4c1NMx";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ZL4xeAjW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D86AF22D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66CD46B0006; Tue, 20 Aug 2019 17:40:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C056B0007; Tue, 20 Aug 2019 17:40:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E3286B0008; Tue, 20 Aug 2019 17:40:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 288256B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 17:40:03 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BA05F52C5
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:40:02 +0000 (UTC)
X-FDA: 75844124244.03.arch91_1d6a0a6681162
X-HE-Tag: arch91_1d6a0a6681162
X-Filterd-Recvd-Size: 9595
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:40:01 +0000 (UTC)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7KLcvpn012283;
	Tue, 20 Aug 2019 14:39:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=S/JKD5K4R62aTLziq12p4L5gjkCqfaRwzl6TC6d2yJA=;
 b=Gh4c1NMx39dAF9caeT3NqYXG9I/xvMqztIBYrlvJkKWwCQzwatAHlvpUDB3G1nCSTuSc
 DChxqFCVTm/lDuxNTgJ4cfVnNmVot2NE1YTPFjFDhqn/I5jG5IprMsj32Bmo9ktFSQOP
 nrS9ni7n3gWu3tdLklOV4sUPxLfArMgO1Ek= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2ugmrph7xg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 20 Aug 2019 14:39:48 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 20 Aug 2019 14:39:10 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 20 Aug 2019 14:39:10 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=PfWW50zSXrpe1C0rfcsRUYQe2dL89awHRyhpWWfARwM49VSNQBkygbC6WRhZdLB/aEv5j8ULnPMX4YmGwYAdd5SYuuz2e8Z8F0WFP8wh2Ia6es8/47w+YN2XMTBJA2rMN7i26BgXbDe5ACdtRf/J1Un9Bm/pxeURMb5lfMsq0r0aOhkPqH5gI4D5hbgrYHbxsB0vqX/gzkbXoDjQfWG0cVZ6A3wDYnCXovIXvlKZgzKuz1BgD6GqUuVuBOptCWKebUTUKN7OTfIlW/7mFBP5Z4UBU3a6kH+7gpnXZQJS9t+4M2N42RId7NwcpASxn+4zauvE4sgey9EVna9H7SR3wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=S/JKD5K4R62aTLziq12p4L5gjkCqfaRwzl6TC6d2yJA=;
 b=fFzaZzqP3vkYJ4ICSKh2L3WYIjgr3bHnb0nuldNeUH13NQq037NBsf6DvuQVzcxXgboH0W2J0Y3TMsQ8mB16kOEgaXbvkHfMd8diNX4Z9qyl6J8cDazHRTjw3w2otkGU3igDBzfLhCYAOka7nS93vPxV1M7abpr7uXU18zGhJKuGmguIPCxOgouyYhCBDLCu7B/sw/bCHsj3WMkP+tlbqV6GY7qRU3xpVeLroVHTjPxmnoMGb1uZSGNu0rLZuNRHP7l/ULVyx0uBK1mHolLfFr/8ip0wXVbSAGqDSHSr6MigViIWru84Np5hfoGJHlG3No5dJdEDwdWXWdefghduiw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=S/JKD5K4R62aTLziq12p4L5gjkCqfaRwzl6TC6d2yJA=;
 b=ZL4xeAjWp7Lqu15g3CEbXdqOVVX01ch23QURwxHzqxM1gTTnxMnp4Qd8OAs2CC1R0ANZKa2MhOp+n+CPDw90t3FbD4CKKP3wBFNDrKUer1qxpJjRuo/R1umGjkQw5220f0cJLuzM/5aeDUFMNjnSxKkAGiEFjsXIvTqvBUFBrkw=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3337.namprd15.prod.outlook.com (20.179.50.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Tue, 20 Aug 2019 21:39:09 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.018; Tue, 20 Aug 2019
 21:39:08 +0000
From: Roman Gushchin <guro@fb.com>
To: Yafang Shao <laoar.shao@gmail.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Randy Dunlap
	<rdunlap@infradead.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko
	<mhocko@suse.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Tetsuo Handa
	<penguin-kernel@i-love.sakura.ne.jp>,
        Souptick Joarder
	<jrdr.linux@gmail.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Thread-Topic: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Thread-Index: AQHVViv/4dAlisUxW0emrEnYHi/MH6cEkwmA
Date: Tue, 20 Aug 2019 21:39:08 +0000
Message-ID: <20190820213905.GB12897@tower.DHCP.thefacebook.com>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO1PR15CA0114.namprd15.prod.outlook.com
 (2603:10b6:101:21::34) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:4a49]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 01d99bf3-e4f4-40c3-81b8-08d725b6d52b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB3337;
x-ms-traffictypediagnostic: DM6PR15MB3337:
x-microsoft-antispam-prvs: <DM6PR15MB3337B4645017DFE3B9546918BEAB0@DM6PR15MB3337.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 013568035E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(396003)(366004)(136003)(376002)(189003)(199004)(316002)(86362001)(52116002)(5660300002)(6436002)(7736002)(305945005)(8936002)(6512007)(9686003)(446003)(99286004)(7416002)(76176011)(478600001)(11346002)(46003)(486006)(476003)(81166006)(81156014)(8676002)(54906003)(71190400001)(71200400001)(186003)(14454004)(66446008)(64756008)(66556008)(66476007)(66946007)(4326008)(53936002)(6246003)(386003)(6506007)(25786009)(102836004)(1076003)(256004)(14444005)(6116002)(6916009)(229853002)(2906002)(6486002)(33656002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3337;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: KE+rVqNK4N+dvGHcpmNvZ6pBEChu+1ywoXoIsvU9BXDenE7LgAd3jK18xfv2mqtz27FKcMw/IPrQ9ieOLCVOpfAz8fFkNoo+2eVt2NnUuCVUPqnHW+uKF8XMezzt9QzzSutIgx3ZGAuzZYr+QC0oYaIttg8ys65qbCmIVOGouj3/vdw9cL7eekRGJQXMeBZUoMjhU4QnMfWYZZw1HWs9/l1bhpCTMmtGp/t+jEto6pk7SRUSuAQr/3/Gj78pS7TbRGx+4xYPfSh8JfiPGv99o0hFIeEzk+PUFRlLu9zNs8fga14M8QD8dDOvSExSTm8VnTNBqYOrzkRdc4YctamvLBXul4zRhSzVjrwBrwTIaM3puouCydmRiqBp5Z2KGZZDqQTSPoN5QtgeiR2hKDbKx4iifJJSxCKjRdbDW4N1h9o=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <28ECA1752DCF7643BC694342350A9263@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 01d99bf3-e4f4-40c3-81b8-08d725b6d52b
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Aug 2019 21:39:08.8597
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: VNdgE5vCrAPNs1OykTiEAleX+2zaqoUV9JrsepigUv95zVTPgGgxCerHFDMrsJ7U
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3337
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-20_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=832 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908200197
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> In the current memory.min design, the system is going to do OOM instead
> of reclaiming the reclaimable pages protected by memory.min if the
> system is lack of free memory. While under this condition, the OOM
> killer may kill the processes in the memcg protected by memory.min.
> This behavior is very weird.
> In order to make it more reasonable, I make some changes in the OOM
> killer. In this patch, the OOM killer will do two-round scan. It will
> skip the processes under memcg protection at the first scan, and if it
> can't kill any processes it will rescan all the processes.
>=20
> Regarding the overhead this change may takes, I don't think it will be a
> problem because this only happens under system  memory pressure and
> the OOM killer can't find any proper victims which are not under memcg
> protection.

Also, after the second thought, what your patch really does,
it basically guarantees that no processes out of memory cgroups
with memory.min set will be ever killed (unless there are any other
processes). In most cases (at least on our setups) it's basically
makes such processes immune to the OOM killer (similar to oom_score_adj
set to -1000).

This is by far a too strong side effect of setting memory.min,
so I don't think the idea is acceptable at all.

Thanks!

