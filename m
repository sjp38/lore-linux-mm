Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E39FBC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:52:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E35D2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:52:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="hwgvpTjU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E35D2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 141E86B0273; Tue,  2 Apr 2019 13:52:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2896B0274; Tue,  2 Apr 2019 13:52:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E87896B0275; Tue,  2 Apr 2019 13:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC9A06B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 13:52:31 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w11so8814410otq.7
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 10:52:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=WVNOwzKcJUm0WIFjTfG1eon5565+e+ooixXWwsmPQa0=;
        b=hhmr+ev6dhcSmyT1243DWLAm11pEpLVtcufKg24qU4/sS81eXDPG7BdSvKhMj/E/hP
         tQtSQr2Eo8MVG/YNRKqXG1r41hTNZx+7yHRarqV3wNcHRBdRMUuA2d8+3ODeasxP8INw
         TSEvCq5BnTl9XGS+4cDsWwTQ8iX33b9EFwshwNriRVuuAGY0rSNaBLxL9Y7d9MPITvId
         vaIahah++jJqDUzmlGAcKtuNQn6IUtxzO36ox/gXky6Uw0iG4JFWDj/Gevbz4YdUqNer
         +C3XRlxcrkauN+MrK8t793UEqzT2z4B74AmBV9/P25CLoFXyZI7+gRzWtBiDcoYCa4Hm
         +T8A==
X-Gm-Message-State: APjAAAUe99PEI+xID39D3zaU2+TmBh+1Jnl0wTA1d2j0kn/jGYXoTWeg
	zm68T663LSm2dTMtOUKKmAIi/Uro+Hp6Avnhot0T+pv8MGXsgWCNHuUub73p08pvSjRhp77S/TF
	Nz4J8H3VTn7vzkWWdfKc8qyPOdEz0A7Vj/gexVLhOM5jaeNOUhm43opiDMWF5Dx0=
X-Received: by 2002:a9d:871:: with SMTP id 104mr52485595oty.315.1554227551307;
        Tue, 02 Apr 2019 10:52:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlZYZVaZDp+4halGHFmnxo+Bf1UDYpScPQ/rSk1AtsEc4GrPP3O+XDNhzMfzKU/3c7Qs53
X-Received: by 2002:a9d:871:: with SMTP id 104mr52485554oty.315.1554227550475;
        Tue, 02 Apr 2019 10:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554227550; cv=none;
        d=google.com; s=arc-20160816;
        b=KoJa8ObfjjbiHALRclVqmBtxiOmdN0W2Vv6V5yQFnKY5C8vuAxGcRvPDvzXMW2dEMT
         gtaREuyHoqQzvyhBKPc+j7AM3eu88V6Isa0fpMKFA+UxN0Is0WfOgJQYZXr/TJ1CSZin
         mVk9Vyy/8kCXwsdkh9YzM6JXcirh7/TlPwRV+hneDTGu1pklk06d+LZ+pvhwcmY98cHb
         Fizn6MZStBYQu8X4R+8JrsgKeEoxTtQedFGZDrYudwmbAZ3acH+Zf0PgiFzt/9jR8/lv
         VDNwdPApchdi0vhyqlqTUTFdzTpV3nWaV9CZtBBzsLE3elSTemqB92iEytTWanITrNgz
         6e/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=WVNOwzKcJUm0WIFjTfG1eon5565+e+ooixXWwsmPQa0=;
        b=Liug+eA6YmV45J959frZK/2Oep6HIg9V/jIxIeL+uWGtBTf1K0hLmh+z/7wZjPpPJ5
         l0HqtpNFdxG/TixIXhZBsQAlYpH0M8wmMV35YRcxeaLY/laWtaU29V7kABZt2097+iFe
         Q6Hqln3e/qDzW92VRSHuXh2gXP7hsCoahCOijH8R4kcfCnNMiPuybl4/NYlliK63Fjoi
         lXkmRsTm0S2V/xsF8k41bZ24mDpNUmk0nLuSim2F9BWY1u/IWa5VCJjddkLgFPy2vcCd
         YOhPh8+DqXd92h4QbSs6QQrPgmu+OsvRP5CopsMugf+J4nblYPNbY7m/Jw+JV9IOHyU0
         ytqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=hwgvpTjU;
       spf=neutral (google.com: 40.107.71.64 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710064.outbound.protection.outlook.com. [40.107.71.64])
        by mx.google.com with ESMTPS id p187si3058619oib.175.2019.04.02.10.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 10:52:30 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.71.64 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.71.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=hwgvpTjU;
       spf=neutral (google.com: 40.107.71.64 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WVNOwzKcJUm0WIFjTfG1eon5565+e+ooixXWwsmPQa0=;
 b=hwgvpTjUlVqIPB8ITW1wses1vsZ3rYIW+e2l6Ti0gyxKUTzezWDxWQD+M8vPmMNw4q01aMkJuIyFTJhu81hmnArUU4Y+F+H4jcI0XAc+48SmwnzCE2rXLWjxzTtTROe6nX7FE4o0wkU2xn28mXPG5joRNy7wk3jxB+At1/yuE2o=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB2918.namprd12.prod.outlook.com (20.179.91.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.16; Tue, 2 Apr 2019 17:52:25 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::e073:d670:f97c:3eb8]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::e073:d670:f97c:3eb8%7]) with mapi id 15.20.1750.017; Tue, 2 Apr 2019
 17:52:24 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>
CC: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
	<robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart
	<kstewart@linuxfoundation.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo
 Molnar <mingo@kernel.org>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Vincenzo
 Frascino <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>,
	"Zhou, David(ChunMing)" <David1.Zhou@amd.com>, Yishai Hadas
	<yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Alex Williamson
	<alex.williamson@redhat.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-arch@vger.kernel.org"
	<linux-arch@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Brodsky
	<kevin.brodsky@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, Jacob
 Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya
 Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana
 Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck
	<luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Evgeniy
 Stepanov <eugenis@google.com>
Subject: Re: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
Thread-Topic: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
Thread-Index: AQHU3yyygJ3HP5e3/0iG1r4hvBquJ6Yc89QAgAwQ6wCAADaGgA==
Date: Tue, 2 Apr 2019 17:52:24 +0000
Message-ID: <cd669813-0279-35bb-6deb-f3e5fb60b16d@amd.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
 <574648a3-3a05-bea7-3f4e-7d71adedf1dc@amd.com>
 <CAAeHK+yQG_oYbBpcZWO80Pr=tdAgEHe80wuAHwuTMWNr=on+Qw@mail.gmail.com>
In-Reply-To:
 <CAAeHK+yQG_oYbBpcZWO80Pr=tdAgEHe80wuAHwuTMWNr=on+Qw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YTXPR0101CA0071.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::48) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 39c5f73f-9b17-4ebb-c603-08d6b793f615
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR12MB2918;
x-ms-traffictypediagnostic: BYAPR12MB2918:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR12MB2918F8C7BCCC263BE20C466C92560@BYAPR12MB2918.namprd12.prod.outlook.com>
x-forefront-prvs: 0995196AA2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(366004)(39860400002)(346002)(136003)(376002)(189003)(199004)(6916009)(229853002)(305945005)(81166006)(3846002)(7416002)(966005)(58126008)(106356001)(31686004)(68736007)(7406005)(81156014)(4326008)(36756003)(53936002)(26005)(93886005)(72206003)(6512007)(71200400001)(6246003)(6486002)(97736004)(256004)(6306002)(86362001)(65826007)(14454004)(52116002)(6506007)(6436002)(6116002)(53546011)(478600001)(2906002)(5660300002)(31696002)(386003)(99286004)(186003)(102836004)(25786009)(71190400001)(105586002)(476003)(7736002)(2616005)(64126003)(316002)(54906003)(8676002)(11346002)(8936002)(446003)(66066001)(486006)(65806001)(76176011)(65956001);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB2918;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gQeQyIabRB8Vt6LAjYCuSeOqVGfwOlGVjW7d3dsRiu/NhW9ciJjbDEAVWpsJ6m2IOLwa5M28FeNwA9Sgf1lFUUXrpyExhr0PpLrhM/8VDSjO45t8iG5D7QftuSw8YW1yt4IIwjN+b4l3qkXHoaEHXFmY8kyisb4J0kvhMzhLVe+GGIF4q7gDvr9ginsOto3G5dxk5xNfq+0mz4W7wH1f609gn4LMxK21VJMcRx/OOyvwKtsV6joVHo24ryDqs1StmhqT9menSHmZOQc8nidN7Q6tkjX+tq8Wyh+njgdhWihZrVeRBtsqyOTri3kTN9NXbzU6fE+3GRxe81SEFPWuzS+hSTAKmtd+lOvDENK/l8OKMbu7mbz82CoOA60wxLlrmVn2GuM2U8lrDwgHkankIHw/xPSzYz5JX7WsWzaoTe8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <EA0C6C3A4A41004299A64E0CA716F0A2@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 39c5f73f-9b17-4ebb-c603-08d6b793f615
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Apr 2019 17:52:24.5518
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB2918
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNC0wMiAxMDozNyBhLm0uLCBBbmRyZXkgS29ub3ZhbG92IHdyb3RlOg0KPiBPbiBN
b24sIE1hciAyNSwgMjAxOSBhdCAxMToyMSBQTSBLdWVobGluZywgRmVsaXggPEZlbGl4Lkt1ZWhs
aW5nQGFtZC5jb20+IHdyb3RlOg0KPj4gT24gMjAxOS0wMy0yMCAxMDo1MSBhLm0uLCBBbmRyZXkg
S29ub3ZhbG92IHdyb3RlOg0KPj4+IFRoaXMgcGF0Y2ggaXMgYSBwYXJ0IG9mIGEgc2VyaWVzIHRo
YXQgZXh0ZW5kcyBhcm02NCBrZXJuZWwgQUJJIHRvIGFsbG93IHRvDQo+Pj4gcGFzcyB0YWdnZWQg
dXNlciBwb2ludGVycyAod2l0aCB0aGUgdG9wIGJ5dGUgc2V0IHRvIHNvbWV0aGluZyBlbHNlIG90
aGVyDQo+Pj4gdGhhbiAweDAwKSBhcyBzeXNjYWxsIGFyZ3VtZW50cy4NCj4+Pg0KPj4+IGFtZGdw
dV90dG1fdHRfZ2V0X3VzZXJfcGFnZXMoKSB1c2VzIHByb3ZpZGVkIHVzZXIgcG9pbnRlcnMgZm9y
IHZtYQ0KPj4+IGxvb2t1cHMsIHdoaWNoIGNhbiBvbmx5IGJ5IGRvbmUgd2l0aCB1bnRhZ2dlZCBw
b2ludGVycy4NCj4+Pg0KPj4+IFVudGFnIHVzZXIgcG9pbnRlcnMgaW4gdGhpcyBmdW5jdGlvbi4N
Cj4+Pg0KPj4+IFNpZ25lZC1vZmYtYnk6IEFuZHJleSBLb25vdmFsb3YgPGFuZHJleWtudmxAZ29v
Z2xlLmNvbT4NCj4+PiAtLS0NCj4+PiAgICBkcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRn
cHVfdHRtLmMgfCA1ICsrKy0tDQo+Pj4gICAgMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygr
KSwgMiBkZWxldGlvbnMoLSkNCj4+Pg0KPj4+IGRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9kcm0v
YW1kL2FtZGdwdS9hbWRncHVfdHRtLmMgYi9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRn
cHVfdHRtLmMNCj4+PiBpbmRleCA3M2U3MWU2MWRjOTkuLjg5MWIwMjdmYTMzYiAxMDA2NDQNCj4+
PiAtLS0gYS9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfdHRtLmMNCj4+PiArKysg
Yi9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfdHRtLmMNCj4+PiBAQCAtNzUxLDEw
ICs3NTEsMTEgQEAgaW50IGFtZGdwdV90dG1fdHRfZ2V0X3VzZXJfcGFnZXMoc3RydWN0IHR0bV90
dCAqdHRtLCBzdHJ1Y3QgcGFnZSAqKnBhZ2VzKQ0KPj4+ICAgICAgICAgICAgICAgICAqIGNoZWNr
IHRoYXQgd2Ugb25seSB1c2UgYW5vbnltb3VzIG1lbW9yeSB0byBwcmV2ZW50IHByb2JsZW1zDQo+
Pj4gICAgICAgICAgICAgICAgICogd2l0aCB3cml0ZWJhY2sNCj4+PiAgICAgICAgICAgICAgICAg
Ki8NCj4+PiAtICAgICAgICAgICAgIHVuc2lnbmVkIGxvbmcgZW5kID0gZ3R0LT51c2VycHRyICsg
dHRtLT5udW1fcGFnZXMgKiBQQUdFX1NJWkU7DQo+Pj4gKyAgICAgICAgICAgICB1bnNpZ25lZCBs
b25nIHVzZXJwdHIgPSB1bnRhZ2dlZF9hZGRyKGd0dC0+dXNlcnB0cik7DQo+Pj4gKyAgICAgICAg
ICAgICB1bnNpZ25lZCBsb25nIGVuZCA9IHVzZXJwdHIgKyB0dG0tPm51bV9wYWdlcyAqIFBBR0Vf
U0laRTsNCj4+PiAgICAgICAgICAgICAgICBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYTsNCj4+
Pg0KPj4+IC0gICAgICAgICAgICAgdm1hID0gZmluZF92bWEobW0sIGd0dC0+dXNlcnB0cik7DQo+
Pj4gKyAgICAgICAgICAgICB2bWEgPSBmaW5kX3ZtYShtbSwgdXNlcnB0cik7DQo+Pj4gICAgICAg
ICAgICAgICAgaWYgKCF2bWEgfHwgdm1hLT52bV9maWxlIHx8IHZtYS0+dm1fZW5kIDwgZW5kKSB7
DQo+Pj4gICAgICAgICAgICAgICAgICAgICAgICB1cF9yZWFkKCZtbS0+bW1hcF9zZW0pOw0KPj4+
ICAgICAgICAgICAgICAgICAgICAgICAgcmV0dXJuIC1FUEVSTTsNCj4+IFdlJ2xsIG5lZWQgdG8g
YmUgY2FyZWZ1bCB0aGF0IHdlIGRvbid0IGJyZWFrIHlvdXIgY2hhbmdlIHdoZW4gdGhlDQo+PiBm
b2xsb3dpbmcgY29tbWl0IGdldHMgYXBwbGllZCB0aHJvdWdoIGRybS1uZXh0IGZvciBMaW51eCA1
LjI6DQo+Pg0KPj4gaHR0cHM6Ly9jZ2l0LmZyZWVkZXNrdG9wLm9yZy9+YWdkNWYvbGludXgvY29t
bWl0Lz9oPWRybS1uZXh0LTUuMi13aXAmaWQ9OTE1ZDNlZWNmYTIzNjkzYmFjOWU1NGNkYWNmODRm
YjRlZmRjYzVjNA0KPj4NCj4+IFdvdWxkIGl0IG1ha2Ugc2Vuc2UgdG8gYXBwbHkgdGhlIHVudGFn
Z2luZyBpbiBhbWRncHVfdHRtX3R0X3NldF91c2VycHRyDQo+PiBpbnN0ZWFkPyBUaGF0IHdvdWxk
IGF2b2lkIHRoaXMgY29uZmxpY3QgYW5kIEkgdGhpbmsgaXQgd291bGQgY2xlYXJseSBwdXQNCj4+
IHRoZSB1bnRhZ2dpbmcgaW50byB0aGUgdXNlciBtb2RlIGNvZGUgcGF0aCB3aGVyZSB0aGUgdGFn
Z2VkIHBvaW50ZXINCj4+IG9yaWdpbmF0ZXMuDQo+Pg0KPj4gSW4gYW1kZ3B1X2dlbV91c2VycHRy
X2lvY3RsIGFuZCBhbWRncHVfYW1ka2ZkX2dwdXZtLmMgKGluaXRfdXNlcl9wYWdlcykNCj4+IHdl
IGFsc28gc2V0IHVwIGFuIE1NVSBub3RpZmllciB3aXRoIHRoZSAodGFnZ2VkKSBwb2ludGVyIGZy
b20gdXNlciBtb2RlLg0KPj4gVGhhdCBzaG91bGQgcHJvYmFibHkgYWxzbyB1c2UgdGhlIHVudGFn
Z2VkIGFkZHJlc3Mgc28gdGhhdCBNTVUgbm90aWZpZXJzDQo+PiBmb3IgdGhlIHVudGFnZ2VkIGFk
ZHJlc3MgZ2V0IGNvcnJlY3RseSBtYXRjaGVkIHVwIHdpdGggdGhlIHJpZ2h0IEJPLiBJJ2QNCj4+
IG1vdmUgdGhlIHVudGFnZ2luZyBmdXJ0aGVyIHVwIHRoZSBjYWxsIHN0YWNrIHRvIGNvdmVyIHRo
YXQuIEZvciB0aGUgR0VNDQo+PiBjYXNlIEkgdGhpbmsgYW1kZ3B1X2dlbV91c2VycHRyX2lvY3Rs
IHdvdWxkIGJlIHRoZSByaWdodCBwbGFjZS4gRm9yIHRoZQ0KPj4gS0ZEIGNhc2UsIEknZCBkbyB0
aGlzIGluIGFtZGdwdV9hbWRrZmRfZ3B1dm1fYWxsb2NfbWVtb3J5X29mX2dwdS4NCj4gV2lsbCBk
byBpbiB2MTQsIHRoYW5rcyBhIGxvdCBmb3IgbG9va2luZyBhdCB0aGlzIQ0KPg0KPiBJcyB0aGlz
IGFwcGxpY2FibGUgdG8gdGhlIHJhZGVvbiBkcml2ZXIgKGRyaXZlcnMvZ3B1L2RybS9yYWRlb24p
IGFzDQo+IHdlbGw/IEl0IHNlZW1zIHRvIGJlIHVzaW5nIHZlcnkgc2ltaWxhciBzdHJ1Y3R1cmUu
DQoNCkkgdGhpbmsgc28uIFJhZGVvbiBkb2Vzbid0IGhhdmUgdGhlIEtGRCBiaXRzIGFueSBtb3Jl
LiBCdXQgdGhlIEdFTSANCmludGVyZmFjZSBhbmQgTU1VIG5vdGlmaWVyIGFyZSB2ZXJ5IHNpbWls
YXIuDQoNClJlZ2FyZHMsDQogwqAgRmVsaXgNCg0KDQo=

