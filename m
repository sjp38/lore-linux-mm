Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 151CCC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB82C21874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:04:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="LZ6hfttc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB82C21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F2F46B0003; Thu,  8 Aug 2019 08:04:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A4486B0006; Thu,  8 Aug 2019 08:04:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 245C56B0007; Thu,  8 Aug 2019 08:04:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6FBE6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 08:04:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15so58114392edu.19
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 05:04:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Z6JHyuoFRG4Z1jLgBh1JdhtifZdosmYbWLGiJHq3JBM=;
        b=flFowDM4CasV5Xa0blX5ogRWDFT/5ZNQAdpOtQvw8G+RL2xUCUenOGtWozktAzN43S
         6LT/cEJVb9JBCuXLQ6CtMg4tf51FjcS91Z6hd6MCtov7FvGarTt1xFTxbBSUNj6McUlI
         FXcQOd54d3IUo81Iv3Z1UTzb1yW+DF9Y8WUE6lFeEYome08GtFcgcSi9jXQzh36DRq6L
         dq1Qbc8KCwcHYytJX8kSx8TYZBaYCNN0Xf4z2MP36gXzToc8l5toJ5MI9NI91d8gZYZv
         a2yJ5peEzCncvXMa4uOXfsBryvjd03L/Lv6Hjlt+tM4q/B+4xalpiUteoQSFgWRMBvZu
         KxWQ==
X-Gm-Message-State: APjAAAXgiazqxr3+Yilv+hoXUVdTCL2VfTVWkwJCfluMlSZ3xkHQ1Uf0
	iUQrti9xKOGNCKnV9k46ZqCrY1RlIqTqjkudf+E1bHN1W+ztD8vzaxfBXvqKFTHdhjrMrDs9ImC
	nfmzuqsbAwTSs3GyzQhndm1g6g4wPN1XOa7YTdERKyZQRClarYCotAMoywX71A54TEA==
X-Received: by 2002:a17:906:d1d0:: with SMTP id bs16mr13271854ejb.286.1565265850241;
        Thu, 08 Aug 2019 05:04:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBJ8CYbNeD+1oKOVky/f7X11gQQIUwcXFkSSaY+8bjz4iQTwC9m85ED9mnZwbSjoqqnDBI
X-Received: by 2002:a17:906:d1d0:: with SMTP id bs16mr13271775ejb.286.1565265849264;
        Thu, 08 Aug 2019 05:04:09 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565265849; cv=pass;
        d=google.com; s=arc-20160816;
        b=LteyqpIbtI0rzYqZh/U20vK3cNHJcvtf/u3KUIZaewm5NQOCcmo2VpQ7sS7Q9h6lw8
         76NVTCc9CK7qJXKqhjfHCYSM3WHTG9j9KH7J4OpqSZI3KGsnuPivwszbeQMk3MwQWgkc
         PuElLto2dcZ/i2mAJgI6xSV3WNqP8hTDaM3R2z2CeIHSKrT28UFJ8zMEGNgnkPeVC7Z4
         slyM40i8R5mZE5vWIttz+9xpOUmih6pIG3sedQ27Y655/W80BotEV44Gy52VadnRbxLH
         Ew733jicuDl2al4pudjxp4APezynH0irwilJZ/cgrtCMHmLgmCQtu1IWVdswhAEDlsXf
         Ue/A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Z6JHyuoFRG4Z1jLgBh1JdhtifZdosmYbWLGiJHq3JBM=;
        b=VOCSgDtYo5gf+Pt0qfsAv9EYdQHNO588QWhiJB+HV2plSlYWVxxU+foU8gxWnWwkuK
         /uWxk6A+50KQ+2czcOZhlzoKPH4uWhJ8UFEFesILRdLQm3hdaCgw9wNOjwzou71t5q6n
         j3xUxtV3W+4DHeYHYAjx0rMgyjXvCGTZZN2I8fYEzppDkeN7jQpoqiuTv8fwGqE3gMLo
         G6Sivqh9n8MRXyhxJdiTHNZixzXdXbgAEoW5fjg/c3pc0D5xtv4YhMpQmFEU/5OhLN2I
         cBjeomGmqbJd3LDpMQoJvdHTWB2nNCHePffEMfnxW1qg4SbdfVmqBDhaL39M1MIiiOvn
         1xfA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=LZ6hfttc;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20074.outbound.protection.outlook.com. [40.107.2.74])
        by mx.google.com with ESMTPS id 13si1084081eds.115.2019.08.08.05.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 05:04:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.74 as permitted sender) client-ip=40.107.2.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=LZ6hfttc;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=QTZnenFcp8PjNtDs2nfArifIZUoGReHzdOAxa8rrsffpM7OnG7VqgizvOMl2pqvdawgwAlZ7N4lkC9itDxYGcEGQIu+clBIIpmO/iI2CUzwzw9AcQS+xwlgnyv/TgDhJu/jf4SXcd4VIel27SNn30+3ZgBl/a+A81BzvLz5gcX3ABygksouOJ8FYpvJjlAZR3ZN2CiDq8+EepsVCTNA4U/f+BMIxJ0EDdtm/Ca7boCKlmO+RPG5PEMuYaN49T7NtQgFb4161+0jIeasOS0UolKZ2CFOjb+S24ZTmUdhlWbkqM28S/+iwq3xGxMZxudBVoQ7xBarZRlpaxYs+U0HktA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Z6JHyuoFRG4Z1jLgBh1JdhtifZdosmYbWLGiJHq3JBM=;
 b=RSf0QmEIFFefChcUL7kmtW1T1J298InTV7XWgXpWEyzAtpLEM+27r4HRp4kksOZjO1yi5G6ZrUnseO7gVk0diat5JulnCYgxjE6Xf4V3H3+RY2U8x4mebPYkY26+9+DEHGx81OCSGadqArAYQx8+3lnZi5L7h+HNy+5iN6qT0DLHwOpcGCLSH6CqCVMKOQL5wKGprkt11rR+mrHo0je4H5uN/tgqdLBGfEenSsXRtBJtCk6jUtZnEMWbAfnADcah8Ext6WoraP7s5bc9yZ68DVPPpaIGxgLnYHXGGIwCdfobs67RcIhMQahFK1YmAnZXLT2Hi97ZEvh+lfkjtYB+Vg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Z6JHyuoFRG4Z1jLgBh1JdhtifZdosmYbWLGiJHq3JBM=;
 b=LZ6hfttcOwTsBEVbf7Aufg5uQMzLBOl9AUnk4SFt96hre8Ci9XJF50Ob/ieIj2zcbmUElDbYO9dmisercdH0fYIy6dKzAgfc7T5kp/W7jxwu6vONKXfiI4wO4HyG3htpQV14AJ0zWOqPMDcmU0cO5Lhl+tsBMcjxLIX5cwF+HcQ=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5245.eurprd05.prod.outlook.com (20.178.10.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.15; Thu, 8 Aug 2019 12:04:07 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.022; Thu, 8 Aug 2019
 12:04:07 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Michal Hocko <mhocko@suse.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Andrea Arcangeli
	<aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Thread-Topic: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Thread-Index: AQHVTVSfVNc5Iz/dOkyoKdT7iQpJS6bw6QyAgAA/BwA=
Date: Thu, 8 Aug 2019 12:04:07 +0000
Message-ID: <20190808120402.GA1975@mellanox.com>
References: <20190807191627.GA3008@ziepe.ca>
 <20190808081827.GB18351@dhcp22.suse.cz>
In-Reply-To: <20190808081827.GB18351@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0033.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::46) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8ed16110-3589-4d7b-0b2a-08d71bf883eb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5245;
x-ms-traffictypediagnostic: VI1PR05MB5245:
x-microsoft-antispam-prvs:
 <VI1PR05MB52456A4870BCCCAA2D30D0ADCFD70@VI1PR05MB5245.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 012349AD1C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(39860400002)(396003)(366004)(376002)(346002)(189003)(199004)(8676002)(36756003)(446003)(8936002)(11346002)(6506007)(386003)(53936002)(76176011)(14454004)(478600001)(66066001)(26005)(186003)(81156014)(86362001)(4326008)(486006)(6512007)(81166006)(2616005)(6486002)(476003)(229853002)(6246003)(6916009)(102836004)(6436002)(316002)(54906003)(66476007)(66946007)(71200400001)(33656002)(71190400001)(66556008)(66446008)(64756008)(305945005)(99286004)(5660300002)(256004)(7736002)(52116002)(3846002)(6116002)(2906002)(25786009)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5245;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 KZTcSVtcYGW6p7NBSRWNWxLKEzdrcCBn7ObM9yVnb+WSDGDV/DWPsQ933R8uCybq5L/v3nEZVvw1BUFYsxmGlD1dPFO04/l+rjvZLCu3pYVxFo5RHrqzrlmbj32AJx15UsY+jHZfcQKFbp1VeQeVhtyWtk8j/I9j7noh5UXtoKH5xPKX9bMX5d4snIJwOdim+z1ACbTLMFinwk/k4US4xWwAUREkKq5ZDwb3xXsgJJQU8EkUWZ2fJq1bjfInmSLLzGpSFQthEM3juidWXBTqcPv2M347zgJTOEzQgHcRF5k9j2CqQkWYjAyhYzKkO/0QMn9/i8w75L6/MtzLxnmzEKJuTnRAOm98OHxKCexOq/9fM/czHM4vgwNs1lxCQVaBoP6cNNy9sYeexFRy1SohTxMcyRg7fTJmXR1Eo/CDm6U=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <7D014773B682B5419ED6854A7ADDBC70@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8ed16110-3589-4d7b-0b2a-08d71bf883eb
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Aug 2019 12:04:07.7801
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5245
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:18:27AM +0200, Michal Hocko wrote:
> On Wed 07-08-19 19:16:32, Jason Gunthorpe wrote:
> > Many users of the mmu_notifier invalidate_range callbacks maintain
> > locking/counters/etc on a paired basis and have long expected that
> > invalidate_range start/end are always paired.
> >=20
> > The recent change to add non-blocking notifiers breaks this assumption
> > when multiple notifiers are present in the list as an EAGAIN return fro=
m a
> > later notifier causes all earlier notifiers to get their
> > invalidate_range_end() skipped.
> >=20
> > During the development of non-blocking each user was audited to be sure
> > they can skip their invalidate_range_end() if their start returns -EAGA=
IN,
> > so the only place that has a problem is when there are multiple
> > subscriptions.
> >=20
> > Due to the RCU locking we can't reliably generate a subset of the linke=
d
> > list representing the notifiers already called, and generate an
> > invalidate_range_end() pairing.
> >=20
> > Rather than design an elaborate fix, for now, just block non-blocking
> > requests early on if there are multiple subscriptions.
>=20
> Which means that the oom path cannot really release any memory for
> ranges covered by these notifiers which is really unfortunate because
> that might cover a lot of memory. Especially when the particular range
> might not be tracked at all, right?

Yes, it is a very big hammer to avoid a bug where the locking schemes
get corrupted and the impacted drivers deadlock.

If you really don't like it then we have to push ahead on either an
rcu-safe undo algorithm or some locking thing. I've been looking at
the locking thing, so we can wait a bit more and see.=20

At least it doesn't seem urgent right now as nobody is reporting
hitting this bug, but we are moving toward cases where a process will
have 4 notififers (amdgpu kfd, hmm, amd iommu, RDMA ODP), so the
chance is higher

> If a different fix is indeed too elaborate then make sure to let users
> known that there is a restriction in place and dump something useful
> into the kernel log.

The 'simple' alternative I see is to use a rcu safe undo algorithm,
such as sorting the hlist. This is not so much code, but it is tricky
stuff.

Jason

