Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A44AC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:01:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8872208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="iBz59Dtm";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Q2Qw/OEf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8872208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ECD38E0006; Mon, 24 Jun 2019 10:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59C798E0002; Mon, 24 Jun 2019 10:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 464E38E0006; Mon, 24 Jun 2019 10:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23DBD8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:01:47 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id p64so6414175vkp.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:01:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=l42/hh6dsvPxxVCT5jkmxUTzJlp8YhLKOjGK7XP7s+I=;
        b=ldmJIwsEPxD9sQQOnOz++A24Vm0QElh76jrPvleRXlq/faI6JBjGicxvogB3L/gV+U
         Xe7wE035uATf3ghppjycohm3NRRK/jOnP9zd74M5K9ox30itJL0ft+D0A/4CpQb0eZOK
         d6y7opKxPX4lOuKr4NLhznSJVzZ/7GCfNSS4Q2ABvY1P/yjLWxZGrkA6z9nRU0JaSjaT
         kpytM33X5PpM72eo42iOmS66siCuyMUSfwRWRkjvsg/kqLnLZPl6kwvWeCSio14d9s7J
         57H7zSVzFRgX/tlGnM4FDyRzO8YRzezNAykl0fEokp78I8UAgy+2GKdDBuAYrftjendD
         yoHw==
X-Gm-Message-State: APjAAAVun2oKqm1ghtJRIzQootF9Rv8pXJdw5QS2czKmC6pWC1RDsUks
	35bJgrgX4RQ1PlGIWqWlIBMr/JuXELYUvCQHSKGDdhMZgXE7XBfhE00kVjikQ/I+4QEhKBHV1EG
	xkZHbmN96a67+XVteqr5MuOebwOkBgHdJi57k+upbyWRSv/x34Y71emi4Lw5Ysns2RQ==
X-Received: by 2002:a9f:326e:: with SMTP id y43mr23088253uad.4.1561384906763;
        Mon, 24 Jun 2019 07:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwod2DJmQmTAEPr9y8QBkG/9BJpcyPPlAHFHJU7yyVuNovalvZtbBhziyVvv+pt/qnGIgSr
X-Received: by 2002:a9f:326e:: with SMTP id y43mr23088197uad.4.1561384905870;
        Mon, 24 Jun 2019 07:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561384905; cv=none;
        d=google.com; s=arc-20160816;
        b=bYT6FXERsJSEBsKEWPEV+XBvlgB9evvBivEPosdDKhaitYPWUzPSwGh1JtPwCEtQHZ
         OgKZE0Uf11WzmlausHC/z8zQCtoEl2OB8Y95bzteCHPGh4Lrxfxidxye27HmGKoYLjQe
         1QNWxuqGonM6Nzw8U4Qu13WJep1pXw7WhvunGyabGMlU+B7SIuwoCLgXdJvgu340N5Do
         RFMHNSeXMDiXiW8emv2e8crvWfqhosBXXWWAGRRd/pIoJuO8IRCqa3+UBs+F3Zo+qrzl
         33mTIWd8tKJC3ch9IKygYxTBaDx79pM8T79f0JEifdGm6rVwi4sXgfFt1r0HPVjaXBge
         OuLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=l42/hh6dsvPxxVCT5jkmxUTzJlp8YhLKOjGK7XP7s+I=;
        b=LPAf7GXj9gJC5qG73KdaryLfZdmRJWRGtz7RlJMfMaFQ1Y+ibSgB31LhsDNwb5zKYV
         qCIphhPOFWU0OPvTrnUGerLjkFDSNJVIFznFEw71gzCsDRtTM5ssqPlvMfP4M0nIE2lh
         L+OlrxBwfXAQvQLyrE/Pp9//AHg/oBhjMt3uQMN7JxPHh6Ss5osN7AtYDNClkOorWp3w
         xj719+2chRMb4PHzIl2mF3AVB/ivj8gRRFp5o4qyx0KPy7uVK+fOtEoGMgmEYJ+Doj8f
         Fh5RwnYDfr7u9EniDFneNG6j2qEsELd2BNkWHfrDAXJ013lmKnnSNjMe14wgSJ4/4l9w
         sveg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=iBz59Dtm;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="Q2Qw/OEf";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l17si1990863vsp.155.2019.06.24.07.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=iBz59Dtm;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="Q2Qw/OEf";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5ODwvEn011621;
	Mon, 24 Jun 2019 07:01:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=l42/hh6dsvPxxVCT5jkmxUTzJlp8YhLKOjGK7XP7s+I=;
 b=iBz59DtmDg+GVP1sXQXK6nJxVxG9spKS2Cka0aA1VvnaC1lTIp1L9VEFRK6Q96XSXc1Z
 5Qb5IZeHbbUKETYOpO1f0ZZO7Jt9T/qrb1Nm9FMDFugc73Dd7vGR742XrpQROMvRpRpY
 bhKM++HQN9ekk4ydLT8w7Fl5nGlLw+EcrC8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tawbt8gf8-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 24 Jun 2019 07:01:44 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 07:01:35 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 24 Jun 2019 07:01:35 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=l42/hh6dsvPxxVCT5jkmxUTzJlp8YhLKOjGK7XP7s+I=;
 b=Q2Qw/OEfrX75XTlWIuzLzxlw6xQA7FBHT8aF5O3gS/JwMSON92kI263CbhajKvYBk/yDOwbHEYbC6Xgm+hJH5expvBozDscTbfXgN3kv9Apmjai+UYWlCMvMEe322s0QBX3oox0Ds729zQ9cfR9/H58uqi/+9lq7O9lNn44BuxM=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1853.namprd15.prod.outlook.com (10.174.255.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Mon, 24 Jun 2019 14:01:34 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 14:01:34 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "hdanton@sina.com"
	<hdanton@sina.com>
Subject: Re: [PATCH v7 6/6] mm,thp: avoid writes to file with THP in pagecache
Thread-Topic: [PATCH v7 6/6] mm,thp: avoid writes to file with THP in
 pagecache
Thread-Index: AQHVKYdFkYGF24iU+UCtXh4EHn17Bqaqw38AgAAUGQA=
Date: Mon, 24 Jun 2019 14:01:34 +0000
Message-ID: <623599AD-71C3-49B9-83A0-F1B8771E0EAE@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-7-songliubraving@fb.com>
 <20190624124936.2vq55jc3qstxrujj@box>
In-Reply-To: <20190624124936.2vq55jc3qstxrujj@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:d642]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 36fc0874-3b87-4c0e-bf08-08d6f8ac77a2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1853;
x-ms-traffictypediagnostic: MWHPR15MB1853:
x-microsoft-antispam-prvs: <MWHPR15MB18535C06A44E7DFD0D99A71DB3E00@MWHPR15MB1853.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(39860400002)(396003)(346002)(136003)(199004)(189003)(6512007)(53546011)(6506007)(2906002)(50226002)(316002)(102836004)(76176011)(99286004)(54906003)(7736002)(68736007)(478600001)(71190400001)(71200400001)(76116006)(81166006)(6436002)(66556008)(66476007)(305945005)(66446008)(66946007)(4326008)(86362001)(25786009)(5660300002)(8676002)(6916009)(6116002)(81156014)(8936002)(14454004)(33656002)(73956011)(57306001)(486006)(64756008)(256004)(186003)(11346002)(46003)(446003)(2616005)(476003)(229853002)(36756003)(6486002)(53936002)(6246003)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1853;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Fm8g1k6RipUQo/vdaJxmjK8QPmVnKx4NCqZq8BjHjcSgsrgBlvzMvxZMDIEOd/0UlC7kOpxRb+2oBsIgCIikS+PtcY2lBCwnRnn/4RcGtgsrDhh2U0aiKjzyf/5pz5P+7Kv5p2LN7Qky31LkElOvZVoqKYfhBxVnkZflV3x1S4GOJ9UwMhL8Kb0ulkM1oRG/i+hyQPuF8/FCIAjA4XDFs34bB5uOLvAa0jN0k0kR7jMdYSg3pROpbuWhnTupqv/wJJQKSwkA0sX8wXZH/VpmFBxEmi5Eg3Yp0iP3t5OlbaR4AyotrSuQyN5eFnkDKw3n3I0UfV5ISF22gd/0LMRd2x/YRGhPVEmLvr3Y+i+ixAy4UpN+zfsYijktHQq0KFLsLtDHqTspx5W2YeKgvSLTYwrW/la/GLIKhHT8BbDDbs8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A8E94E97BC547842BF5B5B4D416E0474@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 36fc0874-3b87-4c0e-bf08-08d6f8ac77a2
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 14:01:34.3180
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1853
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=828 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240115
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 24, 2019, at 5:49 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Sat, Jun 22, 2019 at 10:47:49PM -0700, Song Liu wrote:
>> In previous patch, an application could put part of its text section in
>> THP via madvise(). These THPs will be protected from writes when the
>> application is still running (TXTBSY). However, after the application
>> exits, the file is available for writes.
>>=20
>> This patch avoids writes to file THP by dropping page cache for the file
>> when the file is open for write. A new counter nr_thps is added to struc=
t
>> address_space. In do_last(), if the file is open for write and nr_thps
>> is non-zero, we drop page cache for the whole file.
>>=20
>> Reported-by: kbuild test robot <lkp@intel.com>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> fs/inode.c         |  3 +++
>> fs/namei.c         | 22 +++++++++++++++++++++-
>> include/linux/fs.h | 32 ++++++++++++++++++++++++++++++++
>> mm/filemap.c       |  1 +
>> mm/khugepaged.c    |  4 +++-
>> 5 files changed, 60 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/inode.c b/fs/inode.c
>> index df6542ec3b88..518113a4e219 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -181,6 +181,9 @@ int inode_init_always(struct super_block *sb, struct=
 inode *inode)
>> 	mapping->flags =3D 0;
>> 	mapping->wb_err =3D 0;
>> 	atomic_set(&mapping->i_mmap_writable, 0);
>> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS
>> +	atomic_set(&mapping->nr_thps, 0);
>> +#endif
>> 	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
>> 	mapping->private_data =3D NULL;
>> 	mapping->writeback_index =3D 0;
>> diff --git a/fs/namei.c b/fs/namei.c
>> index 20831c2fbb34..de64f24b58e9 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -3249,6 +3249,22 @@ static int lookup_open(struct nameidata *nd, stru=
ct path *path,
>> 	return error;
>> }
>>=20
>> +/*
>> + * The file is open for write, so it is not mmapped with VM_DENYWRITE. =
If
>> + * it still has THP in page cache, drop the whole file from pagecache
>> + * before processing writes. This helps us avoid handling write back of
>> + * THP for now.
>> + */
>> +static inline void release_file_thp(struct file *file)
>> +{
>> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS
>=20
> Please, use IS_ENABLED() where it is possible.
>=20
I will fix them all.=20

Thanks,
Song

