Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33CA76B0011
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:07:25 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y10so11213774wrg.9
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:07:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h48si55597edh.427.2018.04.17.04.07.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 04:07:23 -0700 (PDT)
Date: Tue, 17 Apr 2018 13:07:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180417110717.GB17484@dhcp22.suse.cz>
References: <20180416160608.GA7071@amd>
 <20180416161412.GZ2341@sasha-vm>
 <20180416170501.GB11034@amd>
 <20180416171607.GJ2341@sasha-vm>
 <alpine.LRH.2.00.1804162214260.26111@gjva.wvxbf.pm>
 <20180416203629.GO2341@sasha-vm>
 <nycvar.YFH.7.76.1804162238500.28129@cbobk.fhfr.pm>
 <20180416211845.GP2341@sasha-vm>
 <nycvar.YFH.7.76.1804162326210.28129@cbobk.fhfr.pm>
 <20180417103936.GC8445@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417103936.GC8445@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Jiri Kosina <jikos@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>, Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>

On Tue 17-04-18 12:39:36, Greg KH wrote:
> On Mon, Apr 16, 2018 at 11:28:44PM +0200, Jiri Kosina wrote:
> > On Mon, 16 Apr 2018, Sasha Levin wrote:
> > 
> > > I agree that as an enterprise distro taking everything from -stable
> > > isn't the best idea. Ideally you'd want to be close to the first
> > > extreme you've mentioned and only take commits if customers are asking
> > > you to do so.
> > > 
> > > I think that the rule we're trying to agree upon is the "It must fix
> > > a real bug that bothers people".
> > > 
> > > I think that we can agree that it's impossible to expect every single
> > > Linux user to go on LKML and complain about a bug he encountered, so the
> > > rule quickly becomes "It must fix a real bug that can bother people".
> > 
> > So is there a reason why stable couldn't become some hybrid-form union of
> > 
> > - really critical issues (data corruption, boot issues, severe security 
> >   issues) taken from bleeding edge upstream
> > - [reviewed] cherry-picks of functional fixes from major distro kernels 
> >   (based on that very -stable release), as that's apparently what people 
> >   are hitting in the real world with that particular kernel
> 
> It already is that :)
> 
> The problem Sasha is trying to solve here is that for many subsystems,
> maintainers do not mark patches for stable at all.

The way he is trying to do that is just wrong. Generate a pressure on
those subsystems by referring to bug reports and unhappy users and I am
pretty sure they will try harder... You cannot solve the problem by
bypassing them without having deep understanding of the specific
subsytem. Once you have it, just make sure you are part of the review
process and make sure to mark patches before they are merged.

> So real bugfixes
> that do hit people are not getting to those kernels, which force the
> distros to do extra work to triage a bug, dig through upstream kernels,
> find and apply the patch.

I would say that this is the primary role of the distro. To hide the
jungle of the upstream work and provide the additional of bug filtering
and forwarding them the right direction.
 
> By identifying the patches that should have been marked for stable,
> based on the ways that the changelog text is written and the logic in
> the patch itself, we circumvent that extra annoyance of users hitting
> problems and complaining, or ignoring them and hoping they go away if
> they reboot.

Well, but this is a two edge sword. You are not only backporting obvious
bug fixes but also pulling many patch out of the context they were
merged to and double checking all the assumptions are still true is a
non-trivial task to do. I am still not convinced any script or AI can do
that right now.

> I've been doing this "by hand" for many years now, with no complaints so
> far.

Really? I remember quite some complains about broken stable releases and
also many discussions on KS how the current workflow doesn't really work
for some users (e.g. distributions).

> Sasha has taken it to the next level as I don't scale and has
> started to automate it using some really nice tools.  That's all, this
> isn't crazy new features being backported, it's just patches that are
> obviously fixes being added to the stable tree.

I have yet to see a tool which can recognize an "obvious fix".
Seriously! Matching keywords in the changelog and some pattern
recognition in the diff can help to do some pre filtering _can_ help a
lot but there is still a human interaction needed to do sanity checking.
And that really requires deep subsystem knowledge. I really fail to see
how that can work without relevant people involvement. Pretending that
you can do stable without maintainers will simply not work IMNHO.

> Yes, sometimes those fixes need additional fixes, and that's fine,
> normal stable-marked patches need that all the time.  I don't see anyone
> complaining about that, right?
> 
> So nothing "new" is happening here, EXCEPT we are actually starting to
> get a better kernel-wide coverage for stable fixes, which we have not
> had in the past.  That's a good thing!  The number of patches applied to
> stable is still a very very very tiny % compared to mainline, so nothing
> new is happening here.

yes I do agree, the stable process is not very much different from the
past and I would tend both processes broken because they explicitly try
to avoid maintainers which is just wrong.

> Oh, and if you do want to complain about huge new features being
> backported, look at the mess that Spectre and Meltdown has caused in the
> stable trees.  I don't see anyone complaining about those massive
> changes :)

Are you serious? Are you going the compare the biggest PITA that the
community had to undergo because of HW issues with random pattern
matching in changelog/diffs? Come on!

-- 
Michal Hocko
SUSE Labs
