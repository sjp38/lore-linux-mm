Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C133EC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:26:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9249D2064A
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:26:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9249D2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CB466B000A; Fri, 16 Aug 2019 08:26:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256106B000C; Fri, 16 Aug 2019 08:26:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11CA36B000D; Fri, 16 Aug 2019 08:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id DDD076B000A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:26:30 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8A27A181AC9D3
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:26:30 +0000 (UTC)
X-FDA: 75828214140.21.game83_38c2c30f65710
X-HE-Tag: game83_38c2c30f65710
X-Filterd-Recvd-Size: 4115
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:26:29 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0F587AF55;
	Fri, 16 Aug 2019 12:26:28 +0000 (UTC)
Date: Fri, 16 Aug 2019 14:26:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816122625.GA10499@dhcp22.suse.cz>
References: <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
 <20190815182448.GP21596@ziepe.ca>
 <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <20190815201323.GU21596@ziepe.ca>
 <20190816081029.GA27790@dhcp22.suse.cz>
 <20190816121906.GC5398@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816121906.GC5398@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 16-08-19 09:19:06, Jason Gunthorpe wrote:
> On Fri, Aug 16, 2019 at 10:10:29AM +0200, Michal Hocko wrote:
> > On Thu 15-08-19 17:13:23, Jason Gunthorpe wrote:
> > > On Thu, Aug 15, 2019 at 09:35:26PM +0200, Michal Hocko wrote:
> > > 
> > > > > The last detail is I'm still unclear what a GFP flags a blockable
> > > > > invalidate_range_start() should use. Is GFP_KERNEL OK?
> > > > 
> > > > I hope I will not make this muddy again ;)
> > > > invalidate_range_start in the blockable mode can use/depend on any sleepable
> > > > allocation allowed in the context it is called from. 
> > > 
> > > 'in the context is is called from' is the magic phrase, as
> > > invalidate_range_start is called while holding several different mm
> > > related locks. I know at least write mmap_sem and i_mmap_rwsem
> > > (write?)
> > > 
> > > Can GFP_KERNEL be called while holding those locks?
> > 
> > i_mmap_rwsem would be problematic because it is taken during the
> > reclaim.
> 
> Okay.. So the fs_reclaim debugging does catch errors.

I do not think fs_reclaim is the udnerlying mechanism to catch this
deadlock. It is a simple AA deadlock. You take i_mmap_rwsem and then
go down the allocation path, direct reclaim and take the lock again.
Nothing really surprising. fs_reclaim is really to catch GFP_NOFS
context calling into a less restricted (e.g. GFP_KERNEL allocation
context).

> Do you have any
> reference for what a false positive looks like? 

I believe I have given some examples when introducing __GFP_NOLOCKDEP.
 
> I would like to inject it into the notifier path as this is very
> difficult for driver authors to discover and know about, but I'm
> worried about your false positive remark.
> 
> I think I understand we can use only GFP_ATOMIC in the notifiers, but
> we need a strategy to handle OOM to guarentee forward progress.

Your example is from the notifier registration IIUC. Can you
pre-allocate before taking locks? Could you point me to some examples
when the allocation is necessary in the range notifier callback?
-- 
Michal Hocko
SUSE Labs

