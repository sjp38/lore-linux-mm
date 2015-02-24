Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3EA6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 17:31:21 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so37987ieb.7
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:31:21 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id w16si12590919icc.90.2015.02.24.14.31.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 14:31:20 -0800 (PST)
Received: by iebtr6 with SMTP id tr6so37944ieb.7
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:31:20 -0800 (PST)
Date: Tue, 24 Feb 2015 14:31:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
In-Reply-To: <CALYGNiON2d9qLjov2B-kw1FmLfdNGwPKTWBqWBpC8Nf82d5oTQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1502241428250.11324@chino.kir.corp.google.com>
References: <20150220143942.19568.4548.stgit@buzz> <alpine.DEB.2.10.1502241239100.3855@chino.kir.corp.google.com> <CALYGNiON2d9qLjov2B-kw1FmLfdNGwPKTWBqWBpC8Nf82d5oTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 25 Feb 2015, Konstantin Khlebnikov wrote:

> >> @@ -3220,11 +3229,10 @@ void show_free_areas(unsigned int filter)
> >>
> >>       printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> >>               " active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> >> -             " unevictable:%lu"
> >> -             " dirty:%lu writeback:%lu unstable:%lu\n"
> >> -             " free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> >> +             " unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> >> +             " slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> >>               " mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> >> -             " free_cma:%lu\n",
> >> +             " free:%lu free_pcp:%lu free_cma:%lu\n",
> >
> > Why is "free:" itself moved?  It is unlikely, but I could imagine that
> > this might break something that is parsing the kernel log and it would be
> > better to just leave it where it is and add "free_pcp:" after "free_cma:"
> > since this is extending the message.
> 
> I think it looks better at the beginning of new line, like this:
> 
> [   44.452955] Mem-Info:
> [   44.453233] active_anon:2307 inactive_anon:36 isolated_anon:0
> [   44.453233]  active_file:4120 inactive_file:4623 isolated_file:0
> [   44.453233]  unevictable:0 dirty:6 writeback:0 unstable:0
> [   44.453233]  slab_reclaimable:3500 slab_unreclaimable:7441
> [   44.453233]  mapped:2113 shmem:45 pagetables:292 bounce:0
> [   44.453233]  free:456891 free_pcp:12179 free_cma:0
> 
> In this order fields at each line have something in common.
> 
> I'll spend some some time playing with this code and oom log,
> maybe I'll try to turn whole output into table or something.
> 

The problem is that oom logs are usually parsed only from the kernel log, 
there's no other userspace trigger that we can use to identify when the 
kernel has killed something unless we wait() on every possible victim.  
It's typical for systems software to parse this information and unless 
there is a compelling reason other than "looks better", I think messages 
should only be extended rather than rearranged.

Admittedly, scraping the kernel log for oom kill events could certainly be 
done better with a userspace notification, but we currently lack that 
support in the kernel and there might be parsers out there in the wild 
that would break because of this.  I agree removing the pcp counters is 
good for this output, though, so I'd love to see that patch without this 
change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
