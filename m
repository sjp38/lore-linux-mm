Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45D88C31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:00:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB1832086A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:00:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SI8F+xNZ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ALomfEwb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB1832086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BCB08E0003; Mon, 17 Jun 2019 11:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86C098E0001; Mon, 17 Jun 2019 11:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7350B8E0003; Mon, 17 Jun 2019 11:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C22E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:00:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so7920951pga.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:00:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=U4sFjNzVPTFL7yvvxqemviKGsQd3j5YPgbZcl+o4n2I=;
        b=CETrClmu477y7/Bq5C2gvqNlw7FPAta7zKtFczjadyH1NFvh8BQvYTCrTdDmzlmqo3
         4bNZpRAadwmOJbJtKBour0uwJYDIH9YkSjC1E2NiRgbFsOqSB6qk5Gol9uismq0JpyN4
         Zk4UrW8ZO8NFsPBwRpUxhdyIrkOvgbmIi8o3QxtVUeLiKcXuxKDtuVGkQ4PFySqV0QgQ
         SBMNEvtMu3AXZEBtnBeKqzLpp95hm8dgt5W/LhBzyzz3Nz4G6i+8r2V10fwxeYhrUmkZ
         bYCz7rJXXYlrxq+vjxlJPDAK/FJhhdVMyHongbwBm5R4JKEw/jFwpW/C4HSup0JI6/Xs
         8+Eg==
X-Gm-Message-State: APjAAAUikVZnxaTPH07tiJ/tUhavDleifJk2Y+gDyDNEMBreHLvEp3za
	OPVABfI0dltN2MM8cqAFX6aYodAIeDYPhNuaC1jCW48P8R3oxUNEv/kRvEUpgep05XTDFYVTYV5
	ZnsZDcmk+Q8+SvjzDIMUedSZ6xJSvJjfLYa7w+TI2MwGQbaKIbnDciAifhIPC8FqjQQ==
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr11613311pln.216.1560783615881;
        Mon, 17 Jun 2019 08:00:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkBC9vnNcAXdviAvJLJygwiny+hND9/omkhlhQtq581rG7jliFc/8/LKaLIquK6rmJMT22
X-Received: by 2002:a17:902:820c:: with SMTP id x12mr11613242pln.216.1560783615081;
        Mon, 17 Jun 2019 08:00:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783615; cv=none;
        d=google.com; s=arc-20160816;
        b=CXjjBkbIu3+xqF/BAiHYZWLtUcLKELpbBxR8m/M8RWshzk7EJOn7ut+tc4HiK71qjw
         ieQ2hBd/tw7iQkzuiA6h9jybU+XAGnsQMhdTtu46XtK2t/KN4aAWth/fRq900hBU9qdt
         aJKLsL1CUyr3T2Kwk+7yo5sUsQXozZxOCDXt31nHJR0+stbcJLXn6SIJf77zBkFGPTUu
         NetFQp7tpnEY4AM52wm280f+g0LwLpJkypBKexZ1Z9/S46qfSjh3pvYepyG+4awZD1zS
         Bf8FVr70bTQQm169CKhuz8Bt7LJpxb4/BmF1HN8s1Tj4XbLijsr81J5w4/7Dyavo70FR
         LGiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=U4sFjNzVPTFL7yvvxqemviKGsQd3j5YPgbZcl+o4n2I=;
        b=W0Es35EBqhdgF+TTH7NFblaeB7LxR97fODWg5SP7eoskQIPWq9kajP+i1z+yihAJMP
         n2DfjQsjTt9WiNjz8jBXlLoczZrTyroDROFF/bb9NptqeAYWGZVp7D0B9V5hiKStsR3V
         c/50JHQwgPX+uhED8OFKyGXpr20/sZMkxYx4B1DFUOEDHC9UQoLJUSr8kD1yf9N6wl/B
         EMsUhgJTylf4IiRh69ZQKL0ulL+ToJ/Y89RX1tjgsRc2uUf/h3GkVkvH4E6St8y875M9
         boppfniUz9syW25H19mtGXoFYcwnNABoZHFuI7bnQlxNx5rmWeskIPhYeqlGTDDtOszH
         aX/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SI8F+xNZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ALomfEwb;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q9si9907134pjp.77.2019.06.17.08.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:00:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SI8F+xNZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ALomfEwb;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5HEvwZM025111;
	Mon, 17 Jun 2019 08:00:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=U4sFjNzVPTFL7yvvxqemviKGsQd3j5YPgbZcl+o4n2I=;
 b=SI8F+xNZf6+1zuWdd+/uNEMoVoW5ctCs1xUTkt/+toJn6IyDD/mKKJHLBpgntomNwx2W
 pOMZudWZ3detWiwJlLj/4NbmSfws5D5r5Z3D+ZT4N9vi9njHD+7Lpm0sYMTnfZNI0HaJ
 10pRp/wuJuCQs6MFPUIfXe2SwoNOtdWZWrs= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t6bq9rb3u-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 17 Jun 2019 08:00:14 -0700
Received: from ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 17 Jun 2019 08:00:11 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.100) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 17 Jun 2019 08:00:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=U4sFjNzVPTFL7yvvxqemviKGsQd3j5YPgbZcl+o4n2I=;
 b=ALomfEwbNHF9Ry14KAS8bLAsY885x/JOIATchTvxFmHf/IEnNBsXcRhlcec6hvN9UW9q/gw/flkKEPlCREr0X5yAAawulovPv9NT9FTW3//kpQCxXR5hJPaMUXrjgMpPl57P3bg2pLk4dW00IlBrES5Y6rX7H3uD5eDoQCftqHA=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB2998.namprd15.prod.outlook.com (20.178.238.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Mon, 17 Jun 2019 15:00:10 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Mon, 17 Jun 2019
 15:00:10 +0000
From: Rik van Riel <riel@fb.com>
To: Song Liu <songliubraving@fb.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com"
	<chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 2/3] mm,thp: stats for file backed THP
Thread-Topic: [PATCH v2 2/3] mm,thp: stats for file backed THP
Thread-Index: AQHVIt49ftbAbYwjIUGze895gpbLsaaf9PKA
Date: Mon, 17 Jun 2019 15:00:10 +0000
Message-ID: <418c52fe130183301029936b8ab001023a06d990.camel@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
	 <20190614182204.2673660-3-songliubraving@fb.com>
In-Reply-To: <20190614182204.2673660-3-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MN2PR07CA0030.namprd07.prod.outlook.com
 (2603:10b6:208:1a0::40) To BYAPR15MB3479.namprd15.prod.outlook.com
 (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:b340]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f7c76b97-ec3f-4185-caf1-08d6f3347e0e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2998;
x-ms-traffictypediagnostic: BYAPR15MB2998:
x-microsoft-antispam-prvs: <BYAPR15MB29989708F0744D976DE26890A3EB0@BYAPR15MB2998.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3276;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(396003)(39860400002)(346002)(136003)(189003)(199004)(476003)(52116002)(54906003)(305945005)(2501003)(316002)(76176011)(386003)(6506007)(102836004)(14454004)(118296001)(110136005)(7736002)(86362001)(558084003)(81156014)(8676002)(81166006)(2906002)(5660300002)(478600001)(6246003)(36756003)(186003)(6512007)(46003)(8936002)(66446008)(64756008)(66556008)(11346002)(446003)(66476007)(68736007)(4326008)(99286004)(6486002)(6436002)(6116002)(71190400001)(71200400001)(53936002)(229853002)(66946007)(486006)(73956011)(25786009)(2616005)(256004)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2998;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6x2lR5y3yaCIAKd3n84fsB98cMikhXPX96//h5aSSaZalcuG9Oy9iCHeHbgpwu8Uc0PTbLxnBW7ZqpQrsoumVGigoDn6nEkauPbrGstBmUKzonBQeO94IahRvJQONuyBUcj6XCwyVEDtmrQu11UZYA1dCxftxLeyQgCgbm9i5W/TRMw3TbVdsvI4fOM5ukxtuujC7vfWN44hqq/jmJokvpEsdlqnxZBT8Kdnk+cQ4GRLJk8Owwu5bsSfC05owrsLupXzP9BPolPHslGBzCDhkENnyDIU+WH0R3DqJJwQKohSpvBRkoWttSrSwB2wOOkdGMBtW6ZUTX+W/VoaWpnW9W16Vkk9tBhLWU46mD6NQ4R7wqq7hNRZ/ckko+gKAjUTvuFhhfph9PjBAcN17PA1eykqjCi9fnY9XqSIJPixuaQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FFC17CFAA9268A43AB5DED18CF823A3B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f7c76b97-ec3f-4185-caf1-08d6f3347e0e
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 15:00:10.1209
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2998
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=711 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170135
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA2LTE0IGF0IDExOjIyIC0wNzAwLCBTb25nIExpdSB3cm90ZToNCj4gSW4g
cHJlcGFyYXRpb24gZm9yIG5vbi1zaG1lbSBUSFAsIHRoaXMgcGF0Y2ggYWRkcyB0d28gc3RhdHMg
YW5kDQo+IGV4cG9zZXMNCj4gdGhlbSBpbiAvcHJvYy9tZW1pbmZvDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBTb25nIExpdSA8c29uZ2xpdWJyYXZpbmdAZmIuY29tPg0KDQpBY2tlZC1ieTogUmlrIHZh
biBSaWVsIDxyaWVsQHN1cnJpZWwuY29tPg0KDQo=

