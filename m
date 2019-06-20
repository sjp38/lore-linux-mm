Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 549F7C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F130D2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:10:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="k6jC37G/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="uK2hfiaR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F130D2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 868026B0003; Wed, 19 Jun 2019 22:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F0DB8E0002; Wed, 19 Jun 2019 22:10:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 669F28E0001; Wed, 19 Jun 2019 22:10:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 469FF6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:10:21 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id u25so2191637iol.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:10:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=WfT4AiiZAGMg3kfOOpZ1NSyUsAK4OwJlhkb3By7Uzlk=;
        b=ggJTjIZsIZLtM+DGjYq/d0tFAx4S3YBrpwuJELrgRcQf9Vw8YdlK1FAUrAUErvNci+
         RqkcfpxOe1I8id5w/oK/DTPX3BO3Xc+NaftwN1MNd+20WkOKHkX9RbYUWvhOyQmy/Gpw
         n8A1/krdDjdbvuzcaGIrj44Brj86QxcRLeesidwZyDNSBhp542DfLb/iLOJCEkKx3BGT
         MN2cgVuosHR3KcwckbmzMs9UwQMYz76ivgwKOHVgUvs+OKW+CePqPcSFP6XMq5OMGeeN
         8z3ENmeARrAip5UnMkyUPxXjUuFvIdsqGRMEof0saK73oQ+i/80PfEeJ4kn1w3aJJPok
         1ZDA==
X-Gm-Message-State: APjAAAUDDyh8e7W8nqHDkx0YNuBNyNc+uGvRamZbZqfljt5xzFOq5rxo
	fjaDmUuZcZwnHssqYDaTyvuG3JjLNqLbe9Y4mVuGtP86DN0ude8S8AxwW5cENLw70M7ke6py1sU
	Eb0MECtnyDiKxd2nu1A25bB3UO9hwIMsDxCqKO2rmY4/gLfkenBGk/tptVJPL2zY0YA==
X-Received: by 2002:a02:b016:: with SMTP id p22mr52275439jah.121.1560996621009;
        Wed, 19 Jun 2019 19:10:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRPvxzTrlvjm1aua0pJWzrbqQ6tU1K63z+Lcf72IFSx8qho8gejTzWBCy8jWEZ0hc3mfwo
X-Received: by 2002:a02:b016:: with SMTP id p22mr52275405jah.121.1560996620476;
        Wed, 19 Jun 2019 19:10:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560996620; cv=none;
        d=google.com; s=arc-20160816;
        b=NDDVJBNR+kSkp1ppHx+MfFwlFliMiKPrCHfhrQ30bqAOQvPbTeu2ASvvDrayoLJdvi
         BiUCBnmRYSoH3iAYAMsPefS4WbZNpHXDkkyJXkmjSwAEFpsCVpDfO5jb07VCAIBAaDaa
         0xK0E4z9ixbj3W/7GkH5AHvOF6riPL7ieoIFtaPiJlFQR10O2rYv0N31dgQn28VQ5+hm
         QdTnCzEFwHc6YpJx33G0VXZtJlyBjwkr653+OgnvrDl/0Wpk7YLBFdLodXhrk0co0OGD
         I9ha1PLtxgsGjN5sa9+pduTpWC4PLA8saR8FXiy1EYoO6T2cqAmdL9qaUanjp+m3Jy8s
         fJTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=WfT4AiiZAGMg3kfOOpZ1NSyUsAK4OwJlhkb3By7Uzlk=;
        b=QtNreqekbl1myglaOb4/G2KH6IM7DeWnpBnqmo6ImUtwaGSkDh6FihOzG9OZFSfxic
         acq5XGnlSbKmDxy15/LtWBfw7hGoxYGxQUq25gPghIlc1R2rDPtbSAOYNEECtCAwTaqU
         hWF8H6nzYO+31JHROGsW0XPdYOWt6GjgpyiI0nUKOqWtPSc5uTGy5sfh+AvDF31DEQUA
         Ui4F9g15BnC8BObFIU/sGOpjkBKwLoq3Pt3oo+4eAsabAA0kOwlL5eQGqXIxFCVnQGAj
         pU1HzDrIcX5tQ1VZyRvqQTJorT3qhmTPAgcQH1V7J+OHc3QhgzMMJX5vLG4yzER5XynN
         75hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="k6jC37G/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=uK2hfiaR;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i142si27866633ioa.23.2019.06.19.19.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:10:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="k6jC37G/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=uK2hfiaR;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K27VDm028938;
	Wed, 19 Jun 2019 19:10:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=WfT4AiiZAGMg3kfOOpZ1NSyUsAK4OwJlhkb3By7Uzlk=;
 b=k6jC37G/ScbuWNWaPbtWtLmi0BMs9+/OFB30ebD+RtbKpMjn9XCSOBVGue72igZlX0WX
 sI/K9f8y8SqhHLvnj47UxCJ8x9Rm9EzE13EvlFewNz9ENkTTTl4VPwMAQJq1akYxVVEq
 9FqV7eDzYUO4Wj+wWhRFWyxIrlNFv6Ehnd0= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7wwcgkms-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 19 Jun 2019 19:10:18 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 19 Jun 2019 19:10:18 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 19 Jun 2019 19:10:17 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 19:10:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WfT4AiiZAGMg3kfOOpZ1NSyUsAK4OwJlhkb3By7Uzlk=;
 b=uK2hfiaRkfOP+Vq0HvHe9Q+if2iC18hgEBQjlA20jlGCLvVyG3ohuojvkiQQz1S67CIu2RtqezlVgH79yrE7f5LOBLexPgayJWIcuxteICRusYfhgYjVvAh7nPha87dxsqBqoRuCLoGoVQmxw8/qGKBMoMpT4ZMxlIEurzl6VMc=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1550.namprd15.prod.outlook.com (10.173.229.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 20 Jun 2019 02:10:16 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 02:10:16 +0000
From: Song Liu <songliubraving@fb.com>
To: Rik van Riel <riel@fb.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Topic: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Index: AQHVJmezv99wdCcaVEmWmrPzjMSHT6ajxTGAgAAImQA=
Date: Thu, 20 Jun 2019 02:10:16 +0000
Message-ID: <B051CE4A-063B-4464-8193-93C9F1D0A0A7@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
 <20190619062424.3486524-7-songliubraving@fb.com>
 <9ec5787861152deb1c6c6365b593343b3aef18d4.camel@fb.com>
In-Reply-To: <9ec5787861152deb1c6c6365b593343b3aef18d4.camel@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:8b5f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 12789224-1134-45c0-68d5-08d6f5247013
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1550;
x-ms-traffictypediagnostic: MWHPR15MB1550:
x-microsoft-antispam-prvs: <MWHPR15MB1550D22D519639E918C18C9CB3E40@MWHPR15MB1550.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4941;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(39860400002)(396003)(376002)(346002)(199004)(189003)(25786009)(81166006)(446003)(2906002)(8676002)(6436002)(57306001)(99286004)(73956011)(71200400001)(66946007)(186003)(71190400001)(81156014)(66476007)(46003)(50226002)(476003)(68736007)(486006)(53546011)(102836004)(6506007)(6116002)(64756008)(36756003)(76116006)(66556008)(8936002)(66446008)(33656002)(2616005)(7736002)(86362001)(305945005)(6862004)(11346002)(76176011)(6246003)(54906003)(14454004)(37006003)(6486002)(316002)(256004)(229853002)(5660300002)(4326008)(53936002)(6512007)(6636002)(478600001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1550;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XLQiSRxhTCp40AIx97UFdKPZobMSLm8eX+rwpwxecTCTNIgTt1/yVzs7V9b2VbDGpySnvKBWfHMVkmf+E6JjwGgaGkDFoCQkO5ZkIfzLlUbMToht5LDv+CzYNv6AWhwWozQAiS1mtd/jbwyx+KI+gw/3Rda6FzAWG97XSrdoLmBq9ShOlGCGVoihrBczehn2CIhjY+GYNHYtqL8IY/QwMTomJ2IGIhF1/rVMvQ+kjSecgjmOjrEmeIRkw2/gITzPW+YMM1kEZENOVO5MWrioQS1PDtIYVvaoTbj9eCWeWEpfzT2o7YenHbVfX5bo6yPHyoGm0fPdPwFAgxFzZ0FOmjzQLsoVMbzmQbRbCpWufOzzCp3Da6NlspkRSe4Y0Z4UAKQdRmDCzu04dhQM+ewTQM4XFbQKVUdOYN3GQKDGqzk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <318691919763C544863EFDAA3EBCA34C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 12789224-1134-45c0-68d5-08d6f5247013
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 02:10:16.6270
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1550
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=736 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200015
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 19, 2019, at 6:39 PM, Rik van Riel <riel@fb.com> wrote:
>=20
> On Tue, 2019-06-18 at 23:24 -0700, Song Liu wrote:
>=20
>> index 8563339041f6..bab8d9eef46c 100644
>> --- a/mm/truncate.c
>> +++ b/mm/truncate.c
>> @@ -790,7 +790,11 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
>> void truncate_pagecache(struct inode *inode, loff_t newsize)
>> {
>> 	struct address_space *mapping =3D inode->i_mapping;
>> -	loff_t holebegin =3D round_up(newsize, PAGE_SIZE);
>> +	loff_t holebegin;
>> +
>> +	/* if non-shmem file has thp, truncate the whole file */
>> +	if (filemap_nr_thps(mapping))
>> +		newsize =3D 0;
>>=20
>=20
> I don't get it. Sometimes truncate is used to
> increase the size of a file, or to change it
> to a non-zero size.
>=20
> Won't forcing the newsize to zero break applications,
> when the file is truncated to a different size than
> they expect?

This is not truncate the file. It only drops page cache.=20
truncate_setsize() will still set correct size. I don't=20
think this breaks anything.=20

We can probably make it smarter and only drop the clean
huge pages (dirty page should not exist).=20

Thanks,
Song


