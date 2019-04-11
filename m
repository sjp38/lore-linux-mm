Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC37CC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:22:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69FA62077C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:22:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="C5Q/Zxjm";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="GaprauWM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69FA62077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 085446B026B; Thu, 11 Apr 2019 17:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 035FF6B026E; Thu, 11 Apr 2019 17:22:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3DE36B0283; Thu, 11 Apr 2019 17:22:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD9606B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:22:26 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id j45so1081154uag.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:22:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=J59ZmlOdTWha1uc+6rXK0NSv6K3t61Wr5VdtTAYniFg=;
        b=q+p7KMoKwdSSzD6VEirhxHvxTAPvDZ/aFdjyCsw6C6gBrfCeni9MuiQ1D+Fa1TYOK1
         T1X/Q136P3ECr+h1lZVPGivMg8FlmaI8Jf/YAnY8qlj5OMr08RrlR4ZUrV9ByP+pZ9iK
         p7WfK3zikKgKDSh4qGxv//LFK9c6Rzon0JABi0l/XC5a34V/JCqt3Igz6Hmpo1u4fEi1
         +oW+CJU2ocDcX9yLe9UpiIVoKk7yJcDWUSxawu11IEPdG+n5Qz9Nkzzb3pcL32xFNYR1
         ffoYXxtss8JGs0l9qF7aGeztzBGJ8PYBvqgsRM5QKcLHH3HUlgjec3Y8fl1z0S9Eb5Dr
         rjlQ==
X-Gm-Message-State: APjAAAVr4Hm4UavJH34GkonHdik1WDDLPY0Q2E+T4W6VnCSt3QP1eH8x
	2QKnY5cspApXO+PDDUURdPP4ia0eeaxoKYX3zX+tUv1Wi51hL1x+57PqQp3SwI8z318UdA/9dwc
	W0sziE1xYdtEYen4X7Gxi3qazz4SP2SMfbHMN0zyYEi/aOi0/UOfTheR/zJywEywU9g==
X-Received: by 2002:a67:e9c8:: with SMTP id q8mr27259605vso.120.1555017746377;
        Thu, 11 Apr 2019 14:22:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/ZKOx3cf8SoWh4lMpelKYESWsEOpJndE6k/CYVDwuvIsjmvRss87jdCoyK3nEq8KMaHpH
X-Received: by 2002:a67:e9c8:: with SMTP id q8mr27259586vso.120.1555017745578;
        Thu, 11 Apr 2019 14:22:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555017745; cv=none;
        d=google.com; s=arc-20160816;
        b=bqsyjHLFXeAfYlZpCExGJZgkVGHmx05xEDEeoZdeQ/nBziK/1CzTAhN4TZFbNkaEbX
         UapT3iiRV7eBQTDFFEdA8TGQividNjsdZRP7cu+KVD0adE6dmcyG7u0rCY1EMq8h4+9C
         rKwDKv4mXG98zxIThofvtDv+zBUqTGfhMRmK/MG6xLUP5+ErhRNWy0d6VnpMeKX20w++
         Qg3DLfJpJW3RTd25gXRFSOpIeYhb6Z4uTSRMw702OXmqj7IW8CmOxcw0QK6EnJxMPT6n
         H7dtbrZGR3klGcbHTHgS3vwHgQTHw1Gtd0g79EqeAy/6ZEDolKxDNuJmZ49mTNFY3J2F
         i9Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=J59ZmlOdTWha1uc+6rXK0NSv6K3t61Wr5VdtTAYniFg=;
        b=kgG11twFzslIR5rfT6qN0eYXjW5OGUIdpveMazofDqbKX9Vsr+y1fpi+brXpHDbFgB
         p1o5TPBEs8ZmjBurYl26xJgQqdKD9OySB+E+m5W56/wvZoaWovQZdK9hhOextlSZl0h9
         hsMflT044Vp1wX9W7NpjWeClj1ianm7ajcoTjUBPDjOU3ugP5WQpzr8fQdxUnmIaYiKT
         sX9J17eD4x4IVUx/ceci1frvPviEM6JSrZPTRTHKe4pQw96SBtxQxCkNf1dj5Bfe9O4V
         qq/hpirKASjDzMhBNLCwhsx3f0F6tYHVx9YxIKhAXNVnIB1E0bruZE5PWXNxHhKH/Pwo
         EB+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="C5Q/Zxjm";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GaprauWM;
       spf=pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9004ee2826=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z25si7816020vsj.278.2019.04.11.14.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:22:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="C5Q/Zxjm";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GaprauWM;
       spf=pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9004ee2826=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3BLCoNZ013831;
	Thu, 11 Apr 2019 14:21:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=J59ZmlOdTWha1uc+6rXK0NSv6K3t61Wr5VdtTAYniFg=;
 b=C5Q/ZxjmL8Qsp02unNiG36lJkdXCpOGra3lM0wBog4IyNkgvVpJlkIcrBik23nPrtaqN
 hh7WIW9JLH1s8suulT/5EPEEwP5fStblJIW9vgKhZuCXf0ayyK7DDecySE5RLF5RVmIC
 r1mBWGls6Cm891o8o5+fKmxhfd9XkqYDGmg= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rt5wmhn9p-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 11 Apr 2019 14:21:40 -0700
Received: from prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 11 Apr 2019 14:21:38 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 11 Apr 2019 14:21:38 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 11 Apr 2019 14:21:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J59ZmlOdTWha1uc+6rXK0NSv6K3t61Wr5VdtTAYniFg=;
 b=GaprauWMbNYde7rr4mieyFI2H44/tHhhsUtQhFZm8f9kwTkWDYqYr5LwsWoCA9rYmienACKXhi+A4DlGIXCMli81eA0joVUq3KYD2gwWt1LYz0hA+zwC2ijyAS5A9dOMLqswmUzWqYDceQyxtcfIQHYg4OWgwroJ23egA/6DJeY=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2229.namprd15.prod.outlook.com (52.135.196.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.16; Thu, 11 Apr 2019 21:21:36 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.016; Thu, 11 Apr 2019
 21:21:36 +0000
From: Roman Gushchin <guro@fb.com>
To: Waiman Long <longman@redhat.com>
CC: Chris Down <chris@chrisdown.name>, Tejun Heo <tj@kernel.org>,
        Li Zefan
	<lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
        Jonathan Corbet
	<corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-doc@vger.kernel.org"
	<linux-doc@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Thread-Topic: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Thread-Index: AQHU79GY2Ag2UCG9SEWEuTyzVdk7J6Y1688AgAEYggCAAHUdAA==
Date: Thu, 11 Apr 2019 21:21:35 +0000
Message-ID: <20190411212129.GA31565@tower.DHCP.thefacebook.com>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410213824.GA13638@chrisdown.name>
 <d8d6f82f-a950-8eea-16ce-9189e78f37fd@redhat.com>
In-Reply-To: <d8d6f82f-a950-8eea-16ce-9189e78f37fd@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO1PR15CA0087.namprd15.prod.outlook.com (10.175.176.159) To
 BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:3965]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2be1fb45-fde0-4020-abfc-08d6bec3ad5b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2229;
x-ms-traffictypediagnostic: BYAPR15MB2229:
x-microsoft-antispam-prvs: <BYAPR15MB2229268A7F7819066ABC4F66BE2F0@BYAPR15MB2229.namprd15.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(366004)(376002)(39860400002)(199004)(189003)(86362001)(46003)(256004)(446003)(476003)(316002)(14444005)(6116002)(99286004)(76176011)(102836004)(71190400001)(478600001)(6506007)(486006)(386003)(71200400001)(2906002)(11346002)(54906003)(52116002)(14454004)(68736007)(25786009)(4326008)(81166006)(81156014)(5660300002)(186003)(305945005)(53546011)(1076003)(7736002)(105586002)(6916009)(106356001)(8676002)(97736004)(33656002)(8936002)(6246003)(53936002)(9686003)(7416002)(6486002)(229853002)(6512007)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2229;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ffp2amr/FaUuv3a0Ob/CkfXBeR3AKJxoNVLNi3Y9q8lDcBGDwsIbsSCG6ZNOI1/wMXxEWylfaWvLenZUywRJb7C4rW4DD9Z5xVbHaZfuWYKkwWgvP7jqLU6pO+DLLiUn3/kntaKTSAcmxkNbbbJ4bw74MYKzZSUSTNGQkU/YHTIfTWZDwzN+XRZn3+KGWudZMaEO+GDax5KZO6BYgX2LKB3XAktiPBdo2/xb+bszr3IaflR64GZ/4JDgsJvcf+fM1D4XUyBg3fZtn5xOsPrXxPZjoTWsyzsd3o2mK1yS/XIWwXMU7W0hWZWDl3tfLm2pQPOrwQuwucqMXep719GuMvDiHTe3ym9axF8/bVZ+wscTFdJiOxlksJPgMfx9UJUP2txsCjSabDMuOTH7x13QPSZfC+611/TWUFC3CxldhMo=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <1E5B2719146AB44CB3FB15816522B144@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2be1fb45-fde0-4020-abfc-08d6bec3ad5b
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 21:21:35.9182
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2229
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-11_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:22:22AM -0400, Waiman Long wrote:
> On 04/10/2019 05:38 PM, Chris Down wrote:
> > Hi Waiman,
> >
> > Waiman Long writes:
> >> The current control mechanism for memory cgroup v2 lumps all the memor=
y
> >> together irrespective of the type of memory objects. However, there
> >> are cases where users may have more concern about one type of memory
> >> usage than the others.
> >
> > I have concerns about this implementation, and the overall idea in
> > general. We had per-class memory limiting in the cgroup v1 API, and it
> > ended up really poorly, and resulted in a situation where it's really
> > hard to compose a usable system out of it any more.
> >
> > A major part of the restructure in cgroup v2 has been to simplify
> > things so that it's more easy to understand for service owners and
> > sysadmins. This was intentional, because otherwise the system overall
> > is hard to make into something that does what users *really* want, and
> > users end up with a lot of confusion, misconfiguration, and generally
> > an inability to produce a coherent system, because we've made things
> > too hard to piece together.
> >
> > In general, for purposes of resource control, I'm not convinced that
> > it makes sense to limit only one kind of memory based on prior
> > experience with v1. Can you give a production use case where this
> > would be a clear benefit, traded off against the increase in
> > complexity to the API?
> >
>=20
> As I said in my previous email on this thread, the customer considered
> pages cache as common goods not fully representing the "real" memory
> footprint used by an application.=A0 Depending on actual mix of
> applications running on a system, there are certainly cases where their
> view is correct. In fact, what the customer is asking for is not even
> provided by the v1 API even with that many classes of memory that you
> can choose from.

Hello Waiman!

If I understand the case correctly, the customer wants to get signaled
when anon memory consumption will reach a certain point, right?

I doubt that the idea is to keep only the certain amount of anon memory
resident and swap out everything else. So, probably, the reaction will
be to kill the application.

If so, do we really need a control?
Maybe polling memory.stats::anon will be enough?

If not, I can imagine some sort of threshold notification mechanism
on top of memory.stats. Similar to what is build on top of psi.

Tracking the size of anon memory is definitely useful for spotting
userspace leaks and spkies, so an ability to set up thresholds and get
events sounds appealing to me.

Thanks!

Roman

