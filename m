Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95FE1C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:21:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 311AC25A87
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:21:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nutanix.com header.i=@nutanix.com header.b="CwanQOUH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 311AC25A87
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nutanix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76BE66B026E; Thu, 30 May 2019 10:21:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71DF06B026F; Thu, 30 May 2019 10:21:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4276B0270; Thu, 30 May 2019 10:21:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22EED6B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 10:21:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e20so2420162pgm.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 07:21:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=u7GW1wajDEeHSjUfIcV2xuIjAdcNVZZMlbomcPM9BnU=;
        b=UE6Vjb97/sWJVRiBW9jYwEE1ubtHmIprVOORf0GK74+SesEocg9iyaUEQlFjVAcoF+
         ePAZLl3194FXfHLXt53HaxD97HyazTt5dRaYCYBRYHvCZtSiTi5sqKzURUH3k/M8q54n
         FApEJNzykP86cmUXK5LJL0l2YgvqnJLSOiJCT2U/a7Fxd+0DdUBrF/NN3DgVP4hQjem+
         Ts0JiEilv7Kb+e0acZVi8dA+mfwHdeb+TWdGz6wlOJstuvPDOhS6dfBsrUqCEiO2fpNI
         JP9qnX7DMShiELQ6zI/e6xh2REIAFxfCT8mKfxXilGsObj8UtnB4iCpcCE2Kizh8Ymd6
         wjCg==
X-Gm-Message-State: APjAAAXuyrYj5NyNt/iYhxIK2G7WOTgQ9CXOHRpuTPiDspSbrPOlQoc4
	DabxwPGNX05hYdrYnhltDS5/aUeqNS7H7KnfMns76xoB6LM8qoSdcOAUc1mrbtGC8GIAAeWeou5
	MUr9JJcdPVHxZbVetSpejUzk5yLlUf8QX8oNqU1GWGBxMlMmK7QqTxKY2CjWbrppkYw==
X-Received: by 2002:a17:90a:a00a:: with SMTP id q10mr3712321pjp.102.1559226064767;
        Thu, 30 May 2019 07:21:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHPIaEbsQII6op6ejxyyqr1ZVZ9+EAr/cIeQM0RBsL3zxP+VZuKS8UoeuLO6bNQY4bpYDO
X-Received: by 2002:a17:90a:a00a:: with SMTP id q10mr3712246pjp.102.1559226063585;
        Thu, 30 May 2019 07:21:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559226063; cv=none;
        d=google.com; s=arc-20160816;
        b=1JhEy+rnnU+XbbRv4z5qwZEUFn+ooz0gi/ql00QWztclAHoR129HmC3fBDvIlNhl0U
         Z/KediY5UEjT0AbJYMqC92iHKUcbvWCzGUzCkE2WotjrXMeoTGOX6bmTTr49a3ZEXVyt
         cJ1hGtr5fCZLGONgorCkg8nYn+35skjIGpizsJsCFjYP7bqk53R/U2NaXywsH7Q9Qefl
         PtSr9DY0TJOK/VZ1HQmwBhbqI0u68oOsNZrwKGxncZEmuLSGvAY2JpbVh3UUK1Gt/9L4
         bxaAbRnuaPYhNzjuwr7sh//Ar2Nv3S/8h4EkBkOv3qiiJ7GjTYNdVurb0X9PMKvEyNcx
         aKnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=u7GW1wajDEeHSjUfIcV2xuIjAdcNVZZMlbomcPM9BnU=;
        b=b+U6uaEl9dI0pB/ZKCwZdQxUD009GIF8fg1bOjuhqDt28XeBQqhSdEF3NGPkaySaRf
         HL8W5bjNIUXqBQPwuLRg+M2pKZh0B6Ep/CfdoScVHoalCgJKVqDl2X34FS02cUYgeAl1
         d+cbkqShOGY5wBtnh+K+AKtlOkQ1FnV29AZxM2biQd6DcEhJkPEA7Q1znUG4cA1bWalw
         SvlFfu7XgyinPuW4RQbP7EbjZndMTT68IIkJigdk3aJ0Pf2TuW3RpihodK/HivFpa2ep
         3SVfjfyRELBpVwKYpXpxEyeRbo+pj0JCS58Nez9jFOCsF+2E4aE5URjkiJ0fLjdTJLwj
         cdFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=CwanQOUH;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from mx0a-002c1b01.pphosted.com (mx0a-002c1b01.pphosted.com. [148.163.151.68])
        by mx.google.com with ESMTPS id z18si2529241pfc.227.2019.05.30.07.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 07:21:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) client-ip=148.163.151.68;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=CwanQOUH;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from pps.filterd (m0127840.ppops.net [127.0.0.1])
	by mx0a-002c1b01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UEK23h032649
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:21:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nutanix.com; h=from : to : subject
 : date : message-id : content-type : content-transfer-encoding :
 mime-version; s=proofpoint20171006;
 bh=u7GW1wajDEeHSjUfIcV2xuIjAdcNVZZMlbomcPM9BnU=;
 b=CwanQOUHDnDizd5ggfWVdSGxzhiij2Kyk5CwxF+oXl9oxBG3khV4Qur+o8FWEEhbsmTk
 JmiQCyMfxefnfqcre3Vynrw1rUQXtq8FFxZRBlePBs0+ZX1kiLycGx1VpSKKqsdjDh79
 uNseWlwhbNAqFz8qJrBpbfxqhbMn7l3g2Evg7HOQsaQq6ZcFJJz/eUF4KpKYylJfhzab
 2+az4gkvCw0uMckKrzqQjDmHtOVMiSqiYvZMPT9diyxt4gf6rzFrDwowKBXVP66AOoRB
 9qmXjjxS832mxhs9nRCkCQTEPCl9YgZNMe2ykqQ06c4Rd0Yy+P4YoGoje8YotyKV9taG Jg== 
Received: from nam03-by2-obe.outbound.protection.outlook.com (mail-by2nam03lp2058.outbound.protection.outlook.com [104.47.42.58])
	by mx0a-002c1b01.pphosted.com with ESMTP id 2ssd3sbmsq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:21:03 -0700
Received: from MN2PR02MB6205.namprd02.prod.outlook.com (52.132.174.26) by
 MN2PR02MB6317.namprd02.prod.outlook.com (52.132.175.78) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.18; Thu, 30 May 2019 14:21:01 +0000
Received: from MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd]) by MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd%3]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 14:21:01 +0000
From: Thanos Makatos <thanos.makatos@nutanix.com>
To: linux-mm <linux-mm@kvack.org>
Subject: can't register to linux-mm
Thread-Topic: can't register to linux-mm
Thread-Index: AdUW8qcXKyG0oYdvTTa5W8TzJOfkNg==
Date: Thu, 30 May 2019 14:21:01 +0000
Message-ID: 
 <MN2PR02MB6205C25B05ABBE3D61A87B4B8B180@MN2PR02MB6205.namprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [62.254.189.133]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 31ecb624-f1e3-4316-1b08-08d6e50a0ab4
x-microsoft-antispam: 
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MN2PR02MB6317;
x-ms-traffictypediagnostic: MN2PR02MB6317:
x-proofpoint-crosstenant: true
x-microsoft-antispam-prvs: 
 <MN2PR02MB631739042A0DEA94AE1DE50F8B180@MN2PR02MB6317.namprd02.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: 
 SFV:NSPM;SFS:(10019020)(979002)(376002)(366004)(39860400002)(136003)(346002)(396003)(199004)(189003)(476003)(71200400001)(74316002)(66556008)(66446008)(6116002)(81166006)(102836004)(7736002)(9686003)(71190400001)(8676002)(81156014)(26005)(6916009)(66476007)(64756008)(53936002)(8936002)(66946007)(44832011)(5660300002)(76116006)(486006)(316002)(3846002)(6506007)(256004)(73956011)(14444005)(305945005)(186003)(66066001)(55016002)(6436002)(14454004)(478600001)(33656002)(52536014)(7696005)(86362001)(99286004)(4744005)(68736007)(2906002)(25786009)(64030200001)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:MN2PR02MB6317;H:MN2PR02MB6205.namprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nutanix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 
 nVMdE47UAxHdzh/EIveg+hhTXQ0L9PrIR4s0gZzd80g6n/oNdNFB5NPHAcMTqKIQqALDdkmUb4ma0Nk/AvWCg11VySVNeiJD5y3ajWKL5fs8cIujCZ6eU7TUoa7le2Erz6cCoiXvSnjriy5umSTsm652WjrOqtx+FL0RgJTz0Q7eNTvQCZskxfJgelZ9rbJiwAeoxT0BPalaYFjDCggqUmfFXGnwhOZ/2GisfpPg0WpTK37YHcjXZauBAta+TIlPLgl4jlnITiE6MHJH6qkfs80VOezwo+hAjD2g5YSd2uFl65mZbxeKiuYWgYCZYMZZ9YA+R0y/fGIhS3gxZnP0dfK7rD6I8cPPh3556SJMC6g6tz+XhkZRFhu0lHhapFeBuIO0VQ7RUUPpC45UK16KLxZvxwhwNsuf05JQBL8paxg=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nutanix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 31ecb624-f1e3-4316-1b08-08d6e50a0ab4
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 14:21:01.0483
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: bb047546-786f-4de1-bd75-24e5b6f79043
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: thanos.makatos@nutanix.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR02MB6317
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_07:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000140, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've been trying to register to linux-mm for the past few days and it's not=
 working, I don't receive the confirmation email from majordomo. I also tri=
ed with different email addresses (e.g. gmail) and it's still not working. =
I'm simply sending a plain text email (subscribe linux-mm) to majordomo@kva=
ck.org. Am I doing something wrong?

