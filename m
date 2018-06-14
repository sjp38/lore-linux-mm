Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10ED36B0006
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 14:34:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c139-v6so5700465qkg.6
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 11:34:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v19-v6si628005qkb.310.2018.06.14.11.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 11:34:12 -0700 (PDT)
Date: Thu, 14 Jun 2018 14:34:06 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180614073153.GB9371@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
References: <1528790608-19557-1-git-send-email-jing.xia@unisoc.com> <20180612212007.GA22717@redhat.com> <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com> <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com>
 <20180614073153.GB9371@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Thu, 14 Jun 2018, Michal Hocko wrote:

> On Thu 14-06-18 15:18:58, jing xia wrote:
> [...]
> > PID: 22920  TASK: ffffffc0120f1a00  CPU: 1   COMMAND: "kworker/u8:2"
> >  #0 [ffffffc0282af3d0] __switch_to at ffffff8008085e48
> >  #1 [ffffffc0282af3f0] __schedule at ffffff8008850cc8
> >  #2 [ffffffc0282af450] schedule at ffffff8008850f4c
> >  #3 [ffffffc0282af470] schedule_timeout at ffffff8008853a0c
> >  #4 [ffffffc0282af520] schedule_timeout_uninterruptible at ffffff8008853aa8
> >  #5 [ffffffc0282af530] wait_iff_congested at ffffff8008181b40
> 
> This trace doesn't provide the full picture unfortunately. Waiting in
> the direct reclaim means that the underlying bdi is congested. The real
> question is why it doesn't flush IO in time.

I pointed this out two years ago and you just refused to fix it:
http://lkml.iu.edu/hypermail/linux/kernel/1608.1/04507.html

I'm sure you'll come up with another creative excuse why GFP_NORETRY 
allocations need incur deliberate 100ms delays in block device drivers.

Mikulas

> >  #6 [ffffffc0282af5b0] shrink_inactive_list at ffffff8008177c80
> >  #7 [ffffffc0282af680] shrink_lruvec at ffffff8008178510
> >  #8 [ffffffc0282af790] mem_cgroup_shrink_node_zone at ffffff80081793bc
> >  #9 [ffffffc0282af840] mem_cgroup_soft_limit_reclaim at ffffff80081b6040
> > #10 [ffffffc0282af8f0] do_try_to_free_pages at ffffff8008178b6c
> > #11 [ffffffc0282af990] try_to_free_pages at ffffff8008178f3c
> > #12 [ffffffc0282afa30] __perform_reclaim at ffffff8008169130
> > #13 [ffffffc0282afab0] __alloc_pages_nodemask at ffffff800816c9b8
> > #14 [ffffffc0282afbd0] __get_free_pages at ffffff800816cd6c
> > #15 [ffffffc0282afbe0] alloc_buffer at ffffff8008591a94
> > #16 [ffffffc0282afc20] __bufio_new at ffffff8008592e94
> > #17 [ffffffc0282afc70] dm_bufio_prefetch at ffffff8008593198
> > #18 [ffffffc0282afd20] verity_prefetch_io at ffffff8008598384
> > #19 [ffffffc0282afd70] process_one_work at ffffff80080b5b3c
> > #20 [ffffffc0282afdc0] worker_thread at ffffff80080b64fc
> > #21 [ffffffc0282afe20] kthread at ffffff80080bae34
> > 
> > > Mikulas
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
