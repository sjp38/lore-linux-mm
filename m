Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C2FFC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:30:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA5E6206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:30:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DJ0oUUC2";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Un0tomMa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA5E6206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 981706B026D; Wed,  5 Jun 2019 12:30:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931FA6B026E; Wed,  5 Jun 2019 12:30:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D28C6B026F; Wed,  5 Jun 2019 12:30:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58ACE6B026D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:30:32 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k142so23189891ywa.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:30:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=1rfsUUFZSCNJ7nuLOUjdlYppiD9fqGCzCGbgwZ6tV7Y=;
        b=dq5SY+7nEcrcp6zK505Pm57r7H/bwgCqyi+kOjjJX47c+x8Kn08mqlcED56y7qHwL5
         TGuRwK2aXRnrgAMJ2SOglL5XgU9wFxk6er4JTwmbX4PBlwqnVlUesEHmzQTBsVL9MATa
         ZN6SNgBO47yTpwDKdtlWgERuJLZ1xZyelsFcQMfBXSkQnYOBPB/H5P97oSLnBNqqdZ+P
         Bpc+luA37321kfU/+0Rd+pwbwWxhcpmKzjwRXONMXyryQ+0EWPjWDHRpGp7U3Hw9B6Oi
         SppvEzMfbEy0CDWOQbAJQ5UM6CGOlJtwBKIXOod0eKji616hBSz1RQ8SJEQqT6YlsLNA
         C8EQ==
X-Gm-Message-State: APjAAAXoCd51E6fsGQ15mZIi8k54pyuzBU3iK2XnpRkdDW6Px07Anmbg
	gGfUXuOnnKEAG7kP5WhbehXNyxfE0SBpOAX3ZD2ouLwiBy4pl+HsVqjPK6h3ZElTggXOuV/B7qU
	kXyecaeEAKPCMlsHbzW838mC0lLs8hf7oqocLjoqUcWskfjwyy5wSQpcvF9eFtOT7TQ==
X-Received: by 2002:a25:2986:: with SMTP id p128mr18524145ybp.168.1559752232064;
        Wed, 05 Jun 2019 09:30:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHRkQ/UiRJIj8MFNo7fVqQbU0mNg+6sZASAjpEJzMw/5M1vl5SwcVoTYU/iEEs5E0jOf84
X-Received: by 2002:a25:2986:: with SMTP id p128mr18524116ybp.168.1559752231448;
        Wed, 05 Jun 2019 09:30:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752231; cv=none;
        d=google.com; s=arc-20160816;
        b=TcC77wCucHTb082SbgFnbDshl4uwKLQkmn8ARcsLQrul+i0KafRG/vjJcOs9SSZTJ5
         mRwT9kLwDki2gSxm1xDCy6JqVFNSlzpEkN+eY84Gm6SsNrDoEKVSIWDdwaZQSri6/XlG
         zofYKDjbWyG9tWZBDxkoHxAAyQ2msHOPVPLJS4wSpipEl50umcQP+8KqLGNyrHyC9TCE
         /a8BNVnfQhSlDEe6hLFDOoQwYKhptP2UU0aQINytwQOGW4Xs7FSE+l/MqqhEB7Y90/sO
         Gy/lVgU2LRnpbrd+6indKgLp4BI8sNvk8Q3JGnF+QRP4omFqA9GIxqxAT8XqpZRx3AuQ
         XecQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=1rfsUUFZSCNJ7nuLOUjdlYppiD9fqGCzCGbgwZ6tV7Y=;
        b=Kok8TECnyB5Na4JrIH+k4FFRVsjbQU08DssYm/nGd1OBAfaj9/w2CoiLR2vWbhj49O
         Ush1ikmq8R6NkS4MP1vXkwbWpjjC6x2PJDYD2xgaEK3YiDvTFZOGu95cTREPuHjwNHcL
         VnJXkqaLAeRWtLsVgnyu770fz+7X2u5MAtTN8fERAcB0XbKZFfrefTm5ex2EJOnXo8iU
         5/PueuOLz+11buuWMsQYbFWuZRLVnVWhgK3esSUVbR1rRAH1rnx6c738Tfqu/QlRz4WD
         AV4PT63qyz8uvUi/enyWcMWm5f4Jq+Kw1O44Hy10yr+It88XUkHk+WAWJcn/IDS1MQUF
         9enw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DJ0oUUC2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Un0tomMa;
       spf=pass (google.com: domain of prvs=105904f990=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105904f990=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o6si7258193ywb.163.2019.06.05.09.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 09:30:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105904f990=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DJ0oUUC2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Un0tomMa;
       spf=pass (google.com: domain of prvs=105904f990=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105904f990=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x55GRgn3031455;
	Wed, 5 Jun 2019 09:29:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=1rfsUUFZSCNJ7nuLOUjdlYppiD9fqGCzCGbgwZ6tV7Y=;
 b=DJ0oUUC2yKaZSiPT+kVByg9Zuasimc1cwwbmBaV8kwl7SVFuDB4MBrIvQ2Rdilk84bel
 28jeqTBOvpqLXYf4ZCVdlELUS0B6hCg6RYKE3/N6Ic5tCS/Eq7aZlsyVTDrtXvYEwe+R
 hf2slRzqF34A0G4QBId/E4thEub91j/yst0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2swycbb388-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 05 Jun 2019 09:29:55 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 5 Jun 2019 09:29:55 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 5 Jun 2019 09:29:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1rfsUUFZSCNJ7nuLOUjdlYppiD9fqGCzCGbgwZ6tV7Y=;
 b=Un0tomMaBxPyF7SOB+fvHE3FJ2JDid87ddln1kco07iCRDGqRpXgqcOLzRFQ5mt7nKOzGpM5VtBC5FcLvMf+q4tmwiDU2ga1m7x5srtZMVgetZhXX7TUg+pFRNIsm44LVVzfKPei0tnJVCWUI+zIFavj0MYfNyt6pjd2I2YXgfY=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1485.namprd15.prod.outlook.com (10.173.234.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.13; Wed, 5 Jun 2019 16:29:36 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1965.011; Wed, 5 Jun 2019
 16:29:36 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "Peter
 Zijlstra" <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "Masami Hiramatsu" <mhiramat@kernel.org>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>
Subject: Re: [PATCH uprobe, thp v2 2/5] uprobe: use original page when all
 uprobes are removed
Thread-Topic: [PATCH uprobe, thp v2 2/5] uprobe: use original page when all
 uprobes are removed
Thread-Index: AQHVGvXYP1uNbtmlEkOH++FxJqf1WKaM1YuAgABsQoA=
Date: Wed, 5 Jun 2019 16:29:36 +0000
Message-ID: <0B1DEAD9-DB1E-46C5-9F5C-1049D0DC043F@fb.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
 <20190604165138.1520916-3-songliubraving@fb.com>
 <20190605100207.GD32406@redhat.com>
In-Reply-To: <20190605100207.GD32406@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:34a6]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b387e601-a04d-42da-1b9b-08d6e9d3000e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1485;
x-ms-traffictypediagnostic: MWHPR15MB1485:
x-microsoft-antispam-prvs: <MWHPR15MB14853D5C37ACC521E2828B87B3160@MWHPR15MB1485.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 00594E8DBA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(366004)(346002)(136003)(376002)(199004)(189003)(11346002)(256004)(25786009)(2616005)(476003)(54906003)(14454004)(486006)(478600001)(14444005)(446003)(76116006)(99286004)(33656002)(46003)(73956011)(66946007)(57306001)(66476007)(6436002)(66556008)(64756008)(66446008)(6116002)(6246003)(53936002)(229853002)(4326008)(6512007)(6486002)(50226002)(36756003)(6916009)(8676002)(81166006)(81156014)(8936002)(68736007)(316002)(186003)(7736002)(305945005)(86362001)(83716004)(102836004)(76176011)(71190400001)(71200400001)(82746002)(2906002)(5660300002)(6506007)(53546011);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1485;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 3cgaycaRqKeuUTuyH+mPkC/EPIhfqVXoah2kEefN4wL3lNzI7SxJx5dUIl8fU3Z4bGO+waD+Lxxutrqx17ufz3p+OWKdskXdpdNRX36T5GhKXqSDltnPH6xo+uZHcho9/d5DvGS0iTWG7/sOAENGa3PYJI9jrj80RbFdtBn9TphpvC0ZMqQZG8SmStpQ4HvO4QGFNbQcyQnyeUg+J6VxDjJTJMOVAI/zz4jbobvrWjfyN6F+09OaUxLyUHQoOcbKDDjBnLtNqzXQdmceZJA601aeTLfKF3y4X0bpzjHmP03BjjPrn1FSwIlbedEDJzqvUJXp6h1iiXK71a0gq/tWaw6vK+SxDZ9636lhldeEFRAD3v6FMW0hwu/PJ+qdY/qm6g66rl75LxMGay/XEYYXPIGKL5RZlV/Gc3R/qUYPXNI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E2E7A7264E573F46B6EB66C308A4E80F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b387e601-a04d-42da-1b9b-08d6e9d3000e
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Jun 2019 16:29:36.6298
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1485
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=958 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050103
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oleg,

Thanks for your kind review!

> On Jun 5, 2019, at 3:02 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 06/04, Song Liu wrote:
>>=20
>> Currently, uprobe swaps the target page with a anonymous page in both
>> install_breakpoint() and remove_breakpoint(). When all uprobes on a page
>> are removed, the given mm is still using an anonymous page (not the
>> original page).
>=20
> Agreed, it would be nice to avoid this,
>=20
>> @@ -461,9 +471,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe=
, struct mm_struct *mm,
>> 			unsigned long vaddr, uprobe_opcode_t opcode)
>> {
>> 	struct uprobe *uprobe;
>> -	struct page *old_page, *new_page;
>> +	struct page *old_page, *new_page, *orig_page =3D NULL;
>> 	struct vm_area_struct *vma;
>> 	int ret, is_register, ref_ctr_updated =3D 0;
>> +	pgoff_t index;
>>=20
>> 	is_register =3D is_swbp_insn(&opcode);
>> 	uprobe =3D container_of(auprobe, struct uprobe, arch);
>> @@ -501,6 +512,19 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe=
, struct mm_struct *mm,
>> 	copy_highpage(new_page, old_page);
>> 	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
>>=20
>> +	index =3D vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
>> +	orig_page =3D find_get_page(vma->vm_file->f_inode->i_mapping, index);
>=20
> I think you should take is_register into account, if it is true we are go=
ing
> to install the breakpoint so we can avoid find_get_page/pages_identical.

Good idea! I will add this to v3.=20

>=20
>> +	if (orig_page) {
>> +		if (pages_identical(new_page, orig_page)) {
>> +			/* if new_page matches orig_page, use orig_page */
>> +			put_page(new_page);
>> +			new_page =3D orig_page;
>=20
> Hmm. can't we simply unmap the page in this case?

I haven't found an easier way here. I tried with zap_vma_ptes() and=20
unmap_page_range(). But neither of them works well here.=20

Also, we need to deal with *_mm_counter, rmap, etc. So I guess reusing
__replace_page() (as current patch) is probably the easiest solution.=20

Did I miss anything?=20

Thanks again,
Song




