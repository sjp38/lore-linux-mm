Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C98C6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 03:31:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so2276425wmi.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 00:31:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x125si1925150wmd.163.2017.01.06.00.31.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 00:31:27 -0800 (PST)
Date: Fri, 6 Jan 2017 09:31:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 190351] New: OOM but no swap used
Message-ID: <20170106083125.GC5556@dhcp22.suse.cz>
References: <bug-190351-27@https.bugzilla.kernel.org/>
 <20170105114611.8b0fa5d3ec779e8a71b3973c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105114611.8b0fa5d3ec779e8a71b3973c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, rtc@helen.plasma.xg8.de

On Thu 05-01-17 11:46:11, Andrew Morton wrote:
[...]
> > Since upgrading from kernel-PAE 4.5.3 on fedora 24 to kernel-PAE 4.8.10 on
> > fedora 25, I get OOM when I run my daily rsync for backup. I upgraded to
> > kernel-PAE-4.9.0-1.fc26.i686 and the problem still occurs. The OOM occurs
> > although the system doesn't use any swap and memory is not used up either.
> > 
> > See https://bugzilla.redhat.com/show_bug.cgi?id=1401012
> > 
> > Here is the dmesg from today:
> > 
> > [32863.748720] gpg-agent invoked oom-killer:
> > gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=0, order=1,  oom_score_adj=0

this is a lowmem request

[...]
> > [32863.748789] active_anon:122505 inactive_anon:129240 isolated_anon:0
> >                 active_file:174922 inactive_file:371696 isolated_file:64
> >                 unevictable:8 dirty:0 writeback:0 unstable:0
> >                 slab_reclaimable:186174 slab_unreclaimable:17717
> >                 mapped:69769 shmem:11168 pagetables:2174 bounce:0
> >                 free:13565 free_pcp:660 free_cma:0

there is a lot of page cache and anonymous memory but...

> > [32863.748792] Node 0 active_anon:490020kB inactive_anon:516960kB
> > active_file:699688kB inactive_file:1486784kB unevictable:32kB
> > isolated(anon):0kB isolated(file):256kB mapped:279076kB dirty:0kB writeback:0kB
> > shmem:44672kB writeback_tmp:0kB unstable:0kB pages_scanned:9963129
> > all_unreclaimable? yes
> > [32863.748795] DMA free:3260kB min:68kB low:84kB high:100kB active_anon:0kB
> > inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> > writepending:0kB present:15992kB managed:15916kB mlocked:0kB
> > slab_reclaimable:12460kB slab_unreclaimable:132kB kernel_stack:64kB
> > pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> > [32863.748796] lowmem_reserve[]: 0 798 4005 4005
> > [32863.748801] Normal free:3880kB min:3580kB low:4472kB high:5364kB
> > active_anon:0kB inactive_anon:0kB active_file:1220kB inactive_file:68kB
> > unevictable:0kB writepending:0kB present:892920kB managed:830896kB mlocked:0kB

no anonymous memory is from eligible zones. There is some pagecache but
1.2MB doesn't sound all that much. There is a known regression from 4.8
when the active list aging is broken with memcg enabled but I am not
sure this would make much of a difference here. You can try
http://lkml.kernel.org/r/20170104100825.3729-1-mhocko@kernel.org
but it seems that the problem you are seeing is really the lowmem
depletion which is hard to come around with 32b kernels.

> > slab_reclaimable:732236kB slab_unreclaimable:70736kB kernel_stack:2560kB

slab consumption is really high. It has eaten a majority of the lowmem.
I would focus on who is eating that memory. Try to watch /proc/slabinfo
for anomalies.

> > pagetables:0kB bounce:0kB free_pcp:1252kB local_pcp:624kB free_cma:0kB

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
