Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01CEFC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:49:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5346218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 15:49:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bNXgVSNf";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="irqteWkU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5346218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 425CF8E0003; Thu, 31 Jan 2019 10:49:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FBD88E0001; Thu, 31 Jan 2019 10:49:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C50D8E0003; Thu, 31 Jan 2019 10:49:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C71F08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:49:26 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t7so1508723edr.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:49:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-transfer-encoding
         :mime-version;
        bh=bZe05LeFwWkwD1dYxHAECYci48pntEe72FbkOp3ldwg=;
        b=LcayodeRCkHP+sGRaiqYj/C3T9yD3Coi4jm/frqOPiPMxwjsz9TrDATs6p632AYFuc
         P2xW6JBCt0fakihyoTr1/j11TKmuIpxZD58krXTIv4vYP4UO9+JgHPCcfQmnVSZzffaz
         ziOCvaLRJ5NafegLanUTsk0yveJkxph1JVfSnoG5MqBkQt8Lby2gQ6En/6hDwCD8cBbb
         /54cS1OYQBuCjw9nsKDXVpFGic8YpN0/IaU9fZuLZdM0xysyzZz3Nc1mikaMl8VgNl8v
         fVP8nBmjsCj0bvlV27tkIf25jXrxw2NDpBeNzpQ/xpAvRZ96PoQMR6OaEPcVGsWnmBGW
         3Ssg==
X-Gm-Message-State: AJcUukdJfpb8nvtsuGjwJQcySPtUE+S6XyoADV8t24NoZV8l7jDf3zZo
	YLI73TrhRgyRpMAoZ5DICCw9bypZ8hBJAuTEHFHEc5uKhX7rsvNyc7CEt1py33c4xhnlku1/yTb
	NpZUQYs0ustEUBFoEgoz3Jfz6Krj53C2+mz2XJ//5bVDooJGhJFB5dO//BBZoXGkiFQ==
X-Received: by 2002:a50:940b:: with SMTP id p11mr33619118eda.135.1548949766380;
        Thu, 31 Jan 2019 07:49:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6VYAjMRMOJYJ6m6DOHazFXIp/2GMe5c6lJ91E//TsiaSOw+QF8pJgUOqz05LbFiCCUcYH5
X-Received: by 2002:a50:940b:: with SMTP id p11mr33619059eda.135.1548949765499;
        Thu, 31 Jan 2019 07:49:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548949765; cv=none;
        d=google.com; s=arc-20160816;
        b=Ejg/0IVGHwFJ98hEQ0uhwRiq7Z/axlRjRjPSt0SUK5/CO1Vffq2h/Lr1Dvu0ZudAe7
         gR0ggbm6r9WRnuKWrGW6cbaYpKoMsjk2csDlXM9Wkon9mD7+3XHjYkhKDVs1K3n96UX8
         Apf8Bj0rjt1Ez9GTZkjac1exT8YJ2LcRLW/lZiYGBaPVdyqwrLFstHAr9vGSlFDKmLqo
         m5qvYasri7vgV6q/tXURk8j0h28KuSvOKncM4TLFOjwJ5L8ynhzdHWcJjgSAOk/qnuCG
         V29AgFB2S0mPHhvWrd/MXzpLgdAhAJALQVxXYb981JkaBF8Zjtb7ekLG4ADSHllNjRgO
         edgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=bZe05LeFwWkwD1dYxHAECYci48pntEe72FbkOp3ldwg=;
        b=M4Wfb3D5JaXexi0Vlf9lNQTUmofuovKXso5f39rsJOdIViJl2mA68th6SkkZ1Ui6u+
         mseYEScZAk6n1LRwXmtyZz50Zxzx5WO5sulUwY+OGTZnyMEWM51Dsi6/xm7ZLP3fenSI
         Pr2uHpCC5Bx+ASuSV5y9dUxRBxs8MnutCuMpNs9sNfWE2Fya3KUD+Jce3EpRNZkTCB6/
         SAg1KZkkDC1rhjCmeNSaaReP1Rat6+0z+GNtjac45R9qPpWboc7e+gHytWuQk4VXs7D+
         SvaDziupLlIDcPVbVZO9drr45ZdEKiWJa93/A0126CeD5XKlL2qtJTp5oClR0AKAhjiz
         JivQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bNXgVSNf;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=irqteWkU;
       spf=pass (google.com: domain of prvs=7934105d56=clm@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=7934105d56=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u28si333570edi.62.2019.01.31.07.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 07:49:25 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=7934105d56=clm@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bNXgVSNf;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=irqteWkU;
       spf=pass (google.com: domain of prvs=7934105d56=clm@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=7934105d56=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0VFcmOf002531;
	Thu, 31 Jan 2019 07:49:21 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=bZe05LeFwWkwD1dYxHAECYci48pntEe72FbkOp3ldwg=;
 b=bNXgVSNfjUyF1QpoRUEW0BZQHo5ZVc/P8eWuBJJ2NnYDxkANPP+KAN/PV2FFpEF0Fo24
 b/MzuI5ASLBdWbankDhd8AsvdekwTQs6vmRm/6XP2LKgjeH+80jy8a3folZPTYvqfZNk
 BbCzdr01Map2J4ChkDqRAriNAWOKSHLTQNE= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qc1a10hxk-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 31 Jan 2019 07:49:21 -0800
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub01.TheFacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 31 Jan 2019 07:48:13 -0800
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 31 Jan 2019 07:48:13 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bZe05LeFwWkwD1dYxHAECYci48pntEe72FbkOp3ldwg=;
 b=irqteWkUnlrYuuwlSY75KLhmCQgcTurVq6Ts9VTfnoZO0p7OL601SPpkc/VQg7ygpHdMdzMZvECYCbSAuC6KMCIrhs52hy4trkg6Kh0xsNMH6stz0MJYbGYzJE01sbwAqTf4Vg7xpm3dYz2h4qPOPwkl3bZDtw2DsqVYqUTdZF4=
Received: from DM5PR15MB1883.namprd15.prod.outlook.com (10.174.247.135) by
 DM5PR15MB1209.namprd15.prod.outlook.com (10.173.209.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.17; Thu, 31 Jan 2019 15:48:11 +0000
Received: from DM5PR15MB1883.namprd15.prod.outlook.com
 ([fe80::9c23:2db3:1e2a:4796]) by DM5PR15MB1883.namprd15.prod.outlook.com
 ([fe80::9c23:2db3:1e2a:4796%9]) with mapi id 15.20.1558.025; Thu, 31 Jan 2019
 15:48:11 +0000
From: Chris Mason <clm@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org"
	<mhocko@kernel.org>,
        "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Thread-Topic: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Thread-Index: AQHUuFK1zOCFq26G8UWPT6kjO3PxRaXHu+OAgADdj4CAAO6hAA==
Date: Thu, 31 Jan 2019 15:48:11 +0000
Message-ID: <E8895615-9DDA-4FC5-A3AB-1BE593138A89@fb.com>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com> <20190131013403.GI4205@dastard>
In-Reply-To: <20190131013403.GI4205@dastard>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: MailMate (1.12.4r5594)
x-clientproxiedby: BN6PR22CA0065.namprd22.prod.outlook.com
 (2603:10b6:404:ca::27) To DM5PR15MB1883.namprd15.prod.outlook.com
 (2603:10b6:4:4f::7)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c091:180::1:9acc]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR15MB1209;20:+FzV+hhrDmQEdxoitFZHMT1PWZE7vg7QVpjtg3fRRI++YbjJrFPkeiv1km3ZE8ZjHz4/t9we3eW7BEFd9clrMLWIlisFjIRaFAmscQ+UxPcOymw+6oFx7LLtoWXKkCRC+Zz8xqjTb4/kjZFVHc7Fnii2sSOhLT45BtwvJ31mR2Y=
x-ms-office365-filtering-correlation-id: 7bc2a95f-4cab-4b25-b16f-08d687938109
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:DM5PR15MB1209;
x-ms-traffictypediagnostic: DM5PR15MB1209:
x-microsoft-antispam-prvs: <DM5PR15MB12094FA8A2731E99F8DE2E90D3910@DM5PR15MB1209.namprd15.prod.outlook.com>
x-forefront-prvs: 09347618C4
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(346002)(136003)(366004)(39860400002)(199004)(51444003)(189003)(478600001)(76176011)(82746002)(6486002)(7736002)(386003)(6506007)(53546011)(6116002)(52116002)(102836004)(6306002)(53936002)(186003)(305945005)(33656002)(316002)(14454004)(6512007)(6436002)(966005)(50226002)(93886005)(99286004)(54906003)(106356001)(11346002)(71190400001)(83716004)(71200400001)(2616005)(97736004)(105586002)(476003)(486006)(4326008)(81166006)(446003)(8676002)(39060400002)(68736007)(6916009)(2906002)(36756003)(86362001)(25786009)(256004)(6246003)(8936002)(229853002)(81156014)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM5PR15MB1209;H:DM5PR15MB1883.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 9SmKB3ybe3AJs41yp/NbPRUtthMoM3CtIIzj9St+4hN+bwL610v10VwXgcAc7T+kAaVWM8shjbUPh7pOLd1llEIsulbs7WP0DNDUHCPu/O4TlV2kevsmPpaNQbzg818zsJ/O8ck6HQ82LuP6mT4ZeUllKug7+5IK9qN64hL8YcxhOIoxulMHaG7vN6CfHXM+QDOBhPMDpfZNsDbAFjB9ec6GwsJnduWU4hdzTI4p6WnhTE3whPdQs7H0Nil090YrsvYPfJcNH77I9qoq5Mk+gJ5xovj7VhOuyB2o82a3wcYR/cCl2Jny6i7HHg0WQsnOdu7DpiUi9tQC2NvkbQWhze25RKLklClcDNCS6BBV4NVsi57kpxjLL21zkirRJTh+84VAop8ug0nJehsegHwIv64Kwa0Csgx9n0BKRox0Sfc=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7bc2a95f-4cab-4b25-b16f-08d687938109
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jan 2019 15:48:10.3172
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR15MB1209
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30 Jan 2019, at 20:34, Dave Chinner wrote:

> On Wed, Jan 30, 2019 at 12:21:07PM +0000, Chris Mason wrote:
>>
>>
>> On 29 Jan 2019, at 23:17, Dave Chinner wrote:
>>
>>> From: Dave Chinner <dchinner@redhat.com>
>>>
>>> This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.
>>>
>>> This change causes serious changes to page cache and inode cache
>>> behaviour and balance, resulting in major performance regressions
>>> when combining worklaods such as large file copies and kernel
>>> compiles.
>>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=3D202441
>>
>> I'm a little confused by the latest comment in the bz:
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D202441#c24
>
> Which says the first patch that changed the shrinker behaviour is
> the underlying cause of the regression.
>
>> Are these reverts sufficient?
>
> I think so.

Based on the latest comment:

"If I had been less strict in my testing I probably would have=20
discovered that the problem was present earlier than 4.19.3. Mr Gushins=20
commit made it more visible.
I'm going back to work after two days off, so I might not be able to=20
respond inside your working hours, but I'll keep checking in on this as=20
I get a chance."

I don't think the reverts are sufficient.

>
>> Roman beat me to suggesting Rik's followup.  We hit a different=20
>> problem
>> in prod with small slabs, and have a lot of instrumentation on Rik's
>> code helping.
>
> I think that's just another nasty, expedient hack that doesn't solve
> the underlying problem. Solving the underlying problem does not
> require changing core reclaim algorithms and upsetting a page
> reclaim/shrinker balance that has been stable and worked well for
> just about everyone for years.
>

Things are definitely breaking down in non-specialized workloads, and=20
have been for a long time.

-chris

