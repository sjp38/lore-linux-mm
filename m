Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B71FC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E001020B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:12:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="K6typON+";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="kR66EuzE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E001020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7152A6B0006; Fri,  2 Aug 2019 10:12:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69E5E6B0008; Fri,  2 Aug 2019 10:12:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5175F6B000A; Fri,  2 Aug 2019 10:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC1D6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:12:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i134so10270618pgd.11
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:12:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-transfer-encoding
         :mime-version;
        bh=deEulwZ0m1CYmU9G9emLgJ5CQF17fbjreDXh/PvQ7Ac=;
        b=oNaQKPf7qFd0xmoGuURgbQYqHsTN79GnMxI4/U2NdTnLCd5DE1T8jQ2NYObrezFOkt
         7ylMVyoBV9WuRjUxpyH6ukxFIesJYVLfsu+xZx1s/UQM3L54maFZjBVt2zBjMCSqT1lK
         U7e8Y4jHm71SIg6qyaAXv5mOB1BvB1cukj3xbyGbsFhaFMC/4hY32Gch1iT2KJFjYSN5
         qwiEek6aWNnCNj+GHcnmAxG9caBe/nUs+81YJu4JzsewmVhGYG44RHEuKTvn4hlOWQD5
         bN0y4me1hdm9mDUAEdMYnVbcFAs4f9iCV7aHrZZgKZpCdZx11KnNv/an8hv4HqlAOgs3
         IrUQ==
X-Gm-Message-State: APjAAAWSbgQXsIWPGj0Nr9IzNsIO/accfdSpgLuVvWX7W81iG9lO+GAk
	JlSx4TL6BiX0ts5fC6NQ0xnob/ed8Qk3Rla70AOJTCE095QmpAgCHBkRoDYYmvseYGRHy4zGIIH
	yyUteQNXBFiHPyOVIvfP0fGO8qEsRmgdZ2WTujvfa5mh7vet7y6wspExUKmQQOfMZYQ==
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr4480832pje.125.1564755146679;
        Fri, 02 Aug 2019 07:12:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIma5+V29ofxAY/jDahQCE03thKy0JZ16mKACUbQSOvoHjN1lu05wCczlzIPGhiRNV9TvR
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr4480749pje.125.1564755145656;
        Fri, 02 Aug 2019 07:12:25 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564755145; cv=pass;
        d=google.com; s=arc-20160816;
        b=kUI9CJznOtXyMzALgQUQHbpAuuF4GB9aHltWg1eHPdgGJrlg6tVtp41HEZo7yAWG7+
         5vPNDQWohxwsm3+uRrbAxu3vWQmYx01j62N8F54II6b4oASrQkfnpXJH+lZTo8f0wNlP
         ltqCybqTIlrJEOPbBczJUxVlfgKj6HB6rmOqX8SxE4SeLeer3n1gyqyzEbQm+ztEdnS0
         GdG2YnDupPgBP2mhRd6t+vQ+dxicaqttRgTwjzEVATLHyvLlFUMfSBvTtUoGG2eIvYXp
         w0IjNi8BRAQT6Bd43uI/l85UO0BPM+AY8+A9JDir3iOlVvHjK02IciQ/XBvcPLu9bxDd
         jWJw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=deEulwZ0m1CYmU9G9emLgJ5CQF17fbjreDXh/PvQ7Ac=;
        b=z4/W+MrubMXRlvWgfKoVN/jfnsAOYu8q8uLLFJHiE2tLda0cQoJEJCPNOkxWmOMvSs
         z966KIjeY+zWfrvwqhaXDf0zxStuBKOZG09g6fkEyleAh21J6ZK5ZW/bgHbbUmoYGhpN
         yd0qscJKPhZuyqRxlgMaJWH15p55IMGAMnbYs1xDl60uI69uP76uNfkvGcVGLRa5bqnk
         a4nBDYPUv8bxbP3afD93xm2HTicdf2xgEWqdGdU53ub4QAGCAQiVitZ322fqnfuYUPmK
         APdyMmZsFNW9SVkMjtl/a3CNDDqLFvJbiOnixQ7gUBPvmZlloxTq5lFU3uL8oz72vnvM
         ePtw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K6typON+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=kR66EuzE;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31176fc4b7=clm@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176fc4b7=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g34si34316463pld.266.2019.08.02.07.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 07:12:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31176fc4b7=clm@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K6typON+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=kR66EuzE;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31176fc4b7=clm@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176fc4b7=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72EBu5X021884;
	Fri, 2 Aug 2019 07:12:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=deEulwZ0m1CYmU9G9emLgJ5CQF17fbjreDXh/PvQ7Ac=;
 b=K6typON+tD279NM23lStQqdjz+e+x5FJwmWKTttWP3rEoptFyXdlEJp5N3kJGMrXDZnj
 seKm3ztrgFCoqHpD5HdAGoo5JVonTHw+K0dV9XQ4rvmS6ADrcfLoMv7uEYjLrPIh1lLr
 SpM0qEzNKNrvEmL0I5fbPiRMbO2iYeHCBQg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u4j3j8x3v-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 02 Aug 2019 07:12:22 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 2 Aug 2019 07:12:08 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 2 Aug 2019 07:12:08 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=MNq4f9rX50Frl9ZkkrbcBpG3NiofWUwEj7QJTIUMtK35k2RWvxdcFnJIcqG2oPWciBjNyaCJ8yklsPWC+UzH1Jdbwhf6tc1+7qxNk0gT+X5xZdPljbICxKXYOY4f23j3V+zH6gM5n5FWCTXNFJxdnfQYpduYyNG+nzoEolWZaayi3CNAEvhLUNDnIckGJnMGYFt4sOjH+qguUxisCu21etF5Np0K5SuVeJtFmfabW5bTrMgDV4kNhjxetJvwldhBiH3QmISReMetGh/o9JgkmxO1+HNmgvzghPFY34DOmMMemdoUM66DMVMPHqUHNUjJusvfK4f8zcSLaOxygyue4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=deEulwZ0m1CYmU9G9emLgJ5CQF17fbjreDXh/PvQ7Ac=;
 b=G2vWSiqidyV3jRmzuXWQ+mXFVNVx7upWggCSuOrwO/dr6140hjeyRP2zdJKmY9kxcK2fTXJczPx54qYixzt/xG4Ki3swIIjo85zeJdIVbBKvdxL1ms+sABv5G5gWPopcQ30NjQz+GtSbwhBb97uNkayW7ryxF/mavdAiFH8txrlEh0OMueZhOJQof+8SCDgFHsP9bsYh/y7U2rvmWqbU9ZoWjcH/qf7/qEPvTFTILyDdboeLehwlNBP5pMxts6wLR4mT4FPIirStrRfq0QN7msswJGE4ZNDSHSv6nVK1lDxbn2+f0rX8ApUX8XkclPE1cSvnVIeAE/MpmPL1fmXcXQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=deEulwZ0m1CYmU9G9emLgJ5CQF17fbjreDXh/PvQ7Ac=;
 b=kR66EuzElwD7fCtJQYpKZjdPD3d/VlEGl6wpz1UQktqgxS0d7OSds42eF/EHAJrWkimVS9Q3fAAqekwZe6oXzEXBjf1Ek5cJM5KmMz86Ax6QCgSmVpNpWB+0CMGEIcQS5AYlrnajIOAM15hX989dkzfo82nnNN5vZv7Vs+k9eDg=
Received: from DM5PR15MB1290.namprd15.prod.outlook.com (10.173.212.17) by
 DM5PR15MB1195.namprd15.prod.outlook.com (10.173.213.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.14; Fri, 2 Aug 2019 14:11:53 +0000
Received: from DM5PR15MB1290.namprd15.prod.outlook.com
 ([fe80::4d32:13fc:cf5b:4746]) by DM5PR15MB1290.namprd15.prod.outlook.com
 ([fe80::4d32:13fc:cf5b:4746%7]) with mapi id 15.20.2136.010; Fri, 2 Aug 2019
 14:11:53 +0000
From: Chris Mason <clm@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Thread-Topic: [PATCH 09/24] xfs: don't allow log IO to be throttled
Thread-Index: AQHVSA9fnWuPStnf6EeOPJMMPtRTUqbmCewAgADwFYCAAO5UAA==
Date: Fri, 2 Aug 2019 14:11:53 +0000
Message-ID: <7093F5C3-53D2-4C49-9C0D-64B20C565D18@fb.com>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
 <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
 <20190801235849.GO7777@dread.disaster.area>
In-Reply-To: <20190801235849.GO7777@dread.disaster.area>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: MailMate (1.12.5r5635)
x-clientproxiedby: MN2PR12CA0004.namprd12.prod.outlook.com
 (2603:10b6:208:a8::17) To DM5PR15MB1290.namprd15.prod.outlook.com
 (2603:10b6:3:b8::17)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c091:480::30bb]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1f39a4a2-31a7-4cc8-09b0-08d717535ea7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM5PR15MB1195;
x-ms-traffictypediagnostic: DM5PR15MB1195:
x-microsoft-antispam-prvs: <DM5PR15MB11958402EA9646A7CF3B8637D3D90@DM5PR15MB1195.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 011787B9DD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(396003)(376002)(366004)(136003)(199004)(189003)(81166006)(8676002)(81156014)(486006)(86362001)(71200400001)(71190400001)(6246003)(7736002)(2906002)(33656002)(6116002)(478600001)(36756003)(14454004)(8936002)(25786009)(14444005)(54906003)(50226002)(6916009)(76176011)(66446008)(305945005)(66946007)(66476007)(66556008)(99286004)(6512007)(53936002)(446003)(229853002)(4326008)(256004)(316002)(52116002)(476003)(102836004)(53546011)(386003)(11346002)(46003)(64756008)(186003)(6486002)(6506007)(68736007)(5660300002)(6436002)(2616005);DIR:OUT;SFP:1102;SCL:1;SRVR:DM5PR15MB1195;H:DM5PR15MB1290.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: GgOp6891Pr3yEfr+3dHN0QyU8VpiaY0ZQwxZfMQFGEpBNRoV8apWZD04Eut+eAr48qr9rIb+PggIunJdu/Gm8JJ3kNGdBJ47Btw82IRErtmxrFJ3NwefJqBDymzKnxK7BGR8Jn2G0NGMPRdsds9w06DDV8Lhk1+ay6qWAjcBGInIkoG+PNK1nzeMAV3+pkh5LYhrcKWFnpEpBLKKJluuUZfrx9Q16BrAsGNf09z4a5nJ1HhIvc17tLKw8sVye8R04hyhOE41RlhMkbaLbBa9zj8cBjkeNDmWj1Zm9sR0yAAEt3thySTcowqXLGP2wFolVBIi1FB2KFVU7PH/DdJtyTZKmkLNpjiKK/FgNagm8Kk/QWuZW89ntXbFax8ZYX4H5OiUZZk87USLyoRsGTpKZzEmTF3AFvgRtigDDU8SvFs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 1f39a4a2-31a7-4cc8-09b0-08d717535ea7
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Aug 2019 14:11:53.6443
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: clm@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR15MB1195
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020147
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1 Aug 2019, at 19:58, Dave Chinner wrote:

> On Thu, Aug 01, 2019 at 01:39:34PM +0000, Chris Mason wrote:
>> On 31 Jul 2019, at 22:17, Dave Chinner wrote:
>>
>>> From: Dave Chinner <dchinner@redhat.com>
>>>
>>> Running metadata intensive workloads, I've been seeing the AIL
>>> pushing getting stuck on pinned buffers and triggering log forces.
>>> The log force is taking a long time to run because the log IO is
>>> getting throttled by wbt_wait() - the block layer writeback
>>> throttle. It's being throttled because there is a huge amount of
>>> metadata writeback going on which is filling the request queue.
>>>
>>> IOWs, we have a priority inversion problem here.
>>>
>>> Mark the log IO bios with REQ_IDLE so they don't get throttled
>>> by the block layer writeback throttle. When we are forcing the CIL,
>>> we are likely to need to to tens of log IOs, and they are issued as
>>> fast as they can be build and IO completed. Hence REQ_IDLE is
>>> appropriate - it's an indication that more IO will follow shortly.
>>>
>>> And because we also set REQ_SYNC, the writeback throttle will no
>>> treat log IO the same way it treats direct IO writes - it will not
>>> throttle them at all. Hence we solve the priority inversion problem
>>> caused by the writeback throttle being unable to distinguish between
>>> high priority log IO and background metadata writeback.
>>>
>>   [ cc Jens ]
>>
>> We spent a lot of time getting rid of these inversions in io.latency
>> (and the new io.cost), where REQ_META just blows through the=20
>> throttling
>> and goes into back charging instead.
>
> Which simply reinforces the fact that that request type based
> throttling is a fundamentally broken architecture.
>
>> It feels awkward to have one set of prio inversion workarounds for=20
>> io.*
>> and another for wbt.  Jens, should we make an explicit one that=20
>> doesn't
>> rely on magic side effects, or just decide that metadata is meta=20
>> enough
>> to break all the rules?
>
> The problem isn't REQ_META blows throw the throttling, the problem
> is that different REQ_META IOs have different priority.

Yes and no.  At some point important FS threads have the potential to=20
wait on every single REQ_META IO on the box, so every single REQ_META IO=20
has the potential to create priority inversions.

>
> IOWs, the problem here is that we are trying to infer priority from
> the request type rather than an actual priority assigned by the
> submitter. There is no way direct IO has higher priority in a
> filesystem than log IO tagged with REQ_META as direct IO can require
> log IO to make progress. Priority is a policy determined by the
> submitter, not the mechanism doing the throttling.
>
> Can we please move this all over to priorites based on
> bio->b_ioprio? And then document how the range of priorities are
> managed, such as:
>
> (99 =3D highest prio to 0 =3D lowest)
>
> swap out
> swap in				>90
> User hard RT max		89
> User hard RT min		80
> filesystem max			79
> ionice max			60
> background data writeback	40
> ionice min			20
> filesystem min			10
> idle				0
>
> So that we can appropriately prioritise different types of kernel
> internal IO w.r.t user controlled IO priorities? This way we can
> still tag the bios with the type of data they contain, but we
> no longer use that to determine whether to throttle that IO or not -
> throttling/scheduling should be done entirely on a priority basis.

I think you and I are describing solutions to different problems.  The=20
reason the back charging works so well in io.latency and io.cost is=20
because the IO controllers are able to remember that a given cgroup=20
created X amount of IO, and then just make that cgroup wait at a safe=20
time, instead of trying to assign priority to things that have infinite=20
priority.

I can't really see bio->b_ioprio working without the rest of the IO=20
controller logic creating a sensible system, and giving userland the=20
framework to define weights etc.  My question is if it's worth trying=20
inside of the wbt code, or if we should just let the metadata go=20
through.

Tejun reminded me that in a lot of ways, swap is user IO and it's=20
actually fine to have it prioritized at the same level as user IO.  We=20
don't want to let a low prio app thrash the drive swapping things in and=20
out all the time, and it's actually fine to make them wait as long as=20
other higher priority processes aren't waiting for the memory.  This=20
depends on the cgroup config, so wrt your current patches it probably=20
sounds crazy, but we have a lot of data around this from the fleet.

-chris

