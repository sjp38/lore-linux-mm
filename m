Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8D26B0261
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:29:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so186017wmu.3
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:29:12 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id p71si24726774wmf.51.2016.08.17.02.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 02:29:11 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so22017252wma.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:29:11 -0700 (PDT)
Date: Wed, 17 Aug 2016 11:29:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher
 order requests
Message-ID: <20160817092909.GA20703@dhcp22.suse.cz>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <201608161318.25412.a.miskiewicz@gmail.com>
 <20160816141007.GF17417@dhcp22.suse.cz>
 <201608171034.54940.arekm@maven.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201608171034.54940.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Wed 17-08-16 10:34:54, Arkadiusz MiA?kiewicz wrote:
[...]
> With "[PATCH] mm, oom: report compaction/migration stats for higher order 
> requests" patch:
> https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160817.txt
> 
> Didn't count much - all counters are 0
> compaction_stall:0 compaction_fail:0 compact_migrate_scanned:0 
> compact_free_scanned:0 compact_isolated:0 pgmigrate_success:0 pgmigrate_fail:0

Dohh, COMPACTION counters are events and those are different than other
counters we have. They only have per-cpu representation and so we would
have to do 
+       for_each_online_cpu(cpu) {
+               struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
+               ret += this->event[item];
+       }

which is really nasty because, strictly speaking, we would have to do
{get,put}_online_cpus around that loop and that uses locking and we do
not want to possibly block in this path just because something is in the
middle of the hotplug. So let's scratch that patch for now and sorry I
haven't realized that earlier.
 
> two processes were killed by OOM (rm and cp), the rest of rm/cp didn't finish 
> and I'm interrupting it to try that next patch:
> 
> > Could you try to test with
> > patch from
> > http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE please?
> > Ideally on top of linux-next. You can add both the compaction counters
> > patch in the oom report and high order atomic reserves patch on top.
> 
> Uhm, was going to use it on top of 4.7.[01] first.

OK
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
