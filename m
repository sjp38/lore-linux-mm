Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A792EC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:26:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40B1120B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:26:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kEaZW2VH";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="l8zUcjfq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40B1120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E757E8E0007; Wed, 19 Jun 2019 02:26:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E26148E0003; Wed, 19 Jun 2019 02:26:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC78A8E0007; Wed, 19 Jun 2019 02:26:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA9F98E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:26:34 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v135so2876900vke.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:26:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=yAd7lMxKqHjnetM9sfHugLOCM1spohnRZMY1b1CM1mc=;
        b=aNg+IESRUxVV+9GN92POv8lluehWgizoijKXFHXuiuOIuAPusZEcKum4mVMzV1yGxF
         2zc/HA8hPAfDKRhrALEpAXr4u9bP1CxXmxU8/96ThWmaxpGaGj57kPhG97aYGEXIxs4t
         TjTjfAmPDUiILYQJqBGnwib6dEf0w7z2e/D/YI9TF/TD9xfXAIddDXuCgWIobTxtkFu7
         OENIFfNcfyA6e2aJT295u3MbUjewilA8BwV1sMGuCS3KSf30R6gucWOL5jO0Jo766Y5K
         N+5HWtwg4x3gehwBXfPd7fBFKwjoGsXFJemdfPDWfTpmNnLt8KUFCpR6ncPujF47aofP
         fOXw==
X-Gm-Message-State: APjAAAXcFwuHzcrH1Aae1le1hPF5PsO7w2RnP7FmHMAumMa3/XPA//GM
	6NKXqSmqjRPCZtBWRS7iJkzKrUD6mqDtWBkkVoojf220m6H1Z3nUddziBxuW5htHz6ttx+SlJBK
	alSLVXifwWkGv8wnblJBRJcY6QSkyKjtDotI0hRlpnVBIXcWN565BR9ncv5glelVjbQ==
X-Received: by 2002:a67:f518:: with SMTP id u24mr49642169vsn.87.1560925594272;
        Tue, 18 Jun 2019 23:26:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa3oDre18lR7sql0m6/QKDZfJbAwrR77yKB3h7JpbhRW+pS7lCgRTVZQ/09kQLGUBWAGkY
X-Received: by 2002:a67:f518:: with SMTP id u24mr49642157vsn.87.1560925593706;
        Tue, 18 Jun 2019 23:26:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925593; cv=none;
        d=google.com; s=arc-20160816;
        b=mDE59Idkwg/4EaM9H+B2Jau5cFmYMeXuVsn1PbJLIpacp8FWfdQofkMCT2nksTaJjp
         lm09E7Mhkuw07Mq00FIoUmcz0i/QFN0CMutako734ykoBgtYaXsQnE0IWYECAIzJyL6v
         f5BP088EfScYPWmiGRdo6QwMFZVO6sKTJDL4Bx+FDpZ6RdBf7eI1a0aN7mi3hLLdKNcq
         2eyNx0Bp/8Lh1r86RRyQRH1jZ/LKzNRrRjYITSaZleCS2M26XmujvtJfB8JvXauBAcKb
         MaO7ifXWMyex7ts2BeGBpTFBDrvSLbXZxUZUKEjse+fyMQtcAndBaoLNom+9/BhlmJMx
         ItNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=yAd7lMxKqHjnetM9sfHugLOCM1spohnRZMY1b1CM1mc=;
        b=Z0WG3+z5zUsNeyVL690UkxuRGBCzj+BdxK2WTF4SQikpDBOFM+TtdmHCWd4To6R9Uw
         6vNvlwB8TccE9yDcNkT+AQAMRP+8f0aiarHuPthP6kCGQ7wOELcojObd5fqPtHrZtAG9
         dV5HHexG7zD+7vVcBjjNX6KqfPnliY9HPQFc3ZRbxaXNGG/2PUsDgWk5hktnR2iMvZtb
         PIxXdjzK21mzG0K7HDzXMkkiT6XzdQxTb2yEVDtkpIIrRLS/mkO0+T+oE28rBfBQ8rFR
         2pVL9BRodSybSvgG/plH197cBUGv6OSBmPotl3OCTfDKi07vIIutIh1sF6XlRGnYR9xh
         mbtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kEaZW2VH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=l8zUcjfq;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 33si3358594uaz.32.2019.06.18.23.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:26:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kEaZW2VH;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=l8zUcjfq;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5J6O17n011333;
	Tue, 18 Jun 2019 23:26:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yAd7lMxKqHjnetM9sfHugLOCM1spohnRZMY1b1CM1mc=;
 b=kEaZW2VHQjUB7uKeRssY2m4CaubuN2fHgbfwPwv9JKu9qTpx73G0AyTxB4pU6WX22G62
 sPx4TVgu+QSe/Ukl23JuJyOg2vmW4gtDHefOoogj51cURj87JOCI0x9xY1AApaQCis9P
 sXJzGtoPWwFpoTXHfu34Sw/tc2EiLLH1T5A= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2t77yyhbt7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 18 Jun 2019 23:26:32 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:26:32 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:26:19 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 18 Jun 2019 23:26:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yAd7lMxKqHjnetM9sfHugLOCM1spohnRZMY1b1CM1mc=;
 b=l8zUcjfq+A8PBHQ5dTspqCyy1YiL0C6eG1CvkpyR9nwAJEc8IEXCft1H08AhKoAOCb2hRZIlcssHd6JgcM+NQR1B3TSLiFf4hfq1TXkbV8ycgk1XWSxs4SraUmD1X0I5jnEGvDX/QdD1cfxa2BBPe1tnw2kpEnX618q7UVcdqkw=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1629.namprd15.prod.outlook.com (10.175.141.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Wed, 19 Jun 2019 06:26:18 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 06:26:18 +0000
From: Song Liu <songliubraving@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Linux-MM <linux-mm@kvack.org>, Matthew Wilcox <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com"
	<chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Thread-Topic: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Thread-Index: AQHVIt4f2F2VuI2II0W4i6vGZDY11qah706AgACawQA=
Date: Wed, 19 Jun 2019 06:26:17 +0000
Message-ID: <262442AD-F121-4A48-A3A6-6630046D7E2C@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
In-Reply-To: <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:8b5f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 05a9f2aa-b74b-4f7f-79fb-08d6f47f09af
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1629;
x-ms-traffictypediagnostic: MWHPR15MB1629:
x-microsoft-antispam-prvs: <MWHPR15MB162962BE8DDFF9151E35379DB3E50@MWHPR15MB1629.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39860400002)(396003)(346002)(376002)(366004)(199004)(189003)(305945005)(71190400001)(14454004)(8936002)(6436002)(53936002)(76176011)(478600001)(6116002)(6486002)(50226002)(99286004)(229853002)(256004)(71200400001)(6506007)(476003)(36756003)(25786009)(486006)(2906002)(53546011)(11346002)(446003)(54906003)(66946007)(7736002)(73956011)(64756008)(186003)(68736007)(14444005)(5660300002)(2616005)(102836004)(8676002)(81156014)(81166006)(4326008)(66446008)(66556008)(66476007)(76116006)(6246003)(33656002)(316002)(6916009)(57306001)(46003)(86362001)(6512007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1629;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Q4WTPV930ZG7cMjDwXTiguaWfNaVGkOBsATfMToLSrREnc9pFB4QbeSCVpTMaVRmZK6BccZ87MfmR89DvoGYzQQAfXA3qIrmd0dxneAWeIJY0OD19Qrl6MF7EJTWVg6IwGz091Vf3OxXnDvS1go9a5HsXLnTBwp87EP9Ok+D6/vftjrX6JFMy3g+JmN7Fl4Qhv5cASCQ3QOZGgnKD1M0goNHKyKlECDo7s/kY6eJWO584Q+X1VI2OvH6HK5fHr/ij5mmD3WuVvL4tM09YgSICm0Ko30Mdou99/2c1Qfw0H86Ai7DZTvTRVSwwRAWNeY4NFYkEVfgpeDTzL2TVEww0fsw3ZPDzDQu9k1V0mYyMXRIbMFvNqpYn5cPgrxxQTCbHlPguuHKb90QO6yytfsXNK/OUZRh2S3WSMWkP4jBoZo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1A3DC50AB9F7A2419DBEEC68975DCCAB@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 05a9f2aa-b74b-4f7f-79fb-08d6f47f09af
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 06:26:17.7550
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1629
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 18, 2019, at 2:12 PM, Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>=20
> On Fri, 14 Jun 2019 11:22:01 -0700 Song Liu <songliubraving@fb.com> wrote=
:
>=20
>> This set follows up discussion at LSF/MM 2019. The motivation is to put
>> text section of an application in THP, and thus reduces iTLB miss rate a=
nd
>> improves performance. Both Facebook and Oracle showed strong interests t=
o
>> this feature.
>>=20
>> To make reviews easier, this set aims a mininal valid product. Current
>> version of the work does not have any changes to file system specific
>> code. This comes with some limitations (discussed later).
>>=20
>> This set enables an application to "hugify" its text section by simply
>> running something like:
>>=20
>>          madvise(0x600000, 0x80000, MADV_HUGEPAGE);
>>=20
>> Before this call, the /proc/<pid>/maps looks like:
>>=20
>>    00400000-074d0000 r-xp 00000000 00:27 2006927     app
>>=20
>> After this call, part of the text section is split out and mapped to THP=
:
>>=20
>>    00400000-00425000 r-xp 00000000 00:27 2006927     app
>>    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
>>    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app
>>=20
>> Limitations:
>>=20
>> 1. This only works for text section (vma with VM_DENYWRITE).
>> 2. Once the application put its own pages in THP, the file is read only.
>>   open(file, O_WRITE) will fail with -ETXTBSY. To modify/update the file=
,
>>   it must be removed first.
>=20
> Removed?  Even if the original mmap/madvise has gone away?  hm.
>=20
> I'm wondering if this limitation can be abused in some fashion: mmap a
> file to which you have read permissions, run madvise(MADV_HUGEPAGE) and
> thus prevent the file's owner from being able to modify the file?  Or
> something like that.  What are the issues and protections here?
>=20

I found a better solution to this limitation. Please refer to changes
in v3 (especially 6/6).=20

Thanks,
Song=

