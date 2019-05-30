Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85512C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AB8F25E40
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:19:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dPPRkci1";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Qupa5ciZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB8F25E40
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B52E76B000D; Thu, 30 May 2019 13:19:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B03876B000E; Thu, 30 May 2019 13:19:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F1B96B026E; Thu, 30 May 2019 13:19:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8064F6B000D
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:19:23 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v15so5168214ybe.13
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:19:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=3T6nroDY3DinVVOxA+4sYA7U+RaGiCglnLDagGHPffg=;
        b=RNWz3tlWQxYP6iqUlyGSfaLArJFXuGnDl0HYfvX8FRXn6qozMZpX++dSUogT8uYee/
         g20aINCe8QY09Ea/dYAVq9Wz8m1EIAQOt51czL+bhGYPhOT5WNXdULCnIhUb4CmFETl/
         BDq8me4O8qzsjxs6JUDR8ftWdaBwpHFFswp9G3x3cenNhwYgCPrpF65dwQib0Fonf2QE
         0oe6m3wgSLvoC1xBRO7SHGeC2bTZ1mftz17MFyaCiuCq/dtMu+ml1vBXpsUqlaYSh0dX
         8ai5R3Df8rn7JQMhmW4VW6glB7Z/4wgFF4hQN5RAdLpMKNCS/rdui56JFhnY7DhUzoqo
         TrEg==
X-Gm-Message-State: APjAAAXWlLtvMDIJ45qymx44FDPrFXG6/HaKw0kuEcsNo9ksAFfhhZ/m
	3R4vYh3qznyYil7W/Ke9rK9uOIbGNlDzihmQB4tEhWWpG5mIK3dZOIurtA8M5NQCALjrV40OnFj
	EQaBjqrv5+nXGhOKZU8zd42Jh/W6GxrPow+mAQimdwTSS2JiYtxIZnX/p17h5QsjzsQ==
X-Received: by 2002:a81:9855:: with SMTP id p82mr2845211ywg.498.1559236763152;
        Thu, 30 May 2019 10:19:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkb+Ro8mKtU2ZAlxVLOwf3ZSvX1jUz+XRsU9hzY6IOVfTl60AtgT5ScWfoNimWDBplBGvo
X-Received: by 2002:a81:9855:: with SMTP id p82mr2845186ywg.498.1559236762524;
        Thu, 30 May 2019 10:19:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559236762; cv=none;
        d=google.com; s=arc-20160816;
        b=h4+V95r/j7a/tTfSoEX+oZGe4YaH7Ri8J5R9DJ5pehrhTEROCzTtesjLr10EMJZBoq
         qzY1KQN10VoQsEeMXsgoKbXTSEDsQrj/9BCsB8mZL6jFhTK88eWGQ90C5ISmyWjLZYvn
         0GDGVrqsqteV6XlO9fGKrqdIOTw47SfGvulmgU9oU8p7JWzEHnQpVuYrrjHQaRjE8znA
         Eb8xbnsqzKhU5AuuIIvpMnwTfSCqLEyYC9I7AAC02KMNXnK22CeiWaOAUAwwOLtoAsSg
         fVQcXMcPYV0kayQ2R71teHTU3FBg9Lvt3gVciAND/RLgVWci7bDqbyTh5rHT8BBy7LlZ
         BJYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=3T6nroDY3DinVVOxA+4sYA7U+RaGiCglnLDagGHPffg=;
        b=KjP2joAvIroKjLV7QN2969uKXVTzAZ5cp5F3wKSN4x11Kgu76XvAajGY9+bwbywBuD
         SG6QEcqJftOvm/vT/UxZl8LRFTWaZM734O7QSL0uZ1kw+oowJ+KfBKeDGmACwyVARdsM
         PIOmgUz3+iI0LcbDLtJvPfPrY90PDhGcw0S18307c4ccsaoSPQs7DwLFFQQqApi/Ui2C
         ojGIMlaUGm4FYZ/ekK/f5t2FI0rHr1Y5zUfDfnbvsgR2LC/hzuRyRRASUBkx82QyFrqW
         vOWVRykj2C0C0kPTTmxdR6RgqIqSmKsurOfth7Juu+QS81nbTLs/62kvDlDHcef1t4Bd
         ojpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dPPRkci1;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Qupa5ciZ;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v198si1053320ybv.133.2019.05.30.10.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 10:19:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dPPRkci1;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Qupa5ciZ;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4UH97i7016413;
	Thu, 30 May 2019 10:18:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=3T6nroDY3DinVVOxA+4sYA7U+RaGiCglnLDagGHPffg=;
 b=dPPRkci17U3M4aLXAZfBtx+bzM0plzsNtVF/gEvKoyZJT0Wivyj2r2c3uTDTz0ZTN5FT
 q1F3Qc/Pe0WKCmakZzEQaXNjlYTVaGdrAm6haVtkZac6I4AX6Wjsd9WOMqLXZ3Dx5stY
 yn04aw1srzoiIwTMQCfAwyvhykmgNRY7sIo= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2stftprtsw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 30 May 2019 10:18:47 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 30 May 2019 10:18:45 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 30 May 2019 10:18:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3T6nroDY3DinVVOxA+4sYA7U+RaGiCglnLDagGHPffg=;
 b=Qupa5ciZYj3rSUffCPX4e5i8sAHT5I+Q4pGZQvCmvnkkBgEFtf9WdM6H11FUBaPFG9uBPToFMjdiUOR/LPLPhbRKrXBjWbk3qVXi+1SdFlfr7zaAusATn0eWz6M7QyYhS6vDxRlTVNu5/VSkEt7w0egiucvtbURA69JYq1kEZ4s=
Received: from BN6PR15MB1154.namprd15.prod.outlook.com (10.172.208.137) by
 BN6PR15MB1793.namprd15.prod.outlook.com (10.174.115.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.16; Thu, 30 May 2019 17:18:44 +0000
Received: from BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd]) by BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd%2]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 17:18:44 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: linux-kernel <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "oleg@redhat.com"
	<oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH uprobe, thp 2/4] uprobe: use original page when all
 uprobes are removed
Thread-Topic: [PATCH uprobe, thp 2/4] uprobe: use original page when all
 uprobes are removed
Thread-Index: AQHVFmapFXZ5K+77uUK6eWDD22eshaaDhceAgABk4oA=
Date: Thu, 30 May 2019 17:18:43 +0000
Message-ID: <F97FB4EB-3416-4BE7-9539-E58A3AD86874@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-3-songliubraving@fb.com>
 <20190530111739.r6b2hpzjadep4xr5@box>
In-Reply-To: <20190530111739.r6b2hpzjadep4xr5@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:bc80]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e4ef1874-a86e-4f28-2153-08d6e522de56
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BN6PR15MB1793;
x-ms-traffictypediagnostic: BN6PR15MB1793:
x-microsoft-antispam-prvs: <BN6PR15MB17939E8756F938742D54EFEAB3180@BN6PR15MB1793.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:989;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(366004)(136003)(346002)(376002)(199004)(189003)(33656002)(6246003)(7416002)(2906002)(36756003)(99286004)(5660300002)(229853002)(57306001)(6506007)(53936002)(446003)(82746002)(54906003)(486006)(316002)(76176011)(102836004)(81166006)(11346002)(256004)(68736007)(53546011)(7736002)(476003)(2616005)(305945005)(6916009)(25786009)(186003)(14454004)(71190400001)(71200400001)(83716004)(8676002)(46003)(478600001)(4744005)(66556008)(8936002)(50226002)(6436002)(4326008)(6116002)(64756008)(66946007)(66446008)(6512007)(6486002)(66476007)(86362001)(91956017)(81156014)(73956011)(76116006);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR15MB1793;H:BN6PR15MB1154.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: YhyDiPd3FP7X/qv3flvqEQjFex8nNdD9A3heognhhMiFB2SV1afcTFgbkI4PYbvv9kckOE5GXLKVSkGAj2CW6XpuJTdg7QKb3ldHj8ctUBBPRDU1sPU/trj3R/xkwJLKsblVFNXNDx+IEBfXSa9fuVPkuezUq5MV5UV5HPQbOw5e56lh5vWHo3yWaE8C6ruG/QRIg0JUxPzbH8Qw3SBIkKdlnyaNieIokXi0+WTrj56HdsAM04gNilwY5aD66BCqliYmWcvgOxKlsjsw7JaRt/WICYfI8DufghQpG8DwBQ3Eqbiu+A7TtwM+Xp5krq1A+spN2ahlxyjCx/TdMRK6YjuL/PAOpfIg7xxQxTCgfT5+EYpyWrfCwamQxI77BtHP3dtH354VGPBd6Cv9hQZ35Hm9rV14tLEwTAbqBRtuW1Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A65156D150C53842A08DD92CCC6D94A7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e4ef1874-a86e-4f28-2153-08d6e522de56
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 17:18:43.9607
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR15MB1793
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=960 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905300121
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 30, 2019, at 4:17 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Wed, May 29, 2019 at 02:20:47PM -0700, Song Liu wrote:
>> @@ -501,6 +512,20 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe=
, struct mm_struct *mm,
>> 	copy_highpage(new_page, old_page);
>> 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
>>=20
>> +	index =3D vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
>> +	orig_page =3D find_get_page(vma->vm_file->f_inode->i_mapping, index);
>> +	if (orig_page) {
>> +		if (memcmp(page_address(orig_page),
>> +			   page_address(new_page), PAGE_SIZE) =3D=3D 0) {
>=20
> Does it work for highmem?

Good catch! I will fix it in v2.=20

Thanks!
Song

>=20
>=20
> --=20
> Kirill A. Shutemov

