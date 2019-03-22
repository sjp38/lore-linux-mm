Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA5DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D487121925
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:49:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="K5W6BNOE";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="MHRDOY0N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D487121925
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70DF76B0005; Fri, 22 Mar 2019 18:49:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 693CB6B0006; Fri, 22 Mar 2019 18:49:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 539266B0007; Fri, 22 Mar 2019 18:49:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9EA6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:49:45 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n13so3876650qtn.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:49:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=eQOCKprcnlqygT88HlJfZeaTj6uoVPtheVIQF6uhGZo=;
        b=mEjgr9fikAiTBxGIvJgNzm/Dt9su+wGd/CWJJ6N3Zz9XM+TVh6oLm3OiJVbWoscm0o
         jlWj0AcF/rJ6r2aMBo2EQ3ms6kT1zmcuWhzkhqwoWiaEscBgYpnxydMdeCZKMSObe0xO
         UOrYgKETx94XcVxcz8vMRpQAdsMggt3fQBppKxNSOGEjRfUj5sPlJd3MnJASWhbzVoyw
         15ozcdih/0VEkL9A88yUoNQMd5kFqha3duJLDQdN7LQvrAQbcY15yJMh90NhXJDtPCQS
         NhAWPv52zQscW+iVsxKZutwiGoka9580SDDMKx59RJHZY9ma6cV5vMXx1q75VdYRa+sO
         A42g==
X-Gm-Message-State: APjAAAUU//lRyk/renGOTlDx9kpHxJB5bFBIP3MQ00Iev6m+LtNyMTzw
	0XmTRoSRX70uPxq06SHgLhRuY8kDKImWob11dfnnHmEbidZ3U+LHBJfaDpWQFUF7JW3TsctnxZI
	HODJCw4a0AE3ut5I83sYv5mzl5GhQT8VnvhSaiTACzCOFdvGOBaA393ZOrPnfkcUCPQ==
X-Received: by 2002:aed:3a62:: with SMTP id n89mr9915825qte.88.1553294984852;
        Fri, 22 Mar 2019 15:49:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd9E+sLtWwIgMVgS56JAB8+Ml0W98JqVuyKBTnEH54L3xq1jw3aSpYCIUFumoMnEr2ko4z
X-Received: by 2002:aed:3a62:: with SMTP id n89mr9915796qte.88.1553294983958;
        Fri, 22 Mar 2019 15:49:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553294983; cv=none;
        d=google.com; s=arc-20160816;
        b=JjnLknwk8oaQ40j8k84F2Q16qCgctGBlGNGrwX4aAgBtfKBNtUfMCSr9yLdQtJY9Rf
         OyNBm6bAa7CCZ9x9ny6n5MM40/Z8ySmXkUz7xlyKdJVZxFjwz8Zc6PCjwSczChES15JD
         8e0Rgw939OzoyDA7jO7K8hYsLhX9GpPvhNOvB8dHcL9hHdK6QUBNvdjYPntU9iSU08TE
         8WUpuTIYmUzFlC2AkUY1zJ37m0GcbTALjFo1KU2J8zYImbHVvnltUZmiLny/sBNtF7n8
         Xv3QUMojJ/RXd/oBGvYUswBrfkcE6PaxehJOR9n4OjlMe2bRCGHSUBvgEQtUN+SteJAH
         75Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=eQOCKprcnlqygT88HlJfZeaTj6uoVPtheVIQF6uhGZo=;
        b=zr+Mk4krjIDNUM6o5GI6HrkNeq624rxUXurfzrHaYLBc77V4/NKpeZ6FNR+M4dm72v
         0lWKWt1j+1ImytOkiCfd7QHeIrBel4s7kHPhNkQnJyY5G1bdsk3zAnhh3SCew/uYiwmP
         Gf26i1CnPA+kte7xXn5wZ9k9x/x8OGvYOUgprw09FsDeSLvvIY/uiY62mZEBmPnJ0+oM
         DyxTlwy/oeCZ+Vu1piU3SBPg+AnhRlZMVJXzuWBFCdPZP9YX/z4JnqJRBKW7CPB6FHFf
         umJXi7DUf3ogm2n3j8iT4tkSEWGzDQr2KXq/rGY4WIS6S8y0S1rcOt9qR8LfG2r/X6Ze
         XZLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K5W6BNOE;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=MHRDOY0N;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m50si346871qtm.179.2019.03.22.15.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 15:49:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=K5W6BNOE;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=MHRDOY0N;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x2MMhosI013126;
	Fri, 22 Mar 2019 15:49:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=eQOCKprcnlqygT88HlJfZeaTj6uoVPtheVIQF6uhGZo=;
 b=K5W6BNOEALBnpbYoB60YVGSYrviw1mgN0v/x5nIaZ30tmg4pfv7lo3qCGKfPuNZKLzM2
 31UkK9V6wbGHiOhdsgJDraTVhNaIlVbqkIzYvc6vKFXprMQNyetEqzs0iMZe8/JZK+aN
 5slPSMyWPbduy9/aZKbedDZEK+EbcAD97ug= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2rd6kj8ft6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 22 Mar 2019 15:49:33 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 15:49:31 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 15:49:31 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 22 Mar 2019 15:49:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eQOCKprcnlqygT88HlJfZeaTj6uoVPtheVIQF6uhGZo=;
 b=MHRDOY0Ngmy2TRg4pJGLj2/9TfSu4HkszqwwL/pV305OLtEI8BgH42csw32T1hG4Ly8JWJgt4d0zsnDsJs54dLCWNluzcaFN/fQNQA3KiR/a8OGS+zZ5D7IP/XiQhm43FAGJid6LxY5iIH0FCTIDeY01DuhlWqKy7vLxFX0ZkKw=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB3153.namprd15.prod.outlook.com (20.179.72.88) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Fri, 22 Mar 2019 22:49:28 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a%4]) with mapi id 15.20.1730.017; Fri, 22 Mar 2019
 22:49:28 +0000
From: Roman Gushchin <guro@fb.com>
To: Chris Down <chris@chrisdown.name>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Tejun Heo
	<tj@kernel.org>,
        Dennis Zhou <dennis@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Topic: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Index: AQHU4MjBAXhBvPMCI0qZ3+WtTr5x4qYXxmuAgAB7AIA=
Date: Fri, 22 Mar 2019 22:49:28 +0000
Message-ID: <20190322224922.GA7729@tower.DHCP.thefacebook.com>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322222907.GA17496@tower.DHCP.thefacebook.com>
In-Reply-To: <20190322222907.GA17496@tower.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0021.namprd14.prod.outlook.com
 (2603:10b6:300:ae::31) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:41f8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8f237f79-b4ed-4967-2367-08d6af18a3fa
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BN8PR15MB3153;
x-ms-traffictypediagnostic: BN8PR15MB3153:
x-microsoft-antispam-prvs: <BN8PR15MB3153CD534EA2C14CD65CDBCFBE430@BN8PR15MB3153.namprd15.prod.outlook.com>
x-forefront-prvs: 09840A4839
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(366004)(346002)(136003)(376002)(189003)(199004)(476003)(6486002)(256004)(186003)(76176011)(52116002)(486006)(6506007)(4326008)(81156014)(71200400001)(478600001)(386003)(105586002)(54906003)(102836004)(11346002)(33656002)(6916009)(8676002)(14454004)(99286004)(7736002)(305945005)(446003)(25786009)(1076003)(106356001)(71190400001)(8936002)(53936002)(229853002)(81166006)(68736007)(316002)(6512007)(46003)(9686003)(6436002)(97736004)(2906002)(6246003)(6116002)(14444005)(86362001)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB3153;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: H0r83NdEsEExzVMLwJT6cs/DTHUNrzvw9l66QU71KmrZZEJhK2HaTbHF0IUYbAifngkOWkafRZ+EuoxyUp3S0Mw0OHiCZkSLbIDT4Iupqb/ReyqB+5cPe/fXcAJ+JzCyZiRbmDX3865+3CVdrpA5cYIa5RF0TTmMZ/u5zccZe7e2rtqpubcKvb2VlNgaiFid1tsdt11vH8m6aMZkVq7ZZJyT6uIx3WKBDAH7LllTWKbwhZevf6h1GGQo1QxaRiyH91bQUjmsqEXwmRkLngu50ASgyae7Z0JdA7COflF5qkReiG1rKOQgd81f+u1bZrWxMaq1Uv3ZdVT/5+prSv8fvDcNrCtyzDHFtlPxZHdAie3BdNhef9WJRecy/Fe5fewBIaoHpBZJDnTmm34JLal1LJ3UGdUd48ddWVKBS0OUMmU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <138A374FD0ADE743A805FFC790F7E616@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 8f237f79-b4ed-4967-2367-08d6af18a3fa
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Mar 2019 22:49:28.7240
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB3153
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:29:10PM -0700, Roman Gushchin wrote:
> On Fri, Mar 22, 2019 at 04:03:07PM +0000, Chris Down wrote:
> > This patch is an incremental improvement on the existing
> > memory.{low,min} relative reclaim work to base its scan pressure
> > calculations on how much protection is available compared to the curren=
t
> > usage, rather than how much the current usage is over some protection
> > threshold.
> >=20
> > Previously the way that memory.low protection works is that if you are
> > 50% over a certain baseline, you get 50% of your normal scan pressure.
> > This is certainly better than the previous cliff-edge behaviour, but it
> > can be improved even further by always considering memory under the
> > currently enforced protection threshold to be out of bounds. This means
> > that we can set relatively low memory.low thresholds for variable or
> > bursty workloads while still getting a reasonable level of protection,
> > whereas with the previous version we may still trivially hit the 100%
> > clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
> > one is more concretely based on the currently enforced protection
> > threshold, which is likely easier to reason about.
> >=20
> > There is also a subtle issue with the way that proportional reclaim
> > worked previously -- it promotes having no memory.low, since it makes
> > pressure higher during low reclaim. This happens because we base our
> > scan pressure modulation on how far memory.current is between memory.mi=
n
> > and memory.low, but if memory.low is unset, we only use the overage
> > method. In most cromulent configurations, this then means that we end u=
p
> > with *more* pressure than with no memory.low at all when we're in low
> > reclaim, which is not really very usable or expected.
> >=20
> > With this patch, memory.low and memory.min affect reclaim pressure in a
> > more understandable and composable way. For example, from a user
> > standpoint, "protected" memory now remains untouchable from a reclaim
> > aggression standpoint, and users can also have more confidence that
> > bursty workloads will still receive some amount of guaranteed
> > protection.
> >=20
> > Signed-off-by: Chris Down <chris@chrisdown.name>
> > Reviewed-by: Roman Gushchin <guro@fb.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Roman Gushchin <guro@fb.com>
> > Cc: Dennis Zhou <dennis@kernel.org>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: cgroups@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: kernel-team@fb.com
> > ---
> >  include/linux/memcontrol.h | 25 ++++++++--------
> >  mm/vmscan.c                | 61 +++++++++++++-------------------------
> >  2 files changed, 32 insertions(+), 54 deletions(-)
> >=20
> > No functional changes, just rebased.
> >=20
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index b226c4bafc93..799de23edfb7 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -333,17 +333,17 @@ static inline bool mem_cgroup_disabled(void)
> >  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
> >  }
> > =20
> > -static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
> > -					 unsigned long *min, unsigned long *low)
> > +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *m=
emcg,
> > +						  bool in_low_reclaim)
> >  {
> > -	if (mem_cgroup_disabled()) {
> > -		*min =3D 0;
> > -		*low =3D 0;
> > -		return;
> > -	}
> > +	if (mem_cgroup_disabled())
> > +		return 0;
> > +
> > +	if (in_low_reclaim)
> > +		return READ_ONCE(memcg->memory.emin);
> > =20
> > -	*min =3D READ_ONCE(memcg->memory.emin);
> > -	*low =3D READ_ONCE(memcg->memory.elow);
> > +	return max(READ_ONCE(memcg->memory.emin),
> > +		   READ_ONCE(memcg->memory.elow));
> >  }
> > =20
> >  enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *roo=
t,
> > @@ -845,11 +845,10 @@ static inline void memcg_memory_event_mm(struct m=
m_struct *mm,
> >  {
> >  }
> > =20
> > -static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
> > -					 unsigned long *min, unsigned long *low)
> > +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *m=
emcg,
> > +						  bool in_low_reclaim)
> >  {
> > -	*min =3D 0;
> > -	*low =3D 0;
> > +	return 0;
> >  }
> > =20
> >  static inline enum mem_cgroup_protection mem_cgroup_protected(
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f6b9b45f731d..d5daa224364d 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2374,12 +2374,13 @@ static void get_scan_count(struct lruvec *lruve=
c, struct mem_cgroup *memcg,
> >  		int file =3D is_file_lru(lru);
> >  		unsigned long lruvec_size;
> >  		unsigned long scan;
> > -		unsigned long min, low;
> > +		unsigned long protection;
> > =20
> >  		lruvec_size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> > -		mem_cgroup_protection(memcg, &min, &low);
> > +		protection =3D mem_cgroup_protection(memcg,
> > +						   sc->memcg_low_reclaim);
> > =20
> > -		if (min || low) {
> > +		if (protection) {
> >  			/*
> >  			 * Scale a cgroup's reclaim pressure by proportioning
> >  			 * its current usage to its memory.low or memory.min
> > @@ -2392,13 +2393,10 @@ static void get_scan_count(struct lruvec *lruve=
c, struct mem_cgroup *memcg,
> >  			 * setting extremely liberal protection thresholds. It
> >  			 * also means we simply get no protection at all if we
> >  			 * set it too low, which is not ideal.
> > -			 */
> > -			unsigned long cgroup_size =3D mem_cgroup_size(memcg);
> > -
> > -			/*
> > -			 * If there is any protection in place, we adjust scan
> > -			 * pressure in proportion to how much a group's current
> > -			 * usage exceeds that, in percent.
> > +			 *
> > +			 * If there is any protection in place, we reduce scan
> > +			 * pressure by how much of the total memory used is
> > +			 * within protection thresholds.
> >  			 *
> >  			 * There is one special case: in the first reclaim pass,
> >  			 * we skip over all groups that are within their low
> > @@ -2408,43 +2406,24 @@ static void get_scan_count(struct lruvec *lruve=
c, struct mem_cgroup *memcg,
> >  			 * ideally want to honor how well-behaved groups are in
> >  			 * that case instead of simply punishing them all
> >  			 * equally. As such, we reclaim them based on how much
> > -			 * of their best-effort protection they are using. Usage
> > -			 * below memory.min is excluded from consideration when
> > -			 * calculating utilisation, as it isn't ever
> > -			 * reclaimable, so it might as well not exist for our
> > -			 * purposes.
> > +			 * memory they are using, reducing the scan pressure
> > +			 * again by how much of the total memory used is under
> > +			 * hard protection.
> >  			 */
> > -			if (sc->memcg_low_reclaim && low > min) {
> > -				/*
> > -				 * Reclaim according to utilisation between min
> > -				 * and low
> > -				 */
> > -				scan =3D lruvec_size * (cgroup_size - min) /
> > -					(low - min);
> > -			} else {
> > -				/* Reclaim according to protection overage */
> > -				scan =3D lruvec_size * cgroup_size /
> > -					max(min, low) - lruvec_size;
>=20
> I've noticed that the old version is just wrong: if cgroup_size is way sm=
aller
> than max(min, low), scan will be set to -lruvec_size.
> Given that it's unsigned long, we'll end up with scanning the whole list
> (due to clamp() below).

Just to clarify: in most cases it works fine because we skip cgroups with
cgroup_size < max(min, low). So we just don't call the code above.

However, we can race with the emin/elow update and end up with negative sca=
n,
especially if cgroup_size is about the effective protection size

The new version looks much more secure.

Thanks!

