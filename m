Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA3CC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A128D2075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:15:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="eCbylcpJ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="blmYgpql"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A128D2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02216B0266; Wed,  5 Jun 2019 17:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8C446B0269; Wed,  5 Jun 2019 17:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE126B026A; Wed,  5 Jun 2019 17:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81A536B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:15:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so14357pgs.13
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=/ZoSr9qLEaZfTbibk7ViM4CPP2qGYwJZdZOwU7WjVTw=;
        b=gPqfA9vp7qqW9xRTHVsrH8Ij4Wia2qXp3bR2F8asmMSTu3iFzdo84mwDnTJ3RegXV0
         vM6cgZ72nYCjcwBbbMALVeeYZ/W8ql0uNjqUTHF9dZApRTjvDIjF0tEzbs3iSqM1kUMt
         AiPQnw7q3eUmSi5fQ/0SE2q9VlM5DteovaEilIOGmzRgBppIE2du01hTCUWmhfyOEw0y
         Wb+9Sb8KS3DRNVvq6UIdsh3qjDbiJG8wGYDN8ij5G73prmODc70fr9iZhoSrTrQRlFhb
         7RqKiAw4cuJNtLHy/OnJJxzx+NouF8gMRSxkPKrCMruP9a0VpczfhgK5L46vCVQOY+xK
         6V7A==
X-Gm-Message-State: APjAAAX6IAaRq/daBhteJY7pbIq+O+XwqMIMXkwYPQ2nnCOUWf4wWerF
	W98CiigCl1ka+UR5A2o9YtY9OOiAB9kqnOLRKxrCNc1wvfbJUZEBRc+VCfdMgQd4H3UrYU3MAzG
	2JDvKa7ZrWiTHRqAbznMxrVyIIjmZx3arHUhwR4Q0Y0A4MzRRf90A294yGUVCoKRRiw==
X-Received: by 2002:a63:1344:: with SMTP id 4mr998524pgt.448.1559769347956;
        Wed, 05 Jun 2019 14:15:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKR8rve/7+zRaEuO+EZpLzL7+CF6Jt27h1W73rOquon3s0PW5Qb1q7/Y/BWPyOPxDOXlc1
X-Received: by 2002:a63:1344:: with SMTP id 4mr998427pgt.448.1559769347090;
        Wed, 05 Jun 2019 14:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559769347; cv=none;
        d=google.com; s=arc-20160816;
        b=j7Z8dvEe0WzHNpeWtZ44RBGbJ3uxSlyQoIyq8WIDPYctHPweeJaakOuOU6v31pQFUj
         b/pLHHGFf87pAs9rKJQhD+eUwPbqcPa1jBQugKQEIpxg/cfpKcJ5/SX1ahoPVC/jUhgS
         SYXxMhTwCR8W6xNl+rUxAeGVxdxMT2YQF5tYd5qju/nLyCljI+8dglNxuSqDRSm9WjVL
         XFyp6x7YjGxeZ0ommzd9L075fNQngABfaL+rQqWFxIiPVADWLHWoagb5fx2xWQu7xzmZ
         5+CzeDyt6yicv+B1rpligMlCbfh5W+XNixEZaZN7mcIoebqlMXQPiEtDKpQMrws1q4ei
         mIFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=/ZoSr9qLEaZfTbibk7ViM4CPP2qGYwJZdZOwU7WjVTw=;
        b=zKcGmLr2Jid9TjIOlknW/MnDsqMH6clkukGJSuN2X8cFfdIAPLcrfH01oVAwnEBBmM
         jKvT7wRRhvPX2t4PxvT/2PS4d+9D/2TDQ5AeqUgTDm5Tk6mmJlfA10wLZ41GT17Z0CnR
         i7hq1+SqlMHxTiWkpBDW4IPJY6e/WLkfCrAEwtOO7vU3DzUAmvOGmqhld1MW0Fa3ikIo
         1wIuiy2rs5A7BtJk4t/MdDRWKQT3HZbR8986Efn+rY7mskIdHRfUwiP84thujseHuD6A
         KKlCtBXYRzOpKsnOi6p849AviSJL6TacIY9/xmFWew4KlFyMxBJYN2APWwkpx+hnvcNq
         qr4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eCbylcpJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=blmYgpql;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k8si55419pgi.123.2019.06.05.14.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 14:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eCbylcpJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=blmYgpql;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x55Kh6op013265;
	Wed, 5 Jun 2019 13:46:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=/ZoSr9qLEaZfTbibk7ViM4CPP2qGYwJZdZOwU7WjVTw=;
 b=eCbylcpJIbYL1lYgp3qNd88zlbam9aOBE7pie8F5+nBHfQyjU4OES9oijek97bvENCAr
 lBep0UCfMWEC0uvyh4U4gEa44WLJzZtr2tu/z8/2xnUbm2o2cRJmIYl8nOpZGdmsRKPX
 fiuATneWOA7/PT9Pu26aZHApiHM0eXqwMtQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sxka80dtu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 05 Jun 2019 13:46:02 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 5 Jun 2019 13:46:01 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 5 Jun 2019 13:46:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/ZoSr9qLEaZfTbibk7ViM4CPP2qGYwJZdZOwU7WjVTw=;
 b=blmYgpqlWSkd9/KML+zZ+1mbI8biZUB3hTATlcOrck3oqUbGbcllfPwKl2JFUT/bGBBngpsA9+h0gDbzPZevmfuyGyp/fz0TfjeYStYQp5+WoybhNCLHdkde7cw5AsnXQFIkg/Ht+jYZP/UiIWF80CHdJqiMrudgZLrDPKLc4NE=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2600.namprd15.prod.outlook.com (20.179.155.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Wed, 5 Jun 2019 20:45:59 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1943.018; Wed, 5 Jun 2019
 20:45:59 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Shakeel Butt <shakeelb@google.com>,
        "Vladimir
 Davydov" <vdavydov.dev@gmail.com>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 00/10] mm: reparent slab memory on cgroup removal
Thread-Topic: [PATCH v6 00/10] mm: reparent slab memory on cgroup removal
Thread-Index: AQHVG0i11hwXEGSev06rqUx7yW/VhKaMc7gAgAEVDoA=
Date: Wed, 5 Jun 2019 20:45:59 +0000
Message-ID: <20190605204555.GC10098@tower.DHCP.thefacebook.com>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190604211418.70d178253550d96da46cee21@linux-foundation.org>
In-Reply-To: <20190604211418.70d178253550d96da46cee21@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR20CA0046.namprd20.prod.outlook.com
 (2603:10b6:300:ed::32) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:a19a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9bab4133-a572-4471-8337-08d6e9f6d0b2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2600;
x-ms-traffictypediagnostic: BYAPR15MB2600:
x-microsoft-antispam-prvs: <BYAPR15MB26008CB813EE481CBB8E608ABE160@BYAPR15MB2600.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 00594E8DBA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(39860400002)(366004)(376002)(346002)(189003)(199004)(76176011)(99286004)(68736007)(54906003)(316002)(52116002)(53936002)(6246003)(6916009)(6512007)(9686003)(25786009)(446003)(46003)(11346002)(4326008)(6116002)(476003)(486006)(478600001)(229853002)(14454004)(33656002)(73956011)(6436002)(66476007)(66556008)(64756008)(66946007)(66446008)(6486002)(305945005)(256004)(14444005)(1076003)(8936002)(81156014)(71200400001)(8676002)(71190400001)(7736002)(86362001)(81166006)(186003)(5660300002)(2906002)(102836004)(386003)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2600;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: psJ6PrpHs3gpw4eMzLKPubEKHR3aamKbYlMVlrNMCHHpC+mIv8M1WZ5MBYql4k8EnCzwcOb/tr2aIQuYsbVZ9L/YnZJqpGm8QhATxHXOtFhftaHmmCjadT3UU9CLJv+lTlF6laWLAcHzJujmZFUP0swUv0G4NAqUG/yNCoVrJgsAqPxPI2AsOoVfPFwzg+4d2UtwChDjFpaNerCX8z2mWTIv8ivLQk/L9dJLpVLvBowLd3e3+Yr2lN2HMrod+8WEI3AICfYV7S7ChSqyj82R9avYcyqo82OZ2T6R/QTCKAHay0fqFnxfuG/9xQwe5ykiAjjVLxz04r+JcHgoroEBPGghaNKnqZt4P0fnAMzUyWo6KNwq9nkz8CSESEeuS+IV/ewtnsqgowV0sTbOYcpHioGHzi5jIMqkRXoks7IeWRw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0EA21FF608EE45438385A171ACF79D9A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9bab4133-a572-4471-8337-08d6e9f6d0b2
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Jun 2019 20:45:59.4688
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2600
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=663 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050131
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 09:14:18PM -0700, Andrew Morton wrote:
> On Tue, 4 Jun 2019 19:44:44 -0700 Roman Gushchin <guro@fb.com> wrote:
>=20
> > So instead of trying to find a maybe non-existing balance, let's do rep=
arent
> > the accounted slabs to the parent cgroup on cgroup removal.
>
> s/slabs/slab caches/.  Take more care with the terminology, please...

Slabs are effectively reparented too (what's most important, their
references), but I agree, "slab caches" suits better here.

>=20
> > There is a bonus: currently we do release empty kmem_caches on cgroup
> > removal, however all other are waiting for the releasing of the memory =
cgroup.
> > These refactorings allow kmem_caches to be released as soon as they
> > become inactive and free.
>=20
> Unclear.
>=20
> s/All other/releasing of all non-empty slab caches depends upon the relea=
sing/
>=20
> I think?
>=20
How about this?

There is a bonus: currently we release all memcg kmem_caches all together
with the memory cgroup itself. This patchset allows individual kmem_caches
to be released as soon as they become inactive and free.

--

Sorry, my bad, I was focused on patches, and didn't give enough attention
to the cover letter. I hope to get some feedback from Vladimir, and then
post a next version with these issues fixed.

Thank you for looking into it!

Roman

