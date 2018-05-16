Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 270AD6B02D7
	for <linux-mm@kvack.org>; Tue, 15 May 2018 22:05:35 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c82-v6so6240968itg.1
        for <linux-mm@kvack.org>; Tue, 15 May 2018 19:05:35 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.8])
        by mx.google.com with ESMTPS id y99-v6si1428824ita.126.2018.05.15.19.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 19:05:33 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem)
 zone
Date: Wed, 16 May 2018 02:05:05 +0000
Message-ID: <HK2PR03MB1684F8D2724BB8AF1FCCF02A92920@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
 <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
 <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com>
 <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180508030959.GB16338@bombadil.infradead.org>
 <HK2PR03MB16841CBB549F40F86BB8D35C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180510162742.GA30442@bombadil.infradead.org>
 <HK2PR03MB1684B34F9D1DF18A8CDE18F292930@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180515162003.GA26489@bombadil.infradead.org>
In-Reply-To: <20180515162003.GA26489@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, NingTing Cheng <chengnt@lenovo.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, Linux MM <linux-mm@kvack.org>, "colyli@suse.de" <colyli@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@verizon.com>, Mel
 Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Ocean HY1 He <hehy1@lenovo.com>

> From: Matthew Wilcox [mailto:willy@infradead.org]
> Sent: Wednesday, May 16, 2018 12:20 AM>=20
> > > > > Then there's the problem of reconnecting the page cache (which is
> > > > > pointed to by ephemeral data structures like inodes and dentries)=
 to
> > > > > the new inodes.
> > > > Yes, it is not easy.
> > >
> > > Right ... and until we have that ability, there's no point in this pa=
tch.
> > We are focusing to realize this ability.
>=20
> But is it the right approach?  So far we have (I think) two parallel
> activities.  The first is for local storage, using DAX to store files
> directly on the pmem.  The second is a physical block cache for network
> filesystems (both NAS and SAN).  You seem to be wanting to supplant the
> second effort, but I think it's much harder to reconnect the logical cach=
e
> (ie the page cache) than it is the physical cache (ie the block cache).

Dear Matthew,

Thanks for correcting my idea with cache line.
But I have questions about that, assuming NVDIMM works with pmem mode, even=
 we
used it as physical block cache, like dm-cache, there is potential risk wit=
h
this cache line issue, because NVDIMMs are bytes-address storage, right?
If system crash happens, that means CPU doesn't have opportunity to flush a=
ll dirty
data from cache lines to NVDIMM, during copying data pointed by bio_vec.bv_=
page to
NVDIMM.=20
I know there is btt which is used to guarantee sector atomic with block mod=
e,
but for pmem mode that will likely cause mix of new and old data in one pag=
e
of NVDIMM.
Correct me if anything wrong.

Another question, if we used NVDIMMs as physical block cache for network fi=
lesystems,
Does industry have existing implementation to bypass Page Cache similarly l=
ike DAX way,
that is to say, directly storing data to NVDIMMs from userspace, rather tha=
n copying
data from kernel space memory to NVDIMMs.

BRs,
Huaisheng
