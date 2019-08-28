Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34AA6C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB44D2080F
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB44D2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DA426B0008; Wed, 28 Aug 2019 03:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48B026B000C; Wed, 28 Aug 2019 03:00:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A1C06B000D; Wed, 28 Aug 2019 03:00:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 196136B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:00:00 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C614987DA
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:59:59 +0000 (UTC)
X-FDA: 75870936918.07.look97_573901039cd38
X-HE-Tag: look97_573901039cd38
X-Filterd-Recvd-Size: 8105
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:59:59 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ECFBCAD3B;
	Wed, 28 Aug 2019 06:59:56 +0000 (UTC)
Date: Wed, 28 Aug 2019 08:59:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190828065955.GB7386@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
 <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 18:07:54, Edward Chron wrote:
> On Tue, Aug 27, 2019 at 12:15 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 26-08-19 12:36:28, Edward Chron wrote:
> > [...]
> > > Extensibility using OOM debug options
> > > -------------------------------------
> > > What is needed is an extensible system to optionally configure
> > > debug options as needed and to then dynamically enable and disable
> > > them. Also for options that produce multiple lines of entry based
> > > output, to configure which entries to print based on how much
> > > memory they use (or optionally all the entries).
> >
> > With a patch this large and adding a lot of new stuff we need a more
> > detailed usecases described I believe.
> 
> I guess it would make sense to explain motivation for each OOM Debug
> option I've sent separately.
> I see there comments on the patches I will try and add more information there.
> 
> An overview would be that we've been collecting information on OOM's
> over the last 12 years or so.
> These are from switches, other embedded devices, servers both large and small.
> We ask for feedback on what information was helpful or could be helpful.
> We try and add it to make root causing issues easier.
> 
> These OOM debug options are some of the options we've created.
> I didn't port all of them to 5.3 but these are representative.
> Our latest is kernel is a bit behind 5.3.
> 
> >
> >
> > [...]
> >
> > > Use of debugfs to allow dynamic controls
> > > ----------------------------------------
> > > By providing a debugfs interface that allows options to be configured,
> > > enabled and where appropriate to set a minimum size for selecting
> > > entries to print, the output produced when an OOM event occurs can be
> > > dynamically adjusted to produce as little or as much detail as needed
> > > for a given system.
> >
> > Who is going to consume this information and why would that consumer be
> > unreasonable to demand further maintenance of that information in future
> > releases? In other words debugfs is not considered a stableAPI which is
> > OK here but the side effect of any change to these files results in user
> > visible behavior and we consider that more or less a stable as long as
> > there are consumers.
> >
> > > OOM debug options can be added to the base code as needed.
> > >
> > > Currently we have the following OOM debug options defined:
> > >
> > > * System State Summary
> > >   --------------------
> > >   One line of output that includes:
> > >   - Uptime (days, hour, minutes, seconds)
> >
> > We do have timestamps in the log so why is this needed?
> 
> 
> Here is how an OOM report looks when we get it to look at:
> 
> Aug 26 09:06:34 coronado kernel: oomprocs invoked oom-killer:
> gfp_mask=0x100dca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0,
> oom_score_adj=1000
> Aug 26 09:06:34 coronado kernel: CPU: 1 PID: 2795 Comm: oomprocs Not
> tainted 5.3.0-rc6+ #33
> Aug 26 09:06:34 coronado kernel: Hardware name: Compulab Ltd.
> IPC3/IPC3, BIOS 5.12_IPC3K.PRD.0.25.7 08/09/2018
> 
> This shows the date and time, not time of the last boot. The
> /var/log/messages output is what we often have to look at not raw
> dmesgs.

This looks more like a configuration of the logging than a kernel
problem. Kernel does provide timestamps for logs. E.g.
$ tail -n1 /var/log/kern.log
Aug 28 08:27:46 tiehlicka kernel: <1054>[336340.954345] systemd-udevd[7971]: link_config: autonegotiation is unset or enabled, the speed and duplex are not writable.

[...]
> > >   Example output when configured and enabled:
> > >
> > > Jul 22 15:20:57 yoursystem kernel: Threads:530 Processes:279 forks_since_boot:2786 procs_runable:2 procs_iowait:0
> > >
> > > * ARP Table and/or Neighbour Discovery Table Summary
> > >   --------------------------------------------------
> > >   One line of output each for ARP and ND that includes:
> > >   - Table name
> > >   - Table size (max # entries)
> > >   - Key Length
> > >   - Entry Size
> > >   - Number of Entries
> > >   - Last Flush (in seconds)
> > >   - hash grows
> > >   - entry allocations
> > >   - entry destroys
> > >   - Number lookups
> > >   - Number of lookup hits
> > >   - Resolution failures
> > >   - Garbage Collection Forced Runs
> > >   - Table Full
> > >   - Proxy Queue Length
> > >
> > >   Example output when configured and enabled (for both):
> > >
> > > ... kernel: neighbour: Table: arp_tbl size:   256 keyLen:  4 entrySize: 360 entries:     9 lastFlush:  1721s hGrows:     1 allocs:     9 destroys:     0 lookups:   204 hits:   199 resFailed:    38 gcRuns/Forced: 111 /  0 tblFull:  0 proxyQlen:  0
> > >
> > > ... kernel: neighbour: Table:  nd_tbl size:   128 keyLen: 16 entrySize: 368 entries:     6 lastFlush:  1720s hGrows:     0 allocs:     7 destroys:     1 lookups:     0 hits:     0 resFailed:     0 gcRuns/Forced: 110 /  0 tblFull:  0 proxyQlen:  0
> >
> > Again, why is this needed particularly for the OOM event? I do
> > understand this might be useful system health diagnostic information but
> > how does this contribute to the OOM?
> >
> 
> It is example of some system table information we print.
> Other adjustable table information may be useful as well.
> These table sizes are often adjustable and collecting stats on usage
> helps determine if settings are appropriate.
> The value during OOM events is very useful as usage varies.
> We also collect the same stats like this from user code periodically
> and can compare these.

I suspect that this is a very narrow usecase and there are more like
that and I can imagine somebody with a different workload could come up
with yet another set of useful information to print. The more I think of these
additional modules the more I am convinced that this "plugin" architecture
is a wrong approach. Why? Mostly because all the code maintenance burden
is likely to be not worth all the niche usecase. This all has to be more
dynamic and ideally scriptable so that the code in the kernel just
provides the basic information and everybody can just hook in there and
dump whatever additional information is needed. Sounds like something
that eBPF could fit in, no? Have you considered that?

[...]

Skipping over many useful stuff. I can reassure you that my experience
with OOM debugging has been a real pain at times (e.g. when there is
simply no way to find out who has eaten all the memory because it is not
accounted anywhere) as well and I completely understand where you are
coming from. There is definitely a room for improvements we just have to
find a way how to get there.

Thanks!
-- 
Michal Hocko
SUSE Labs

