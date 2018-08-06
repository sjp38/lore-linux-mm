Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5486B0266
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 08:00:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t24-v6so1914428edq.13
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 05:00:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w33-v6si11138250edd.30.2018.08.06.05.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 05:00:43 -0700 (PDT)
Date: Mon, 6 Aug 2018 14:00:42 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180806120042.GL19540@dhcp22.suse.cz>
References: <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz>
 <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
 <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
 <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
 <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

[Please do not top-post]

On Mon 06-08-18 12:29:43, Marinko Catovic wrote:
> > Maybe a memcg with kmemcg limit? Michal could know more.
> 
> Could you/Michael explain this perhaps?

The only way how kmemcg limit could help I can think of would be to
enforce metadata reclaim much more often. But that is rather a bad
workaround.

> The hardware is pretty much high end datacenter grade, I really would
> not know how this is to be related with the hardware :(

Well, there are some drivers (mostly out-of-tree) which are high order
hungry. You can try to trace all allocations which with order > 0 and
see who that might be.
# mount -t tracefs none /debug/trace/
# echo stacktrace > /debug/trace/trace_options
# echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
# echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
# cat /debug/trace/trace_pipe

And later this to disable tracing.
# echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable

> I do not understand why apparently the caching is working very much
> fine for the beginning after a drop_caches, then degrades to low usage
> somewhat later.

Because a lot of FS metadata is fragmenting the memory and a large
number of high order allocations which want to be served reclaim a lot
of memory to achieve their gol. Considering a large part of memory is
fragmented by unmovable objects there is no other way than to use
reclaim to release that memory.

> I can not possibly drop caches automatically, since
> this requires monitoring for overload with temporary dropping traffic
> on specific ports until the writes/reads cool down.

You do not have to drop all caches. echo 2 > /proc/sys/vm/drop_caches
should be sufficient to drop metadata only.
-- 
Michal Hocko
SUSE Labs
