Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7850C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 22:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6220A26F59
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 22:36:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=marvell.com header.i=@marvell.com header.b="kGHV6O4A";
	dkim=pass (1024-bit key) header.d=marvell.onmicrosoft.com header.i=@marvell.onmicrosoft.com header.b="lp3Xf8WL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6220A26F59
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=marvell.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 061856B0269; Fri, 31 May 2019 18:36:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2D216B026A; Fri, 31 May 2019 18:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCF356B026B; Fri, 31 May 2019 18:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA5F56B0269
	for <linux-mm@kvack.org>; Fri, 31 May 2019 18:36:15 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id j6so8779986iom.3
        for <linux-mm@kvack.org>; Fri, 31 May 2019 15:36:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:mime-version;
        bh=RIK+8dr1u/ZklSH+m7dQIB3smBnxKEPF0UNlTR+XKUA=;
        b=pR47Go8YjdAII1NR0f1UuRGzCmxvKxvCgLXo4NcaFc/hlSfy5XnsfmoXm4J/TjpXal
         c/C97p24AUfVDCc6X1e37DGBA5mYvUU89XN4igAiII353Qft3FpSITyYC02f9aL0GAUW
         Rk4/3f91YeloCKVY1rH6UmmvDQR30yNxupXPc5oiPE17nuh4KeXJi/ijOvogh1b1597u
         lX9cXQStpgmLcxeFgqOLer7HsGm5BjMnA3aavArvQvs/Th5pyKpe3Wa/Stb8rCaI2tsz
         haMtMXTTtlhi7eNUAQPCFpW4V9MUfJhhlV7i1WxzR02P2bjtM/gUSv6q3HJ6P8Ch7hUi
         XzIw==
X-Gm-Message-State: APjAAAWNt5w60RQRT+MyTjCY0cZg9ehFEqXQyA3rAQ3tMJ6nj4KugXUC
	HCRQCurxL7npoQY4OKk/bB21p7EliqKbWteQU+xIjH82FjImnRjKgxbmLjWioWf/+hh+fBJv0cG
	EZASHWRo35jsJ2GRH71Lo0mobhJq3+zqWSvfg/CugYIQupJSDgtpcp0f8GaD/e1FnSA==
X-Received: by 2002:a02:1649:: with SMTP id a70mr8788930jaa.116.1559342175476;
        Fri, 31 May 2019 15:36:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd+khffxA2ZGN1ZuYwLhaIiRtGK8FM30SpzdbxBDQMsd8MGZrk/VSfzRRHwfqgp8EaFEvM
X-Received: by 2002:a02:1649:: with SMTP id a70mr8788889jaa.116.1559342174564;
        Fri, 31 May 2019 15:36:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559342174; cv=none;
        d=google.com; s=arc-20160816;
        b=rXXxkQM9gLulnivyLsu/P85Ub+s7QJX8EEww8SonaGAdtylCHc8FQpZtJx4V+cVoF+
         KxiiscMz/O82cYac8B43oMDumS2F1embfBMqH1ODWgi2q4jq+koCWDe/ktlQsO0wl7P1
         v+f1aSEfVRFOvDVlB4FNm7G4naBB8WKxPoqN5Md4CUZuvrkVozeQKXi3UjUzWCUyNdhy
         6kLtM/P5ssTdYvtPSp54Gut5G7FiVhwFWBGIy8oykOp2t1LgJSfJmGAXhuPO3BEQ+p/u
         ciHwm/ucqwWJTXOMOvOfqOQb6w85Psyj+LyhNSq8znHfHHIxI2TPdqpOey153ApFjIN7
         pLdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature:dkim-signature;
        bh=RIK+8dr1u/ZklSH+m7dQIB3smBnxKEPF0UNlTR+XKUA=;
        b=I6P3hEb7sEyFqAHb3YU+K2BVERdVGPz4VELbWfkZCIY3oKLeUFUPSSDwT41z9ObXPW
         wo5OCjHWSg2Ld47wuep8wU/M2fyOzphzuVe3MPpg9YUz92XQxvxFR8ceIoa0Y2hkVn0C
         Aiqa1CV/GCfhupjhQwYvlt6aJ+gayqaUqdr5c+6h+4wcYAu9+Rx060IElJxnvoA5Gigt
         Ya/aBXJi+BL+S8fQOICbn3E7hHPUDDAHeb18c8Trme4pfg/IFOblKFa9zqp38zhVcOdK
         7YWl3z8HxrGMzljvftEuvUeWFOFYN4yuXlLzS4eb6zeBra2ndMXmgPujcSdxhbg+HY4u
         KBuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b=kGHV6O4A;
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b=lp3Xf8WL;
       spf=pass (google.com: domain of prvs=3054bb642c=ynorov@marvell.com designates 67.231.148.174 as permitted sender) smtp.mailfrom="prvs=3054bb642c=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from mx0b-0016f401.pphosted.com (mx0a-0016f401.pphosted.com. [67.231.148.174])
        by mx.google.com with ESMTPS id 128si4735594itl.122.2019.05.31.15.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 15:36:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3054bb642c=ynorov@marvell.com designates 67.231.148.174 as permitted sender) client-ip=67.231.148.174;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b=kGHV6O4A;
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b=lp3Xf8WL;
       spf=pass (google.com: domain of prvs=3054bb642c=ynorov@marvell.com designates 67.231.148.174 as permitted sender) smtp.mailfrom="prvs=3054bb642c=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from pps.filterd (m0045849.ppops.net [127.0.0.1])
	by mx0a-0016f401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4VMP75k002337;
	Fri, 31 May 2019 15:36:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=marvell.com; h=from : to : cc :
 subject : date : message-id : references : in-reply-to : content-type :
 mime-version; s=pfpt0818; bh=RIK+8dr1u/ZklSH+m7dQIB3smBnxKEPF0UNlTR+XKUA=;
 b=kGHV6O4Ayvsb0VuolxYDAyUZmE6uRAnLv/toq/Th2paPWFx8yWITzDkEy8ofhIlBbKYi
 DcJKfM8UHvQcJOypDGWbEX43JE1Ui+ExkC2ZKCpr7kI7YhvAxAti1m2mNACFRT2kmwx8
 JgY303/DQ2krB3vqyBBcyVodtniZ85MEfuotr5rD24j2zT1Cz10FAjijReOlayVQSLTO
 oJS2kBeKFGiBem6/8fHRbTTpJpDNQXBFc6nytj92+kIRaEfcDsZhzfwgyiZKdWDIpQ8I
 0k6rVAZN0+iT/k40n7eFd4gsn5Z7iGboDxxh3k+M4iDP5erFXUZ4gDzX0+jKAO8ULc0u AA== 
Received: from sc-exch04.marvell.com ([199.233.58.184])
	by mx0a-0016f401.pphosted.com with ESMTP id 2su6g1sp7f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 31 May 2019 15:36:07 -0700
Received: from SC-EXCH03.marvell.com (10.93.176.83) by SC-EXCH04.marvell.com
 (10.93.176.84) with Microsoft SMTP Server (TLS) id 15.0.1367.3; Fri, 31 May
 2019 15:36:06 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (104.47.41.54) by
 SC-EXCH03.marvell.com (10.93.176.83) with Microsoft SMTP Server (TLS) id
 15.0.1367.3 via Frontend Transport; Fri, 31 May 2019 15:36:06 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=marvell.onmicrosoft.com; s=selector2-marvell-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RIK+8dr1u/ZklSH+m7dQIB3smBnxKEPF0UNlTR+XKUA=;
 b=lp3Xf8WLvLAFlf7ob4/7RN9bZliueLe4DPVOCLCFb3tKoT8AvqfO8hfJxpcNEBE5yl01+z66NvLurWlAS+rcGHBZLmtOd235Ss3A61MebFGZrfUiVKlvU4gR8YYj49LLJPI7IehenPc0oPUKWpbNAz69XwPria7HYaX0tZPJYtI=
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com (10.161.157.12) by
 BN6PR1801MB1908.namprd18.prod.outlook.com (10.161.153.14) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.18; Fri, 31 May 2019 22:36:03 +0000
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::dcb8:35bc:5639:1942]) by BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::dcb8:35bc:5639:1942%5]) with mapi id 15.20.1922.021; Fri, 31 May 2019
 22:36:03 +0000
From: Yuri Norov <ynorov@marvell.com>
To: Qian Cai <cai@lca.pw>, Dexuan-Linux Cui <dexuan.linux@gmail.com>,
        "Mike
 Kravetz" <mike.kravetz@oracle.com>
CC: "Huang, Ying" <ying.huang@intel.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
        Andrea Parri
	<andrea.parri@amarulasolutions.com>,
        "Paul E . McKenney"
	<paulmck@linux.vnet.ibm.com>,
        Michal Hocko <mhocko@suse.com>, Minchan Kim
	<minchan@kernel.org>,
        Hugh Dickins <hughd@google.com>, Dexuan Cui
	<decui@microsoft.com>,
        "v-lide@microsoft.com" <v-lide@microsoft.com>,
        "Yury
 Norov" <yury.norov@gmail.com>
Subject: Re: [EXT] Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
Thread-Topic: [EXT] Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
Thread-Index: AQHVF+Vv2V1HT6rTK0GyY8zH9JbqY6aF0CMp
Date: Fri, 31 May 2019 22:36:03 +0000
Message-ID: <BN6PR1801MB2065F9E5FF6F9E8928879290CB190@BN6PR1801MB2065.namprd18.prod.outlook.com>
References: <20190531024102.21723-1-ying.huang@intel.com>
	 <2d8e1195-e0f1-4fa8-b0bd-b9ea69032b51@oracle.com>
	 <CAA42JLZ=X_gzvH6e3Kt805gJc0PSLSgmE5ozPDjXeZbiSipuXA@mail.gmail.com>,<1559330205.6132.40.camel@lca.pw>
In-Reply-To: <1559330205.6132.40.camel@lca.pw>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [172.56.30.76]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 63caecb1-0264-4d37-316e-08d6e6185d12
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN6PR1801MB1908;
x-ms-traffictypediagnostic: BN6PR1801MB1908:
x-ms-exchange-purlcount: 3
x-microsoft-antispam-prvs: <BN6PR1801MB1908867D0D09C01DC56A41C1CB190@BN6PR1801MB1908.namprd18.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:854;
x-forefront-prvs: 00540983E2
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(136003)(376002)(346002)(366004)(39850400004)(199004)(189003)(6436002)(7696005)(4326008)(76176011)(5660300002)(45080400002)(6606003)(99286004)(8676002)(66066001)(14454004)(186003)(476003)(7416002)(33656002)(478600001)(6246003)(256004)(25786009)(14444005)(1015004)(229853002)(86362001)(3846002)(73956011)(53936002)(76116006)(66946007)(966005)(66476007)(66556008)(64756008)(66446008)(54896002)(486006)(6306002)(6116002)(68736007)(606006)(6506007)(8936002)(71200400001)(71190400001)(9686003)(102836004)(11346002)(19627405001)(446003)(236005)(55016002)(110136005)(81156014)(81166006)(54906003)(53546011)(52536014)(2906002)(74316002)(7736002)(26005)(316002)(6606295002);DIR:OUT;SFP:1101;SCL:1;SRVR:BN6PR1801MB1908;H:BN6PR1801MB2065.namprd18.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: marvell.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: GMfjzsLMk1n/k0Z54nR5rEpE1PaXKZzWs07C4V22ouU5dlVHB03grRtrzBLFekUjPCs7R7I/2+HaoF57rJ3bz+ZgD+Eo/VyrHwfgOhahk7GaK/ybOehxzNspttVorva2gWQFVUTgTUETnBfJmU+QJV9aGPG6lN1EY0lfJzNa9eGh5FCbcs21CQlKnkp+GoWwwX/D/loGgFYhzPVkE8BbiFw/+NM2h/ubPYeOhBaOdvC7Gx9LENXb9mwFVrTXmabQ2MhwQt3uQ0k6IBzaMTN8zi9e+XQRaTXFuebJ5BoyN8IkypH1yz5s2bD4XfKW+utQu+KnNned+0IND1txXa9DQey9bb0ynvx6nNE3FhLiRAXrJTFcMIJ+ywWnDF/0VcAHU7ufEBS6dE45VFGhOs5poRvDdhbe9mVEMq+JzxBTtCE=
Content-Type: multipart/alternative;
	boundary="_000_BN6PR1801MB2065F9E5FF6F9E8928879290CB190BN6PR1801MB2065_"
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 63caecb1-0264-4d37-316e-08d6e6185d12
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 May 2019 22:36:03.2085
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 70e1fb47-1155-421d-87fc-2e58f638b6e0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ynorov@marvell.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR1801MB1908
X-OriginatorOrg: marvell.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-31_15:,,
 signatures=0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_BN6PR1801MB2065F9E5FF6F9E8928879290CB190BN6PR1801MB2065_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable




________________________________
From: Qian Cai <cai@lca.pw>
Sent: Friday, May 31, 2019 11:16 PM
To: Dexuan-Linux Cui; Mike Kravetz
Cc: Huang, Ying; Andrew Morton; linux-mm@kvack.org; Linux Kernel Mailing Li=
st; Andrea Parri; Paul E . McKenney; Michal Hocko; Minchan Kim; Hugh Dickin=
s; Dexuan Cui; v-lide@microsoft.com; Yuri Norov
Subject: [EXT] Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
----------------------------------------------------------------------
> On Fri, 2019-05-31 at 11:27 -0700, Dexuan-Linux Cui wrote:
> > Hi,
> > Did you know about the panic reported here:
> > https://marc.info/?t=3D155930773000003&r=3D1&w=3D2
> >
> > "Kernel panic - not syncing: stack-protector: Kernel stack is
> > corrupted in: write_irq_affinity.isra> "
> >
> > This panic is reported on PowerPC and x86.
> >
> > In the case of x86, we see a lot of "get_swap_device: Bad swap file ent=
ry"
> > errors before the panic:
> >
> > ...
> > [   24.404693] get_swap_device: Bad swap file entry 5800000000000001
> > [   24.408702] get_swap_device: Bad swap file entry 5c00000000000001
> > [   24.412510] get_swap_device: Bad swap file entry 6000000000000001
> > [   24.416519] get_swap_device: Bad swap file entry 6400000000000001
> > [   24.420217] get_swap_device: Bad swap file entry 6800000000000001
> > [   24.423921] get_swap_device: Bad swap file entry 6c00000000000001

[..]

I don't have a panic, but I observe many lines like this.

> Looks familiar,
>
> https://lore.kernel.org/lkml/1559242868.6132.35.camel@lca.pw/<https://lor=
e.kernel.org/lkml/1559242868.6132.35.camel@lca.pw/>
>
> I suppose Andrew might be better of reverting the whole series first befo=
re Yury
> came up with a right fix, so that other people who is testing linux-next =
don't
> need to waste time for the same problem.

I didn't observe any problems with this series on top of 5.1, and there's a=
 fix for swap that eliminates
the problem on top of current next for me:
https://lkml.org/lkml/2019/5/30/1630


<https://lkml.org/lkml/2019/5/30/1630>
LKML: "Huang, Ying": [PATCH -mm] mm, swap: Fix bad swap file entry warning<=
https://lkml.org/lkml/2019/5/30/1630>
lkml.org
From: Huang Ying <ying.huang@intel.com> Mike reported the following warning=
 messages get_swap_device: Bad swap file entry 1400000000000001 This is pro=
duced by
Could you please test your series with the patch of Huang Ying?

Thanks,
Yury

--_000_BN6PR1801MB2065F9E5FF6F9E8928879290CB190BN6PR1801MB2065_
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
<p style=3D"margin-top:0;margin-bottom:0"><br>
</p>
<br>
<br>
<div style=3D"color: rgb(0, 0, 0);">
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div class=3D"PlainText"><font style=3D"font-size:11pt" face=3D"Calibri, sa=
ns-serif" color=3D"#000000"><b>From:</b> Qian Cai &lt;cai@lca.pw&gt;<br>
<b>Sent:</b> Friday, May 31, 2019 11:16 PM<br>
<b>To:</b> Dexuan-Linux Cui; Mike Kravetz<br>
<b>Cc:</b> Huang, Ying; Andrew Morton; linux-mm@kvack.org; Linux Kernel Mai=
ling List; Andrea Parri; Paul E . McKenney; Michal Hocko; Minchan Kim; Hugh=
 Dickins; Dexuan Cui; v-lide@microsoft.com; Yuri Norov<br>
<b>Subject:</b> [EXT] Re: [PATCH -mm] mm, swap: Fix bad swap file entry war=
ning</font><br>
----------------------------------------------------------------------<br>
&gt; On Fri, 2019-05-31 at 11:27 -0700, Dexuan-Linux Cui wrote:<br>
&gt; &gt; Hi,<br>
<span>&gt; </span>&gt; Did you know about the panic reported here:<br>
<span>&gt; </span>&gt; <a href=3D"https://marc.info/?t=3D155930773000003&am=
p;r=3D1&amp;w=3D2" id=3D"LPlnk772316" class=3D"OWAAutoLink" previewremoved=
=3D"true">
https://marc.info/?t=3D155930773000003&amp;r=3D1&amp;w=3D2</a><br>
<span>&gt; </span>&gt; <br>
<span>&gt; </span>&gt; &quot;Kernel panic - not syncing: stack-protector: K=
ernel stack is<br>
<span>&gt; </span>&gt; corrupted in: write_irq_affinity.isra<span>&gt; </sp=
an>&quot;<br>
<span>&gt; </span>&gt; <br>
<span>&gt; </span>&gt; This panic is reported on PowerPC and x86.<br>
<span>&gt; </span>&gt; <br>
<span>&gt; </span>&gt; In the case of x86, we see a lot of &quot;get_swap_d=
evice: Bad swap file entry&quot;<br>
<span>&gt; </span>&gt; errors before the panic:<br>
<span>&gt; </span>&gt; <br>
<span>&gt; </span>&gt; ...<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.404693] get_swap_device: Bad s=
wap file entry 5800000000000001<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.408702] get_swap_device: Bad s=
wap file entry 5c00000000000001<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.412510] get_swap_device: Bad s=
wap file entry 6000000000000001<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.416519] get_swap_device: Bad s=
wap file entry 6400000000000001<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.420217] get_swap_device: Bad s=
wap file entry 6800000000000001<br>
<span>&gt; </span>&gt; [&nbsp;&nbsp;&nbsp;24.423921] get_swap_device: Bad s=
wap file entry 6c00000000000001<br>
</div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText">[..]</div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText">I don't have a panic, but I observe many lines lik=
e this.</div>
<div class=3D"PlainText"><br>
&gt; Looks familiar,<br>
&gt;<br>
<a href=3D"https://lore.kernel.org/lkml/1559242868.6132.35.camel@lca.pw/" i=
d=3D"LPlnk502224" class=3D"OWAAutoLink" previewremoved=3D"true">&gt; https:=
//lore.kernel.org/lkml/1559242868.6132.35.camel@lca.pw/</a><br>
&gt;<br>
&gt; I suppose Andrew might be better of reverting the whole series first b=
efore Yury<br>
&gt; came up with a right fix, so that other people who is testing linux-ne=
xt don't<br>
&gt; need to waste time for the same problem.<br>
<br>
I didn't observe any problems with this series on top of 5.1, and there's a=
 fix for swap that eliminates</div>
<div class=3D"PlainText">the problem on top of current next for me:</div>
<div class=3D"PlainText"><a href=3D"https://lkml.org/lkml/2019/5/30/1630" c=
lass=3D"OWAAutoLink" id=3D"LPlnk862799" previewremoved=3D"true">https://lkm=
l.org/lkml/2019/5/30/1630</a></div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText"><a href=3D"https://lkml.org/lkml/2019/5/30/1630" c=
lass=3D"OWAAutoLink" id=3D"LPlnk862799" previewremoved=3D"true"><br>
</a>
<div id=3D"LPBorder_GT_15593419429030.701166164629317" style=3D"margin-bott=
om: 20px; overflow: auto; width: 100%; text-indent: 0px;">
<table id=3D"LPContainer_15593419428950.4472279304378397" style=3D"width: 9=
0%; background-color: rgb(255, 255, 255); position: relative; overflow: aut=
o; padding-top: 20px; padding-bottom: 20px; margin-top: 20px; border-top: 1=
px dotted rgb(200, 200, 200); border-bottom: 1px dotted rgb(200, 200, 200);=
" role=3D"presentation" cellspacing=3D"0">
<tbody>
<tr style=3D"border-spacing: 0px;" valign=3D"top">
<td id=3D"TextCell_15593419428980.7745271051655324" style=3D"vertical-align=
: top; position: relative; padding: 0px; display: table-cell;" colspan=3D"2=
">
<div id=3D"LPRemovePreviewContainer_15593419428980.0939933518208994"></div>
<div id=3D"LPTitle_15593419428980.06315769909612456" style=3D"top: 0px; col=
or: rgb(0, 1, 255); font-weight: 400; font-size: 21px; font-family: &quot;w=
f_segoe-ui_normal&quot;, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma=
, Arial, sans-serif; line-height: 21px;">
<a id=3D"LPUrlAnchor_15593419428990.5928835665625852" style=3D"text-decorat=
ion: none;" href=3D"https://lkml.org/lkml/2019/5/30/1630" target=3D"_blank"=
>LKML: &quot;Huang, Ying&quot;: [PATCH -mm] mm, swap: Fix bad swap file ent=
ry warning</a></div>
<div id=3D"LPMetadata_15593419429010.32876544711840183" style=3D"margin: 10=
px 0px 16px; color: rgb(102, 102, 102); font-weight: 400; font-family: &quo=
t;wf_segoe-ui_semibold&quot;, &quot;Segoe UI Semibold&quot;, &quot;Segoe WP=
 Semibold&quot;, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma, Arial,=
 sans-serif; font-size: 14px; line-height: 14px;">
lkml.org</div>
<div id=3D"LPDescription_15593419429010.5699215528054768" style=3D"display:=
 block; color: rgb(102, 102, 102); font-weight: 400; font-family: &quot;wf_=
segoe-ui_semibold&quot;, &quot;Segoe UI Semibold&quot;, &quot;Segoe WP Semi=
bold&quot;, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma, Arial, sans=
-serif; font-size: 14px; line-height: 20px; max-height: 100px; overflow: hi=
dden;">
From: Huang Ying &lt;ying.huang@intel.com&gt; Mike reported the following w=
arning messages get_swap_device: Bad swap file entry 1400000000000001 This =
is produced by</div>
</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class=3D"PlainText">Could you please test your series with the patch o=
f <span>
Huang Ying</span>?</div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText">Thanks,</div>
<div class=3D"PlainText">Yury<br>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
"></span></font></div>
</div>
</div>
</body>
</html>

--_000_BN6PR1801MB2065F9E5FF6F9E8928879290CB190BN6PR1801MB2065_--

