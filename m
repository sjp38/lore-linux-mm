Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5312C8E0001
	for <linux-mm@kvack.org>; Sat, 29 Sep 2018 04:46:19 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b12-v6so7981444qtp.16
        for <linux-mm@kvack.org>; Sat, 29 Sep 2018 01:46:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l62-v6si150964qkb.0.2018.09.29.01.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Sep 2018 01:46:17 -0700 (PDT)
Date: Sat, 29 Sep 2018 04:46:09 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
Message-ID: <20180929084608.GA3188@redhat.com>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928152958.GA3321@redhat.com>
 <4c884529-e2ff-3808-9763-eb0e71f5a616@nvidia.com>
 <20180928214934.GA3265@redhat.com>
 <dfa6aaef-b97e-ebd4-6cc8-c907a7b3f9bb@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <dfa6aaef-b97e-ebd4-6cc8-c907a7b3f9bb@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On Fri, Sep 28, 2018 at 07:28:16PM -0700, John Hubbard wrote:
> On 9/28/18 2:49 PM, Jerome Glisse wrote:
> > On Fri, Sep 28, 2018 at 12:06:12PM -0700, John Hubbard wrote:
> >> On 9/28/18 8:29 AM, Jerome Glisse wrote:
> >>> On Thu, Sep 27, 2018 at 10:39:45PM -0700, john.hubbard@gmail.com wrote:
> >>>> From: John Hubbard <jhubbard@nvidia.com>
> [...]
> >>> So the solution is to wait (possibly for days, months, years) that the
> >>> RDMA or GPU which did GUP and do not have mmu notifier, release the page
> >>> (or put_user_page()) ?
> >>>
> >>> This sounds bads. Like i said during LSF/MM there is no way to properly
> >>> fix hardware that can not be preempted/invalidated ... most GPU are fine.
> >>> Few RDMA are fine, most can not ...
> >>>
> >>
> >> Hi Jerome,
> >>
> >> Personally, I'm think that this particular design is the best one I've seen
> >> so far, but if other, better designs show up, than let's do those instead, sure.
> >>
> >> I guess your main concern is that this might take longer than other approaches.
> >>
> >> As for time frame, perhaps I made it sound worse than it really is. I have patches
> >> staged already for all of the simpler call sites, and for about half of the more
> >> complicated ones. The core solution in mm is not large, and we've gone through a 
> >> few discussion threads about it back in July or so, so it shouldn't take too long
> >> to perfect it.
> >>
> >> So it may be a few months to get it all reviewed and submitted, but I don't
> >> see "years" by any stretch.
> > 
> > Bit of miss-comprehention there :) By month, years, i am talking about
> > the time it will take for some user to release the pin they have on the
> > page. Not the time to push something upstream.
> > 
> > AFAICT RDMA driver do not have any upper bound on how long they can hold
> > a page reference and thus your solution can leave one CPU core stuck for
> > as long as the pin is active. Worst case might lead to all CPU core waiting
> > for something that might never happen.
> > 
> 
> Actually, the latest direction on that discussion was toward periodically
> writing back, even while under RDMA, via bounce buffers:
> 
>   https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
> 
> I still think that's viable. Of course, there are other things besides 
> writeback (see below) that might also lead to waiting.

Write back under bounce buffer is fine, when looking back at links you
provided the solution that was discuss was blocking in page_mkclean()
which is horrible in my point of view.

> 
> >>> If it is just about fixing the set_page_dirty() bug then just looking at
> >>> refcount versus mapcount should already tell you if you can remove the
> >>> buffer head from the page or not. Which would fix the bug without complex
> >>> changes (i still like the put_user_page just for symetry with GUP).
> >>>
> >>
> >> It's about more than that. The goal is to make it safe and correct to
> >> use a non-CPU device to read and write to "pinned" memory, especially when
> >> that memory is backed by a file system.
> >>
> >> I recall there were objections to just narrowly fixing the set_page_dirty()
> >> bug, because the underlying problem is large and serious. So here we are.
> > 
> > Except that you can not solve that issue without proper hardware. GPU are
> > fine. RDMA are broken except the mellanox5 hardware which can invalidate
> > at anytime its page table thus allowing to write protect the page at any
> > time.
> 
> Today, people are out there using RDMA without page-fault-capable hardware.
> And they are hitting problems, as we've seen. From the discussions so far,
> I don't think it's impossible to solve the problems, even for "lesser", 
> non-fault-capable hardware. Especially once we decide on what is reasonable
> and supported.  Certainly the existing situation needs *something* to 
> change, even if it's (I don't recommend this) "go forth and tell the world
> to stop using RDMA with their current hardware".

I am not saying stop using their hardware, i am saying their hardware do
things it should not do because the driver developer did not do their due
diligence in understanding what GUP really is. As a result i believe that
what ever solution we decide to have must penalize only and only users of
such device drivers. It should not hurt the general case with sane hw.


> > 
> > With the solution put forward here you can potentialy wait _forever_ for
> > the driver that holds a pin to drop it. This was the point i was trying to
> > get accross during LSF/MM. 
> 
> I agree that just blocking indefinitely is generally unacceptable for kernel
> code, but we can probably avoid it for many cases (bounce buffers), and
> if we think it is really appropriate (file system unmounting, maybe?) then
> maybe tolerate it in some rare cases.  
> 
> >You can not fix broken hardware that decided to
> > use GUP to do a feature they can't reliably do because their hardware is
> > not capable to behave.
> > 
> > Because code is easier here is what i was meaning:
> > 
> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup&id=a5dbc0fe7e71d347067579f13579df372ec48389
> > https://cgit.freedesktop.org/~glisse/linux/commit/?h=gup&id=01677bc039c791a16d5f82b3ef84917d62fac826
> > 
> 
> While that may work sometimes, I don't think it is reliable enough to trust for
> identifying pages that have been gup-pinned. There's just too much overloading of
> other mechanisms going on there, and if we pile on top with this constraint of "if you
> have +3 refcounts, and this particular combination of page counts and mapcounts, then
> you're definitely a long-term pinned page", I think users will find a lot of corner
> cases for us that break that assumption. 

So the mapcount == refcount (modulo extra reference for mapping and
private) should holds, here are the case when it does not:
    - page being migrated
    - page being isolated from LRU
    - mempolicy changes against the page
    - page cache lookup
    - some file system activities
    - i likely miss couples here i am doing that from memory

What matter is that all of the above are transitory, the extra reference
only last for as long as it takes for the action to finish (migration,
mempolicy change, ...).

So skipping those false positive page while reclaiming likely make sense,
the blocking free buffer maybe not.


> 
> So I think we agree that the put_user_page() approach, to complement the
> get_user_pages*() call sites, is worth doing regardless of the details of the core
> solution. btw, now that I'm refreshing my memory of our earlier discussions: Jan had an
> interesting point that "long-term pinned" is a property of the call site, rather than
> of the page:
> 
>   https://lkml.kernel.org/r/20180704104318.f5pnqtnn3unkwauw@quack2.suse.cz
> 
> ...which really sounded like a useful way to think about this.
> 
> Here's what I think would help:
> 
> 1) I'll send out a freshened-up RFC for the core implementation (it's hard to talk about
> here without that, although your code above helps), and we can hammer out some answers
> there.
> 
> 2) I'll work through remaining comments (Jason had some) on this and respin this patchset.
> 
> Basically, I'm hearing "Jerome is totally going to ACK this, but maybe disagree about
> some or all of the upcoming RFC". But then again, I hear what I want to hear! :)

I am fine with having symetry with GUP and put_user_page() so this
patchset is fine from my POV. But i was looking at the final solution
and what the first links suggested when digging the internet was the
lets block forever in page_mkclean() and that is not fine. The bounce
buffer solution is fine it will put the extra cost burden onto user of
such broken hardware.

Thanks for looking into all that,
Cheers,
Jerome
