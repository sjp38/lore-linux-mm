Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 358F06B79A9
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 13:03:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l65-v6so5737260pge.17
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 10:03:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si5462191plx.27.2018.09.06.10.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 10:03:40 -0700 (PDT)
Date: Thu, 6 Sep 2018 19:03:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
Message-ID: <20180906170334.GE14951@dhcp22.suse.cz>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
 <20180906151336.GD14951@dhcp22.suse.cz>
 <CAKgT0UfiKWZO6hyjc1RpRTgD+CvM=KnbYokSueLFi7X5h+GMKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfiKWZO6hyjc1RpRTgD+CvM=KnbYokSueLFi7X5h+GMKQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Duyck, Alexander H" <alexander.h.duyck@intel.com>, pavel.tatashin@microsoft.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 06-09-18 08:41:52, Alexander Duyck wrote:
> On Thu, Sep 6, 2018 at 8:13 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 06-09-18 07:59:03, Dave Hansen wrote:
> > > On 09/05/2018 10:47 PM, Michal Hocko wrote:
> > > > why do you have to keep DEBUG_VM enabled for workloads where the boot
> > > > time matters so much that few seconds matter?
> > >
> > > There are a number of distributions that run with it enabled in the
> > > default build.  Fedora, for one.  We've basically assumed for a while
> > > that we have to live with it in production environments.
> > >
> > > So, where does leave us?  I think we either need a _generic_ debug
> > > option like:
> > >
> > >       CONFIG_DEBUG_VM_SLOW_AS_HECK
> > >
> > > under which we can put this an other really slow VM debugging.  Or, we
> > > need some kind of boot-time parameter to trigger the extra checking
> > > instead of a new CONFIG option.
> >
> > I strongly suspect nobody will ever enable such a scary looking config
> > TBH. Besides I am not sure what should go under that config option.
> > Something that takes few cycles but it is called often or one time stuff
> > that takes quite a long but less than aggregated overhead of the former?
> >
> > Just consider this particular case. It basically re-adds an overhead
> > that has always been there before the struct page init optimization
> > went it. The poisoning just returns it in a different form to catch
> > potential left overs. And we would like to have as many people willing
> > to running in debug mode to test for those paths because they are
> > basically impossible to review by the code inspection. More importantnly
> > the major overhead is boot time so my question still stands. Is this
> > worth a separate config option almost nobody is going to enable?
> >
> > Enabling DEBUG_VM by Fedora and others serves us a very good testing
> > coverage and I appreciate that because it has generated some useful bug
> > reports. Those people are paying quite a lot of overhead in runtime
> > which can aggregate over time is it so much to ask about one time boot
> > overhead?
> 
> The kind of boot time add-on I saw as a result of this was about 170
> seconds, or 2 minutes and 50 seconds on a 12TB system.

Just curious. How long does it take to get from power on to even reaach
boot loader on that machine... ;)

> I spent a
> couple minutes wondering if I had built a bad kernel or not as I was
> staring at a dead console the entire time after the grub prompt since
> I hit this so early in the boot. That is the reason why I am so eager
> to slice this off and make it something separate. I could easily see
> this as something that would get in the way of other debugging that is
> going on in a system.

But you would get the same overhead a kernel release ago when the
memmap init optimization was merged. So you are basically back to what
we used to have for years. Unless I misremember.

> If we don't want to do a config option, then what about adding a
> kernel parameter to put a limit on how much memory we will initialize
> like this before we just start skipping it. We could put a default
> limit on it like 256GB and then once we cross that threshold we just
> don't bother poisoning any more memory. With that we would probably be
> able to at least cover most of the early memory init, and that value
> should cover most systems without getting into delays on the order of
> minutes.

No, this will defeat the purpose of the check.
-- 
Michal Hocko
SUSE Labs
