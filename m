Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB77FC3A5A2
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 02:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D97D21726
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 02:12:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MROcyqGg";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="RlvPu07t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D97D21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B7126B04CE; Fri, 23 Aug 2019 22:12:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4675F6B04CF; Fri, 23 Aug 2019 22:12:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 356196B04D0; Fri, 23 Aug 2019 22:12:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 12F2B6B04CE
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 22:12:35 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id AD11F52D3
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 02:12:34 +0000 (UTC)
X-FDA: 75855697428.23.plate56_6db296f62a012
X-HE-Tag: plate56_6db296f62a012
X-Filterd-Recvd-Size: 9715
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 02:12:33 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7O29YRM019059;
	Fri, 23 Aug 2019 19:12:26 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=/oegRWb3ammnVvupQjrHMnCHszWE4ZQU+KbjiiXDi4M=;
 b=MROcyqGgk+lj/uhk8/kwir8AS8Q/5EWuUF1nBRguO4Xa0yCoCvELEY+3Nw4euM4IZNnb
 SAkjfWrjOJB0fd0y76LIcM9uRqeoIJzX85JQEI1egKGii/rGJV+PLOUMUFB/mIiYp6Nl
 nSqmwG+H2ZsUf3NOYrGsorAvzVq9k5o8rd4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ujrvygmqq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 23 Aug 2019 19:12:26 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 23 Aug 2019 19:12:25 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 23 Aug 2019 19:12:25 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=e6Ci3B89G2o8vqabLmgAXByAljSQJOuHkXdsMVctVLjlchxeBc+MmaCKnBIL6osQr8YGxJloRXcR7MMT8InanLO6ys4auNJR9YhDvpE/2LBDQ+u53wKcg8mH8aaHYqGuJtJtuhu8lwwsJmmjUQXCXMzP1yOs/b8lfF+10Y13Y3/QE3A/IBtVkVu9+4OnF8G97OB7L29UZ5jHLr9SyDNZak+v//4invUzwWd6vNkx967BxlBlUmjJXg54j35HxBnPpKxqOTOgUOeOvlpeGpRsEFL8JEv3HHWq7lnrVOWPpLyqLfqXeNrnNQKv4jqaFARLqBF1MhgmS4Eeu9cAIIVM1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/oegRWb3ammnVvupQjrHMnCHszWE4ZQU+KbjiiXDi4M=;
 b=lgGd1M2snquuQjvImSbHsRpm9UGGirZC+L7y6xvZluvkTHs4c9QiQV26GaS27jK/RwxSVXGzruesbtXi0HHMlG2VJ1XDSTlFr/5MF7S0nGDVTWXQYauRnbc6ersKaLr/BXE9r1XyFilRG0vHRzyudl/+xRsY8SJV4HEOfO0Q37scVT7ApBqAg7MGqsDxhLwk8RbfxWuTsZGcrw5hQi8vIhqsIUCWZwHqNWwqyhAPCyMr07dE68cK5PYMYv23jjIBzZGQc7e99RLVtZr8cn2kZd5OSMviA3z4nSgW3y4JwUX4X4Egunu84/tXbalDYBfQc+pEmvkYQ2TSgasdQt5Lgg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/oegRWb3ammnVvupQjrHMnCHszWE4ZQU+KbjiiXDi4M=;
 b=RlvPu07tRhR/97EmUajtXhcryl0s6KnnDvQoW4RugjQUwjcnQlVA5LiWC+jQG+/odu3eGiUAfJFvlRFIUViZIzokMdC2Pk0ldT5XsdoX/LYatDbBJrQ7xepdtmzc4XNOPYU6RXB25MfeDL265drlYTw4pem3+NX5k8OUYi4l2Nk=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1552.namprd15.prod.outlook.com (10.173.229.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Sat, 24 Aug 2019 02:12:23 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::45ee:bc50:acfa:60a5]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::45ee:bc50:acfa:60a5%3]) with mapi id 15.20.2178.020; Sat, 24 Aug 2019
 02:12:23 +0000
From: Song Liu <songliubraving@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        Joerg Roedel
	<jroedel@suse.de>, Thomas Gleixner <tglx@linutronix.de>,
        Dave Hansen
	<dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
Thread-Topic: [PATCH v2] x86/mm/pti: in pti_clone_pgtable(), increase addr
 properly
Thread-Index: AQHVV5U99G5SsRzRUkunOQ/1Fd5gD6cFYg0AgAAFmQCABCvpAA==
Date: Sat, 24 Aug 2019 02:12:23 +0000
Message-ID: <33ED1189-0509-4F66-A96B-8CBD465889C3@fb.com>
References: <20190820202314.1083149-1-songliubraving@fb.com>
 <20190821101008.GX2349@hirez.programming.kicks-ass.net>
 <20190821103010.GJ2386@hirez.programming.kicks-ass.net>
In-Reply-To: <20190821103010.GJ2386@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::5e10]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0dfc2b6e-f090-410c-fdbf-08d7283880ba
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MWHPR15MB1552;
x-ms-traffictypediagnostic: MWHPR15MB1552:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB1552D4BD5316081A44F1967AB3A70@MWHPR15MB1552.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4502;
x-forefront-prvs: 0139052FDB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(136003)(346002)(366004)(396003)(376002)(199004)(189003)(53936002)(54906003)(81166006)(229853002)(25786009)(99286004)(86362001)(8936002)(6512007)(64756008)(46003)(66476007)(186003)(66556008)(81156014)(2906002)(66446008)(256004)(57306001)(76176011)(305945005)(66946007)(7736002)(6246003)(76116006)(36756003)(6436002)(6486002)(478600001)(4326008)(71200400001)(71190400001)(53546011)(5660300002)(102836004)(6506007)(6916009)(486006)(50226002)(6116002)(446003)(11346002)(33656002)(476003)(316002)(2616005)(8676002)(14454004);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1552;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JA+LJ25coI9NI9Xe1AI/AqBZN5taFqcGAa3o3FkdgUtb6HjgRsXFP1YdD8xTcCGiA1QE4vOApmYOgvYuWyZ0jRRBDEOm3WjOFWrNEr1Wv0eV6M6ywwKt348noaJ5GopjGIDZkPTs/VlTYcRKK2CKrHlWTVaxRxZKhUGtidqFzaAbe5DquLibI3K/fZ+W9y4GGRzL/4rrOnf6vKNRrm4KJLPhoQhZ7UakrtZplCBeGxjYP8W2W7Eohd07BapMNwx5WydQcu47lB5TUYUJl55ktrqyUOQ3waWcKi6SfwhBMRvOfW4AZsI70iyGo3XcjAzXn017Rl1dql1X47mXLYPy6r+N0UytKKLdDvgntpQJY+zqliyLKEiN1aK/lAbbtnMru99xYoSfDhx62mE26gYM4a5u9Y2lB9OIOS0fxfyZ5YY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F92BCEE5473C2946834B98F4CCA6B9FD@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0dfc2b6e-f090-410c-fdbf-08d7283880ba
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Aug 2019 02:12:23.6788
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: qYer2JhenY1uogzEGadhYxZTzKNEqxfK/pvcI7EReuOQCh0E2na3HARYT7MkOG60zNpHzz3+kLNHCNSLAJ8p5w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1552
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-24_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=878 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908240022
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 21, 2019, at 3:30 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Wed, Aug 21, 2019 at 12:10:08PM +0200, Peter Zijlstra wrote:
>> On Tue, Aug 20, 2019 at 01:23:14PM -0700, Song Liu wrote:
>=20
>>> host-5.2-after # grep "x  pmd" /sys/kernel/debug/page_tables/dump_pid
>>> 0x0000000000600000-0x0000000000e00000           8M USR ro         PSE  =
       x  pmd
>>> 0xffffffff81000000-0xffffffff81e00000          14M     ro         PSE  =
   GLB x  pmd
>>>=20
>>> So after this patch, the 5.2 based kernel has 7 PMDs instead of 1 PMD
>>> in 4.16 kernel.
>>=20
>> This basically gives rise to more questions than it provides answers.
>> You seem to have 'forgotten' to provide the equivalent mappings on the
>> two older kernels. The fact that they're not PMD is evident, but it
>> would be very good to know what is mapped, and what -- if anything --
>> lives in the holes we've (accidentally) created.
>>=20
>> Can you please provide more complete mappings? Basically provide the
>> whole cpu_entry_area mapping.
>=20
> I tried on my local machine and:
>=20
>  cat /debug/page_tables/kernel | awk '/^---/ { p=3D0 } /CPU entry/ { p=3D=
1 } { if (p) print $0 }' > ~/cea-{before,after}.txt
>=20
> resulted in _identical_ files ?!?!
>=20
> Can you share your before and after dumps?

I was really dumb on this. The actual issue this that kprobe on=20
CONFIG_KPROBES_ON_FTRACE splits kernel text PMDs (0xffffffff81000000-).=20

I will dig more into this.=20

Sorry for being silent, somehow I didn't see this email until just now.

Song=

