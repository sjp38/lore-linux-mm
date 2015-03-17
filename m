Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F78D6B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:41:41 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so17143536wgb.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 12:41:40 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id x1si4864368wif.79.2015.03.17.12.41.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 12:41:39 -0700 (PDT)
Received: by wibdy8 with SMTP id dy8so71979923wib.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 12:41:39 -0700 (PDT)
Date: Tue, 17 Mar 2015 20:41:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150317194136.GA31691@dhcp22.suse.cz>
References: <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
 <20150316211146.GA15456@phnom.home.cmpxchg.org>
 <20150317102508.GG28112@dhcp22.suse.cz>
 <20150317132926.GA1824@phnom.home.cmpxchg.org>
 <20150317141729.GI28112@dhcp22.suse.cz>
 <20150317172628.GA5109@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150317172628.GA5109@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-03-15 13:26:28, Johannes Weiner wrote:
> On Tue, Mar 17, 2015 at 03:17:29PM +0100, Michal Hocko wrote:
> > On Tue 17-03-15 09:29:26, Johannes Weiner wrote:
> > > On Tue, Mar 17, 2015 at 11:25:08AM +0100, Michal Hocko wrote:
> > > > On Mon 16-03-15 17:11:46, Johannes Weiner wrote:
> > > > > A sysctl certainly doesn't sound appropriate to me because this is not
> > > > > a tunable that we expect people to set according to their usecase.  We
> > > > > expect our model to work for *everybody*.  A boot flag would be
> > > > > marginally better but it still reeks too much of tunable.
> > > > 
> > > > I am OK with a boot option as well if the sysctl is considered
> > > > inappropriate. It is less flexible though. Consider a regression testing
> > > > where the same load is run 2 times once with failing allocations and
> > > > once without it. Why should we force the tester to do a reboot cycle?
> > > 
> > > Because we can get rid of the Kconfig more easily once we transitioned.
> > 
> > How? We might be forced to keep the original behavior _for ever_. I do
> > not see any difference between runtime, boottime or compiletime option.
> > Except for the flexibility which is different for each one of course. We
> > can argue about which one is the most appropriate of course but I feel
> > strongly we cannot go and change the semantic right away.
> 
> Sure, why not add another slab allocator while you're at it.  How many
> times do we have to repeat the same mistakes?  If the old model sucks,
> then it needs to be fixed or replaced.  Don't just offer another one
> that sucks in different ways and ask the user to pick their poison,
> with a promise that we might improve the newer model until it's
> suitable to ditch the old one.
> 
> This is nothing more than us failing and giving up trying to actually
> solve our problems.

I probably fail to communicate the primary intention here. The point
of the knob is _not_ to move the responsibility to userspace. Although
I would agree that the knob as proposed might look like that and that is
my fault.

The primary motivation is to actually help _solving_ our long standing
problem. Default non-failing allocations policy is simply wrong and we
should move away from it. We have a way to _explicitly_ request such a
behavior. Are we in agreement on this part?

The problem, as I see it, is that such a change cannot be pushed to
Linus tree without extensive testing because there are thousands of code
paths which never got exercised. We have basically two options here.
Either have a non-upstream patch (e.g. sitting in mmotm and linux-next)
and have developers to do their testing. This will surely help to
catch a lot of fallouts and fix them right away. But we will miss those
who are using Linus based trees and would be willing to help to test
in their loads which we never dreamed of.
The other option would be pushing an experimental code to the Linus
tree (and distribution kernels) and allow people to turn it on to help
testing.

I am not ignoring the rest of the email, I just want to make sure we are
on the same page before we go into a potentially lengthy discussion just
to find out we are talking past each other.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
