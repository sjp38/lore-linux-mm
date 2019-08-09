Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8298C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:56:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F6182086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 17:56:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F6182086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1002B6B027D; Fri,  9 Aug 2019 13:56:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B10E6B027E; Fri,  9 Aug 2019 13:56:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE2596B0292; Fri,  9 Aug 2019 13:56:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B67EA6B027D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 13:56:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b18so60163858pgg.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 10:56:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=ihrdGp0i/eSmctA1BAHL9aDuB9XQq46XMozZ2xpN4QA=;
        b=itEwGFXdEd3MtfdJx1dmW+ncnNCibIyd4mNrJK05lweaiQKNzw98G4d8j8n4TBQ8iM
         BecNEDxwQwhRD0b3Ct1eT17J3V3m4G3GOFLg4j197k6BCPrteZaDeStV36b32k4cpYaB
         YuFyaHILW+2/PpBRp50EWI+H2olre5wSGV+EaketYKguOmiBH9xgh/Tic7Gk/61iaEEk
         bB+QdNTivW72mwmhTEb/S1EATtIkWNfCXs6aB+CcNp6L2JprcuXyMx2wR/Q2PsLO64rp
         PElENT5mNhg2+1asr33o7Eccozi268dtenMUrHFU74dPtCJjrDkMgP0i2iAwiqmMTf0U
         W6WA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWsrQk9s8+umelRAWz0huSH1Ai4/jdsyM2TfM5PqKW/pbhN6Qiz
	w2vSigiHqCmrRshka04mKqyKRTjQGz8aEq7vPFSyh4cq4zDWRaut+7xcBvfYH4/9znS0K87115r
	NmdD5X6gdnx8KL1gU7yBINrNYuvY2OBRaSGVA3IN6HcougY//OTe10IYhKwRttz1b3g==
X-Received: by 2002:aa7:9591:: with SMTP id z17mr22984488pfj.215.1565373386310;
        Fri, 09 Aug 2019 10:56:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvRL799jIkM1Mb/E6y95084ryFeKAVTIqNZZi+7SSLCRg4karz+vXeMyA4EX7ZcwPaS5fS
X-Received: by 2002:aa7:9591:: with SMTP id z17mr22984422pfj.215.1565373385396;
        Fri, 09 Aug 2019 10:56:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373385; cv=none;
        d=google.com; s=arc-20160816;
        b=0Vb+BXAATF+u1WafQiQa2MLCSnKLTRk0/nxBDptq+Qqb9sfzcBOUTRMA4GdncEoGZf
         L0nmaiPtmt21GFcCexlTYDp3DMFQ/TK9nRHGl7sPCIo9AA5Lh9856KEXbkOYhBEIYzGs
         CQN0KqCpU8D3JiSjIyG7g8R6nDac9O7AQuKA0n7DyHBbOhhxcgOY44EWuT83NWKGZZWA
         tT8vKSApLDxgZEd/8DhZ4n9AKqyrt6KkSLGl0S+Hmk+HCWqjQ6a4tGH8I4QM+WYDCOow
         5qbaFyO68xRcICp3D+oUfE96KVK92D1rpEmqes1nvYzVyTbGKfmozqp7yz+RUQf2efN+
         8iLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=ihrdGp0i/eSmctA1BAHL9aDuB9XQq46XMozZ2xpN4QA=;
        b=IH5DmfDesSMFgDtO/8ukey806y/MvhrWV6eYQBd/v2QJCwYpabSbBsse3kJGEGBpdC
         W8Ox6X5Fz+Iu6VKYfGbI5c9e5C0voqhzATGcrmw9ZMd8rrK66IlJUCE46+dLB4wz/TPf
         +gAJNyAAwqKYUU9g/quXJmAWABCSm2tspVp2tO70X7O43Q6iABZXc1CP0iCf/OV1rymz
         CJ7RSQbx08yj5NjiM2BZo8edStW/hnyr6O4br49O9cYxS2PxUO180N30ZxJ1Cl03aHS5
         L+l+Qp5Kyh+NfuwEoYY0W8WV18RUdfjoIYNwRN9Gz//Rp7JN0JDnjQRyn7DiMqWmp5FD
         kM6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 144si22703484pgh.176.2019.08.09.10.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 10:56:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 10:56:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,366,1559545200"; 
   d="scan'208";a="350560074"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by orsmga005.jf.intel.com with ESMTP; 09 Aug 2019 10:56:24 -0700
Received: from crsmsx151.amr.corp.intel.com (172.18.7.86) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 9 Aug 2019 10:56:23 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.115]) by
 CRSMSX151.amr.corp.intel.com ([169.254.3.186]) with mapi id 14.03.0439.000;
 Fri, 9 Aug 2019 11:56:21 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Jan Kara <jack@suse.cz>
CC: Michal Hocko <mhocko@kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>, "john.hubbard@gmail.com"
	<john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, "Williams, Dan J"
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "ceph-devel@vger.kernel.org"
	<ceph-devel@vger.kernel.org>, "devel@driverdev.osuosl.org"
	<devel@driverdev.osuosl.org>, "devel@lists.orangefs.org"
	<devel@lists.orangefs.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, "kvm@vger.kernel.org"
	<kvm@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>, "linux-crypto@vger.kernel.org"
	<linux-crypto@vger.kernel.org>, "linux-fbdev@vger.kernel.org"
	<linux-fbdev@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-rpi-kernel@lists.infradead.org"
	<linux-rpi-kernel@lists.infradead.org>, "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "rds-devel@oss.oracle.com"
	<rds-devel@oss.oracle.com>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Subject: RE: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Thread-Topic: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Thread-Index: AQHVSNjU1EYxEMQcyke2Y16AlWiV+abn98YAgAA6ZwCAABzEgIAAB8CAgABJHoCABynCAIAAAqCAgAC1jYCAAmuxgIAANKMg
Date: Fri, 9 Aug 2019 17:56:20 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79E7F367@CRSMSX101.amr.corp.intel.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
 <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
 <20190809083435.GA17568@quack2.suse.cz>
In-Reply-To: <20190809083435.GA17568@quack2.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMjgzZWFlNTQtZDMwNC00YTZiLThiNDktMzI0ZWY3MGNjMDdiIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiY2tWUXpQWXg4RTZvTlVIZFwvOFVSVWNwbCs3V2JDTG5GcHNpZTB3bzRRaEhFUExOQzZXZGtLeFkzNUhuNjVBOEYifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>=20
> On Wed 07-08-19 19:36:37, Ira Weiny wrote:
> > On Wed, Aug 07, 2019 at 10:46:49AM +0200, Michal Hocko wrote:
> > > > So I think your debug option and my suggested renaming serve a bit
> > > > different purposes (and thus both make sense). If you do the
> > > > renaming, you can just grep to see unconverted sites. Also when
> > > > someone merges new GUP user (unaware of the new rules) while you
> > > > switch GUP to use pins instead of ordinary references, you'll get
> > > > compilation error in case of renaming instead of hard to debug
> > > > refcount leak without the renaming. And such conflict is almost
> > > > bound to happen given the size of GUP patch set... Also the
> > > > renaming serves against the "coding inertia" - i.e., GUP is around =
for
> ages so people just use it without checking any documentation or comments=
.
> > > > After switching how GUP works, what used to be correct isn't
> > > > anymore so renaming the function serves as a warning that
> > > > something has really changed.
> > >
> > > Fully agreed!
> >
> > Ok Prior to this I've been basing all my work for the RDMA/FS DAX
> > stuff in Johns put_user_pages()...  (Including when I proposed failing
> > truncate with a lease in June [1])
> >
> > However, based on the suggestions in that thread it became clear that
> > a new interface was going to need to be added to pass in the "RDMA
> > file" information to GUP to associate file pins with the correct proces=
ses...
> >
> > I have many drawings on my white board with "a whole lot of lines" on
> > them to make sure that if a process opens a file, mmaps it, pins it
> > with RDMA, _closes_ it, and ummaps it; that the resulting file pin can
> > still be traced back to the RDMA context and all the processes which
> > may have access to it....  No matter where the original context may
> > have come from.  I believe I have accomplished that.
> >
> > Before I go on, I would like to say that the "imbalance" of
> > get_user_pages() and put_page() bothers me from a purist standpoint...
> > However, since this discussion cropped up I went ahead and ported my
> > work to Linus' current master
> > (5.3-rc3+) and in doing so I only had to steal a bit of Johns code...
> > Sorry John...  :-(
> >
> > I don't have the commit messages all cleaned up and I know there may
> > be some discussion on these new interfaces but I wanted to throw this
> > series out there because I think it may be what Jan and Michal are
> > driving at (or at least in that direction.
> >
> > Right now only RDMA and DAX FS's are supported.  Other users of GUP
> > will still fail on a DAX file and regular files will still be at
> > risk.[2]
> >
> > I've pushed this work (based 5.3-rc3+ (33920f1ec5bf)) here[3]:
> >
> > https://github.com/weiny2/linux-kernel/tree/linus-rdmafsdax-b0-v3
> >
> > I think the most relevant patch to this conversation is:
> >
> > https://github.com/weiny2/linux-
> kernel/commit/5d377653ba5cf11c3b716f90
> > 4b057bee6641aaf6
> >
> > I stole Jans suggestion for a name as the name I used while
> > prototyping was pretty bad...  So Thanks Jan...  ;-)
>=20
> For your function, I'd choose a name like vaddr_pin_leased_pages() so tha=
t
> association with a lease is clear from the name :)

My gut was to just change this as you suggested.  But the fact is that thes=
e calls can get used on anonymous pages as well.  So the "leased" semantic =
may not apply...  OTOH if a file is encountered it will fail the pin...  :-=
/  I'm going to leave it for now and get the patches submitted to the list.=
..

> Also I'd choose the
> counterpart to be vaddr_unpin_leased_page[s](). Especially having put_pag=
e
> in the name looks confusing to me...

Ah yes, totally agree with the "pin/unpin" symmetry.  I've changed from "pu=
t" to "unpin"...

Thanks,
Ira

>=20
> 								Honza
>=20
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

