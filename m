Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A50796B02B5
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:07:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j33-v6so546312qtc.18
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:07:58 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.207])
        by mx.google.com with ESMTPS id x12-v6si366206qvb.230.2018.05.15.09.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 09:07:56 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v1 0/6] use mm to manage NVDIMM (pmem)
 zone
Date: Tue, 15 May 2018 16:07:28 +0000
Message-ID: <HK2PR03MB1684B34F9D1DF18A8CDE18F292930@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525704627-30114-1-git-send-email-yehs1@lenovo.com>
 <20180507184622.GB12361@bombadil.infradead.org>
 <CAPcyv4hBJN3npXwg3Ur32JSWtKvBUZh7F8W+Exx3BB-uKWwPag@mail.gmail.com>
 <x49a7tbi8r3.fsf@segfault.boston.devel.redhat.com>
 <HK2PR03MB1684659175EB0A11E75E9B61929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180508030959.GB16338@bombadil.infradead.org>
 <HK2PR03MB16841CBB549F40F86BB8D35C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180510162742.GA30442@bombadil.infradead.org>
In-Reply-To: <20180510162742.GA30442@bombadil.infradead.org>
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




> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behal=
f Of Matthew
> Wilcox
> Sent: Friday, May 11, 2018 12:28 AM
> On Wed, May 09, 2018 at 04:47:54AM +0000, Huaisheng HS1 Ye wrote:
> > > On Tue, May 08, 2018 at 02:59:40AM +0000, Huaisheng HS1 Ye wrote:
> > > > Currently in our mind, an ideal use scenario is that, we put all pa=
ge caches to
> > > > zone_nvm, without any doubt, page cache is an efficient and common =
cache
> > > > implement, but it has a disadvantage that all dirty data within it =
would has risk
> > > > to be missed by power failure or system crash. If we put all page c=
aches to NVDIMMs,
> > > > all dirty data will be safe.
> > >
> > > That's a common misconception.  Some dirty data will still be in the
> > > CPU caches.  Are you planning on building servers which have enough
> > > capacitance to allow the CPU to flush all dirty data from LLC to NV-D=
IMM?
> > >
> > Sorry for not being clear.
> > For CPU caches if there is a power failure, NVDIMM has ADR to guarantee=
 an interrupt
> will be reported to CPU, an interrupt response function should be respons=
ible to flush
> all dirty data to NVDIMM.
> > If there is a system crush, perhaps CPU couldn't have chance to execute=
 this response.
> >
> > It is hard to make sure everything is safe, what we can do is just to s=
ave the dirty
> data which is already stored to Pagecache, but not in CPU cache.
> > Is this an improvement than current?
>=20
> No.  In the current situation, the user knows that either the entire
> page was written back from the pagecache or none of it was (at least
> with a journalling filesystem).  With your proposal, we may have pages
> splintered along cacheline boundaries, with a mix of old and new data.
> This is completely unacceptable to most customers.

Dear Matthew,

Thanks for your great help, I really didn't consider this case.
I want to make it a little bit clearer to me. So, correct me if anything wr=
ong.

Is that to say this mix of old and new data in one page, which only has cha=
nce to happen when CPU failed to flush all dirty data from LLC to NVDIMM?
But if an interrupt can be reported to CPU, and CPU successfully flush all =
dirty data from cache lines to NVDIMM within interrupt response function, t=
his mix of old and new data can be avoided.

Current X86_64 uses N-way set associative cache, and every cache line has 6=
4 bytes.
For 4096 bytes page, one page shall be splintered to 64 (4096/64) lines. Is=
 it right?


> > > Then there's the problem of reconnecting the page cache (which is
> > > pointed to by ephemeral data structures like inodes and dentries) to
> > > the new inodes.
> > Yes, it is not easy.
>=20
> Right ... and until we have that ability, there's no point in this patch.
We are focusing to realize this ability.

Sincerely,
Huaisheng Ye
