Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CB9DC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FBD9206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WIK4AJ3R";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="huJe6imf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FBD9206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11876B0010; Thu,  4 Apr 2019 12:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC13B6B0266; Thu,  4 Apr 2019 12:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A62136B026B; Thu,  4 Apr 2019 12:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF586B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:53:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c40so1784125eda.10
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:53:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=S63qVG4Ums0IRdEubLKn7lMmhUCcy/JMfjD3BkPbknI=;
        b=PzWnPGV6qjO1EWoX6rUw2mdzxa5elBqQyrci+nUpIsiRTDCVqqMDNQJ9H9i9o10a3v
         h+ZZpiZGMhzMfuUXj7b3z6EP3zxZmQIvkROs5gPgoDctafkLRzO4Bw1JCvK8XwF70CfI
         6ADEo6g82RkUrDApTHAoLH0kJnD75ZSgb8YKRznDuW/r7iKYni1pdqOYC/gEweBD0hoa
         48XjVGVRMojZxLu+2Vkbl68ngg9nKtvI59qfnPoUTe+fPFPHPcSqooonyYR8gVOfTpwn
         +T+uwmZi7oo7lispXlG+h4f/e1IvlNCX0sWaXF0h+ALuYlbyuzi4+iHLb802nguvDBnc
         SvaQ==
X-Gm-Message-State: APjAAAUAKKkjvPhR0xzz9t6FMtr8FC1VL/SQmEvmV5kKgMglJE0imTmt
	j4ML4axLD1hdy9LODSdmI2M1AnAgU18nP3tP9jwmq5rfO56mEBfWfgr4I9XcLbTDK2WLzdWLveT
	GddMtNtFmWJGCjrcQBM06b+LilZy/drjT50KeOxx8TeWMYQhjTL2uMEqcX6phOAKEsA==
X-Received: by 2002:a17:906:4f19:: with SMTP id t25mr4272144eju.165.1554396821814;
        Thu, 04 Apr 2019 09:53:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDHwE6AuW81OnAXb1uQ36aR/X9A/LM5B6ikjEK+gg8zkv5HPoQ+JZvsUo61qNts3m5RkjW
X-Received: by 2002:a17:906:4f19:: with SMTP id t25mr4272084eju.165.1554396820613;
        Thu, 04 Apr 2019 09:53:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396820; cv=none;
        d=google.com; s=arc-20160816;
        b=BMz8mPMZyuJ6KnqNxZsqxUphCrRRQxeFEi2Kwh1EeQb8sLEHSDs2D3DeQh5pR7p+aj
         LpOU/G0tZkkC15u7lcJYhZs9v7MHIRwDcz0KCTVO6vyzpeDJiIrHYZQ0T8CfQWcnhe0h
         rVCQ4sggOtuH0jaO4eERt02k5sVF9IsT95ce+P/j+1EIuEbwql9AqOI0lkdEvxJ1KK3X
         +Gb0PFGbVqUELObrXY7JCA76quDel9z2iO7Da+ZZRDQVZuSgqK441BQDNPr+cW1J1hhM
         bUUQlXX6J6zNBadYWSmdEy3v6llsdceUjkkSfT1TmgsZdrIkT/rqxZryXGRhQ/I6cNqs
         N6Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=S63qVG4Ums0IRdEubLKn7lMmhUCcy/JMfjD3BkPbknI=;
        b=hQ9x1jME35oqc10pgL3C98k8WhkL9FHb0ksrIQ0lkNviCr1zBVYNhLoQK1Edb2bYIL
         jaUDt31Pna1ULEg3x30atqAKG5kMj/pyzXoni3JaoYkYGV3OhV+tANSvh5J0CkmTC8fF
         wKqGf1rI/D1E5l3K6uHUDEQ+M6E4F5WiQSlewOJiVQ2CmqTLEl4FdJq0DfpsGbbVUYny
         MZkXVhHkaV/vEo0h65VaIOv2HBqVo63FITFIYOl3DarbwDys74ussjnuZ7ZrV4TagEGH
         TKuafc6xT+P+XhuHLt+beWksDyO1KImgoCcAtIR6Ta4U1Pc5zy7/qozEh9HTt5X/UHG8
         pQ9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WIK4AJ3R;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=huJe6imf;
       spf=pass (google.com: domain of prvs=9997d050a3=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=9997d050a3=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v6si7039038ejw.330.2019.04.04.09.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:53:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9997d050a3=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WIK4AJ3R;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=huJe6imf;
       spf=pass (google.com: domain of prvs=9997d050a3=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=9997d050a3=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x34GnlZx027649;
	Thu, 4 Apr 2019 09:52:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=S63qVG4Ums0IRdEubLKn7lMmhUCcy/JMfjD3BkPbknI=;
 b=WIK4AJ3RgfW4GW4fLqhaC63uxFncQnNyZwOtssDGpvVznG4fqhVxD1DXKiKw9qZxfSUI
 eaCxWl+F3QM/wD88/+hGWVMDUHXiMMRE8kVR/vhOuuQi/uTltR8FwJ1Hp5GBR2BiuvHx
 tgrm+ZZGUdEI92WtQyD7xcKUAhfaus1WAVc= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rngp5s7td-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 04 Apr 2019 09:52:49 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 4 Apr 2019 09:52:48 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 4 Apr 2019 09:52:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=S63qVG4Ums0IRdEubLKn7lMmhUCcy/JMfjD3BkPbknI=;
 b=huJe6imf7meVpS9GL7wv9EoABgEB/SX9hkb6P6twsZ4oxr8RiN6K73HcPDsFzk9tY2gVZCBCxUU4YeMad7m0nuRVJBddChi+82hu87CQmX7l07IAQY4jKLsrIohQoJVqMADZXH1khCf0H/17nx5nuJeJCR698crf2JkpztOzLoU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2646.namprd15.prod.outlook.com (20.179.156.83) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.17; Thu, 4 Apr 2019 16:52:46 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Thu, 4 Apr 2019
 16:52:46 +0000
From: Roman Gushchin <guro@fb.com>
To: Uladzislau Rezki <urezki@gmail.com>
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
Subject: Re: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Topic: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Index: AQHU6XC/t3CdtEyCo0+G5po95xTuJ6Yqeg4AgAGtUgCAABNhAA==
Date: Thu, 4 Apr 2019 16:52:45 +0000
Message-ID: <20190404165240.GA9713@tower.DHCP.thefacebook.com>
References: <20190402162531.10888-1-urezki@gmail.com>
 <20190402162531.10888-2-urezki@gmail.com>
 <20190403210644.GH6778@tower.DHCP.thefacebook.com>
 <20190404154320.pf3lkwm5zcblvsfv@pc636>
In-Reply-To: <20190404154320.pf3lkwm5zcblvsfv@pc636>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR05CA0061.namprd05.prod.outlook.com
 (2603:10b6:a03:74::38) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::cc5e]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 41255fba-84ba-4a69-5992-08d6b91df630
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2646;
x-ms-traffictypediagnostic: BYAPR15MB2646:
x-microsoft-antispam-prvs: <BYAPR15MB26464D5F7A7409FA31E5B95FBE500@BYAPR15MB2646.namprd15.prod.outlook.com>
x-forefront-prvs: 0997523C40
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(39860400002)(376002)(366004)(136003)(199004)(54094003)(189003)(6512007)(99286004)(5024004)(33656002)(6486002)(478600001)(1411001)(316002)(46003)(6246003)(14454004)(446003)(6116002)(86362001)(7736002)(8676002)(5660300002)(105586002)(106356001)(81166006)(8936002)(256004)(6916009)(4326008)(53936002)(81156014)(9686003)(11346002)(6436002)(476003)(52116002)(76176011)(102836004)(68736007)(97736004)(6506007)(2906002)(25786009)(186003)(14444005)(486006)(54906003)(7416002)(386003)(71200400001)(1076003)(93886005)(305945005)(71190400001)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2646;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: j8P50ziYRGSyTjyrHthchymK1Z5p1NfaA2JW6hCjhWJxXDl7jWht1/ln8UKDaLTyw8TOz2joA6X+lfNVnrwkYCNo6zCjmcmgzz4u8EOu8LI/wXWJPfESp0FDUi5EMeDP9t3Mi4sqYU0sCCjvvr9biARMFZwqJFND/HgL0JC9oKNr30JGm9f/oRNrBkoa3A/bDzkaq+yLkWhmE/2kNeFiGUrXfhtnIrwHYNKfq7yL0CmSLxYow0wdzoaN2TME6/Krf4mTcCDzmpLugS6d6Smf0jZoC0o64WiBvHvCFm6MCmfNNdJDUBdBuDDT1KLKAg54kt0tUkmi09NNLeWFK0Ky8K8Kt4dpOvrpBYbiabooe+Yvj5k0v6bqsazW2UCr3Iz3uDb+8OvC++mmy9eEkghgLmhYWjYaRDTkmkJbH5zP5p4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <509A0A9AE64BB144BE3DCA20C4D57063@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 41255fba-84ba-4a69-5992-08d6b91df630
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Apr 2019 16:52:45.9390
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2646
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-04_09:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 05:43:20PM +0200, Uladzislau Rezki wrote:
> Hello, Roman!
>=20
> >=20
> > The patch looks really good to me! I've tried hard, but didn't find
> > any serious issues/bugs. Some small nits below.
> >=20
> > Thank you for working on it!
> >=20
> I try my best, thank you for your review!
>=20
> > BTW, when sending a new iteration, please use "[PATCH vX]" subject pref=
ix,
> > e.g. [PATCH v3 1/3] mm/vmap: keep track of free blocks for vmap allocat=
ion".
> > RESEND usually means that you're sending the same version, e.g. when
> > you need cc more people.
> >=20
> Thank you for the clarification. I will fix that next time.
>=20
> >=20
> > On Tue, Apr 02, 2019 at 06:25:29PM +0200, Uladzislau Rezki (Sony) wrote=
:
> > > Currently an allocation of the new vmap area is done over busy
> > > list iteration(complexity O(n)) until a suitable hole is found
> > > between two busy areas. Therefore each new allocation causes
> > > the list being grown. Due to over fragmented list and different
> > > permissive parameters an allocation can take a long time. For
> > > example on embedded devices it is milliseconds.
> > >=20
> > > This patch organizes the KVA memory layout into free areas of the
> > > 1-ULONG_MAX range. It uses an augment red-black tree that keeps
> > > blocks sorted by their offsets in pair with linked list keeping
> > > the free space in order of increasing addresses.
> > >=20
> > > Each vmap_area object contains the "subtree_max_size" that reflects
> > > a maximum available free block in its left or right sub-tree. Thus,
> > > that allows to take a decision and traversal toward the block that
> > > will fit and will have the lowest start address, i.e. sequential
> > > allocation.
> >=20
> > I'd add here that an augmented red-black tree is used, and nodes
> > are augmented with the size of the maximum available free block.
> >=20
> Will add.
>=20
> > >=20
> > > Allocation: to allocate a new block a search is done over the
> > > tree until a suitable lowest(left most) block is large enough
> > > to encompass: the requested size, alignment and vstart point.
> > > If the block is bigger than requested size - it is split.
> > >=20
> > > De-allocation: when a busy vmap area is freed it can either be
> > > merged or inserted to the tree. Red-black tree allows efficiently
> > > find a spot whereas a linked list provides a constant-time access
> > > to previous and next blocks to check if merging can be done. In case
> > > of merging of de-allocated memory chunk a large coalesced area is
> > > created.
> > >=20
> > > Complexity: ~O(log(N))
> > >=20
> > > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > > ---
> > >  include/linux/vmalloc.h |    6 +-
> > >  mm/vmalloc.c            | 1004 +++++++++++++++++++++++++++++++++++--=
----------
> > >  2 files changed, 762 insertions(+), 248 deletions(-)
> > >=20
> > > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > > index 398e9c95cd61..ad483378fdd1 100644
> > > --- a/include/linux/vmalloc.h
> > > +++ b/include/linux/vmalloc.h
> > > @@ -45,12 +45,16 @@ struct vm_struct {
> > >  struct vmap_area {
> > >  	unsigned long va_start;
> > >  	unsigned long va_end;
> > > +
> > > +	/*
> > > +	 * Largest available free size in subtree.
> > > +	 */
> > > +	unsigned long subtree_max_size;
> > >  	unsigned long flags;
> > >  	struct rb_node rb_node;         /* address sorted rbtree */
> > >  	struct list_head list;          /* address sorted list */
> > >  	struct llist_node purge_list;    /* "lazy purge" list */
> > >  	struct vm_struct *vm;
> > > -	struct rcu_head rcu_head;
> > >  };
> > > =20
> > >  /*
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index 755b02983d8d..3adbad3fb6c1 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -31,6 +31,7 @@
> > >  #include <linux/compiler.h>
> > >  #include <linux/llist.h>
> > >  #include <linux/bitops.h>
> > > +#include <linux/rbtree_augmented.h>
> > > =20
> > >  #include <linux/uaccess.h>
> > >  #include <asm/tlbflush.h>
> > > @@ -320,9 +321,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_=
addr)
> > >  }
> > >  EXPORT_SYMBOL(vmalloc_to_pfn);
> > > =20
> > > -
> > >  /*** Global kva allocator ***/
> > > -
> >=20
> > Do we need this change?
> >
> This patch does not tend to refactor the code. I have removed extra empty
> lines because i touched the code around. I can either keep that change or
> remove it. What is your opinion?

Usually it's better to separate cosmetic changes from functional, if you're
not touching directly these lines. Not a big deal, of course.

>=20
> > >  #define VM_LAZY_FREE	0x02
> > >  #define VM_VM_AREA	0x04
> > > =20
> > > @@ -331,14 +330,76 @@ static DEFINE_SPINLOCK(vmap_area_lock);
> > >  LIST_HEAD(vmap_area_list);
> > >  static LLIST_HEAD(vmap_purge_list);
> > >  static struct rb_root vmap_area_root =3D RB_ROOT;
> > > +static bool vmap_initialized __read_mostly;
> > > +
> > > +/*
> > > + * This kmem_cache is used for vmap_area objects. Instead of
> > > + * allocating from slab we reuse an object from this cache to
> > > + * make things faster. Especially in "no edge" splitting of
> > > + * free block.
> > > + */
> > > +static struct kmem_cache *vmap_area_cachep;
> > > +
> > > +/*
> > > + * This linked list is used in pair with free_vmap_area_root.
> > > + * It gives O(1) access to prev/next to perform fast coalescing.
> > > + */
> > > +static LIST_HEAD(free_vmap_area_list);
> > > +
> > > +/*
> > > + * This augment red-black tree represents the free vmap space.
> > > + * All vmap_area objects in this tree are sorted by va->va_start
> > > + * address. It is used for allocation and merging when a vmap
> > > + * object is released.
> > > + *
> > > + * Each vmap_area node contains a maximum available free block
> > > + * of its sub-tree, right or left. Therefore it is possible to
> > > + * find a lowest match of free area.
> > > + */
> > > +static struct rb_root free_vmap_area_root =3D RB_ROOT;
> > > =20
> > > -/* The vmap cache globals are protected by vmap_area_lock */
> > > -static struct rb_node *free_vmap_cache;
> > > -static unsigned long cached_hole_size;
> > > -static unsigned long cached_vstart;
> > > -static unsigned long cached_align;
> > > +static __always_inline unsigned long
> > > +__va_size(struct vmap_area *va)
> > > +{
> > > +	return (va->va_end - va->va_start);
> > > +}
> > > +
> > > +static __always_inline unsigned long
> > > +get_subtree_max_size(struct rb_node *node)
> > > +{
> > > +	struct vmap_area *va;
> > > =20
> > > -static unsigned long vmap_area_pcpu_hole;
> > > +	va =3D rb_entry_safe(node, struct vmap_area, rb_node);
> > > +	return va ? va->subtree_max_size : 0;
> > > +}
> > > +
> > > +/*
> > > + * Gets called when remove the node and rotate.
> > > + */
> > > +static __always_inline unsigned long
> > > +compute_subtree_max_size(struct vmap_area *va)
> > > +{
> > > +	unsigned long max_size =3D __va_size(va);
> > > +	unsigned long child_max_size;
> > > +
> > > +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_right);
> > > +	if (child_max_size > max_size)
> > > +		max_size =3D child_max_size;
> > > +
> > > +	child_max_size =3D get_subtree_max_size(va->rb_node.rb_left);
> > > +	if (child_max_size > max_size)
> > > +		max_size =3D child_max_size;
> > > +
> > > +	return max_size;
> >=20
> > Nit: you can use max3 instead, e.g. :
> >=20
> > return max3(__va_size(va),
> > 	    get_subtree_max_size(va->rb_node.rb_left),
> > 	    get_subtree_max_size(va->rb_node.rb_right));
> >=20
> Good point. Will replace it!
>=20
> > > +}
> > > +
> > > +RB_DECLARE_CALLBACKS(static, free_vmap_area_rb_augment_cb,
> > > +	struct vmap_area, rb_node, unsigned long, subtree_max_size,
> > > +	compute_subtree_max_size)
> > > +
> > > +static void purge_vmap_area_lazy(void);
> > > +static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
> > > +static unsigned long lazy_max_pages(void);
> > > =20
> > >  static struct vmap_area *__find_vmap_area(unsigned long addr)
> > >  {
> > > @@ -359,41 +420,520 @@ static struct vmap_area *__find_vmap_area(unsi=
gned long addr)
> > >  	return NULL;
> > >  }
> > > =20
> > > -static void __insert_vmap_area(struct vmap_area *va)
> > > -{
> > > -	struct rb_node **p =3D &vmap_area_root.rb_node;
> > > -	struct rb_node *parent =3D NULL;
> > > -	struct rb_node *tmp;
> > > +/*
> > > + * This function returns back addresses of parent node
> > > + * and its left or right link for further processing.
> > > + */
> > > +static __always_inline struct rb_node **
> > > +__find_va_links(struct vmap_area *va,
> > > +	struct rb_root *root, struct rb_node *from,
> > > +	struct rb_node **parent)
> >=20
> > The function looks much cleaner now, thank you!
> >=20
> > But if I understand it correctly, it returns a node (via parent)
> > and a pointer to one of two links, so that the returned value
> > is always =3D=3D parent + some constant offset.
> > If so, I wonder if it's cleaner to return a parent node
> > (as rb_node*) and a bool value which will indicate if the left
> > or the right link should be used.
> >=20
> > Not a strong opinion, just an idea.
> >=20
> I see your point. Yes, that is possible to return "bool" value that
> indicates left or right path. After that we can detect the direction.
>=20
> From the other hand, we end up and access the correct link anyway during
> the traversal the tree. In case of "bool" way, we will need to add on top
> some extra logic that checks where to attach to.

Sure, makes sense. I'd add some comments here then.

Thanks!

