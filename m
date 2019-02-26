Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4463C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A1F21873
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:09:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="GG+44yW7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A1F21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05D998E000B; Mon, 25 Feb 2019 19:09:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00D008E000A; Mon, 25 Feb 2019 19:09:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E40EB8E000B; Mon, 25 Feb 2019 19:09:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1F988E000A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:09:34 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a72so9018100pfj.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:09:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=wCvq76C8qjRNTcx1wcwD3+MWlU64pb9oHDYv1BMphJk=;
        b=FWDYJCUKcmfppHN11eRVYUgb9Cpe/TF9mEZ9R3bAdLknAD62wJGc3ZwuA0CnILviNk
         s64cRZR/k2x7xyou+v25ibVdFq/wK6bTJjCNBcUupgi95hpCNL6xwBzhqCI6AnGdvKkK
         jFJn+RTF4csmFaBGqOUErqP9OD5WcCRJEk7PZ3OmdxHlv3z2+8QALs5WU/536TC+Sjgp
         gbSjBtN+JbT96GvuavFZGK6MweNMHtJmcrstSfUV+m5Gl1xgXYdAId/1dxW0SoGD685w
         QWCs4aLrkV06zAT63c6uq1GMGhMsQjeWDLg1uKFBEqFSGtMr7kltaL7RcZtZT46HaUXj
         H8jw==
X-Gm-Message-State: AHQUAuZfc65+svz6klfcfV5dimih3F9jOzu4XcNUP1n7IPyqvJo9toZ4
	oCYWSJEreKRot1pwjgH46qQ45AUXuZEKAHVvuDursn1EAY6D8Xqv9weYqPAoBHaz1dsuqn4FEC+
	k75j7he9BqRfqQ+glhnlHj8EGGoEtyNAkgJ8bItJHcteoOk7YWjC678mZ4uSZNrWdeQ==
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr11892743ple.82.1551139774155;
        Mon, 25 Feb 2019 16:09:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZgWMfdcPQqO5yalOBOC56JhuhmMLuihWpjEzBmOc8YmQJ584h4fcu6/AxpScrEAV7eOAzF
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr11892650ple.82.1551139773004;
        Mon, 25 Feb 2019 16:09:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551139772; cv=none;
        d=google.com; s=arc-20160816;
        b=UnTscnHP+zmbNnwERDsbbmB1yPaDBGIXb3guhNDBD8xZCr0GtpJZmlKjNe7+Wn9R8J
         XBxiOICbAw5uYmQD4I+mmW535Boo5qm/fXLvd5iNqeibL7JV7VzISZh18Nth55JGSPZw
         KERnrlgVSoyjl7Vfz+tMNfFNvYrQhirDNziu13ChQ+ujlVDCPUkrx0p1olLcL72Ma/fM
         qJQYvUpIVNgYv20ZlYLXiRnj+ZhGIoeDN9QucZL93jVFQlNmT5NA5fy/EmJlTPFmcad3
         zOH15hrd7wCQmx/63w85IrwrlccAWl9lDOMRJnvbl+APfVYARBhbw5sWVQtxHM6AEcbM
         Hb2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=wCvq76C8qjRNTcx1wcwD3+MWlU64pb9oHDYv1BMphJk=;
        b=iUeuEctTKZFxkQvyBVaLu1tHPvOH8zefJoJh7o1wFM/+3rRDicUSPbGO+oHBjq6qy+
         lJSkd8CfjWVkJ9IaXILvs48cIL1R2iNKtStMIZlbrL4iZk4/4gedW6y0+NknrMwFSJph
         Po3x96Lmceon379PH9PJDJnYvlZsExnaonTmzOVme8lDkeEAMID9GF95DKas2UTw+caF
         XxHASGNJBPu+xh1BiApJjEQpCywPY0tMZjulurfY2DXSgqBi+H96Z+Gqaal15wIIaJSC
         sV7goqeck3Cu6f3jfd2QP93HcWIJ9LEdIKXpVwsw1LNsgW/escBIn1B+3L5UaQ+JM2QR
         RYvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=GG+44yW7;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.53 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150053.outbound.protection.outlook.com. [40.107.15.53])
        by mx.google.com with ESMTPS id d34si11108257pld.290.2019.02.25.16.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 16:09:32 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.53 as permitted sender) client-ip=40.107.15.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=GG+44yW7;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.53 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wCvq76C8qjRNTcx1wcwD3+MWlU64pb9oHDYv1BMphJk=;
 b=GG+44yW7YkU47nANCEP3UEDpxsfSORqyYp6kIpiIj/p81uc0dPIpwqhVEMBEIFcpPQkdtPUMSZ2D1t5vt9xoQvcxAmaExeLdzdwHtLFvJvlL7FWJ6ZxebOok36yKDfHSBy+r1vqZtknlkDRVMJn5cHSrHYd2KdaI2AAcmsrDo3c=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4466.eurprd04.prod.outlook.com (52.135.147.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Tue, 26 Feb 2019 00:09:28 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1643.019; Tue, 26 Feb 2019
 00:09:28 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "dennis@kernel.org" <dennis@kernel.org>
CC: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [RFC] percpu: decrease pcpu_nr_slots by 1
Thread-Topic: [RFC] percpu: decrease pcpu_nr_slots by 1
Thread-Index: AQHUzCG3EUVkDmE6x0qXBqXQe9HUi6Xwo+MAgACRjOA=
Date: Tue, 26 Feb 2019 00:09:28 +0000
Message-ID:
 <AM0PR04MB448161D9ED7D152AD58B53E9887B0@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190224092838.3417-1-peng.fan@nxp.com>
 <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3e069c5f-8757-4247-bb54-08d69b7eac9d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4466;
x-ms-traffictypediagnostic: AM0PR04MB4466:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI0NDY2OzIzOlRhWjRhVm5iN0JjaG5tNWNNUUZ5OTdpSHhk?=
 =?gb2312?B?d05GOXFMNXkxVGVJdFBzU2NGcUw5bHdiRyt2UXI5Wk1PaUZvTms1aGxnM3Vj?=
 =?gb2312?B?YUNLY1ZLT0RUdFBQZVc2eW0xVS9JY3J1N25HL1ZrQzY0UG9QSCtUWXM5djl4?=
 =?gb2312?B?cEp3bW0xSHhkZjM1OUh2K3hHNGQvbUR1Y3VaQnkwamN0VTBERXJ0cEk2QzlJ?=
 =?gb2312?B?NTJhZWpHcVZxbmJMUUw5dEhZWllIbytmRld5OFQ3RUlUaCs1ZHJRUUpqUzg0?=
 =?gb2312?B?cEpCRW9TZDMxSHlzMUVES3czWTBBTjVTK1ZoeE82Q0VzRDdnNGpPWFgzMlZ2?=
 =?gb2312?B?aWlqOWFJbFQ3QklUTEdBdEI0dUR6QWpnT3ZCV3Q2NlBUeHlpRDFrekVUdTRM?=
 =?gb2312?B?MVQvLzZSV09ZYVBOdTRjbHRtcVZwdlpObEwxalF0ZHVPT3k4cXlHSHlEYjNj?=
 =?gb2312?B?eUsybFIwaVFsVlg3MEpHK29KeDNBTnpaeUhvSlhoekwzNTBQNWYyOWVQbCsv?=
 =?gb2312?B?TVlxbVBxUXFsT3dEOVFqdUFzc0pMSDRMdjMzUW9KVUpDWUVEYUV5Tm1PK1hK?=
 =?gb2312?B?MVZZMnc2dTVFODErcmlSMWNRVU9VMFd5UXJsZS9FN1RtdEFiazdqMGNuaUJs?=
 =?gb2312?B?bmYvR2ZSSU1lSm9vQ1FicXBHQ0wyMmNvTGN3bS85VnE4MjJPN1l2NnA3bFdj?=
 =?gb2312?B?ZnhVMnJzYWg1T0F0MWNnaUNhSDgxOTBoanp2V0I0NUZIQ0V2WitUZFRNdkdH?=
 =?gb2312?B?eFNuVVY0cDVIcDEyRWNFSjVWZURjYjQralpWRzNZczU2dXY0VkcyQWVDaHFr?=
 =?gb2312?B?WEp5Ylp1MkNHc0MvK1dRMVo0aTVVSUVGaHlhTndhSjh3KzlrRG4zTkkxL0xD?=
 =?gb2312?B?UDRoc1NzRkJsTHJ5c1BoTTNTeHJ4SnU0enZWLysxYVJINFlTWVdMVFdxZENt?=
 =?gb2312?B?WEM0SmlKZDJoNWU4aFBLa1lCTzBlcGVnQWNYZ0RKekZua0pxTEJDbnVWSE1P?=
 =?gb2312?B?aDNPZ0tsYVphMmxqTmY4R2dteGo3K2JQS01ZMFV2RXFsczlidThFNzVpUjcy?=
 =?gb2312?B?SGxkTklQUUtQQXFFcGVWaExyK1NqN29QMEFZZzdOcUhUc0NaT2Y0YXFYK0Yy?=
 =?gb2312?B?enR6ZzdvZXE3NVpuRys0eFVFWnZLVEovRkdTN0M2KzJudWkwUVpFd1RqVmw2?=
 =?gb2312?B?OFFadzdZaVBqNWt0dFkvaThoRGkvY0pDRlA0OUZmOFBRUkZjeFhuRVRuelVX?=
 =?gb2312?B?bi9JRHhrbTM3SGhjYmNiNTQ3YlNlR0hmYWJ1aXd2dlZ6VWpia09wNW5MSWY4?=
 =?gb2312?B?d2d2NG5KQVJuOXVEL0c3eUczK2hTZVd2Qk1RdkErODNraFhMSWZuZ2N2akdz?=
 =?gb2312?B?ZW51SHBjSGhKaEV3WEhsSVoranQ2TDUveStaLyt0cUxDbjFMdW9OQXpTckl2?=
 =?gb2312?B?Wlc3OEtUWTFjNXBobXd2VnVMTU5vVStheXNVSE80Y2lRdkFIYm1yMDV6c3lT?=
 =?gb2312?B?aG0xaG9LMFVld0NmUXV1NVZhMS9nYXZGNzBSNTJaZHhLYXQzcGkrVE5LRUxH?=
 =?gb2312?B?cjNjNy9PYW9vRzZLMTNWbGJ0VkgzR0NQZzJQZUEybjZDOW1UdFhvSGtjM1M2?=
 =?gb2312?B?OWkxdjBWMEJyN2JDVHVlU2MxYmVaRTd4YlMwdnVKbWw1S2llVDBsTHdVSUdY?=
 =?gb2312?B?VzhGWlhsVHAyUGVOQnE1NVdtTTQ1RS9nVzlNSyswZ2orcU16bVhnYXdIZ3JL?=
 =?gb2312?B?UHV5dEYwOGRtYnd1bEhsU25oSnVHbmRGSnVHYjRaQjFJbXRNKzJ3TTlzTlpl?=
 =?gb2312?B?TVB4ZE85K21sZm51a2g1YjB3UzRTWUtTYlVSTW9Jbjc1SVIrWHp4amM0bnA4?=
 =?gb2312?Q?yyqbS6g2/M4=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB44665D06CA60668EE01D1AB2887B0@AM0PR04MB4466.eurprd04.prod.outlook.com>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(39860400002)(396003)(366004)(346002)(376002)(199004)(189003)(13464003)(476003)(66066001)(486006)(68736007)(6246003)(71190400001)(71200400001)(6916009)(2501003)(6506007)(81166006)(2351001)(102836004)(6116002)(53546011)(3846002)(4326008)(8936002)(44832011)(76176011)(52536013)(446003)(7696005)(86362001)(11346002)(5660300002)(186003)(25786009)(26005)(97736004)(14454004)(106356001)(478600001)(55016002)(9686003)(229853002)(8676002)(74316002)(1730700003)(81156014)(54906003)(2906002)(33656002)(14444005)(256004)(99286004)(305945005)(7736002)(316002)(105586002)(53936002)(6436002)(5640700003);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4466;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 PEVAW15z4IHFl8riTkMGdP3puBXT44yeU/pnNsb1yp2olo9NFxPhYWDycH1ebO/uQlnHHPa9R4wP+Hj6dK+qU8ChLVM+JLvYBzcfMmiu6RhWdCYqMBdiX3cirtMknnda38F5bq6Pc6qOly/CZCSsJCecQRMMLQ4DInU6+CXf7XLFEAnrsY5ooz6ccGVrOvxMaoLFwH0l84vb2fwU5sPxmFvCsEQoNpRCgU7r7FlPi2eERM1ICHvdqqHNTbY1fXELxi8dc6cOMqrJAKEtYAR8T7SfIoYjal+NR79ge2C6PL8eNS8X26ujrh2J16yRkDxfKbUtFd2tDCmd0ov4tTriUvuozFyjforxvo5SQNz6x23R5NkiDAyPcgd81jgbysi6otf6Vdkhy4w46Q/Q3jrare+DK3v7BEvdhR2yjoErfMI=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3e069c5f-8757-4247-bb54-08d69b7eac9d
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 00:09:28.2345
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4466
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGRlbm5p
c0BrZXJuZWwub3JnIFttYWlsdG86ZGVubmlzQGtlcm5lbC5vcmddDQo+IFNlbnQ6IDIwMTnE6jLU
wjI1yNUgMjM6MjQNCj4gVG86IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiBDYzogdGpA
a2VybmVsLm9yZzsgY2xAbGludXguY29tOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+IGxpbnV4LWtl
cm5lbEB2Z2VyLmtlcm5lbC5vcmc7IHZhbi5mcmVlbml4QGdtYWlsLmNvbQ0KPiBTdWJqZWN0OiBS
ZTogW1JGQ10gcGVyY3B1OiBkZWNyZWFzZSBwY3B1X25yX3Nsb3RzIGJ5IDENCj4gDQo+IE9uIFN1
biwgRmViIDI0LCAyMDE5IGF0IDA5OjE3OjA4QU0gKzAwMDAsIFBlbmcgRmFuIHdyb3RlOg0KPiA+
IEVudHJ5IHBjcHVfc2xvdFtwY3B1X25yX3Nsb3RzIC0gMl0gaXMgd2FzdGVkIHdpdGggY3VycmVu
dCBjb2RlIGxvZ2ljLg0KPiA+IHBjcHVfbnJfc2xvdHMgaXMgY2FsY3VsYXRlZCB3aXRoIGBfX3Bj
cHVfc2l6ZV90b19zbG90KHNpemUpICsgMmAuDQo+ID4gVGFrZSBwY3B1X3VuaXRfc2l6ZSBhcyAx
MDI0IGZvciBleGFtcGxlLCBfX3BjcHVfc2l6ZV90b19zbG90IHdpbGwNCj4gPiByZXR1cm4gbWF4
KDExIC0gUENQVV9TTE9UX0JBU0VfU0hJRlQgKyAyLCAxKSwgaXQgaXMgOCwgc28gdGhlDQo+ID4g
cGNwdV9ucl9zbG90cyB3aWxsIGJlIDEwLg0KPiA+DQo+ID4gVGhlIGNodW5rIHdpdGggZnJlZV9i
eXRlcyAxMDI0IHdpbGwgYmUgbGlua2VkIGludG8gcGNwdV9zbG90WzldLg0KPiA+IEhvd2V2ZXIg
ZnJlZV9ieXRlcyBpbiByYW5nZSBbNTEyLDEwMjQpIHdpbGwgYmUgbGlua2VkIGludG8NCj4gPiBw
Y3B1X3Nsb3RbN10sIGJlY2F1c2UgYGZscyg1MTIpIC0gUENQVV9TTE9UX0JBU0VfU0hJRlQgKyAy
YCBpcyA3Lg0KPiA+IFNvIHBjcHVfc2xvdFs4XSBpcyBoYXMgbm8gY2hhbmNlIHRvIGJlIHVzZWQu
DQo+ID4NCj4gPiBBY2NvcmRpbmcgY29tbWVudHMgb2YgUENQVV9TTE9UX0JBU0VfU0hJRlQsIDF+
MzEgYnl0ZXMgc2hhcmUgdGhlDQo+IHNhbWUNCj4gPiBzbG90IGFuZCBQQ1BVX1NMT1RfQkFTRV9T
SElGVCBpcyBkZWZpbmVkIGFzIDUuIEJ1dCBhY3R1YWxseSAxfjE1IHNoYXJlDQo+ID4gdGhlIHNh
bWUgc2xvdCAxIGlmIHdlIG5vdCB0YWtlIFBDUFVfTUlOX0FMTE9DX1NJWkUgaW50byBjb25zaWRl
cmF0aW9uLA0KPiA+IDE2fjMxIHNoYXJlIHNsb3QgMi4gQ2FsY3VsYXRpb24gYXMgYmVsb3c6DQo+
ID4gaGlnaGJpdCA9IGZscygxNikgLT4gaGlnaGJpdCA9IDUNCj4gPiBtYXgoNSAtIFBDUFVfU0xP
VF9CQVNFX1NISUZUICsgMiwgMSkgZXF1YWxzIDIsIG5vdCAxLg0KPiA+DQo+ID4gVGhpcyBwYXRj
aCBieSBkZWNyZWFzaW5nIHBjcHVfbnJfc2xvdHMgdG8gYXZvaWQgd2FzdGUgb25lIHNsb3QgYW5k
IGxldA0KPiA+IFtQQ1BVX01JTl9BTExPQ19TSVpFLCAzMSkgcmVhbGx5IHNoYXJlIHRoZSBzYW1l
IHNsb3QuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBQZW5nIEZhbiA8cGVuZy5mYW5AbnhwLmNv
bT4NCj4gPiAtLS0NCj4gPg0KPiA+IFYxOg0KPiA+ICBOb3QgdmVyeSBzdXJlIGFib3V0IHdoZXRo
ZXIgaXQgaXMgaW50ZW5kZWQgdG8gbGVhdmUgdGhlIHNsb3QgdGhlcmUuDQo+ID4NCj4gPiAgbW0v
cGVyY3B1LmMgfCA0ICsrLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwg
MiBkZWxldGlvbnMoLSkNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9tbS9wZXJjcHUuYyBiL21tL3Bl
cmNwdS5jIGluZGV4DQo+ID4gOGQ5OTMzZGI2MTYyLi4xMmE5YmEzOGYwYjUgMTAwNjQ0DQo+ID4g
LS0tIGEvbW0vcGVyY3B1LmMNCj4gPiArKysgYi9tbS9wZXJjcHUuYw0KPiA+IEBAIC0yMTksNyAr
MjE5LDcgQEAgc3RhdGljIGJvb2wgcGNwdV9hZGRyX2luX2NodW5rKHN0cnVjdCBwY3B1X2NodW5r
DQo+ID4gKmNodW5rLCB2b2lkICphZGRyKSAgc3RhdGljIGludCBfX3BjcHVfc2l6ZV90b19zbG90
KGludCBzaXplKSAgew0KPiA+ICAJaW50IGhpZ2hiaXQgPSBmbHMoc2l6ZSk7CS8qIHNpemUgaXMg
aW4gYnl0ZXMgKi8NCj4gPiAtCXJldHVybiBtYXgoaGlnaGJpdCAtIFBDUFVfU0xPVF9CQVNFX1NI
SUZUICsgMiwgMSk7DQo+ID4gKwlyZXR1cm4gbWF4KGhpZ2hiaXQgLSBQQ1BVX1NMT1RfQkFTRV9T
SElGVCArIDEsIDEpOw0KPiA+ICB9DQo+IA0KPiBIb25lc3RseSwgaXQgbWF5IGJlIGJldHRlciB0
byBqdXN0IGhhdmUgWzEtMTYpIFsxNi0zMSkgYmUgc2VwYXJhdGUuIEknbSB3b3JraW5nDQo+IG9u
IGEgY2hhbmdlIHRvIHRoaXMgYXJlYSwgc28gSSBtYXkgY2hhbmdlIHdoYXQncyBnb2luZyBvbiBo
ZXJlLg0KPiANCj4gPg0KPiA+ICBzdGF0aWMgaW50IHBjcHVfc2l6ZV90b19zbG90KGludCBzaXpl
KSBAQCAtMjE0NSw3ICsyMTQ1LDcgQEAgaW50DQo+ID4gX19pbml0IHBjcHVfc2V0dXBfZmlyc3Rf
Y2h1bmsoY29uc3Qgc3RydWN0IHBjcHVfYWxsb2NfaW5mbyAqYWksDQo+ID4gIAkgKiBBbGxvY2F0
ZSBjaHVuayBzbG90cy4gIFRoZSBhZGRpdGlvbmFsIGxhc3Qgc2xvdCBpcyBmb3INCj4gPiAgCSAq
IGVtcHR5IGNodW5rcy4NCj4gPiAgCSAqLw0KPiA+IC0JcGNwdV9ucl9zbG90cyA9IF9fcGNwdV9z
aXplX3RvX3Nsb3QocGNwdV91bml0X3NpemUpICsgMjsNCj4gPiArCXBjcHVfbnJfc2xvdHMgPSBf
X3BjcHVfc2l6ZV90b19zbG90KHBjcHVfdW5pdF9zaXplKSArIDE7DQo+ID4gIAlwY3B1X3Nsb3Qg
PSBtZW1ibG9ja19hbGxvYyhwY3B1X25yX3Nsb3RzICogc2l6ZW9mKHBjcHVfc2xvdFswXSksDQo+
ID4gIAkJCQkgICBTTVBfQ0FDSEVfQllURVMpOw0KPiA+ICAJZm9yIChpID0gMDsgaSA8IHBjcHVf
bnJfc2xvdHM7IGkrKykNCj4gPiAtLQ0KPiA+IDIuMTYuNA0KPiA+DQo+IA0KPiBUaGlzIGlzIGEg
dHJpY2t5IGNoYW5nZS4gVGhlIG5pY2UgdGhpbmcgYWJvdXQga2VlcGluZyB0aGUgYWRkaXRpb25h
bA0KPiBzbG90IGFyb3VuZCBpcyB0aGF0IGl0IGVuc3VyZXMgYSBkaXN0aW5jdGlvbiBiZXR3ZWVu
IGEgY29tcGxldGVseSBlbXB0eQ0KPiBjaHVuayBhbmQgYSBuZWFybHkgZW1wdHkgY2h1bmsuDQoN
CkFyZSB0aGVyZSBhbnkgaXNzdWVzIG1ldCBiZWZvcmUgaWYgbm90IGtlZXBpbmcgdGhlIHVudXNl
ZCBzbG90Pw0KRnJvbSByZWFkaW5nIHRoZSBjb2RlIGFuZCBnaXQgaGlzdG9yeSBJIGNvdWxkIG5v
dCBmaW5kIGluZm9ybWF0aW9uLg0KSSB0cmllZCB0aGlzIGNvZGUgb24gYWFyY2g2NCBxZW11IGFu
ZCBkaWQgbm90IG1lZXQgaXNzdWVzLg0KDQogSXQgaGFwcGVucyB0byBiZSB0aGF0IHRoZSBsb2dp
YyBjcmVhdGVzDQo+IHBvd2VyIG9mIDIgY2h1bmtzIHdoaWNoIGVuZHMgdXAgYmVpbmcgYW4gYWRk
aXRpb25hbCBzbG90IGFueXdheS4gDQoNCg0KU28sDQo+IGdpdmVuIHRoYXQgdGhpcyBsb2dpYyBp
cyB0cmlja3kgYW5kIGFyY2hpdGVjdHVyZSBkZXBlbmRlbnQsIA0KDQpDb3VsZCB5b3Ugc2hhcmUg
bW9yZSBpbmZvcm1hdGlvbiBhYm91dCBhcmNoaXRlY3R1cmUgZGVwZW5kZW50Pw0KDQpUaGFua3Ms
DQpQZW5nLg0KDQpJIGRvbid0IGZlZWwNCj4gY29tZm9ydGFibGUgbWFraW5nIHRoaXMgY2hhbmdl
IGFzIHRoZSByaXNrIGdyZWF0bHkgb3V0d2VpZ2hzIHRoZQ0KPiBiZW5lZml0Lg0KPiANCj4gVGhh
bmtzLA0KPiBEZW5uaXMNCg==

