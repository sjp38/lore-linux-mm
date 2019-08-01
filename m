Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69DB3C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B779206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mXlmfYU3";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="cgFNgptX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B779206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9789F8E0005; Thu,  1 Aug 2019 13:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94FE48E0001; Thu,  1 Aug 2019 13:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F15C8E0005; Thu,  1 Aug 2019 13:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9AC8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 13:37:26 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id k10so19000705vso.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 10:37:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=0VVMyITJ/PqGQxblrrmnumvluMQB2xI3qLfo3DBeWe8=;
        b=jK/0PzHxQq3Lp/m8LH6cMw6RcM9PMYIwRphEhj6caTIXIvr9/BPsYarDOoMhE56hbt
         bFAj829ooJ6dwgBA/BOOPC+Uzi7TWecS7tvRKyH4Z+px6dVSCriQDMlFn1tu8Fmbk7Lh
         JOVmrR4f4X6TNbNyM1nx9HAYU38jNhdk7+kEIVbcsvYFyzYxmclXZWMLGl122Sn5dCmS
         6S+WsW9xKX9vPtJqS6qk1hpeizOo3aS5sfMooLLDZwVZG5YpBoTtxMLtMyLRN2eAOWrw
         uDaILjAOP8UAp84Au+C+2UFBiSg+J9VTAmsFFh4XPhm257QuZeRLOWgf6/nyS7RZx5sZ
         XW4Q==
X-Gm-Message-State: APjAAAUoxi+zcBWTmINDMZ/v2XjeHaiq5p9/1NyxvrX6mp8btl1ADIUk
	0HM0n9BwZFwOEBF1lEfZm8dRlXgBqcsy7KMb3C57DbI4RgORKKwiF+rBmtWEfn/xp1nrS9E4qyq
	A7VvvAmWc7wY7t3nRz+1VngOuBaJtc1Vl9MxDFH8TQgCY8KzDRN2QI9tpL54gp1E8og==
X-Received: by 2002:a05:6102:c1:: with SMTP id u1mr83344061vsp.224.1564681046052;
        Thu, 01 Aug 2019 10:37:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAi6AP1xNE0CgMyrgbkEbWtdE4XR8MiSsq0bN7QBtxUYQUACnoQeciPl2lXqDXVTTb5bVR
X-Received: by 2002:a05:6102:c1:: with SMTP id u1mr83344021vsp.224.1564681045383;
        Thu, 01 Aug 2019 10:37:25 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564681045; cv=pass;
        d=google.com; s=arc-20160816;
        b=L55OyOQLer/XwOS4ru6LkL9GUjuQZRtPNn2F7O9O7KzoT7MWp5dPKPFJrKs/8cNZsj
         g0ZbwesnUQ3IzFAj9/8dh5PVENnVhASad4OCSgmfjT+BPMY+0aJw+SPUvOOv+8hU9sZC
         W9/N0VbXBqDD/T3fObpULmkPOGB5nvNXU8eVsCHRRK3eSyuuh1zT0RSexNMSUD+RB63B
         z+6RaMt5uY81+zqy9UKUE7gD+JdAzPmxyHccIN6ey9Kj4ZfoO3CHA70u1yphQ+S1622l
         IYSdEFZnhdr9R8BUJE1OLiUnn7JkSDkGCPz7VV2f6MzQiMWeDtKsCtpVG98bA+kzfZnm
         C0tw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=0VVMyITJ/PqGQxblrrmnumvluMQB2xI3qLfo3DBeWe8=;
        b=FyII7XfFnJmd8uB17svexkNvfPLf6dakAWbL4UlrFP88BKcBlvazYB0LVB6S8fmgUD
         7a8BJ3I6sADr4f/SWUAZN4MtTW4VxFZeautVsFSe5FTIi1hjaFUxLTs7O1YoUgC7yt2h
         Viq9cafU8f7CSVgngU5PN1pewWue4aMw0DWMKW28CllAGpjacqHpNK0sWgMBt1/XaRgn
         IGnYtWeVolzjEmD6Fcsuuw/TNfWZYY0kakyIDfGc70/GWaEpvl29RixNRDOec4Qjjt0C
         pViWNxvxJtMi8io1wCIWhVoXWZjEZi9OI+B+okYujYb/ZHiTL0cgp3AGPJnJ5uyrQS7i
         AC1w==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mXlmfYU3;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=cgFNgptX;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n24si25814982uao.72.2019.08.01.10.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 10:37:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mXlmfYU3;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=cgFNgptX;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71HY44f030418;
	Thu, 1 Aug 2019 10:37:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=0VVMyITJ/PqGQxblrrmnumvluMQB2xI3qLfo3DBeWe8=;
 b=mXlmfYU3g7vnzIOYJpWMzQo1S8MnTPOJXb4lYtkrGgAutue0paALgifmQ9n9TCbrZ853
 d419rzoViKTLx6ws1sGY8PqVVHM1A5DLvmPKl60FZo5XDyf55U8kpf8DGpNrAvT1z/un
 cTlvaPk+i5oOLVlr3faYWKLdogUR9UYRAXQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u44e2r1wu-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 01 Aug 2019 10:37:24 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 1 Aug 2019 10:37:05 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 1 Aug 2019 10:37:05 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=b5QcVeHA2jEuDQg+EhoWNPplFOAyi16iyGAAl+oKYDsitJAgv6Mi/M1gC2eK80ozX31nfL7Wdl1K6ohimWJYh/Dsgq6kLtmzkaZm7jM0KpiAXI3/r6eysXI9u4hvACslWdpXps9KKuoPimihbfmpM13IkppLVQmH8ykqeQh2x77nTHdzfYl1+TLoUZ0A8far5hArc4LxXAYVt6LzDNolH9TPI2ifhvxH/s2YktXdlc/8oBPgxueaYA2JDIgpGOcnJVC3lX+jx74mIXHyi6Xb7aPEk+SQopmosaMhzx0brGgAzjaQjQN4AUythfyc7xzs22IREHJCBALA5aUebi2eZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0VVMyITJ/PqGQxblrrmnumvluMQB2xI3qLfo3DBeWe8=;
 b=bTmLJEPeb8t7fCzpfyIMnV+Pa1hi3V056yd+N7OhdCmE/UStsx8cuPM+asEqSl8TrOxCvDBEPDHGr6Qm3+taEHdCYu9/qVunVWcV5AHp4qSELBD2H0WF8zLoQE/6uZwk7KVvvC8DSY0mIvQyFbz4XBCGnrQ2MWoloiougFJkxviW3HuMFuRjOES5VwwssWnzTdtU69CyRAe78gLTMunY2s8dsT3FzvQU9+WiTNi3+wf/gLpM3z3H4NYbZDWFvpbPP0BRE2IudQKSIcM6BNosyC9js9vmtgm/aJCDExKXrt/dv2UUC34PWybTSIHoU+BGPVda45+YMfcjlkHlVuunKQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0VVMyITJ/PqGQxblrrmnumvluMQB2xI3qLfo3DBeWe8=;
 b=cgFNgptXSpaqIirNRP4jNpK1oWgmP/AonNQ5YTd6MmLBNzc5YjGUzVa5WRpidY1wfDAi0KEWO6qyJFHx9Q+ijpSgoRrn3Aa5GiXHfmhubw/Mq8rHxZ5PDBbSEpkpV4YPH6A99cgNoQGEs5vm0LfIi+oXrotBCzeJIQ2rtXxISHs=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1167.namprd15.prod.outlook.com (10.175.3.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Thu, 1 Aug 2019 17:37:03 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Thu, 1 Aug 2019
 17:37:03 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVR86KvCEU4VHLnkGVG5f001755abmYVIAgAAuhoA=
Date: Thu, 1 Aug 2019 17:37:03 +0000
Message-ID: <36D3C0F0-17CE-42B9-9661-B376D608FA7D@fb.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
 <20190801145032.GB31538@redhat.com>
In-Reply-To: <20190801145032.GB31538@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::2:33d7]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b57bd20e-96ba-440a-ef4b-08d716a6ddb2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1167;
x-ms-traffictypediagnostic: MWHPR15MB1167:
x-microsoft-antispam-prvs: <MWHPR15MB116703B8B8D5480C37AD95E8B3DE0@MWHPR15MB1167.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 01165471DB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(376002)(366004)(136003)(39860400002)(199004)(189003)(476003)(33656002)(6916009)(76116006)(2616005)(71200400001)(66446008)(486006)(102836004)(57306001)(11346002)(86362001)(66476007)(229853002)(66556008)(50226002)(81156014)(256004)(64756008)(6246003)(446003)(71190400001)(25786009)(8676002)(66946007)(81166006)(46003)(7736002)(68736007)(4326008)(8936002)(186003)(6506007)(5024004)(478600001)(305945005)(316002)(99286004)(14444005)(76176011)(6436002)(5660300002)(53936002)(2906002)(36756003)(6486002)(14454004)(53546011)(6512007)(54906003)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1167;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: srvbaBzJxlOx1zaHLQ3sB97bI65aIO4n071B3OPYSboTkEpG8cAskK1yTkLuWk+xSDJ+kL2f9hUBQHYv7DbRyCA12XASxLt6oCI+LDAgkUwawx+KPn1nOgsCwkCTZk2toWf7pJLoEQCPmzboTcq6ltDzAkSdcVSTmj0CJYoJEd5hZ5Rs4pFyzNYuJV+uGUhiv3xmEfv+2lZSY5xUaiyJZ9loDjV3QaLDA1WTuQP0xpqKdfyco5LlM6EHidol5kE3bQQx6MIMO7R4mkSTiRFTjmOOFxDIMMfRlIsnt/cG86nXmSWxkYVPv52LvyTAWXGevp8Pl98f8OcNzMs2Pj4I8xqwERY1qd7STn3OB+4oQfq4y1NxcY3xf7C6GdmJ96Rqb8Wwm/83HXMGnoYWRLQJ9cdSCnBMza8MRB7+Lk/V4CA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <33FB7EC24D20944497C1091E287D6732@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b57bd20e-96ba-440a-ef4b-08d716a6ddb2
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Aug 2019 17:37:03.4767
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1167
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=646 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010183
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 1, 2019, at 7:50 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/31, Song Liu wrote:
>>=20
>> +static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>> +					 unsigned long addr)
>> +{
>> +	struct mm_slot *mm_slot;
>> +	int ret =3D 0;
>> +
>> +	/* hold mmap_sem for khugepaged_test_exit() */
>> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
>> +	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
>> +
>> +	if (unlikely(khugepaged_test_exit(mm)))
>> +		return 0;
>> +
>> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
>> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
>> +		ret =3D __khugepaged_enter(mm);
>> +		if (ret)
>> +			return ret;
>> +	}
>=20
> could you explain why do we need mm->mmap_sem, khugepaged_test_exit() che=
ck
> and __khugepaged_enter() ?

If the mm doesn't have a mm_slot, we would like to create one here (by=20
calling __khugepaged_enter()).=20

This happens when the THP is created by another mm, or by tmpfs with=20
"huge=3Dalways"; and then page table of this mm got split by split_huge_pmd=
().=20
With current kernel, this happens when we attach/detach uprobe to a file=20
in tmpfs with huge=3Dalways.=20

Does this answer your question?

Thanks,
Song

