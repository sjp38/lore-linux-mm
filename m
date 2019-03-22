Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48297C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 00:12:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC86721900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 00:12:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GRcJyQLa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC86721900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C5186B0003; Thu, 21 Mar 2019 20:12:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 774DB6B0006; Thu, 21 Mar 2019 20:12:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664516B0007; Thu, 21 Mar 2019 20:12:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 280946B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 20:12:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d128so457452pgc.8
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:12:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=eAchGUtF0pobQH/wb60CG/gq9ayx2k/HN7Oh4t6Sgr0=;
        b=LE3zOJX3Xcu2/U1i1QVGRjCsm/vRZSh9FeiRgeDSW6JmI4KrT42wckz7Qm2Q0xyw1t
         cv+ivxkeh+VsovohTp9hKzZhyxyvkFz1LtYA5PCgZzAUB60LOu7wz38hINZZf2mN8GpE
         twTBo/58QCr5MF9dSeJ7m9x0GhNHqysgpm97EUyXcDz4k6vRsUmv+kAuhMg7uwJRmp4t
         8OxCaMLSzk2PJWXdhs7m8E5Z6dDf2VrJwCRLKsEa0jGtFBHOKUJJvrE4vSl67qO/I9eI
         HqlebqXqxGJ0+E6qVVRCpH1RgH3l4UIxyE5ofzR4MgqxBvz3fLBYH+vNPrXAydu7r+Ds
         HVDQ==
X-Gm-Message-State: APjAAAVQ+WrPIlmGPcofCWhqPVh5jzHhqEdTEpk89hW1aqQeCJbQb4l1
	joz4s5KNA1NnlVs8d88dLia/ZFjJ6OQyrUPBKmFDzlUcGSD8gJvTiAYkw1AYDOkbRW1ml7+aMQo
	RmEcrCr4FF24ZCELcHMoopM9COF5CpIuNRnJbt7rmjawqdntCfIQj5F3wKeQzweEzLQ==
X-Received: by 2002:a63:2403:: with SMTP id k3mr6008021pgk.200.1553213556610;
        Thu, 21 Mar 2019 17:12:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9gTSwfNIjpQvtnJ1U3Kh95YiU8qliks5NCTr3EBebqb6SHPVIB7oqKBNA8fCktGBfmZhx
X-Received: by 2002:a63:2403:: with SMTP id k3mr6007945pgk.200.1553213555476;
        Thu, 21 Mar 2019 17:12:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553213555; cv=none;
        d=google.com; s=arc-20160816;
        b=GFY5jnyue14cbSWSwKdoJslLNDUtO/Qr/uBKSTtfRvU6nm904iUB77ChYb5W4KsAJW
         kENttXYbxIWifEF8fkwGJygF23jRRJhoQ1Osg9sgA70k9pVxXgdniUp+L6/Zo0iQIXor
         F0zIYbPZ9Q1VyV10pJuonmdFY57NPJiID7dtQ7PDsBvq02AmI5xxsp7Pq7+G6lR18swy
         qfipxJ89Yl7MGhiUUFaZ/yxKJAsDfWm0KMo/ILHeia7+8kZrRccQDFrOCkvRPF6gABzP
         4EK54sFpoTrycUIxnultcTrJfRt6pkJfucuVPYl+7DhGt2s4WmfIBTZo9NCDEZTMxhyK
         MiOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=eAchGUtF0pobQH/wb60CG/gq9ayx2k/HN7Oh4t6Sgr0=;
        b=K6ai0usTZuQRGN7qy4tNKr7zdU1DhdgdKmmeTW5D1zjWQgDFUPpP3ocRKzx+1+oa2i
         DN6Mr5KHKsW8meixgBDCmJRThJHGZSzWpjOxRhT8dgGuNny4Le2PRRY5y4bKr872gMsB
         IjmrRVKZxsT4MMIuFT76P86S/+lhnzw+8gme7RbCsJtXzo3JIObIKH0f+I8m62fpVN5v
         SGMVdFPG3j7sk5M8Z566mx15JwYZiQfOwFnhhJdLgCuCBc+fdAnM36qogslFTMBnF7+/
         +g58Yeett9DHqtbyKo8v5j1U5M3XWkIMzMC2p9IR3vSvoGNRvRfMGjhPcdibnShtmFiz
         4Vuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GRcJyQLa;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v18si5099627pfm.241.2019.03.21.17.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 17:12:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=GRcJyQLa;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9428750000>; Thu, 21 Mar 2019 17:12:37 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 21 Mar 2019 17:12:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 21 Mar 2019 17:12:34 -0700
Received: from [10.2.161.82] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 22 Mar
 2019 00:12:34 +0000
From: Zi Yan <ziy@nvidia.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov"
	<kirill@shutemov.name>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko
	<mhocko@suse.com>, David Nellans <dnellans@nvidia.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
Date: Thu, 21 Mar 2019 17:12:33 -0700
X-Mailer: MailMate (1.12.4r5614)
Message-ID: <F33CDC43-745B-4555-B8E0-D50D8024C727@nvidia.com>
In-Reply-To: <20190321223706.GA29817@localhost.localdomain>
References: <20190321200157.29678-1-keith.busch@intel.com>
 <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
 <20190321223706.GA29817@localhost.localdomain>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_2FF9B97D-293E-453D-9986-85B2771222A1_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553213557; bh=eAchGUtF0pobQH/wb60CG/gq9ayx2k/HN7Oh4t6Sgr0=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=GRcJyQLa/v2YOAfChnXurfBveYWztijaEFDrB1as80C1C2jRslVVnBwX93wgrwOxm
	 DBU3KJpDD2ybFSmpX2Rpd+2Tb+PUgERMhi7dC9VPa8oo2bbNTKW9lpDqCkHKYT1eUI
	 +YmZsnaU64lg1q0OqHX+GooeJd5DEQ2w+Se1CrD9jh+SA1rqRLKPILb9R+vBph+rgk
	 Y14SA7KEVRYzA7dfbgwbvhhKPIhEddN79RziFv+QEb6UGE8jupsUlZKbKs0oxbYFn0
	 +KaZD9OYhHZVbYhtS/rVbhGW8rPvX7LqBFnP7meoDEzFHezGfa5oWJxsv+qvWD6Yao
	 YddZcCNXVxZHw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_2FF9B97D-293E-453D-9986-85B2771222A1_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<snip>
>> 2. For the demotion path, a common case would be from high-performance=
 memory, like HBM
>> or Multi-Channel DRAM, to DRAM, then to PMEM, and finally to disks, ri=
ght? More general
>> case for demotion path would be derived from the memory performance de=
scription from HMAT[1],
>> right? Do you have any algorithm to form such a path from HMAT?
>
> Yes, I have a PoC for the kernel setting up a demotion path based on
> HMAT properties here:
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/kbusch/linux.git/comm=
it/?h=3Dmm-migrate&id=3D4d007659e1dd1b0dad49514348be4441fbe7cadb
>
> The above is just from an experimental branch.

Got it. Thanks.

>
>> 3. Do you have a plan for promoting pages from lower-level memory to h=
igher-level memory,
>> like from PMEM to DRAM? Will this one-way demotion make all pages sink=
 to PMEM and disk?
>
> Promoting previously demoted pages would require the application do
> something to make that happen if you turn demotion on with this series.=

> Kernel auto-promotion is still being investigated, and it's a little
> trickier than reclaim.
>
> If it sinks to disk, though, the next access behavior is the same as
> before, without this series.

This means, when demotion is on, the path for a page would be DRAM->PMEM-=
>Disk->DRAM->PMEM->=E2=80=A6 .
This could be a start point.

I actually did something similar here for two-level heterogeneous memory =
structure: https://github.com/ysarch-lab/nimble_page_management_asplos_20=
19/blob/nimble_page_management_4_14_78/mm/memory_manage.c#L401.
What I did basically was calling shrink_page_list() periodically, so page=
s will be separated
in active and inactive lists. Then, pages in the _inactive_ list of fast =
memory (like DRAM)
are migrated to slow memory (like PMEM) and pages in the _active_ list of=
 slow memory are migrated
to fast memory. It is kinda of abusing the existing page lists. :)

My conclusion from that experiments is that you need high-throughput page=
 migration mechanisms,
like multi-threaded page migration, migrating a bunch of pages in a batch=
 (https://github.com/ysarch-lab/nimble_page_management_asplos_2019/blob/n=
imble_page_management_4_14_78/mm/copy_page.c), and
a new mechanism called exchange pages (https://github.com/ysarch-lab/nimb=
le_page_management_asplos_2019/blob/nimble_page_management_4_14_78/mm/exc=
hange.c), so that using page migration to manage multi-level
memory systems becomes useful. Otherwise, the overheads (TLB shootdown an=
d other kernel activities
in the page migration process) of page migration may kill the benefit. Be=
cause the performance
gap between DRAM and PMEM is supposed to be smaller than the one between =
DRAM and disk,
the benefit of putting data in DRAM might not compensate the cost of migr=
ating cold pages from DRAM
to PMEM. Namely, directly putting data in PMEM after DRAM is full might b=
e better.


>> 4. In your patch 3, you created a new method migrate_demote_mapping() =
to migrate pages to
>> other memory node, is there any problem of reusing existing migrate_pa=
ges() interface?
>
> Yes, we may not want to migrate everything in the shrink_page_list()
> pages. We might want to keep a page, so we have to do those checks firs=
t. At
> the point we know we want to attempt migration, the page is already
> locked and not in a list, so it is just easier to directly invoke the
> new __unmap_and_move_locked() that migrate_pages() eventually also call=
s.

Right, I understand that you want to only migrate small pages to begin wi=
th. My question is
why not using the existing migrate_pages() in your patch 3. Like:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5ad0b35ab8e..0a0753af357f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1261,6 +1261,20 @@ static unsigned long shrink_page_list(struct list_=
head *page_list,
                        ; /* try to reclaim the page below */
                }

+               if (!PageCompound(page)) {
+                       int next_nid =3D next_migration_node(page);
+                       int err;
+
+                       if (next_nid !=3D TERMINAL_NODE) {
+                               LIST_HEAD(migrate_list);
+                               list_add(&migrate_list, &page->lru);
+                               err =3D migrate_pages(&migrate_list, allo=
c_new_node_page, NULL,
+                                       next_nid, MIGRATE_ASYNC, MR_DEMOT=
ION);
+                               if (err)
+                                       putback_movable_pages(&migrate_li=
st);
+                       }
+               }
+
                /*
                 * Anonymous process memory has backing store?
                 * Try to allocate it some swap space here.

Because your new migrate_demote_mapping() basically does the same thing a=
s the code above.
If you are not OK with the gfp flags in alloc_new_node_page(), you can ju=
st write your own
alloc_new_node_page(). :)

>
>> 5. In addition, you only migrate base pages, is there any performance =
concern on migrating THPs?
>> Is it too costly to migrate THPs?
>
> It was just easier to consider single pages first, so we let a THP spli=
t
> if possible. I'm not sure of the cost in migrating THPs directly.

AFAICT, when migrating the same amount of 2MB data, migrating a THP is mu=
ch quick than migrating
512 4KB pages. Because you save 511 TLB shootdowns in THP migration and c=
opying 2MB contiguous data
achieves higher throughput than copying individual 4KB pages. But it high=
ly depends on whether
any subpage in a THP is hotter than others, so migrating a THP as a whole=
 might hurt performance
sometimes. Just some of my observation in my own experiments.


--
Best Regards,
Yan Zi

--=_MailMate_2FF9B97D-293E-453D-9986-85B2771222A1_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlyUKHEPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKG6oP/3OQ573fMxvauLNuxYpady5bM1FB6ugGHtCW
XEzJKifXTMVue0qe8Jctz+tHwzljpzuralc3brVasDu3CLBAOKbzHtWuOrEuqprm
njE8WJEY/tcegYGuiYzIi+EIr7r0+hINCZiqbdQqxyXRKRahYNnoqVBG/riBusYT
cFwjE6Rg6hadb3QimDz4zYfHIk9ztTc4HbNwLOOrm8VhzLTXOWyq2b+xfe8Ko2Oq
BRtJcX49jIP3HMAo07YzSultExpHuYJnNTvNvAlkJVAMWAKM4HxRsNzBopRABgKg
3bA78ay4WODc0rKiqfoGOq+L3zpB+Qwwdq/G6OOuRl+/Hlp2hXAh3zEUQu9q5m2B
35cskVwYw1YG2zVJauI2MWRXbklFp8aMNJYn0jpF3U3xcTs+qVw5+Bo81sq1vFT6
oOkqsiXKPxp8lIPYFpRJA45UHw1oAOEPNyD7gAsz7b+TKQ6x1/JaDpXh0sCzMyWl
jyxexCon0SSLnOw5iRX6yyGVQsJkrp/5GqHtFwrTn+liXHl/p0Kisk1Em+y70dj5
BTHIQ7BLSavWJ+s4BczEu6ur4mJUIcQhtSFFodKAqv6CN5NioBd8k2ZoXsLJ5NBi
ufQd5XsFSNp8Zkv7GZk077NKRFhB5FsaHN4HzWsXwi0C0GbsidkPP61FGw/G2gQS
MkLYyxFh
=lbIR
-----END PGP SIGNATURE-----

--=_MailMate_2FF9B97D-293E-453D-9986-85B2771222A1_=--

