Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id B88B46B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:53:01 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w8so3939094qac.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 12:53:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d88si28293343qgf.124.2015.01.13.12.53.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 12:53:00 -0800 (PST)
Date: Tue, 13 Jan 2015 12:52:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-Id: <20150113125258.0d7d3da2920234fc9461ef69@linux-foundation.org>
In-Reply-To: <20150113155040.GC8180@phnom.home.cmpxchg.org>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
	<1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
	<20150112153716.d54e90c634b70d49e8bb8688@linux-foundation.org>
	<20150113155040.GC8180@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 13 Jan 2015 10:50:40 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, Jan 12, 2015 at 03:37:16PM -0800, Andrew Morton wrote:
> > On Thu,  8 Jan 2015 23:15:04 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > Introduce the basic control files to account, partition, and limit
> > > memory using cgroups in default hierarchy mode.
> > > 
> > > This interface versioning allows us to address fundamental design
> > > issues in the existing memory cgroup interface, further explained
> > > below.  The old interface will be maintained indefinitely, but a
> > > clearer model and improved workload performance should encourage
> > > existing users to switch over to the new one eventually.
> > > 
> > > The control files are thus:
> > > 
> > >   - memory.current shows the current consumption of the cgroup and its
> > >     descendants, in bytes.
> > > 
> > >   - memory.low configures the lower end of the cgroup's expected
> > >     memory consumption range.  The kernel considers memory below that
> > >     boundary to be a reserve - the minimum that the workload needs in
> > >     order to make forward progress - and generally avoids reclaiming
> > >     it, unless there is an imminent risk of entering an OOM situation.
> > 
> > The code appears to be ascribing a special meaning to low==0: you can
> > write "none" to set this.  But I'm not seeing any description of this?
> 
> Ah, yes.
> 
> The memory.limit_in_bytes and memory.soft_limit_in_bytes currently
> show 18446744073709551615 per default, which is a silly way of saying
> "this limit is inactive".  And echoing -1 into the control file is an
> even sillier way of setting this state.  So the new interface just
> calls this state "none".  Internally, 0 and Very High Number represent
> this unconfigured state for memory.low and memory.high, respectively.
> 
> I added a bullet point at the end of the changelog below.

Added, thanks.

> > This all sounds pretty major.  How much trouble is this change likely to
> > cause existing memcg users?
> 
> That is actually entirely up to the user in question.
> 
> 1. The old cgroup interface remains in place as long as there are
> users, so, technically, nothing has to change unless they want to.

It would be good to zap the old interface one day.  Maybe we won't ever
be able to, but we should try.  Once this has all settled down and is
documented, how about we add a couple of printk_once's to poke people
in the new direction?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
