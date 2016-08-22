Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEA2B6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:02:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id e7so67949265lfe.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 00:02:53 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id eb3si17178651wjb.247.2016.08.22.00.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 00:02:52 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so11990308wmf.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 00:02:52 -0700 (PDT)
Date: Mon, 22 Aug 2016 09:02:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher
 order requests
Message-ID: <20160822070250.GA13596@dhcp22.suse.cz>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <201608182049.42261.a.miskiewicz@gmail.com>
 <809abac0-961d-9cc1-ce6b-3227ffc791c7@suse.cz>
 <201608212319.51001.a.miskiewicz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201608212319.51001.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arekm@maven.pl
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Sun 21-08-16 23:19:50, Arkadiusz Miskiewicz wrote:
> On Friday 19 of August 2016, Vlastimil Babka wrote:
> > On 08/18/2016 08:49 PM, Arkadiusz Miskiewicz wrote:
> > > On Wednesday 17 of August 2016, Michal Hocko wrote:
> > >> On Wed 17-08-16 10:34:54, Arkadiusz MiA?kiewicz wrote:
> > >> [...]
> > >> 
> > >>> With "[PATCH] mm, oom: report compaction/migration stats for higher
> > >>> order requests" patch:
> > >>> https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160817.txt
> > >>> 
> > >>> Didn't count much - all counters are 0
> > >>> compaction_stall:0 compaction_fail:0 compact_migrate_scanned:0
> > >>> compact_free_scanned:0 compact_isolated:0 pgmigrate_success:0
> > >>> pgmigrate_fail:0
> > >> 
> > >> Dohh, COMPACTION counters are events and those are different than other
> > >> counters we have. They only have per-cpu representation and so we would
> > >> have to do
> > >> +       for_each_online_cpu(cpu) {
> > >> +               struct vm_event_state *this = &per_cpu(vm_event_states,
> > >> cpu); +               ret += this->event[item];
> > >> +       }
> > >> 
> > >> which is really nasty because, strictly speaking, we would have to do
> > >> {get,put}_online_cpus around that loop and that uses locking and we do
> > >> not want to possibly block in this path just because something is in the
> > >> middle of the hotplug. So let's scratch that patch for now and sorry I
> > >> haven't realized that earlier.
> > >> 
> > >>> two processes were killed by OOM (rm and cp), the rest of rm/cp didn't
> > >>> finish
> > >>> 
> > >>> and I'm interrupting it to try that next patch:
> > >>>> Could you try to test with
> > >>>> patch from
> > >>>> http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
> > >>>> please? Ideally on top of linux-next. You can add both the compaction
> > >>>> counters patch in the oom report and high order atomic reserves patch
> > >>>> on top.
> > >>> 
> > >>> Uhm, was going to use it on top of 4.7.[01] first.
> > >> 
> > >> OK
> > > 
> > > So with 
> > > http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE OOM no
> > > longer happens (all 10x rm/cp processes finished).
> > 
> > Is it on top of 4.7 then? 
> 
> Yes, it was on top of 4.7.0.
> 
> > That's a bit different from the other reporter
> > who needed both linux-next and this patch to avoid OOM.
> > In any case the proper solution should restrict this disabled heuristic
> > to highest compaction priority, which needs the patches from linux-next
> > anyway.
> > 
> > So can you please also try linux-next with the patch from
> > http://marc.info/?l=linux-mm&m=147158805719821 ?
> 
> https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160819.txt
> https://ixion.pld-linux.org/~arekm/p2/ext4/log-trace_pipe-20160819.txt.gz
> 
> rm/cp -al x10 succeeded without any OOM
> 
> so the question is - which solution is "the one" for stable/4.7.x ?

I will send an email later today with other people reporting pre-mature
OOMs later today and will make sure you are on the CC list as well.

Thanks for the testing!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
