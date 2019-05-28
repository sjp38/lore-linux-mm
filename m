Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E622C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAAA620B1F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:50:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DXjFe0ve";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VddlbJUR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAAA620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B9546B026C; Tue, 28 May 2019 18:50:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86A0A6B0279; Tue, 28 May 2019 18:50:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 730A26B027C; Tue, 28 May 2019 18:50:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53BB16B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:50:49 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id g1so168505itd.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:50:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=vChAmuht2uWVCormYqL7nE9KjT/v7EEo7uAkLjr/rVc=;
        b=KrI3Db+BAdvg08ij2AHgUoJ4ZA0wC/yvtL4BIq6gs8GpIqfIgt766iHM+3wkxU0+VT
         jNmbYT7Dz5z+BC7NwD+OXp5X2zyiN9Y9rYHDiTra7IKhf0fXM2o7sUEH5W9kp4HiAZnN
         Syb1dTjVAUjpL2TUH+rLmROPWNNIwDbirMa+uL4Ukj0UqTggz8Y/PC9yza+UlqaqKgdm
         /kXM2+nM6FsNvjInKqp+4BCA9XFz3rwLMKPT6SrAKDWk5OwC/0nPoVjtiiV6fFw2Cc7T
         JQtgoH3giD3Zfgudh6iTM8EuoAucTAQ+Avmbl+yceptEy+++CAQew3hHCakSiPqbkG6+
         s43g==
X-Gm-Message-State: APjAAAWrrsahqH8XWTdtqSw2FttCz5RFJ0I8e19UVH5xiTSfXOhlxqpx
	nSBzjwRpNNiGlya0TrjbILtAmMkinbfdLr+Y8NOFy3GDgdCJBTWnVz9bcjDzTGJDR00C9Owo5WE
	ameCMxaMfOJKrPIiF6e0XX7uZtoFwcnTplLcS6/C43RK/TMKep9zaRItpuFdsfq24Lw==
X-Received: by 2002:a05:660c:40c:: with SMTP id c12mr4951885itk.37.1559083849131;
        Tue, 28 May 2019 15:50:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxd5pujQlK0z7tK62Hibn/u8d17B+Gi6f64EHweTC/sPEoaCl2gF9fLQGwj7fbasIignZC
X-Received: by 2002:a05:660c:40c:: with SMTP id c12mr4951863itk.37.1559083848605;
        Tue, 28 May 2019 15:50:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559083848; cv=none;
        d=google.com; s=arc-20160816;
        b=PDti9AydRkcGQ89mtFLNSd9wLwQ2izTUlEMIjxmjaJJ4ZffFGqdlWDgmaqoZ9ereAN
         dwUhB8tX+TG2NuhpQwpK8fvJGMG0HE1j17vHf7fGas9dOW/V+PQPZPROziSVpWRNDHzK
         oE4tlq2T6jyKxQURP7Trt8ugZYaUvAeyenc9qclgPDbti71MH/KbtgOJyb4DszPs9DPm
         TVcsI+RztGepJB8PF48hzEoSXTMkW1ArJlAq7fOaJ97tOkc7oEpTqLFWEP06hgq3bj5C
         LHBO8m5hB9BZ/NNTWx9/T4VSNistM96d3bahJq+EjqnF8y9QkE8uXWFcYtN4VEQF1BFH
         mfHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=vChAmuht2uWVCormYqL7nE9KjT/v7EEo7uAkLjr/rVc=;
        b=Ox8nR991Yl2FsCqdXNAOKgQZGZUdF79r2MrnlYGkVmKHCNmM4crkjyGzKD/8tDwFQs
         9AgUPb3no2jPLfIZiuiYUsy2iFsHn0y2xjMlo5vznKdh45KCe4AZoV2KtV+96ZxkD+C1
         odn1Stm+sIpOlXzGptyTT9QBIDGvbSFZm8nqq4pXr5VPhDrR2267B6EEj2qYNhPM3Uks
         kaB8JdRmeOEtOcYRuZgKeutJiN5kmLKZfF1TmFngcHd1BHi0zFRvTvcrX4y94ThTziSL
         E0sYy5FfIhw9lf5jVvmMCceIBqNEvClBnydI6VHsfDoZSWDoVpFYVvBdWGcQ/VEdhTy2
         7fKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DXjFe0ve;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VddlbJUR;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 69si258331itx.97.2019.05.28.15.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 15:50:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DXjFe0ve;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VddlbJUR;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4SMmQ7j002629;
	Tue, 28 May 2019 15:50:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=vChAmuht2uWVCormYqL7nE9KjT/v7EEo7uAkLjr/rVc=;
 b=DXjFe0ve+CWy2lowjmtebB4ZGZxcn5FyXjmzO1g6X81EDaE4Luyi/ts0zVxmG0/R+RFn
 GDNJpekEf5Rk5jO6fBNdySiIQsXCl8wZkmYzyydC1t0Uxrcb4v4gZ6N5nM3vwoJjOp1r
 O2jwsrq1EWldxS7oCbdn0XoUtfTzx9mU+v0= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2ssaeygtkp-19
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 28 May 2019 15:50:12 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 15:50:10 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 15:50:08 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 28 May 2019 15:50:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vChAmuht2uWVCormYqL7nE9KjT/v7EEo7uAkLjr/rVc=;
 b=VddlbJUR1Enmmyy1rDxLLJpf7b8d87Y7F9S3kQBpP+ozQcj6OGV0QJmCcuIFjYFu4mZda+M+578ratEd5TKJOgyawR/xIH9OZghw+BPwk3WZHSe2xQnEyZM++q9FRs54t9seQWYw7x0W3+Pw+vgd4N374eXrrJ5oFcQdgXwehGE=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2743.namprd15.prod.outlook.com (20.179.157.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.18; Tue, 28 May 2019 22:50:05 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Tue, 28 May 2019
 22:50:05 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Hillf Danton <hdanton@sina.com>, Michal Hocko
	<mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        LKML
	<linux-kernel@vger.kernel.org>,
        Thomas Garnier <thgarnie@google.com>,
        Oleksiy
 Avramchenko <oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt
	<rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner
	<tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Thread-Topic: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Thread-Index: AQHVFHAFBgyZ0nJ640yaup+zuj/dD6aBJn2A
Date: Tue, 28 May 2019 22:50:05 +0000
Message-ID: <20190528225001.GI27847@tower.DHCP.thefacebook.com>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-5-urezki@gmail.com>
In-Reply-To: <20190527093842.10701-5-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1301CA0026.namprd13.prod.outlook.com
 (2603:10b6:301:29::39) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:3dca]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6698c9f2-8457-412c-afbe-08d6e3bed3ac
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2743;
x-ms-traffictypediagnostic: BYAPR15MB2743:
x-microsoft-antispam-prvs: <BYAPR15MB2743543F10F6F0D2819A17E8BE1E0@BYAPR15MB2743.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 00514A2FE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(346002)(396003)(39860400002)(199004)(189003)(66556008)(66946007)(64756008)(66476007)(66446008)(1411001)(2906002)(6436002)(73956011)(71190400001)(4744005)(6512007)(71200400001)(6116002)(9686003)(305945005)(7736002)(256004)(1076003)(6486002)(186003)(316002)(446003)(11346002)(5660300002)(476003)(46003)(33656002)(486006)(386003)(68736007)(14454004)(102836004)(7416002)(6506007)(478600001)(86362001)(4326008)(6246003)(52116002)(54906003)(76176011)(99286004)(229853002)(8936002)(81166006)(8676002)(81156014)(6916009)(25786009)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2743;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +02sCcCENlEvdwcMEl2vUahcwTdDIf0yZqv9CJRbaO7pV7cBp1G77+59/7o9dM/9IuSyS46eHUCQljtGklFFxfjs8TdfFhWJfuk6nCLsyHbwJIBG77oGJyLjBLbdQHAP7eySITq7CRW2GFsLtFd559ZbsczI0gudVYY0b2v61MrsqtEM5SSpLV+cq25hzgZkngsEmwZpgojsiQ2oEIViiUhO7bOhtZvhs+DJuO/2coulJtHGHTWlWBeBoBKLJMUjj7fESJ5vBAThxFEU4eKMTQotTLCFFc2N8qjq0SRmi7nzLvtSKcK0H0zxwZdkkuFjzNO0Skq4lxTDBP6DbdemQwKDwiRrVsXP7XOWPQ7SM261l5sQ8nZK1E9cHO9atLP/MwDT6nWN8HT5IFbKZh8NfWY4RCO6xJPR1vWbvEJM2Ek=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <065DF65F3017CB419EB6F1BFF7AFC9C9@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 6698c9f2-8457-412c-afbe-08d6e3bed3ac
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 May 2019 22:50:05.6683
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2743
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280143
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 11:38:42AM +0200, Uladzislau Rezki (Sony) wrote:
> Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> function, it means if an empty node gets freed it is a BUG
> thus is considered as faulty behaviour.

It's not exactly clear from the description, why it's better.

Also, do we really need a BUG_ON() in either place?

Isn't something like this better?

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..2df0e86d6aff 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1118,7 +1118,8 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
=20
 static void __free_vmap_area(struct vmap_area *va)
 {
-       BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+       if (WARN_ON_ONCE(RB_EMPTY_NODE(&va->rb_node)))
+               return;
=20
        /*
         * Remove from the busy tree/list.

Thanks!

