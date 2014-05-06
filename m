Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB8F82963
	for <linux-mm@kvack.org>; Tue,  6 May 2014 10:32:46 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so5326802eek.35
        for <linux-mm@kvack.org>; Tue, 06 May 2014 07:32:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s46si13573175eeg.135.2014.05.06.07.32.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 07:32:45 -0700 (PDT)
Date: Tue, 6 May 2014 16:32:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140506143242.GB19672@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
 <20140506132932.GF19914@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140506132932.GF19914@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 06-05-14 09:29:32, Johannes Weiner wrote:
> On Fri, May 02, 2014 at 06:00:56PM -0400, Johannes Weiner wrote:
> > On Fri, May 02, 2014 at 06:49:30PM +0200, Michal Hocko wrote:
> > > On Fri 02-05-14 11:58:05, Johannes Weiner wrote:
> > > > This is not even guarantees anymore, but rather another reclaim
> > > > prioritization scheme with best-effort semantics.  That went over
> > > > horribly with soft limits, and I don't want to repeat this.
> > > > 
> > > > Overcommitting on guarantees makes no sense, and you even agree you
> > > > are not interested in it.  We also agree that we can always add a knob
> > > > later on to change semantics when an actual usecase presents itself,
> > > > so why not start with the clear and simple semantics, and the simpler
> > > > implementation?
> > > 
> > > So you are really preferring an OOM instead? That was the original
> > > implementation posted at the end of last year and some people
> > > had concerns about it. This is the primary reason I came up with a
> > > weaker version which fallbacks rather than OOM.
> > 
> > I'll dig through the archives on this then, thanks.
> 
> The most recent discussion on this I could find was between you and
> Greg, where the final outcome was (excerpt):
> 
> ---
> 
> From: Greg Thelen <gthelen@google.com>
> To: Michal Hocko <mhocko@suse.cz>
> Cc: linux-mm@kvack.org,  Johannes Weiner <hannes@cmpxchg.org>,  Andrew Morton <akpm@linux-foundation.org>,  KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,  LKML <linux-kernel@vger.kernel.org>,  Ying Han <yinghan@google.com>,  Hugh Dickins <hughd@google.com>,  Michel Lespinasse <walken@google.com>,  KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,  Tejun Heo <tj@kernel.org>
> Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
> References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
> 	<xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
> 	<20140130123044.GB13509@dhcp22.suse.cz>
> 	<xr931tzphu50.fsf@gthelen.mtv.corp.google.com>
> 	<20140203144341.GI2495@dhcp22.suse.cz>
> Date: Mon, 03 Feb 2014 17:33:13 -0800
> Message-ID: <xr93zjm7br1i.fsf@gthelen.mtv.corp.google.com>
> List-ID: <linux-mm.kvack.org>
> 
> On Mon, Feb 03 2014, Michal Hocko wrote:
> 
> > On Thu 30-01-14 16:28:27, Greg Thelen wrote:
> >> But this soft_limit,priority extension can be added later.
> >
> > Yes, I would like to have the strong semantic first and then deal with a
> > weaker form. Either by a new limit or a flag.
> 
> Sounds good.
> 
> ---
> 
> So I think everybody involved in the discussions so far are preferring
> a hard guarantee, and then later, if needed, to either add a knob to
> make it a soft guarantee or to actually implement a usable soft limit.

I am afraid the most of that discussion happened off-list :( Sadly not
much of a discussion happened on the list.
Sorry I should have been specific and mention that the discussions
happened at LSF and partly at the KS.

The strongest point was made by Rik when he claimed that memcg is not
aware of memory zones and so one memcg with lowlimit larger than the
size of a zone can eat up that zone without any way to free it. This
can cause additional troubles (permanent reclaim on that zone and OOM in
an extreme situations).

That convinced me that having the default oom semantic from the very
beginning is too much and starting with something more relaxed (fallback
rather than oom), but still usable, is a better choice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
