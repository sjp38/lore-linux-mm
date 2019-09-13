Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56CBFC49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:12:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21C07208C0
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 11:12:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21C07208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 917C96B0008; Fri, 13 Sep 2019 07:12:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C8486B000A; Fri, 13 Sep 2019 07:12:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DD2C6B000C; Fri, 13 Sep 2019 07:12:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEE76B0008
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:12:46 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E499220BEE
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:12:45 +0000 (UTC)
X-FDA: 75929634690.13.look40_18172ec593e08
X-HE-Tag: look40_18172ec593e08
X-Filterd-Recvd-Size: 5082
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 11:12:45 +0000 (UTC)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8DBCOfg035064
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:12:42 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2v0923tetq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 07:12:42 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 13 Sep 2019 12:12:40 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 13 Sep 2019 12:12:38 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8DBCbUF28901630
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 13 Sep 2019 11:12:37 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 53B9FA405F;
	Fri, 13 Sep 2019 11:12:37 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D8B57A4060;
	Fri, 13 Sep 2019 11:12:36 +0000 (GMT)
Received: from pomme.local (unknown [9.145.117.92])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 13 Sep 2019 11:12:36 +0000 (GMT)
Subject: Re: Speculative page faults
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Linux-MM <linux-mm@kvack.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        charante@codeaurora.org
References: <5D74BC65.4070309@huawei.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Fri, 13 Sep 2019 13:12:36 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <5D74BC65.4070309@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
X-TM-AS-GCONF: 00
x-cbid: 19091311-0012-0000-0000-0000034AD318
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091311-0013-0000-0000-0000218542DF
Message-Id: <b681a5c4-5bb8-4e6c-3323-30e1645782c3@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-13_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=657 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909130108
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 08/09/2019 =C3=A0 10:31, zhong jiang a =C3=A9crit=C2=A0:
> Hi, Laurent,  Vinayak
>=20
> I have got the following crash on 4.14 kernel with speculative page fau=
lts enabled.
> Unfortunately,  The issue disappears when trying disabling SPF.

Hi Zhong,

Sorry for to late answer, I was busy at the LPC.

I never hit that.

Is there any steps identified leading to this crash ?

Thanks,
Laurent.


> The call trace is as follows.
>=20
> Unable to handle kernel NULL pointer dereference at virtual address 000=
00000
> user pgtable: 4k pages, 39-bit VAs, pgd =3D ffffffc177337000
> [0000000000000000] *pgd=3D0000000177346003, *pud=3D0000000177346003, *p=
md=3D0000000000000000
> Internal error: Oops: 96000046 [#1] PREEMPT SMP
>=20
> CPU: 0 PID: 3184 Comm: Signal Catcher VIP: 00 Tainted: G           O   =
 4.14.116 #1
> PC is at __rb_erase_color+0x54/0x260
> LR is at anon_vma_interval_tree_remove+0x2ac/0x2c0
>=20
> Call trace:
> [<ffffff8009aa45c4>] __rb_erase_color+0x54/0x260
> [<ffffff80083a73f8>] anon_vma_interval_tree_remove+0x2ac/0x2c0
> [<ffffff80083b96ac>] unlink_anon_vmas+0x84/0x170
> [<ffffff80083aa8f4>] free_pgtables+0x9c/0x100
> [<ffffff80083b6814>] exit_mmap+0xb0/0x1d8
> [<ffffff8008227e8c>] mmput+0x3c/0xe0
> [ffffff800822ed00>] do_exit+0x2f0/0x954
> [<ffffff800822f41c>] do_group_exit+0x88/0x9c
> [<ffffff800823b768>] get_signal+0x360/0x56c
> [<ffffff8008208eb8>] do_notify_resume+0x150/0x5e4
> Exception stack(0xffffffc1eac07ec0 to 0xffffffc1eac08000)
>=20
> It seems to rb_node is empty accidentally under anon_vma rwsem when the=
 process is exiting.
> I have no idea whether any race existence or not to result in the issue=
.
>=20
> Let me know if you have hit the issue or any  suggestions.
>=20
> Thanks,
> zhong jiang
>=20


