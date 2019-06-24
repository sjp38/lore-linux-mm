Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5247C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:42:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F479208C3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:42:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YbT/S+4j";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="YkUAdX/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F479208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13A378E0006; Mon, 24 Jun 2019 10:42:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EB058E0002; Mon, 24 Jun 2019 10:42:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA7088E0006; Mon, 24 Jun 2019 10:42:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6E738E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:42:20 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c207so16328954qkb.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:42:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=biTD7+gjv13LBHVp56WKg5wlOTLn7gVlvfXmHII4/ok=;
        b=D0NmWqWwtDVDCM74xUa6Lzs/WfpoXQUg4fBn3M61hk31450njpFJSxoic5pRE5MjD3
         vw7B39qmFealqmpP2JRluVxy/tHRM/eNvK0b5495KoL4E1ZmlJqZMrcBwt2VaiPIZMqG
         sOASn/Lwl1nbt/3VKhJz3c9l+gDjFWDh3yRB6qh6SBLB6g4fX6w2LTMVxQn+HNFmRVdH
         IPSSoTppRsEU8iKHeX+3LVNIO7lwzLzKbihN6y5QRAVor4EEAfBXHAAQJ04ZJajVC21B
         wflP55KALIpN8AaSuTNf1S24tpssYFwalWxsk+zB6t8sAmviopkZzx05bphhGQzDeqRY
         TdIQ==
X-Gm-Message-State: APjAAAU6LtbZU0QFgFhc2j9rTNKFpCgkrxBJZw634fXl5auTHA8rNeaE
	AHVh7Otm10GhemkXPznvS0sX20w8hxOXK+qJII0X8XdTR5gpnREO3NrLpWFerXfJTepU9TIXkKE
	24Me81Wq5Gt/7ZYSW8ZHlPFpsYBSElI5Ru/ksAnzSuKXR5+tZtY1SJvg6VJ0spqgwJw==
X-Received: by 2002:a0c:acb5:: with SMTP id m50mr58040215qvc.82.1561387340567;
        Mon, 24 Jun 2019 07:42:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyILAB9QFvDOVWjSC6pl9dUva917X608OgQ/F+dyfyDMs6e8XSCLhkjpjjEU6WnY8Vlccw6
X-Received: by 2002:a0c:acb5:: with SMTP id m50mr58040165qvc.82.1561387339973;
        Mon, 24 Jun 2019 07:42:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561387339; cv=none;
        d=google.com; s=arc-20160816;
        b=Xu3HwYiAWqqJjCgyxlXDPXWan3SON+/HEY3Rq9EL9aXzhS1DzJm/W0KO1j/NDF0maA
         rw7MTG1y8B0Y8NUW7H3rFV5vCcP886DqatbNO2WC44MnSVHbVliLHW0UPanfJ2I7AAL3
         jDSVvpMadpQ8WlehT/ob8wDS+o/duUNRPscmcKejFjrbmE3G+wx7TI8xYdGUfASCx22U
         bPsistjRkdXzqrjz/PQkaX4yw6ie1WhhskR5/JbHzd9Y0IR0+4um9Qwc3pYHE0gF2Vue
         9D5iGbn0zG31OCR4QFMJZ/VyhyDWRl1Esx8bfWB9VLAMqL23Cud2v+7ZlM5dmay/cDFp
         p5sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=biTD7+gjv13LBHVp56WKg5wlOTLn7gVlvfXmHII4/ok=;
        b=Rl+zo9SGWlrcOb35sNxLWg1UIOYj5N+ltV+xe1igzOTBuYMMFd7Jf7L5ZLBCa3l3Ge
         RNq69mLUR2ITaa03ZwH+FnalWwBoMmNyMsM3EKn+Sl3L+0l3it9yMOy7k3/lHDfAUcD2
         Rzk+YB+s5lHlg1VCmcqWGO9dklaZLf9USJtJSyZvvnBsrWuleoAcZWn9xo8VNnIKa1bN
         +XOix9cg+aKBuQ318jroZA8Jz6knWSrZGv8I4yu5ehIcpSK9IBn8KUwYzMbcF1lMA5DV
         0mGLD6iNuVUiDhjjdXq1lKafMS+ZfDoC5+J8LWqPxktcLoih8TL4zpZC24plOmDUxfEN
         Uv7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="YbT/S+4j";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="YkUAdX/C";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o51si7910351qvc.39.2019.06.24.07.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:42:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="YbT/S+4j";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="YkUAdX/C";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5OEccID028211;
	Mon, 24 Jun 2019 07:42:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=biTD7+gjv13LBHVp56WKg5wlOTLn7gVlvfXmHII4/ok=;
 b=YbT/S+4jHhwcBUnVmSpfg/CTv+qiHSa2j6QjIcDl18JMdRk2nD2uHIJn0YWv6JALpzJP
 zbKM8BWJoyqfL1UP4IfzjGvN3HFG8NaqMiWeipfrkyBgXjfur8uH8SzQ46voPT89jB5k
 oBswVWrhd05YwMe+wt7ccxbPEm0ffPSHj+k= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2tavm1rt2c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 24 Jun 2019 07:42:16 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 24 Jun 2019 07:42:14 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 24 Jun 2019 07:42:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=biTD7+gjv13LBHVp56WKg5wlOTLn7gVlvfXmHII4/ok=;
 b=YkUAdX/CR/SfdHVD2JNUQSU0NdeTpCi0XH2ngMXk3QgAFuyId43CFQgdiD3JMPNU8Me9i1wasfDlGvSxp4wND/MJUTfmwE8lFwqyP/0j0ydaC2WuIBw3K9gqiG9DSGFn7kkJUw7a0GaD1Talvx9ix+l4HTZVMBcRRlVHi2s5P5w=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1807.namprd15.prod.outlook.com (10.174.255.135) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Mon, 24 Jun 2019 14:42:13 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 14:42:13 +0000
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
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Topic: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVKYdGAmz09KUZ80Kts9GVGsmXGaaqwvwAgAAUeoCAAAd4gIAABAcA
Date: Mon, 24 Jun 2019 14:42:13 +0000
Message-ID: <C3161C66-5044-44E6-92F4-BBAD42EDF4E2@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-6-songliubraving@fb.com>
 <20190624124746.7evd2hmbn3qg3tfs@box>
 <52BDA50B-7CBF-4333-9D15-0C17FD04F6ED@fb.com>
 <20190624142747.chy5s3nendxktm3l@box>
In-Reply-To: <20190624142747.chy5s3nendxktm3l@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:d642]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 45d81ac6-ac3e-48e2-beae-08d6f8b2257b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1807;
x-ms-traffictypediagnostic: MWHPR15MB1807:
x-microsoft-antispam-prvs: <MWHPR15MB180742845552E60E19A13010B3E00@MWHPR15MB1807.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(346002)(376002)(39860400002)(189003)(199004)(6506007)(76176011)(81166006)(4326008)(14454004)(229853002)(8936002)(33656002)(478600001)(81156014)(316002)(305945005)(446003)(11346002)(486006)(476003)(2906002)(68736007)(54906003)(71190400001)(2616005)(7736002)(46003)(6916009)(5660300002)(99286004)(86362001)(102836004)(53546011)(186003)(6116002)(50226002)(71200400001)(14444005)(256004)(53936002)(6486002)(6246003)(6436002)(8676002)(57306001)(66946007)(36756003)(6512007)(66446008)(25786009)(64756008)(66556008)(66476007)(73956011)(76116006)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1807;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Lk/CUEMV78I14ydrlsW5qgP88OvuK0x0jsbMzojChZI4NXsxs7L5JIxUdB54ovFl1olcDjTDROkr4Bxf3UCCcY9zKBFkQfnr9nubd1XPluSCROzP5cicyHWygeW7Dz9wtOGA6diNLFhvJ3YyYBl2Of5B3kpBr1lm8yb3eZznP6vPttZz8I2dc9HoEuIdPl/L3SvjRKw3XeYoH5i3JFSRjdDlFdp9+mmiCkX44tOgfqQWizoSz5Xb21BnIUwfeOvOebo+jvrnGsBU8sFkm9IYLJ00a0t+fRwgmGSpoCC95AxAF6hoZ1ujDhN1Fko5AYpBQfmVYXr2cKltW9YnoZG/n7Iw8hXP+2bT0OWGVrO3a/nyZlzul1gupwRB09UVlxxGZuZXW2ieBDJxVuQ1LBRiV/gTVYbg24l55bwIFHQ7qIw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2A04ABA06972B54D9DEF657049A91AAE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 45d81ac6-ac3e-48e2-beae-08d6f8b2257b
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 14:42:13.4296
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1807
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240119
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 24, 2019, at 7:27 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Mon, Jun 24, 2019 at 02:01:05PM +0000, Song Liu wrote:
>>>> @@ -1392,6 +1403,23 @@ static void collapse_file(struct mm_struct *mm,
>>>> 				result =3D SCAN_FAIL;
>>>> 				goto xa_unlocked;
>>>> 			}
>>>> +		} else if (!page || xa_is_value(page)) {
>>>> +			xas_unlock_irq(&xas);
>>>> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
>>>> +						  index, PAGE_SIZE);
>>>> +			lru_add_drain();
>>>=20
>>> Why?
>>=20
>> isolate_lru_page() is likely to fail if we don't drain the pagevecs.=20
>=20
> Please add a comment.

Will do.=20

>=20
>>>> +			page =3D find_lock_page(mapping, index);
>>>> +			if (unlikely(page =3D=3D NULL)) {
>>>> +				result =3D SCAN_FAIL;
>>>> +				goto xa_unlocked;
>>>> +			}
>>>> +		} else if (!PageUptodate(page)) {
>>>=20
>>> Maybe we should try wait_on_page_locked() here before give up?
>>=20
>> Are you referring to the "if (!PageUptodate(page))" case?=20
>=20
> Yes.

I think this case happens when another thread is reading the page in.=20
I could not think of a way to trigger this condition for testing.=20

On the other hand, with current logic, we will retry the page on the=20
next scan, so I guess this is OK.=20

Thanks,
Song=

