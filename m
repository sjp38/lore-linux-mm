Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA6E4C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88844206B8
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="G16/4bcl";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="HB2kCROa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88844206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08E336B026B; Wed,  3 Apr 2019 17:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 063656B026D; Wed,  3 Apr 2019 17:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E46C66B026F; Wed,  3 Apr 2019 17:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95B7C6B026B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 17:17:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so205872edo.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 14:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=yMSHUAGOc8xPTYbjOLszOfE79ayRLFWYphU/fwtGWes=;
        b=eOv4tC0gIiIJkKfa5FEkzZ69Zf3d8EwPzicjgL+2VGlD/SLWRgwBd9sg4Z3u8Chlz3
         VYs834iQB5ri12od2uegJ/BxiT2mMw87WTXwI09LRAI3ORuQk0OMq+sojLOm0n6xDMvW
         TriUwG3S3puBRmoTgiq1rOV9J0z13p/vOZFUi9ZKmgqURvPqFX0HbgAKr25ytTaaZbQB
         xxB+bbkwr5t6Bj6XVEXTxBmHu59E4T8chtKSm774ybMt0rdKCzXD1liQAMPCPW36yqku
         y8/IxSZNHTenmkqYAxhyMPoMgABsNXwYLK0A9X85jz3/sCqIuiblXVCVe8Hi9gmhDyDO
         ay8g==
X-Gm-Message-State: APjAAAWd9qRmPOkc8Nz1v7KcYhfWOb80fmJfLSqTxnFEGAjD2xxpBdEm
	1M9TI/hbEOJp86yor67Ai5wp5T6zQve/aTk05yI+/n27jzAYeVeLHMTxUxERdbCvC9JJ+kr6mJ9
	W42MjYwL0NkccCmIgkqHTuEgUfJZfWH6AjCImx4sQMFjhO4p7/jFGnxPiacLcMvbmUQ==
X-Received: by 2002:a17:906:1906:: with SMTP id a6mr1137730eje.236.1554326225153;
        Wed, 03 Apr 2019 14:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2gVf+gTtyWoU/UbMyMgglMbGIB3aDWtud1qWZBkw4AcSqHifvyHOgLXPlQUS63A6qECaK
X-Received: by 2002:a17:906:1906:: with SMTP id a6mr1137683eje.236.1554326224239;
        Wed, 03 Apr 2019 14:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554326224; cv=none;
        d=google.com; s=arc-20160816;
        b=bMtz/xkCQyCVFGic7asK4JNc0x69ULNBZOJChBW6H2gUC2ZxVtvqJTVJkrBJkKEoT2
         wS7/KRqAefkp8iYX5J+WYUI1e1GJEmZtJGw6NoeKNcS18fp3ECvqsoHZuWc73iYX39Jz
         eBFMhLa1yvM9VwqzNqMidGIjqrE3LpoHTAtTQ16QypF4va9oB53yLWmdhJr4d6GeKLh/
         OP3BUKIiruucBvmi4ZzdTy1t1qZWvI5TDqSeJUuC95PYOO3S7NFbAzLQwpw7tJu6C690
         wHMC7wjAYV2amuvzUURuAurN2+wsAKySO9Kq0csd+GrcQBrxUG+UOWCYHnp2PwRsp3TK
         l3jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=yMSHUAGOc8xPTYbjOLszOfE79ayRLFWYphU/fwtGWes=;
        b=TsKBNN2FjQsmD0XKvxc1EmtyZcWmktDNkrzWK974hPe93dwFIW8cqUnqQAFUOOCAp4
         urGmbJMXpaXG1Xa5PV/hQopVsw5fqr4bHhA9RdVkTdDJMZJDHIskSeZ8nf1mqEdXoZYE
         AyhqxfWaXyLl4XAYlooFrtKagrmZs790Z6ZNVjTCT8wt6+Gc1EUe5rEi7ryN3U5wzN4M
         wDPXX74EazgnNKb8MQGkxRWcyU0NlgltcyH4DSQkdcJDBKyeDKsKerZX0ujiH5LCNN2A
         scvTXFZRU+jn3ugp1fQNX4qJTt3hD+g+7NP6rOLdM1XQclYKdkao53AfzuHNAoKvIbgG
         mYVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="G16/4bcl";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=HB2kCROa;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f21si614957edy.208.2019.04.03.14.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 14:17:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="G16/4bcl";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=HB2kCROa;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33LFZE4008359;
	Wed, 3 Apr 2019 14:16:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yMSHUAGOc8xPTYbjOLszOfE79ayRLFWYphU/fwtGWes=;
 b=G16/4bclIhRv7sDTLlomJwG+x12SDa+vcllv8iTWutuXwCN3kt5PNjgop2AYcDCMT6mG
 BIHD7lC0lSi8ZTX275ytcjyhsKikIx2l4qwg2+yGSzvQQVLyPUTSL26xajjaPmtS8kB/
 fYV4eEYprA0FHyC8PJGH+rYP4C/Ex0TgqOg= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rn4kd8032-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 14:16:25 -0700
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub06.TheFacebook.com (2620:10d:c021:18::176) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 14:15:51 -0700
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 14:15:51 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 14:15:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yMSHUAGOc8xPTYbjOLszOfE79ayRLFWYphU/fwtGWes=;
 b=HB2kCROaU6X1BlFj85skXoHyOO8qQq//oBjZ1/QCXjxUSbu/X0y8HdhAsmDKty2l9GfJyBUgmrGExNBLeJmEgNOvnh6Jgs3kbgf4Uekavpnj+iYQu8Ww/RDsQ2qC7u0VxLE2IgT0jbct4zc8vMJ8UOGTWpr4CDD4xhqziu9vZL0=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3047.namprd15.prod.outlook.com (20.178.238.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.22; Wed, 3 Apr 2019 21:15:44 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 21:15:44 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Thomas Garnier
	<thgarnie@google.com>,
        Oleksiy Avramchenko
	<oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [RESEND PATCH 2/3] mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK
 macro
Thread-Topic: [RESEND PATCH 2/3] mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK
 macro
Thread-Index: AQHU6XC/snrJ8Ur+cUCmvX5DYASOrqYq8eaA
Date: Wed, 3 Apr 2019 21:15:44 +0000
Message-ID: <20190403211540.GJ6778@tower.DHCP.thefacebook.com>
References: <20190402162531.10888-1-urezki@gmail.com>
 <20190402162531.10888-3-urezki@gmail.com>
In-Reply-To: <20190402162531.10888-3-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR16CA0002.namprd16.prod.outlook.com (2603:10b6:907::15)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: db2e13a4-d8ef-42fd-48f6-08d6b87988c4
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3047;
x-ms-traffictypediagnostic: BYAPR15MB3047:
x-microsoft-antispam-prvs: <BYAPR15MB3047F945C1986C7A87B230FCBE570@BYAPR15MB3047.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39860400002)(136003)(346002)(376002)(396003)(189003)(199004)(46003)(1411001)(105586002)(5660300002)(6506007)(102836004)(2906002)(54906003)(71190400001)(386003)(33656002)(229853002)(14454004)(71200400001)(106356001)(25786009)(446003)(86362001)(7736002)(6486002)(7416002)(99286004)(186003)(6116002)(476003)(97736004)(11346002)(316002)(1076003)(478600001)(305945005)(6246003)(6436002)(6512007)(486006)(68736007)(256004)(8936002)(9686003)(6916009)(53936002)(14444005)(81166006)(4326008)(81156014)(52116002)(76176011)(8676002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3047;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: sAfwE7KuSIm727q7QqyR1oRwz98c12PYJPcIKYhQbTEv1Gf7UjgHM5nvpZ2bxBpYpdJPYv2qXNaWvtmHlzHa4gtv7gEuUrVUlg4kfwWmfX2W6d1umnyNM1Zd41d+UNA7+IM4PnwDbSAQ5B4EiiKunNYtEDzcAFVlwaIbk4T/oGWTL4GWxAjwABuyG2Uqguncieymo/387xq4W70s5CUPJTu8h7E745I/IHxz+UR9wcVuM+2i816SiLgYc8DplS3mXXu9nR/j6dLo9Oz4QdXaRFQzPZmWP1FFzvp+4vI3EbRVTdQvlWcid2YU8pqqgm22wzuuMlr03IHPvtFGXADgO145KaYglV2kEo+QqzqiFAvgM7jy2QwOGnotbeXBqk8BVh9IEMPAT6kwdL9uGad6/TsTU0qFSpnvcD5BrKk5M34=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3C933796509DFD49A841B366184840E0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: db2e13a4-d8ef-42fd-48f6-08d6b87988c4
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 21:15:44.7434
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3047
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 06:25:30PM +0200, Uladzislau Rezki (Sony) wrote:
> This macro adds some debug code to check that the augment tree
> is maintained correctly, meaning that every node contains valid
> subtree_max_size value.
>=20
> By default this option is set to 0 and not active. It requires
> recompilation of the kernel to activate it. Set to 1, compile
> the kernel.
>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  mm/vmalloc.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
>=20
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 3adbad3fb6c1..1449a8c43aa2 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -322,6 +322,8 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr=
)
>  EXPORT_SYMBOL(vmalloc_to_pfn);
> =20
>  /*** Global kva allocator ***/
> +#define DEBUG_AUGMENT_PROPAGATE_CHECK 0
> +
>  #define VM_LAZY_FREE	0x02
>  #define VM_VM_AREA	0x04
> =20
> @@ -544,6 +546,53 @@ __unlink_va(struct vmap_area *va, struct rb_root *ro=
ot)
>  	}
>  }
> =20
> +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> +static void
> +augment_tree_propagate_do_check(struct rb_node *n)
> +{
> +	struct vmap_area *va;
> +	struct rb_node *node;
> +	unsigned long size;
> +	bool found =3D false;
> +
> +	if (n =3D=3D NULL)
> +		return;
> +
> +	va =3D rb_entry(n, struct vmap_area, rb_node);
> +	size =3D va->subtree_max_size;
> +	node =3D n;
> +
> +	while (node) {
> +		va =3D rb_entry(node, struct vmap_area, rb_node);
> +
> +		if (get_subtree_max_size(node->rb_left) =3D=3D size) {
> +			node =3D node->rb_left;
> +		} else {
> +			if (__va_size(va) =3D=3D size) {
> +				found =3D true;
> +				break;
> +			}
> +
> +			node =3D node->rb_right;
> +		}
> +	}
> +
> +	if (!found) {
> +		va =3D rb_entry(n, struct vmap_area, rb_node);
> +		pr_emerg("tree is corrupted: %lu, %lu\n",
> +			__va_size(va), va->subtree_max_size);
> +	}
> +
> +	augment_tree_propagate_do_check(n->rb_left);
> +	augment_tree_propagate_do_check(n->rb_right);
> +}
> +
> +static void augment_tree_propagate_from_check(void)

Why do you need this intermediate function?

Other than that looks good to me, please free to use
Reviewed-by: Roman Gushchin <guro@fb.com>

Thank you!

