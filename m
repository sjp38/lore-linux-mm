Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1344C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D3AE218AF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:00:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dz52cer/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ly4E81vp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D3AE218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 495D26B0007; Mon,  9 Sep 2019 16:00:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 447106B0008; Mon,  9 Sep 2019 16:00:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30D606B000A; Mon,  9 Sep 2019 16:00:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8216B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:00:09 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id ACF45181AC9B4
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:00:08 +0000 (UTC)
X-FDA: 75916448496.15.tiger78_1e25459822f2d
X-HE-Tag: tiger78_1e25459822f2d
X-Filterd-Recvd-Size: 10028
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:00:06 +0000 (UTC)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.42/8.16.0.42) with SMTP id x89JfnKp028449;
	Mon, 9 Sep 2019 13:00:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=LMymMa5k2CyJJyAWhW1S8xr496iweGFGF0ckn8b/UOA=;
 b=dz52cer/ZHiJUPBFARy3hDqWjHluLSpHAaHDDslLb68f4TaIgFNsm5P+sYCTLfiVkApZ
 7dZiNiEvSooPAUT0fUSNrjQD7QOp77woQ4hzxPfFdroaj346IhfDuUFed+0mzBbpVt0s
 h4PO4x+zg5hWunmDQGkNUQbx7FDFcZiueOQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2uv87nh461-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 09 Sep 2019 13:00:03 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 9 Sep 2019 13:00:02 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 9 Sep 2019 13:00:02 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ab6A9nQCcMqYOJig1WVcmyTJl7jhSQN6pl1NDKEZvumCHhVV9Uu6MxcJb3xN7FUDgRHcRfNo1Xtk6uE8MHaE3TEzJ9C9sMdLRwpeM96gL7EWKtINLtVK5TDZAM3afYo5OKm2xZeL0QALuqV7L+mSY56PAdv8KVpHIWZLTJua5sxvJKbnrjqgVjDtkrepB8pnzFlDQWaAVZuzOOBRucUWJBkBT5pw9rwuwRnFKZsQYkgeebiW70B3nXSg/9XFX3oLv6nlx0C57R31P5HMyIdBlZr1s8Gw9xYENtEsVY1uRbOv+pg+wYdOSfmfZqnx5sVz3lPoQ1HClkLRWhzYcVPx3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LMymMa5k2CyJJyAWhW1S8xr496iweGFGF0ckn8b/UOA=;
 b=Np4mSOb8tEPr4DVvInYVTfhpPF5SACgkzuJsEeu7PJRpdYiVWlikBi9EqaAxkjuiqA+881blYAtEg3FxaalxSuwg+mna4bSxriq//5Caaxs1b3hAmJDXV6+zAH7UMbIk//9Jloxvv3WK1Ny45ax8IRTtpN7bhYTmYHJd/rYD8mbGWWDe/Gf/z0UzY3W+43lqq8HzMIjwEX8tcC21Hdp1uFMyQ82akWqTHVPFAO+5bTLfZA0eZwv2zvbfcbLj1CJMTK3pVv+JocTOYm3/iFzfCgMVTeYypGw5Nh0cUVAhp78bSYTqc1pnfUvhA7rW6KLYdGUQyIp1kTO1YgsPSSl39Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LMymMa5k2CyJJyAWhW1S8xr496iweGFGF0ckn8b/UOA=;
 b=Ly4E81vppH90256KQ82OsK+zLErsbzUvUMahRi6dSTq3GoCfHVcJaJfef/r4rFmquVS33izems9iXhIVqd4cRwPyMZaubK5VQBIPpyVYGvjqyIK0/OkimybdU9NqaCmWh9iToIgizGjAongMp1qz3odQjmcayI3zcPpyshVnkA8=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2947.namprd15.prod.outlook.com (20.178.219.218) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.18; Mon, 9 Sep 2019 20:00:00 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::5d2:6eec:98cc:76d2]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::5d2:6eec:98cc:76d2%3]) with mapi id 15.20.2241.018; Mon, 9 Sep 2019
 20:00:00 +0000
From: Roman Gushchin <guro@fb.com>
To: Pengfei Li <lpf.vector@gmail.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "vbabka@suse.cz"
	<vbabka@suse.cz>, "cl@linux.com" <cl@linux.com>,
        "penberg@kernel.org"
	<penberg@kernel.org>,
        "rientjes@google.com" <rientjes@google.com>,
        "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 3/4] mm, slab_common: Make 'type' is enum
 kmalloc_cache_type
Thread-Topic: [PATCH v2 3/4] mm, slab_common: Make 'type' is enum
 kmalloc_cache_type
Thread-Index: AQHVZzE0SUuLIOWnuUe4DGQG2id7Facjw+qA
Date: Mon, 9 Sep 2019 20:00:00 +0000
Message-ID: <20190909195955.GA2181@tower.dhcp.thefacebook.com>
References: <20190909170715.32545-1-lpf.vector@gmail.com>
 <20190909170715.32545-4-lpf.vector@gmail.com>
In-Reply-To: <20190909170715.32545-4-lpf.vector@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0093.namprd22.prod.outlook.com
 (2603:10b6:301:5e::46) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:2b5d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9f1cbd64-0437-41fb-9cd7-08d735604bbf
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB2947;
x-ms-traffictypediagnostic: BN8PR15MB2947:
x-microsoft-antispam-prvs: <BN8PR15MB2947250E78CD973EC4B07D11BEB70@BN8PR15MB2947.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:534;
x-forefront-prvs: 01559F388D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(376002)(396003)(136003)(366004)(189003)(199004)(229853002)(14444005)(54906003)(316002)(46003)(478600001)(6506007)(305945005)(7736002)(386003)(4326008)(186003)(256004)(1076003)(33656002)(6246003)(99286004)(76176011)(8676002)(2906002)(52116002)(9686003)(81156014)(81166006)(6512007)(53936002)(8936002)(6916009)(66446008)(64756008)(66556008)(66476007)(66946007)(446003)(6436002)(6116002)(86362001)(6486002)(5660300002)(14454004)(71190400001)(71200400001)(102836004)(25786009)(476003)(11346002)(486006);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2947;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: zpAanssIGGp+bGyFCNGrJe8UXY7mdhS8JtaZKUlJBkREAa6cmeI3SL+m5qjowCLEBzPkAvdBRLmRAJj5S1Dtc9L1rp9x5zd0dLRE/r0+iAKbiAQ+C0fwgkhcRswH33UeseRcDDTXE8G3k+u9PC9dwW6X7CaHHYy31XmuQLjzWYXXwb1Ja8SdLRxuDU6JnqfqdFO9ek7DnElkghl+qe4hwxAivjpmxU4f9NUN7biKw4+CGOuPe4nd9XstErpTJ0n5EL5vAH1fVYOftEuYPQ4PNJyzZ2enwQt9lBhGO2WMaZ1FfKKh6KOqPn3IpgUckDreBv5PAtsDiTAlDcPjoTX6NPCPoeetZSnp2p4trg+PwCBmJ+QMuu6nHKWgYWbc2qLI/pcAPjqGZdJwv1ppacMaRFIfI2fLCQj14tYH85uQTJM=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <153F3585B42C304694B3B0667164B592@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9f1cbd64-0437-41fb-9cd7-08d735604bbf
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Sep 2019 20:00:00.2114
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 77njtViFhNLDLEkJP6otBl15B3x/EjAovW7ff+4j/WSFXHcm1OhuaxysymFnmwv0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2947
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-09_07:2019-09-09,2019-09-09 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 mlxlogscore=999
 clxscore=1011 phishscore=0 adultscore=0 suspectscore=0 priorityscore=1501
 bulkscore=0 lowpriorityscore=0 impostorscore=0 spamscore=0 mlxscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1906280000 definitions=main-1909090197
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 01:07:14AM +0800, Pengfei Li wrote:

Hi Pengfei!

> The 'type' of the function new_kmalloc_cache should be
> enum kmalloc_cache_type instead of int, so correct it.

I think you mean type of the 'i' variable, not the type of
new_kmalloc_cache() function. Also the name of the patch is
misleading. How about
mm, slab_common: use enum kmalloc_cache_type to iterate over kmalloc caches=
 ?
Or something like this.

The rest of the series looks good to me.

Please, feel free to use
Acked-by: Roman Gushchin <guro@fb.com>
for patches [1-3] in the series after fixing this commit message and
restoring __initconst.

Patch [4] needs some additional clarifications, IMO.

Thank you!

>=20
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>



> ---
>  mm/slab_common.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index cae27210e4c3..d64a64660f86 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1192,7 +1192,7 @@ void __init setup_kmalloc_cache_index_table(void)
>  }
> =20
>  static void __init
> -new_kmalloc_cache(int idx, int type, slab_flags_t flags)
> +new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
>  {
>  	if (type =3D=3D KMALLOC_RECLAIM)
>  		flags |=3D SLAB_RECLAIM_ACCOUNT;
> @@ -1210,7 +1210,8 @@ new_kmalloc_cache(int idx, int type, slab_flags_t f=
lags)
>   */
>  void __init create_kmalloc_caches(slab_flags_t flags)
>  {
> -	int i, type;
> +	int i;
> +	enum kmalloc_cache_type type;
> =20
>  	for (type =3D KMALLOC_NORMAL; type <=3D KMALLOC_RECLAIM; type++) {
>  		for (i =3D KMALLOC_SHIFT_LOW; i <=3D KMALLOC_SHIFT_HIGH; i++) {
> --=20
> 2.21.0
>=20
>=20

