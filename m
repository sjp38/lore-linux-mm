Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E0E1C28CC0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3292261DE
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 00:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=marvell.com header.i=@marvell.com header.b="YZyNA+5L";
	dkim=pass (1024-bit key) header.d=marvell.onmicrosoft.com header.i=@marvell.onmicrosoft.com header.b="Z/GWibAX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3292261DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=marvell.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E13C6B027F; Thu, 30 May 2019 20:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39AB86B0280; Thu, 30 May 2019 20:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233C66B0281; Thu, 30 May 2019 20:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCFA96B027F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 20:06:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so3383050pgo.14
        for <linux-mm@kvack.org>; Thu, 30 May 2019 17:06:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:mime-version;
        bh=d7nxq1uSw40pP14jbOcFOYWZTOInzJ9O+Oscz7fFsrc=;
        b=KejOdTsH7TyN3Tz82LcGeIQQiZOgovsDp6kbWKiZLGrfbSAT3FCZwpfqV0iWrbcaiw
         2K4jRoNsHfzFCv5m0dyOx4eOJdB+cRXy/ceFtDG7RAPuPKTqxEterVXQhWWpjCxp9Agv
         Dla+Zw/FdvLySb8/jQorYgj+8klWLKVpTmLnGgclQYtdZFL/0d2F1sSFfCpe/JMEJKJc
         9dnw3wUOqKDgssJZdWKJ4WFRVZKL25/E5Wn66ZeccM0U6h0Bemc6WLo0Gh0vRiebbu5x
         gblagB2cDhv6jxqhRul0JrnKBU6RMwvK1W4yyQ22w8d2AvcUfEmx9XJBc/Q424pAK+O7
         e2RA==
X-Gm-Message-State: APjAAAUSXCwtgJS8Yeqr9bkY6IfH9ScUcYP/FpmMa0vYqSO/KDGzL12i
	gMuWvwLxGRUqVLFnFD77QO2Es5c5rusG8R0O8tBxAD6cFSrn0gZzmkXA05ijC49U33Gwjy8ftJO
	hpNBjUd9PLArpp+AhhYIdeFfVJJTIdoM76aehMCWs9RYi+4ngjDcWlC3Vr9sid+lljQ==
X-Received: by 2002:a17:90a:2561:: with SMTP id j88mr5955005pje.121.1559261204546;
        Thu, 30 May 2019 17:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydG44B7Wka+rvlzXaA2DXP7WP5rlONpU/qN+DqYlTpymECCItAMBsYkGtAgT2Bk5UodCgu
X-Received: by 2002:a17:90a:2561:: with SMTP id j88mr5954948pje.121.1559261203658;
        Thu, 30 May 2019 17:06:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559261203; cv=none;
        d=google.com; s=arc-20160816;
        b=At/SjGiqwPDX+t11rUmGDCLqwar7910PD65MoJ+1RjqszHHz9qWaeXeQlYbf3bGRmH
         B2BgNB0Z9J21kRCSq95fWbRkfyS3PuO9bOPAfyimJn1cFNqvwXrpYxZWjilDKJDFYPyp
         ynDaX2a+7u9kVDb+Aev1kDm77AfLykL8XrY4AY+z75+iuGFAcJxhsLF6p5OV7jVRIQts
         T6bOrk2ioSmXDtelaiA04Dll+t439GyT8O7PgY9UAMOCa/6O7kiOS4ehZUgjZZLiSYy6
         IWJKj/n3xwYWKcCSHMKmkTngge/atJFw5A50fcAqPiAIMX4T1L7/zYjPV2eW5uvsEA2v
         0o3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature:dkim-signature;
        bh=d7nxq1uSw40pP14jbOcFOYWZTOInzJ9O+Oscz7fFsrc=;
        b=cbxyrpQeDSv8WRPhbKhH9JqmMccc9biDZVWfr5XjsrTrgkG9zwaXtYqq3wTr9y3+gW
         XCRmsBEL1lqZkSJEqq6iV9gNgrfHKX72ZBb7A6G9cziGFNfFjTasn4+zUBUd2wCOwpQX
         BZy1KZrsNOYU4ltLxX6EU273KlJMP5qKZKz5e2KKHjUE1+Ry5hCc2/ybhSiFYcKWLxMi
         2kJiTU5Jg4P4Y3jwXIKuttvPYNPnBaJw1z9p0Y0U0HoAx0/fcqh116ZbGpZyCCubuO4h
         qA0Ir7MOLLs3c9fJS69p/iu4k2pinaaZfersXL9Uh0BJ1dQdS28eNa7Yp6t5QA6lxUF4
         EOFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b=YZyNA+5L;
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b="Z/GWibAX";
       spf=pass (google.com: domain of prvs=30532b5d15=ynorov@marvell.com designates 67.231.148.174 as permitted sender) smtp.mailfrom="prvs=30532b5d15=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from mx0b-0016f401.pphosted.com (mx0a-0016f401.pphosted.com. [67.231.148.174])
        by mx.google.com with ESMTPS id y125si4811756pfb.115.2019.05.30.17.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 17:06:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=30532b5d15=ynorov@marvell.com designates 67.231.148.174 as permitted sender) client-ip=67.231.148.174;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b=YZyNA+5L;
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b="Z/GWibAX";
       spf=pass (google.com: domain of prvs=30532b5d15=ynorov@marvell.com designates 67.231.148.174 as permitted sender) smtp.mailfrom="prvs=30532b5d15=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from pps.filterd (m0045849.ppops.net [127.0.0.1])
	by mx0a-0016f401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UNKoJB013270;
	Thu, 30 May 2019 16:20:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=marvell.com; h=from : to : cc :
 subject : date : message-id : references : in-reply-to : content-type :
 mime-version; s=pfpt0818; bh=d7nxq1uSw40pP14jbOcFOYWZTOInzJ9O+Oscz7fFsrc=;
 b=YZyNA+5Lch6NzdWnjDTDuvZlfduemPIhqe7Qc+umwmhKldIDxfRSpH7oBTJdRewldPAX
 wC6KH8pAHj6PZWDU+wTFDQGknXrLb9TETFGQXIF3PWmssOX4Q34hrHXt97UoeWHdMtbV
 dnfhjkV00DEP7jlew2a7M7ZVqma1TZfbakMk8m/kEyAymJBVXAhKabtYo+vfh/kAAqoo
 wcGCQDXDkeXmxVn4SV7zFR12LQ1cTMLD3rYquzaf4t3choejU5BmE1R/+uL9u3ygfnx0
 S5IMxYu1Z0ZaeyJoWOKoUIjwLJwcG5v9mK5vDHNPqVKffaFs+7XEBrKH/Q1ivhvk9ipe VA== 
Received: from sc-exch02.marvell.com ([199.233.58.182])
	by mx0a-0016f401.pphosted.com with ESMTP id 2stba9bm7a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 30 May 2019 16:20:53 -0700
Received: from SC-EXCH03.marvell.com (10.93.176.83) by SC-EXCH02.marvell.com
 (10.93.176.82) with Microsoft SMTP Server (TLS) id 15.0.1367.3; Thu, 30 May
 2019 16:20:52 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (104.47.44.56) by
 SC-EXCH03.marvell.com (10.93.176.83) with Microsoft SMTP Server (TLS) id
 15.0.1367.3 via Frontend Transport; Thu, 30 May 2019 16:20:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=marvell.onmicrosoft.com; s=selector2-marvell-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=d7nxq1uSw40pP14jbOcFOYWZTOInzJ9O+Oscz7fFsrc=;
 b=Z/GWibAXTFCmueaxc6Ft2rxKRxU63GCOvFrjK01/AV/jfO6+UIycJJ8Ve3u1az77EPKFypCHYDMxbNsU5U7PpYbzVhIwjtdZa+P64n7U3+JNumwIbNixBlLg3/GDgDrgf6FJrrMUqCsBindg0PC379D2UFIvlnuikz90yb9jLps=
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com (10.161.157.12) by
 BN6PR1801MB1985.namprd18.prod.outlook.com (10.161.154.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.20; Thu, 30 May 2019 23:20:45 +0000
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::dcb8:35bc:5639:1942]) by BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::dcb8:35bc:5639:1942%5]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 23:20:45 +0000
From: Yuri Norov <ynorov@marvell.com>
To: Qian Cai <cai@lca.pw>
CC: Andrey Konovalov <andreyknvl@google.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Andy Shevchenko
	<andriy.shevchenko@linux.intel.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [EXT] "lib: rework bitmap_parse()" triggers invalid access errors
Thread-Topic: [EXT] "lib: rework bitmap_parse()" triggers invalid access
 errors
Thread-Index: AQHVFxoODR4JTfLgj0qm7X2ZHF02n6aETV3p
Date: Thu, 30 May 2019 23:20:45 +0000
Message-ID: <BN6PR1801MB20652E92AA9F04B2490BD4F3CB180@BN6PR1801MB2065.namprd18.prod.outlook.com>
References: <1559242868.6132.35.camel@lca.pw>
In-Reply-To: <1559242868.6132.35.camel@lca.pw>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [192.31.105.237]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e859e793-7414-4802-1cd7-08d6e5557167
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN6PR1801MB1985;
x-ms-traffictypediagnostic: BN6PR1801MB1985:
x-microsoft-antispam-prvs: <BN6PR1801MB1985230AC0C81ED6E42EB114CB180@BN6PR1801MB1985.namprd18.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:605;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(39860400002)(346002)(136003)(396003)(366004)(376002)(199004)(189003)(486006)(478600001)(4326008)(66066001)(476003)(11346002)(14454004)(53546011)(102836004)(53936002)(6246003)(99286004)(19627405001)(4744005)(3846002)(71190400001)(6506007)(52536014)(6116002)(33656002)(86362001)(71200400001)(5660300002)(68736007)(64756008)(66946007)(8676002)(76176011)(7736002)(9686003)(316002)(55016002)(74316002)(8936002)(66446008)(54896002)(26005)(6436002)(25786009)(81156014)(2906002)(76116006)(73956011)(6606003)(81166006)(229853002)(7696005)(256004)(66556008)(66476007)(91956017)(6916009)(446003)(54906003)(186003)(14444005);DIR:OUT;SFP:1101;SCL:1;SRVR:BN6PR1801MB1985;H:BN6PR1801MB2065.namprd18.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: marvell.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: iIwHqKYVnMt5xa91OOsr74Bp9tP/SphxRoXRDy+jTD2yys5zFe5dQRijQRTyFJyx68g+wI8Lk9Yf90UUXKt4/2/bxSVBhb/lFX9DxWytGvW0GrCqnVGfeMRSJfT9N1T40vP2J8UnRC0fi6rvFknDWfVX7TXG5jh208C5OzYsMA/p0ShIkvD7Ii21hOM3/wB2pDoEmQ8bqCE70RpMxCwPAxB+oK+uaDbkFJ057mdrZif30ry/dhgKMUbeRrlQcm5hTy0XG9B8oqXTjQ+guywZDcfk2XGV27UIsC7V/10oxQn539Faovtg9Zuy3vmOPbrbPgKILh2V3BT4gaUN1g75jEAkUpc3sIxwUmgC55syRFm2W1kGJRTHQe4XHO0MXfmkLUGZEZh+dd3AwP7zLftPp2lGE72QTvcmzdP4rBfTX0k=
Content-Type: multipart/alternative;
	boundary="_000_BN6PR1801MB20652E92AA9F04B2490BD4F3CB180BN6PR1801MB2065_"
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e859e793-7414-4802-1cd7-08d6e5557167
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 23:20:45.5131
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 70e1fb47-1155-421d-87fc-2e58f638b6e0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ynorov@marvell.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR1801MB1985
X-OriginatorOrg: marvell.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_14:,,
 signatures=0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000054, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_BN6PR1801MB20652E92AA9F04B2490BD4F3CB180BN6PR1801MB2065_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

From: Qian Cai <cai@lca.pw>
Sent: Thursday, May 30, 2019 11:01 PM
To: Yuri Norov
Cc: Andrey Konovalov; linux-kernel@vger.kernel.org; Andy Shevchenko; Andrew=
 Morton; linux-mm@kvack.org
Subject: "lib: rework bitmap_parse()" triggers invalid access errors

> The linux-next commit "lib: rework bitmap_parse" triggers errors below du=
ring
> boot on both arm64 and powerpc with KASAN_SW_TAGS or SLUB_DEBUG enabled.

> Reverted the commit and its dependency (lib: opencode in_str()) fixed the=
 issue.

Thanks, I'll take a look

[...]


--_000_BN6PR1801MB20652E92AA9F04B2490BD4F3CB180BN6PR1801MB2065_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size: 12pt; color: rgb(0, 0,=
 0); font-family: Calibri, Helvetica, sans-serif, &quot;EmojiFont&quot;, &q=
uot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, NotoColorEmoji, &q=
uot;Segoe UI Symbol&quot;, &quot;Android Emoji&quot;, EmojiSymbols;" dir=3D=
"ltr">
<font style=3D"font-size:11pt" face=3D"Calibri, sans-serif" color=3D"#00000=
0"><b>From:</b> Qian Cai &lt;cai@lca.pw&gt;</font><br>
<div style=3D"color: rgb(0, 0, 0);">
<div class=3D"PlainText"><font style=3D"font-size:11pt" face=3D"Calibri, sa=
ns-serif" color=3D"#000000"><b>Sent:</b> Thursday, May 30, 2019 11:01 PM<br=
>
<b>To:</b> Yuri Norov<br>
<b>Cc:</b> Andrey Konovalov; linux-kernel@vger.kernel.org; Andy Shevchenko;=
 Andrew Morton; linux-mm@kvack.org<br>
<b>Subject:</b> &quot;lib: rework bitmap_parse()&quot; triggers invalid acc=
ess errors</font></div>
<div class=3D"PlainText"><br>
&gt; The linux-next commit &quot;lib: rework bitmap_parse&quot; triggers er=
rors below during<br>
&gt; boot on both arm64 and powerpc with KASAN_SW_TAGS or SLUB_DEBUG enable=
d.<br>
<br>
&gt; Reverted the commit and its dependency (lib: opencode in_str()) fixed =
the issue.<br>
<span><br>
</span></div>
<div class=3D"PlainText"><span>Thanks, I'll take a look</span><br>
</div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText">[...]<br>
<br>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
"></span></font></div>
</div>
</div>
</body>
</html>

--_000_BN6PR1801MB20652E92AA9F04B2490BD4F3CB180BN6PR1801MB2065_--

