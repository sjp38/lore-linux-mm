Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D43E3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F5392175B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:05:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ejRv1O3Q";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KgvJqOeJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F5392175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD9B8E0003; Tue, 12 Mar 2019 14:05:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AA9B8E0002; Tue, 12 Mar 2019 14:05:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 172008E0003; Tue, 12 Mar 2019 14:05:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFDA48E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:05:41 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id i63so2899322itb.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:05:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=6Ws3AIdbpT34KncUDlT96q/8l4bC8vf7Sa0gpmMAouw=;
        b=AvoGss52VH2IFOR5pDTyoY4BT7GvsRb7fq53X9stGZIG3DlV1MlwpVtI+onseFwHA5
         I2VWTeuZu9BbdTIOYSRrQgv5MmTi8cftmYUqzhGgs6nJh2e8nWd6tSaqwY3FtMBN3SkB
         glX5bx4KyPVU1pBekNnC0ZTstAM6U/PQpGw6NaZNQN4ggUNpGmg+tWzXtyC95SYbGdVn
         Fuurn5e5/E9M/2j7IHodTSji6wvWnwGf7Ln/cauIx+NbaX0N/xFTFF+giQ3yDN6muZ52
         C4H+pfvo+c81R/DMAmoV60A+N5O/S2edees05GjhSFfhTSJiaPS9PMUNtC+rd3xu1rD2
         Vk9g==
X-Gm-Message-State: APjAAAU91odyotsuLJ+rIDTJ9AUMoh6Wt+mz3EiqDbOsRR57qnSMtxbP
	6V8Bs44FCbHweBoSn23L5J/Qy40k2FVM1KXcBKhpxENlI/E6ZPeTwvuoogT50RRKNoggbUjNIkf
	Aka+7CbJCwaAYVwODlmLHPmFvonD4Cxe+5CzgHcVAQBbWve207Jjrn5s8dP6xROAzvg==
X-Received: by 2002:a24:6fce:: with SMTP id x197mr3007488itb.108.1552413941618;
        Tue, 12 Mar 2019 11:05:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH0tdCahdbpA7mbhvWFxPJhWgCGn2rWG7GDyk/4tjV8KViW/sBczXCnz5yhMylSdfHnNyn
X-Received: by 2002:a24:6fce:: with SMTP id x197mr3007417itb.108.1552413940520;
        Tue, 12 Mar 2019 11:05:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552413940; cv=none;
        d=google.com; s=arc-20160816;
        b=EJMmTHzadDcfMLjiQ13ufMWuWrZRokbUjVMmOspb0qDQy5CThorVYIVs7hq5W9OWDh
         FHpw1UOieBXlBgmK4g1mq0MNq303BsUwgTwIAbXPaT3k2jcrUQWPkamim5DZQoGjuOe5
         3YrIL94ju1NQCYpVigvd2yZ8Suc5vZc9ZLSpXjDXgxeLeEtpswGIPfuoY7ZBz3emAxsM
         FBauqkC+a8i0c4rBbWGFFGgp35UVXOrp0h6kwL4BXlg9h6wzoEMjPNWga3qcYhr04ehC
         fdI1AEgV4XrMEprXg3yRTLHe56eFn32+twJw1ji8fty+VnMGAjxjsszal7QCma6hPBud
         JdKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=6Ws3AIdbpT34KncUDlT96q/8l4bC8vf7Sa0gpmMAouw=;
        b=lw1kvboLxsRjCyfwn7w+REMdXhuLNWdTFdn1UvmWpRqc4696YF+RS1wlhjC01o0XUw
         fZ50VBJ12NdP5YFpmoNVSp5pvwHcTW9nIdizMQZs0u9Y3DVQsay+p0SNgLsB0QJT48o3
         3oqZQKeOJuhevziBAa9fK3gkp2OfebhmZ0+9WkaVCrM2nQJ9ENc8TwlGO4Ki4qAc5EYj
         jqCXevSHFtcsziO38YUIxMkqxx9FCsbcd8yugY6izUkymyR5l0PCYVAVM3e4TJAT/21v
         PQgh9gOFmrxZNw/QrKv2PNcIvwd8saDPNidfH4JO6QkwMGiZXbAvxhcWBmkRRGlIeeKB
         ogcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ejRv1O3Q;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KgvJqOeJ;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t6si4300651iom.118.2019.03.12.11.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:05:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ejRv1O3Q;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KgvJqOeJ;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2CI2tbv023074;
	Tue, 12 Mar 2019 11:05:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=6Ws3AIdbpT34KncUDlT96q/8l4bC8vf7Sa0gpmMAouw=;
 b=ejRv1O3QkHjC2LPTJglsnvuZ2Mv9sEQqLemmivqBQZIVDEHfzDQZVAuxdpR+onFx2M7I
 R5ecoo1wUvQVMQ2GvMxTSagf9pRNAfOlyx7lB2zhmvY19Bgpzq80Do2KLE/myNgUPSm3
 gl2J2ImM94AG5zpI9FDoHZKStSSfF2llHoY= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r6f6j8xtb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 12 Mar 2019 11:05:28 -0700
Received: from frc-mbx08.TheFacebook.com (192.168.155.29) by
 frc-hub06.TheFacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 12 Mar 2019 11:00:25 -0700
Received: from frc-hub04.TheFacebook.com (192.168.177.74) by
 frc-mbx08.TheFacebook.com (192.168.155.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 12 Mar 2019 11:00:25 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 12 Mar 2019 11:00:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6Ws3AIdbpT34KncUDlT96q/8l4bC8vf7Sa0gpmMAouw=;
 b=KgvJqOeJHy4E4dmODiDb6j5FbkFzjezHKH5QUcHSQlgML9z3iuUgW5g+VLafvSMoRvFYdQsKFCSTVy9RL4TCZPSGaphgsDHEtmMGqCEsd+QnivAdOGcAFnFZp+YPPCgWYm9hoKLHdJZJBgRNzuGKEWfUO0klwzW7aL1yj3jWf/Y=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3159.namprd15.prod.outlook.com (20.178.207.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.19; Tue, 12 Mar 2019 18:00:09 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Tue, 12 Mar 2019
 18:00:09 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <me@tobin.cc>
CC: "Tobin C. Harding" <tobin@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Christopher Lameter <cl@linux.com>,
        Pekka Enberg
	<penberg@cs.helsinki.fi>,
        Matthew Wilcox <willy@infradead.org>,
        "Tycho
 Andersen" <tycho@tycho.ws>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Thread-Topic: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Thread-Index: AQHU1WWOlMss86oUX0OspYov/G2S1KYGmQIAgACnOACAAQ/MAA==
Date: Tue, 12 Mar 2019 18:00:09 +0000
Message-ID: <20190312175958.GA31407@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-5-tobin@kernel.org>
 <20190311224842.GC7915@tower.DHCP.thefacebook.com>
 <20190312014712.GF9362@eros.localdomain>
In-Reply-To: <20190312014712.GF9362@eros.localdomain>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1301CA0018.namprd13.prod.outlook.com
 (2603:10b6:301:29::31) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:d3a0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 923feb45-9ecd-4b02-534c-08d6a71490cf
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3159;
x-ms-traffictypediagnostic: BYAPR15MB3159:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3159;20:+ulgd+cC+WcT4q2RwZ6I8BT1sdE+AfWTOEqCwcBjhMpyRaSFLUTfW/dXSfa+DmWB0yujhw6RsWx3EnwWlvcJW4m0cgJu89YqzkCZLlBObgR3BXgortvpDrlQxnIJeCx93bAZdpsZWzS9dNkp5ZJzqKWhXbtM9jsqBAvQ7dczRF8=
x-microsoft-antispam-prvs: <BYAPR15MB315991C75D0827E975FDE105BE490@BYAPR15MB3159.namprd15.prod.outlook.com>
x-forefront-prvs: 09749A275C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(396003)(346002)(376002)(39860400002)(189003)(199004)(52314003)(186003)(46003)(8676002)(106356001)(6246003)(81166006)(81156014)(25786009)(33656002)(14454004)(478600001)(6506007)(102836004)(52116002)(386003)(71190400001)(8936002)(229853002)(76176011)(68736007)(6116002)(4326008)(71200400001)(6512007)(9686003)(476003)(11346002)(446003)(53936002)(486006)(6436002)(99286004)(6486002)(2906002)(7736002)(305945005)(86362001)(316002)(14444005)(93886005)(256004)(1076003)(5660300002)(6916009)(105586002)(54906003)(97736004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3159;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 05YkwGLcmrv07Rd/Wgqz9MJxu23uFHUInNh2+aJzbtwZOlU8hzCFEof85Pm+35TC+tzqq+YxXztS3x61A+tkYUAwr6MBRItsr28/61dW0YvqQPzH18QIXn2Pr1zYt6zgnTdoDpADAfLWOs5YpSnrpgQTmFbrYw//cR2muwwmBXzt9CwmovqKtEqgy5GBSsd0lP8ZvCly9Cu78XZ8lxAUy30JHCT9U/Ql+J9Sotapm+CgSU8tKN0mzDnvuaGeu4zhvnN1nKPHJijPUoUjKAOf55B6/9CQ77s2TG3ybz7jBB2tiSaus+X6YXqQcvg8D0FZ/75eZw8rJ7dQQcweTnXefFXpUkcmYECuRCLsQO92xINqiTXgXjd71+P94qkiRAOmnuda1DdtEp57Jzz5qD3gkohnKCqw9hVFyqDzhNvgmDk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <431E5C4F4C688345ABB7F7F3714A6E90@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 923feb45-9ecd-4b02-534c-08d6a71490cf
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2019 18:00:09.3276
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3159
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

On Tue, Mar 12, 2019 at 12:47:12PM +1100, Tobin C. Harding wrote:
> On Mon, Mar 11, 2019 at 10:48:45PM +0000, Roman Gushchin wrote:
> > On Fri, Mar 08, 2019 at 03:14:15PM +1100, Tobin C. Harding wrote:
> > > We have now in place a mechanism for adding callbacks to a cache in
> > > order to be able to implement object migration.
> > >=20
> > > Add a function __move() that implements SMO by moving all objects in =
a
> > > slab page using the isolate/migrate callback methods.
> > >=20
> > > Co-developed-by: Christoph Lameter <cl@linux.com>
> > > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > > ---
> > >  mm/slub.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++=
++
> > >  1 file changed, 85 insertions(+)
> > >=20
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 0133168d1089..6ce866b420f1 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -4325,6 +4325,91 @@ int __kmem_cache_create(struct kmem_cache *s, =
slab_flags_t flags)
> > >  	return err;
> > >  }
> > > =20
> > > +/*
> > > + * Allocate a slab scratch space that is sufficient to keep pointers=
 to
> > > + * individual objects for all objects in cache and also a bitmap for=
 the
> > > + * objects (used to mark which objects are active).
> > > + */
> > > +static inline void *alloc_scratch(struct kmem_cache *s)
> > > +{
> > > +	unsigned int size =3D oo_objects(s->max);
> > > +
> > > +	return kmalloc(size * sizeof(void *) +
> > > +		       BITS_TO_LONGS(size) * sizeof(unsigned long),
> > > +		       GFP_KERNEL);
> >=20
> > I wonder how big this allocation can be?
> > Given that the reason for migration is probably highly fragmented memor=
y,
> > we probably don't want to have a high-order allocation here. So maybe
> > kvmalloc()?
> >=20
> > > +}
> > > +
> > > +/*
> > > + * __move() - Move all objects in the given slab.
> > > + * @page: The slab we are working on.
> > > + * @scratch: Pointer to scratch space.
> > > + * @node: The target node to move objects to.
> > > + *
> > > + * If the target node is not the current node then the object is mov=
ed
> > > + * to the target node.  If the target node is the current node then =
this
> > > + * is an effective way of defragmentation since the current slab pag=
e
> > > + * with its object is exempt from allocation.
> > > + */
> > > +static void __move(struct page *page, void *scratch, int node)
> > > +{
> >=20
> > __move() isn't a very explanatory name. kmem_cache_move() (as in Christ=
opher's
> > version) is much better, IMO. Or maybe move_slab_objects()?
>=20
> How about move_slab_page()?  We use kmem_cache_move() later in the
> series.  __move() moves all objects in the given page but not all
> objects in this cache (which kmem_cache_move() later does).  Open to
> further suggestions though, naming things is hard :)
>=20
> Christopher's original patch uses kmem_cache_move() for a function that
> only moves objects from within partial slabs, I changed it because I did
> not think this name suitably describes the behaviour.  So from the
> original I rename:
>=20
> 	__move() -> __defrag()
> 	kmem_cache_move() -> __move()
> =09
> And reuse kmem_cache_move() for move _all_ objects (includes full list).
>=20
> With this set applied we have the call chains
>=20
> kmem_cache_shrink()		# Defined in slab_common.c, exported to kernel.
>  -> __kmem_cache_shrink()	# Defined in slub.c
>    -> __defrag()		# Unconditionally (i.e 100%)
>      -> __move()
>=20
> kmem_cache_defrag()		# Exported to kernel
>  -> __defrag()
>    -> __move()
>=20
> move_store()			# sysfs
>  -> kmem_cache_move()
>    -> __move()
>  or
>  -> __move_all_objects_to()
>    -> kmem_cache_move()
>      -> __move()
>=20
>=20
> Suggested improvements?

move_slab_page() looks good to me. I don't have a strong opinion on naming =
here,
I just think that unique names are always preferred even for static functio=
ns
(that's why I don't like __move()). Also, it's not clear what '__' means he=
re.
So maybe move_slab_page(), defrag_kmem_node(), etc? Or something like this.

>=20
> > Also, it's usually better to avoid adding new functions without calling=
 them.
> > Maybe it's possible to merge this patch with (9)?
>=20
> Understood.  The reason behind this is that I attempted to break this
> set up separating the implementation of SMO with the addition of each
> feature.  This function is only called when features are implemented to
> use SMO, I did not want to elevate any feature above any other by
> including it in this patch.  I'm open to suggestions on how to order
> though, also I'm happy to order it differently if/when we do PATCH
> version.  Is that acceptable for the RFC versions?

The general rule is that any patch should be self-sufficient.
If it's required to look into further patches to understand why something
has been done, it makes the review process harder.

I think it's possible to make the patchset to conform this rule with
some almost cosmetic changes, e.g. move some changes from one patch
to another, add some comments, etc.

Anyway, it's definitely fine for an RFC, just something to think of
in the next version.

Thanks!

