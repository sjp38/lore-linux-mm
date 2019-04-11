Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC383C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:45:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E66A2184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:45:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="C6aYrfiw";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="YalNxcjw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E66A2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F8E76B026E; Thu, 11 Apr 2019 17:45:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A8986B0271; Thu, 11 Apr 2019 17:45:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 022126B0272; Thu, 11 Apr 2019 17:45:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6A876B026E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:45:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n63so5048374pfb.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:45:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Uycx9w4oxxYGUR9EyzTH5ito/EdyYrW2Wmut8rQPRoo=;
        b=XVdpx3iAAHLpzkGRaPZ7l5yVX4vUl446HthBjLNwhf5tamMYDrwBQlvKHiMSYiUQeA
         v72eoy+NbkuUN9sopzQ2DPytNmf8APGRvP7VU8CKwLJifG2XUCZceVwc2YGl9LgCc5Qh
         Kco9c2kTTEQO25f4Wep2nCCDVhgan4KbuAlmusN409dRlwyXXhghzAUsMrO80HJV7LMK
         md40aEEurN6SeOWFq9HYkclVmtaTEHmEo6QFa+DjQaQpr21v8QVf/uVuvDFctWk6fhSW
         DYuU+dZ2N3CEdTDOLPwtJx7srOTC/xeC5sWHjqcgsxe3prkUKSjtoNMMcEhobAkzgjnM
         vvNw==
X-Gm-Message-State: APjAAAVMOrrhzSNjx0CoSloRzEVY5aABKd4i/1ho40C9nhH/mFyECfJk
	5FNS4kzXM8nRBMx741IJ17ruLCd6I9D5KtYfDDDxXDteyAYK+pZR8diHUhDIU+9W8Itpsbanc5V
	Jb7m+kSPhhXuV8G4wyumO+XJX9FOSUSIKUMq9aM3ma9CmAQ1yf3FKyNPC9H/JwxYn/w==
X-Received: by 2002:a17:902:42:: with SMTP id 60mr14571290pla.79.1555019145931;
        Thu, 11 Apr 2019 14:45:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3f3nHCSOooUWFTXJIO4U8p3nuZk1BcptgoETELDyxJI7bcC2SgNFtO89GH3p9IwBUc4lE
X-Received: by 2002:a17:902:42:: with SMTP id 60mr14571225pla.79.1555019145174;
        Thu, 11 Apr 2019 14:45:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555019145; cv=none;
        d=google.com; s=arc-20160816;
        b=R75u77B84vL2yLd5u4iP+j+7RUwagHg6s+QRbccGmAjBZnL+w8IyPL9sOxekzDBcTI
         hQAnbsNoaBrrrSC+rMRfxO4jUgvUsB3d4Od+IpbrbDSJx3h0Sd4n96DTLNtqHN5dNXge
         f26AvVCCNr1Zj2IaXD8Rc+KMgar+0IoRwSxlw9JjFTYpkpPSI1bmxMIkfaEFHGJO8Sm5
         f+gIA9lANcr2/KTSbb/Dg1Ih7cQP5m7GztIF+Ade2kHGdRgarHvh0AKMC7vR6F3eTm9d
         IzYv4gvDGCYfQkjCf9jRSsEDQkNH9CbxBXJPv6RUnqllpJmBNf6CdXHhnqHuKGaR7XMb
         aUlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Uycx9w4oxxYGUR9EyzTH5ito/EdyYrW2Wmut8rQPRoo=;
        b=eMHw7Ta3G+sAaUSIfdJ83OJZvnF6wXv2XF3D8gaE+V5SjGLVhOhfcKracXf5hkKbwn
         mwQoTcQQY0kF2i+FdkvxUc1KTRu6M//bpgovnTlX+J5+8h+IiZhFYtG2uXHh+enA3y1a
         VEbM7UseQ11iqOcXWlf4JG1KYB1r9Jr12D1S8BBZahuDGF9WHxER3mKEyZ+lPBPk+MaW
         N0qdGmOHgyPkNDIsfphXc8ohjh3IzFK/6xUeohXElVTgiO4jh59Z6RAVgAaR/ZYhKTIi
         5HumO7p8Et7HouoYYCBadmi3X6vOzwDk7h8k9g1wh3FdHEV1Wr2qMH5S+pH4dCetAKBN
         VM1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=C6aYrfiw;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=YalNxcjw;
       spf=pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9004ee2826=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u2si12766831pgc.250.2019.04.11.14.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:45:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=C6aYrfiw;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=YalNxcjw;
       spf=pass (google.com: domain of prvs=9004ee2826=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9004ee2826=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3BLXY59026043;
	Thu, 11 Apr 2019 14:45:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Uycx9w4oxxYGUR9EyzTH5ito/EdyYrW2Wmut8rQPRoo=;
 b=C6aYrfiwjXz+tFHJ6VbBeye6ERPqa+K8lsGWSxldL4zxM/4wFnpU2sOb4rwkg5PTj+xQ
 6NYy+FfAlQGnI17qgn/OBxrjPXZIAIcv68AFlBMAjO9BUwQwyaBGoaNb+AaOR0GhuZZx
 higHQLN/8igJf+JB45KAgHHAx7QXdfX02x4= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2rt88816wn-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 11 Apr 2019 14:45:12 -0700
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-hub04.TheFacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 11 Apr 2019 14:45:06 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 11 Apr 2019 14:45:06 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Uycx9w4oxxYGUR9EyzTH5ito/EdyYrW2Wmut8rQPRoo=;
 b=YalNxcjwAH8q+jgoWxRxXjO9xHptzmENNqdiivZqMSSeD+M+P0X9jn3EjaJnsog+2/VJbvwCl+LpAnVswcc4LIls+3kfHPaqZCeBVJDOLru8Tw3dJmVcud8iGEFxnYOebOkfMbeTM1qbz2Oyv+eZBTaHPY7UBHa5RGSLjtn/FA0=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3238.namprd15.prod.outlook.com (20.179.57.29) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.16; Thu, 11 Apr 2019 21:45:03 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.016; Thu, 11 Apr 2019
 21:45:03 +0000
From: Roman Gushchin <guro@fb.com>
To: Suren Baghdasaryan <surenb@google.com>
CC: Matthew Wilcox <willy@infradead.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "mhocko@suse.com" <mhocko@suse.com>,
        "David
 Rientjes" <rientjes@google.com>,
        "yuzhoujian@didichuxing.com"
	<yuzhoujian@didichuxing.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tetsuo Handa
	<penguin-kernel@i-love.sakura.ne.jp>,
        "ebiederm@xmission.com"
	<ebiederm@xmission.com>,
        Shakeel Butt <shakeelb@google.com>,
        "Christian
 Brauner" <christian@brauner.io>,
        Minchan Kim <minchan@kernel.org>, Tim Murray
	<timmurray@google.com>,
        Daniel Colascione <dancol@google.com>,
        Joel Fernandes
	<joel@joelfernandes.org>, Jann Horn <jannh@google.com>,
        linux-mm
	<linux-mm@kvack.org>,
        "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-team <kernel-team@android.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Thread-Topic: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Thread-Index: AQHU8Agfba8deeGsZ0iHj8xHvEZD6KY3F6+AgAAaygCAAE0VgA==
Date: Thu, 11 Apr 2019 21:45:03 +0000
Message-ID: <20190411214458.GB31565@tower.DHCP.thefacebook.com>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
 <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
In-Reply-To: <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0072.namprd14.prod.outlook.com
 (2603:10b6:300:81::34) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:3965]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e74d29b9-c262-478a-c75b-08d6bec6f43b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3238;
x-ms-traffictypediagnostic: BYAPR15MB3238:
x-microsoft-antispam-prvs: <BYAPR15MB3238A6D79F2AD14C94083F3ABE2F0@BYAPR15MB3238.namprd15.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(39860400002)(366004)(376002)(346002)(199004)(189003)(256004)(25786009)(6916009)(76176011)(53936002)(316002)(8936002)(71200400001)(81156014)(6486002)(7416002)(305945005)(7736002)(99286004)(97736004)(8676002)(4326008)(81166006)(6512007)(102836004)(68736007)(6246003)(14444005)(6116002)(6436002)(54906003)(52116002)(229853002)(33656002)(11346002)(186003)(86362001)(1076003)(53546011)(9686003)(14454004)(476003)(6506007)(105586002)(486006)(386003)(478600001)(106356001)(5660300002)(46003)(93886005)(71190400001)(2906002)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3238;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 77AToC3krpjoZ8GjvAzNHNhSjw+fHUKGGcDHXEKEOj5M0FwMitA0PTNkiV3TanQCAdkR4Kd3Qeg3qXMu+WaxRN9cGrpD2+oqThMEPai64Q1/XTIGyVPGo+LO/Lq+GdkNwN1DWxtxSJW9w57pbYHQe1GWFeaeEOxxeF0OXlz9r9JXjg96PRDf0U/8Ga2Se022K67LOaRnL+zsk2De9l0o+dSuRgH2eQhp2xYioDMdGbF1bHqOf8Kgv4hx3Mk82ilX//Kd6EGvbLM+JRZY6IXZBiMUAWuvDe/qM4uHcjnCGoN5/3oFidZ4pUhMvN9liQfG1LTcQMV8ciLUL2drs3Se+Uu3xX1tz2f46QAyw4hS03o0eIfohZHp1n5YsCePGY3oyKEjEuF5YYtxR1EbB2EpLDlxMf528MOYAA5jjcf9HCg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9898E43111BA1D479F58D887B9230D92@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e74d29b9-c262-478a-c75b-08d6bec6f43b
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 21:45:03.2856
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3238
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

On Thu, Apr 11, 2019 at 10:09:06AM -0700, Suren Baghdasaryan wrote:
> On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrot=
e:
> >
> > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > victim process. The usage of this flag is currently limited to SIGKIL=
L
> > > signal and only to privileged users.
> >
> > What is the downside of doing expedited memory reclaim?  ie why not do =
it
> > every time a process is going to die?

Hello, Suren!

I also like the idea to reap always.

> I think with an implementation that does not use/abuse oom-reaper
> thread this could be done for any kill. As I mentioned oom-reaper is a
> limited resource which has access to memory reserves and should not be
> abused in the way I do in this reference implementation.

In most OOM cases it doesn't matter that much which task to reap,
so I don't think that reusing the oom-reaper thread is bad.
It should be relatively easy to tweak in a way, that it won't
wait for mmap_sem if there are other tasks waiting to be reaped.
Also, the oom code add to the head of the list, and the expedited
killing to the end, or something like this.

The only think, if we're going to reap all tasks, we probably
want to have a per-node oom_reaper thread.

Thanks!

