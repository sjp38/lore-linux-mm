Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52CE7C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E74B7204FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:31:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="avBQUkdJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74B7204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 986C28E0005; Tue, 30 Jul 2019 13:31:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937258E0001; Tue, 30 Jul 2019 13:31:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 826C38E0005; Tue, 30 Jul 2019 13:31:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3424F8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:31:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so40779630ede.0
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:31:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=5Dpvwj1Vtrl40s/CzWekqNXiV7V74mCDmjAcgNvX+1w=;
        b=RuQJCY+x6GgcWMCQFNcj3Eeoko50EV4uEcNY+GhVeAq2QW4Q0XTvyICIZpV7xHGRJz
         eMKGRJN1hrkgCJr9zYrZin1CR1f/ggHtBFwv/hocSz0yJZOXR1wya0zEseituBFSZMJ9
         zQlk7/yPr59SGE/7Fgp8u9+5g2WRBeIXt310jbbD1iC83wUZGR4ErgDrMG9ltj2QDb0A
         YQPjQyBSIA8gkiXEnh/hn1qin10duAKoAtgrW3r2RgbBOkgb+wqWhb/F6wreq6N3iRzR
         jkMhax1xunUGdn2icWs13Dw9xhmtNsn3eW+Xz63kyckO7Hyr2/XfRl9v6GSEb9IGC6qo
         aDqw==
X-Gm-Message-State: APjAAAVJOS5sRaFQtRNGCYmObECqZTDFmSDyoOIdJ13FiuFG8JdqaRiU
	8Ve42x2grODlQ/WhH/vvwx5a3mplr6RkkOyoQ8cBePl2dxqTDb7PrhzgAHKYoZp8B8kWxvS5yQi
	LZDCt2a2B5ZwpyyZ+w504OG5hyJn68cOvo6AO8GocQ5kKSxR/1NzPJchzx5+inQPHXQ==
X-Received: by 2002:a50:eb96:: with SMTP id y22mr102324641edr.211.1564507891786;
        Tue, 30 Jul 2019 10:31:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuqQ7DmsonnF7NuRS5OenA8BL1UxVOAukKoSEZkHuplhRFBZ91HUAreaYdRFBKxkEe8YgI
X-Received: by 2002:a50:eb96:: with SMTP id y22mr102324593edr.211.1564507891018;
        Tue, 30 Jul 2019 10:31:31 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564507891; cv=pass;
        d=google.com; s=arc-20160816;
        b=YlibjJKOzJq73po79U8oDV0S5R+FcGuxWxgf6SWUVTaqgXu0q45BNEbYdKVptu3Etd
         PK3qxKDKHe6ixiI9XtoPCrt6IUJwsgIVpCtTick5tMn/Yrdzac8S4//2G9RI+tZIsU00
         x3MxOe6039vzys591X0511s2UgNsdl/oJbgZok+PYdYlePMv6gr7V3imT+xGgfDz2Exa
         Y4lTmlqytJafIo+7DOaza/o4q4hD/Ab9PTDOvqBZ4T8H+zJtgnltdC9V3e6awIqnakNg
         Usr+xg6l7ZHUrYDBTIaWblzuOtpflllXtY10EoUE0V+Cs90ypCCgXT8KaAQDnCh6ifjf
         MyNA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=5Dpvwj1Vtrl40s/CzWekqNXiV7V74mCDmjAcgNvX+1w=;
        b=q1rr3OAs/FUNYUevQpTlwIJctXHXBeYaCg+8fIB5bt4XShg8FqZoZvl+Uq3saT4oKt
         jMLhGunXKfG+PIhoGTayTY4snGOxk/JFq6h/BDSjsUnJbr3ugrf5ZqStJ0kh/80AJYgy
         CtMDGh5zPW7M8gX97JGwre1mqkKw0XZ5FksKlKQp2qBMMtk6Nc2jZJRXH5TFlKQy3ZON
         uzlwUCCNBdMPEKHGCjtup+xt0VLhqIwv19XzHssNZxm4aZiMnt009CMMRA/5jSRVbDvw
         pU+vjvBdfRwsEiM+EDO6MPeOLH50oZx9Coz/2Ss5nc3qkbG++pD66HtuP0XnVDE+XAz8
         rQyQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=avBQUkdJ;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.77.128 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770128.outbound.protection.outlook.com. [40.107.77.128])
        by mx.google.com with ESMTPS id q34si21534405edd.242.2019.07.30.10.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jul 2019 10:31:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.77.128 as permitted sender) client-ip=40.107.77.128;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=avBQUkdJ;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.77.128 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=jiyNpSz64BfSw0warQY4fsHK0/j/YGdJpBR71SAqatxVOLsuDA7R/T9RnDCWV6PdwOkpzbpKhJG0FZJhUSn15r0OH5tS6yTiSwNZgzguZOGzCLOgzOHAOgJjgCAWyjS88F3B+IeRNuWS5YFY2bRrII0tIzTIr3VL/F6g3uZyv1R7plIfBpmRJ3ko7I4TEFaIuSBF9koj/dbXqXJDJ2JLiV5COy8gn75cAx04HT+END63Nl8qW9lXvSXVzEBLGr/L/h4kozGZWr+9+0n0J540jAC/i4NQeXsvmvjdaeqCK4hg5IpxMXqTELLlRL4mM4De+sfm1DJM2swh7FQd+507qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5Dpvwj1Vtrl40s/CzWekqNXiV7V74mCDmjAcgNvX+1w=;
 b=Ro/9uQiobS+LlZ9N2nwDHiJQLS74pEQTK/jzsXdL/oVdohE5oFSMabbRRLczWTHAgGMNmB18YFhJ/qtRZZ5UsqvljHjJEiqKQOcvY4xSiF/K/YMS+SKulxoYY6yNKT6G1mgfHu+YR9eG8mXjzP9ZmRBicLesBAmIcayGYVXShGNnbFI2XAblpMaCyMsqP0gR2o9mecM71mqXJlJEpmZud1E+pxaQDA5PXbCRsQmkso59gm5Kmx4IFqr/fbEogjFDezpI2ZdJjWPH29nMtLMdGIJ+YUSRPc3jjAYQ9dEJBxFUP/Wnzd9RYKxSj8zlZ9iF/bdVYJmMhlqlUUIEM9ojnw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5Dpvwj1Vtrl40s/CzWekqNXiV7V74mCDmjAcgNvX+1w=;
 b=avBQUkdJHvGi9jjVzaXBrY6tSW94+DIMAflTgen1OPiyTrbfG+9yaMyhuHVqlpU/ji5NgTE7jFBoJLgjWvOjRkncOMvJWdIcQYV1Np5oOB5fgpP3FNh6Shs7Cb7A2MyXZmrFqrhY3HrOYM0xYFLiJSj8XyAjDZbNYQbiC8HXm14=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.105.203) by
 DM6PR01MB5164.prod.exchangelabs.com (20.176.121.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.17; Tue, 30 Jul 2019 17:31:27 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::88b7:bfbe:79e9:b251]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::88b7:bfbe:79e9:b251%7]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:31:27 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>, "open list:MEMORY MANAGEMENT"
	<linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, "H . Peter Anvin"
	<hpa@zytor.com>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Michael Ellerman
	<mpe@ellerman.id.au>, "x86@kernel.org" <x86@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Ingo
 Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Benjamin
 Herrenschmidt <benh@kernel.crashing.org>, Open Source Submission
	<patches@amperecomputing.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>,
	Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, Oscar Salvador <osalvador@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org"
	<linuxppc-dev@lists.ozlabs.org>, "David S . Miller" <davem@davemloft.net>,
	"willy@infradead.org" <willy@infradead.org>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Topic: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Index:
 AQHVOD/24o0J5njgPEqkosNO5sbs8abGjx+AgABBUoCAABUugIAAKIsAgAAGUoCABOfTgIAW8L6AgACbnwA=
Date: Tue, 30 Jul 2019 17:31:27 +0000
Message-ID: <d100011c-d5b4-a8c3-d3c0-d8f6dabd1363@os.amperecomputing.com>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
In-Reply-To: <20190730081415.GN9330@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR14CA0034.namprd14.prod.outlook.com
 (2603:10b6:903:101::20) To DM6PR01MB4090.prod.exchangelabs.com
 (2603:10b6:5:27::11)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [4.28.12.214]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 064f48f0-c434-4356-49d7-08d71513c001
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5164;
x-ms-traffictypediagnostic: DM6PR01MB5164:
x-microsoft-antispam-prvs:
 <DM6PR01MB51647A820E23BA8DC5ED60C0F1DC0@DM6PR01MB5164.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(136003)(366004)(376002)(346002)(396003)(39850400004)(189003)(199004)(54534003)(8676002)(3846002)(6116002)(7416002)(7736002)(25786009)(2906002)(76176011)(71200400001)(71190400001)(6246003)(305945005)(52116002)(26005)(478600001)(5660300002)(102836004)(186003)(53936002)(11346002)(6512007)(446003)(2616005)(6486002)(476003)(6436002)(31686004)(6916009)(486006)(54906003)(229853002)(68736007)(99286004)(86362001)(4326008)(66446008)(64756008)(8936002)(81156014)(66946007)(53546011)(6506007)(386003)(66476007)(31696002)(81166006)(256004)(316002)(14454004)(66556008)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5164;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 i0S9/fCjfev4t4mP+iL9KF/iGB7s2EgAtQdYLocxCP/PXh3RTe6KRbOGLDsPANckZIOFxe7lGY6xgba0YiumuwnIPaPkI/Vh3P/kG1Bm3T3ZOFwGa5qMZIIiepSyJRk9JRyO7Ru7B3Mosg3QTm62kTezrmVDH3zcBHQvo6M0yYUHgdAO9UPn6hmBUq+gME/+DCkagk8bfO8K/A3x2I7NGCfYqUvSet+4TRTQYuWQvYmw7JbZAiWO+LNFz4fg9Yjf7xKOH8c8uIY5EM2o1K36ExGbgd2rKxxPFzKQOkc5FPM0uyV/1nCoai5Nz6NPPoINZyIjAZ4MTtf7otqUEQ2dWC0F86NzSKhmOAT4+kZa6qUde1roOO3QHVs1maRYqEZFLuBdNywvZnC+SmAQR6sbA3xsmVguH1U1eCw+4sGbd6A=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F25D28E1CB44404EB408F8B8C25EAF53@prod.exchangelabs.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 064f48f0-c434-4356-49d7-08d71513c001
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:31:27.1673
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB5164
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksDQoNCk9uIDcvMzAvMTkgMToxNCBBTSwgTWljaGFsIEhvY2tvIHdyb3RlOg0KPiBbU29ycnkg
Zm9yIGEgbGF0ZSByZXBseV0NCj4gDQo+IE9uIE1vbiAxNS0wNy0xOSAxNzo1NTowNywgSG9hbiBU
cmFuIE9TIHdyb3RlOg0KPj4gSGksDQo+Pg0KPj4gT24gNy8xMi8xOSAxMDowMCBQTSwgTWljaGFs
IEhvY2tvIHdyb3RlOg0KPiBbLi4uXQ0KPj4+IEhtbSwgSSB0aG91Z2h0IHRoaXMgd2FzIHNlbGVj
dGFibGUuIEJ1dCBJIGFtIG9idmlvdXNseSB3cm9uZyBoZXJlLg0KPj4+IExvb2tpbmcgbW9yZSBj
bG9zZWx5LCBpdCBzZWVtcyB0aGF0IHRoaXMgaXMgaW5kZWVkIG9ubHkgYWJvdXQNCj4+PiBfX2Vh
cmx5X3Bmbl90b19uaWQgYW5kIGFzIHN1Y2ggbm90IHNvbWV0aGluZyB0aGF0IHNob3VsZCBhZGQg
YSBjb25maWcNCj4+PiBzeW1ib2wuIFRoaXMgc2hvdWxkIGhhdmUgYmVlbiBjYWxsZWQgb3V0IGlu
IHRoZSBjaGFuZ2Vsb2cgdGhvdWdoLg0KPj4NCj4+IFllcywgZG8geW91IGhhdmUgYW55IG90aGVy
IGNvbW1lbnRzIGFib3V0IG15IHBhdGNoPw0KPiANCj4gTm90IHJlYWxseS4gSnVzdCBtYWtlIHN1
cmUgdG8gZXhwbGljaXRseSBzdGF0ZSB0aGF0DQo+IENPTkZJR19OT0RFU19TUEFOX09USEVSX05P
REVTIGlzIG9ubHkgYWJvdXQgX19lYXJseV9wZm5fdG9fbmlkIGFuZCB0aGF0DQo+IGRvZXNuJ3Qg
cmVhbGx5IGRlc2VydmUgaXQncyBvd24gY29uZmlnIGFuZCBjYW4gYmUgcHVsbGVkIHVuZGVyIE5V
TUEuDQoNClllcywgSSB3aWxsIGFkZCB0aGlzIGluZm8gaW50byB0aGUgcGF0Y2ggZGVzY3JpcHRp
b24uDQoNCj4gDQo+Pj4gQWxzbyB3aGlsZSBhdCBpdCwgZG9lcyBIQVZFX01FTUJMT0NLX05PREVf
TUFQIGZhbGwgaW50byBhIHNpbWlsYXINCj4+PiBidWNrZXQ/IERvIHdlIGhhdmUgYW55IE5VTUEg
YXJjaGl0ZWN0dXJlIHRoYXQgZG9lc24ndCBlbmFibGUgaXQ/DQo+Pj4NCj4+DQo+PiBBcyBJIGNo
ZWNrZWQgd2l0aCBhcmNoIEtjb25maWcgZmlsZXMsIHRoZXJlIGFyZSAyIGFyY2hpdGVjdHVyZXMs
IHJpc2N2DQo+PiBhbmQgbWljcm9ibGF6ZSwgZG8gbm90IHN1cHBvcnQgTlVNQSBidXQgZW5hYmxl
IHRoaXMgY29uZmlnLg0KPj4NCj4+IEFuZCAxIGFyY2hpdGVjdHVyZSwgYWxwaGEsIHN1cHBvcnRz
IE5VTUEgYnV0IGRvZXMgbm90IGVuYWJsZSB0aGlzIGNvbmZpZy4NCj4gDQo+IENhcmUgdG8gaGF2
ZSBhIGxvb2sgYW5kIGNsZWFuIHRoaXMgdXAgcGxlYXNlPw0KDQpTdXJlLCBJJ2xsIHRha2UgYSBs
b29rLg0KDQpUaGFua3MNCkhvYW4NCj4gDQoNCg0K

