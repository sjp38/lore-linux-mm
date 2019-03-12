Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6FA0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86C58206BA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:48:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="IJSeswfW";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="WUmomp+y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86C58206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 217BF8E0004; Tue, 12 Mar 2019 14:48:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6608E0002; Tue, 12 Mar 2019 14:48:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08F308E0004; Tue, 12 Mar 2019 14:48:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0A488E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:48:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i59so1493488edi.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:48:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=a5lxcpFrG4f+ml3OZhKJemoJ+5+50skRxcyCNMCmnaY=;
        b=fOQ87+3cpnxOn4qTCAPasiA9j00nYA0OsREzlLl2koJ1NZNb4zAqgHshPBs+t8OvtN
         zM0+BcJALMEwr6ofPdMsJt+nEha+TJm8LIJcP5OBHXqTvvjPld5U0wI+XoKAJV0E0YPM
         ZP1zqIdQSR4+GRUkve0/4eJx/YVOkjBNEy8B+bA0Lw5RxMteXX4jhXsrJA2YsdsPyKG2
         50pYvH1d1ANIN3hm1DdcebxRHFwYLqtTUik/Zb9t7RjqdpKuFyQ3asJrywrv0EZubqLY
         iAjS1vN81kbEKvrQiEzPmpS+LTNKFiBRIuYihDVSGTqg1g1vh5qP19N5pF6dyiWmBeDh
         e8JQ==
X-Gm-Message-State: APjAAAVgceZWj4ASYh2Q27x+WnEd98+OEdGvYfJ/1xor0Xd15Ac7BPxf
	y1bKQ+lwXMLBjcGkyyiYyX3K7i0NNajb3qti2j7/vwxSUxz2n17rhHmnFLnUfkM7MH/wCp5aGtL
	z9KyINpeTwKQOyQ80J4NiFbnoAVxj/M78dKb/4pc7aEFSlHT4QuM1w6vnccIvcP8TcA==
X-Received: by 2002:a50:8693:: with SMTP id r19mr4761256eda.60.1552416500126;
        Tue, 12 Mar 2019 11:48:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUP1iqlkdkLWHq2Umyr/cwQg7scEMTdfxdYYPaV3PF7qPdWKEwNeRRwoaen03TB+GrehfU
X-Received: by 2002:a50:8693:: with SMTP id r19mr4761209eda.60.1552416499275;
        Tue, 12 Mar 2019 11:48:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552416499; cv=none;
        d=google.com; s=arc-20160816;
        b=gdt1Kg38+RDOHOZyofHH3s7WvvMN2tc23Dd/vJcls0gQMxKUVW0nJl2WRm6pgsSx8j
         MnnDs5SjePIhoITHbxP/cAaukrLhMmspw6wR3RQ5/IDx46Jr1yHGfI8uovhF2QIjIo8y
         /dwY4xNpdXzFx7AQtjupx9hjwNpI4owor/Cy6Sl3Bj96lyBCQsNXdZX1FKgkCbg47TtN
         JJVUTy6ekH0eXHAtPLEdPSdp9DEzY/XCKFOuWJyG4mDv6gEBxSTq0Fpb8hZCopVT+4KM
         UOwD6txloydMrrxuiurqScOMMPgCkN0jjEH6KIeGGA7WeOtrPHw7F5bLXS2kDBSEHub4
         JALw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=a5lxcpFrG4f+ml3OZhKJemoJ+5+50skRxcyCNMCmnaY=;
        b=Sw45XlNBIQL+t/iCq99yMZx1uA6dLcCuHcj8l51LMiwIOlUYLz1ktw7pg5/Tn0G956
         onqUiLnxHB8sJ+fWlb/ICxPyH1fuSuCZdVzgYyxVhCtVICrKqdmpjW26tM1MT06FlG2t
         7/aVCYF6mMAmjWq6rK2u0WHSMOSBi09kOQuMWEL9FkwlrDx4ZS9R6dpqGyccd9voi4pt
         lxmDC+YpdmF8wSeVJxrAk1F3wRzAfXXVwhOS9PUgoBaui4/A4hJyLjpqoNQT03eVd7eI
         KPoaECIqAmLVpM5XInk1WSPaYh9c0r5UmmtAcFBcaTqooURhe+u6wZ1pfE9C/YdEO7Vo
         gElA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IJSeswfW;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=WUmomp+y;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c4si1527854ejs.18.2019.03.12.11.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:48:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IJSeswfW;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=WUmomp+y;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x2CIiBIK019653;
	Tue, 12 Mar 2019 11:48:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=a5lxcpFrG4f+ml3OZhKJemoJ+5+50skRxcyCNMCmnaY=;
 b=IJSeswfWIScosNrugkeWB8ikdV9sRpN89Phz/Y/Zr9DMuI7SamzyzMGcgA3/SLyprukm
 euSexIjjsJ5woK1K25dudMFATc9iNyAeSC//3PDA1ERvxgtEzlOksRydNKPgI/+vFgr+
 5LPO5gBGPumxIbgPV3WHhTeqoOLqxTlWYJ8= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0089730.ppops.net with ESMTP id 2r6gt2rgh0-19
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 12 Mar 2019 11:48:09 -0700
Received: from frc-mbx08.TheFacebook.com (192.168.155.29) by
 frc-hub03.TheFacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 12 Mar 2019 11:48:00 -0700
Received: from frc-hub04.TheFacebook.com (192.168.177.74) by
 frc-mbx08.TheFacebook.com (192.168.155.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 12 Mar 2019 11:48:00 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 12 Mar 2019 11:48:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=a5lxcpFrG4f+ml3OZhKJemoJ+5+50skRxcyCNMCmnaY=;
 b=WUmomp+yWR2NK8isAkjIS6osoN9+X0tSw461ku9wwc+lgoD8UeUsESsyaLcIuPeT+JmXR1t6PaRR8NDsswU0RbxYyrfMoTeOGwQtkYNTy0RnIJR5+J1+067QeJuudoqyOpqacfPuPwpszyIb/M1zLfv/a/P+QqGzqtmL2itD2+I=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3510.namprd15.prod.outlook.com (20.179.60.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.18; Tue, 12 Mar 2019 18:47:58 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Tue, 12 Mar 2019
 18:47:58 +0000
From: Roman Gushchin <guro@fb.com>
To: Christopher Lameter <cl@linux.com>
CC: "Tobin C. Harding" <tobin@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Pekka Enberg <penberg@cs.helsinki.fi>,
        "Matthew
 Wilcox" <willy@infradead.org>,
        Tycho Andersen <tycho@tycho.ws>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
Thread-Topic: [RFC 02/15] slub: Add isolate() and migrate() methods
Thread-Index: AQHU1WWOzoo+8Mo/g0+TXm2HFlFybKYGiOoAgADmRICAAO46AA==
Date: Tue, 12 Mar 2019 18:47:57 +0000
Message-ID: <20190312184754.GB31407@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-3-tobin@kernel.org>
 <20190311215106.GA7915@tower.DHCP.thefacebook.com>
 <01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@email.amazonses.com>
In-Reply-To: <01000169702ee357-fe8b85e5-e601-41da-8ba2-25e8b7db52eb-000000@email.amazonses.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR03CA0005.namprd03.prod.outlook.com
 (2603:10b6:300:117::15) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:d3a0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: af1a46df-4e5a-440b-5e95-08d6a71b3eab
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3510;
x-ms-traffictypediagnostic: BYAPR15MB3510:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3510;20:OfzLOrUcUBv2Fd2vakFl3InVBLbYWE/Irtqtn3Y3w8O7+VeGuSmWyjeBfJA/7AizCUEhkgLnQvRuqx4E1Z32H28NK2y75/9qHbVCSiK+4O1qPO9fYNeTTH4arDhP0h9skf7RogYxUpvLS92869H+FOp7u+dPYGTV8FB0R2t/Cyc=
x-microsoft-antispam-prvs: <BYAPR15MB3510E8CA0DAF9B933CA93EC8BE490@BYAPR15MB3510.namprd15.prod.outlook.com>
x-forefront-prvs: 09749A275C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(136003)(366004)(39860400002)(376002)(199004)(189003)(54094003)(256004)(386003)(14444005)(6506007)(25786009)(54906003)(1076003)(6436002)(7736002)(102836004)(68736007)(6486002)(5660300002)(71190400001)(6246003)(229853002)(14454004)(81156014)(81166006)(9686003)(76176011)(305945005)(11346002)(478600001)(476003)(8676002)(446003)(6916009)(4326008)(46003)(99286004)(6512007)(8936002)(186003)(97736004)(53936002)(486006)(316002)(106356001)(93886005)(71200400001)(105586002)(86362001)(52116002)(33656002)(2906002)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3510;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: oqcbNJ/DPl4R11an69bG1xo6rHxmu+XOK04/Nw3L1eJ994FG1De6IakPnkS6DlpOfrcMgPo7MC4/FQRy8iqM05W/JE7/rTqFr/QCB5G7BHOcNM7FEXV1SBg7wMsGIQPSnp48bYq0oECrWwnF52LwICtR+Xj9RL2bBGoxHEBLf8WLpMukFHaZGDesvnTlAWxng442Q4qT2W23vv8cF/HqZ8csdtf3UMho3T1AxKd6OYi3j63nzT3NVeJ4xEGeYjdrN0dj8wsOIPqnp261zE6PSoJBMpzXOevmjpctNyv3ZTPGUQ7A1e1jOPL/Kv/JiqdwSngccZdIrtteXTiTlbJyBiwiNOhKZ0qMnXZP2BF2xslq6lFiai4e5ngEdSmjYNzbJhdmsNVbDO6lINAtuFRWA+16x9QuIKZYrUw8Fm0oUiM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6569EAB69B17AE42B6B6270C7F703CBE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: af1a46df-4e5a-440b-5e95-08d6a71b3eab
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2019 18:47:57.9999
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3510
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 04:35:15AM +0000, Christopher Lameter wrote:
> On Mon, 11 Mar 2019, Roman Gushchin wrote:
>=20
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -4325,6 +4325,34 @@ int __kmem_cache_create(struct kmem_cache *s, =
slab_flags_t flags)
> > >  	return err;
> > >  }
> > >
> > > +void kmem_cache_setup_mobility(struct kmem_cache *s,
> > > +			       kmem_cache_isolate_func isolate,
> > > +			       kmem_cache_migrate_func migrate)
> > > +{
> >
> > I wonder if it's better to adapt kmem_cache_create() to take two additi=
onal
> > argument? I suspect mobility is not a dynamic option, so it can be
> > set on kmem_cache creation.
>=20
> One other idea that prior versions of this patchset used was to change
> kmem_cache_create() so that the ctor parameter becomes an ops vector.
>=20
> However, in order to reduce the size of the patchset I dropped that. It
> could be easily moved back to the way it was before.

Understood. I like the idea of an ops vector, but it can be done later,
agree.

>=20
> > > +	/*
> > > +	 * Sadly serialization requirements currently mean that we have
> > > +	 * to disable fast cmpxchg based processing.
> > > +	 */
> >
> > Can you, please, elaborate a bit more here?
>=20
> cmpxchg based processing does not lock the struct page. SMO requires to
> ensure that all changes on a slab page can be stopped. The page->lock wil=
l
> accomplish that. I think we could avoid dealing with actually locking the
> page with some more work.

Thank you for the explanation!

