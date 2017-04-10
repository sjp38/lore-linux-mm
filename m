Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C52476B03A1
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:13:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 63so3023015wmr.15
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:13:41 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a76si7154717wmi.45.2017.04.10.07.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 07:13:39 -0700 (PDT)
Date: Mon, 10 Apr 2017 10:13:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: re-use global VM event enum
Message-ID: <20170410141334.GA16119@cmpxchg.org>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
 <20170404220148.28338-2-hannes@cmpxchg.org>
 <20170407124702.GE16413@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407124702.GE16413@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Apr 07, 2017 at 02:47:02PM +0200, Michal Hocko wrote:
> I do agree that we should share global and memcg specific events constants
> but I am not sure we want to share all of them. Would it make sense to
> reorganize the global enum and put those that are shared to the
> beginning? We wouldn't need the memcg specific translation then.

I'm not sure I follow. Which translation?

> Anyway, two comments on the current implementation.
> 
> On Tue 04-04-17 18:01:46, Johannes Weiner wrote:
> [...]
> > +/* Cgroup-specific events, on top of universal VM events */
> > +enum memcg_event_item {
> > +	MEMCG_LOW = NR_VM_EVENT_ITEMS,
> > +	MEMCG_HIGH,
> > +	MEMCG_MAX,
> > +	MEMCG_OOM,
> > +	MEMCG_NR_EVENTS,
> > +};
> 
> The above should mention that each supported global VM event should
> provide the corresponding translation
> 
> [...]
> 
> here...
> > +/* Universal VM events cgroup1 shows, original sort order */
> > +unsigned int memcg1_events[] = {
> > +	PGPGIN,
> > +	PGPGOUT,
> > +	PGFAULT,
> > +	PGMAJFAULT,
> > +};
> > +
> > +static const char *const memcg1_event_names[] = {
> > +	"pgpgin",
> > +	"pgpgout",
> > +	"pgfault",
> > +	"pgmajfault",
> > +};
> 
> the naming doesn't make it easier to undestand why we need this.
> global2memcg_event?

This is just to keep the file order consistent. It could have been
done like memory.stat in cgroup2, where we simply do

   seq_printf(s, "pgmajfault %lu\n", stat[PGMAJFAULT]);

but I didn't want to change the v1 code too much. So these two arrays
are just a sorted list of global VM events shown in v1's memory.stat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
