Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCF246B000D
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:41:42 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y199-v6so1823174wmc.6
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:41:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d12-v6sor1562693wrj.1.2018.10.23.10.41.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 10:41:41 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz> <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
In-Reply-To: <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Tue, 23 Oct 2018 19:41:28 +0200
Message-ID: <CADF2uSrh=sUwKN1WLGzkQ0V=2Fgn0B8TGh7pY-ARJOvYq7Yn1Q@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>

Am Mo., 22. Okt. 2018 um 03:19 Uhr schrieb Marinko Catovic
<marinko.catovic@gmail.com>:
>
> Am Mi., 29. Aug. 2018 um 18:44 Uhr schrieb Marinko Catovic
> <marinko.catovic@gmail.com>:
> >
> >
> >> > one host is at a healthy state right now, I'd run that over there immediately.
> >>
> >> Let's see what we can get from here.
> >
> >
> > oh well, that went fast. actually with having low values for buffers (around 100MB) with caches
> > around 20G or so, the performance was nevertheless super-low, I really had to drop
> > the caches right now. This is the first time I see it with caches >10G happening, but hopefully
> > this also provides a clue for you.
> >
> > Just after starting the stats I reset from previously defer to madvise - I suspect that this somehow
> > caused the rapid reaction, since a few minutes later I saw that the free RAM jumped from 5GB to 10GB,
> > after that I went afk, returning to the pc since my monitoring systems went crazy telling me about downtime.
> >
> > If you think changing /sys/kernel/mm/transparent_hugepage/defrag back to its default, while it was
> > on defer now for days, was a mistake, then please tell me.
> >
> > here you go: https://nofile.io/f/VqRg644AT01/vmstat.tar.gz
> > trace_pipe: https://nofile.io/f/wFShvZScpvn/trace_pipe.gz
> >
>
> There we go again.
>
> First of all, I have set up this monitoring on 1 host, as a matter of
> fact it did not occur on that single
> one for days and weeks now, so I set this up again on all the hosts
> and it just happened again on another one.
>
> This issue is far from over, even when upgrading to the latest 4.18.12
>
> https://nofile.io/f/z2KeNwJSMDj/vmstat-2.zip
> https://nofile.io/f/5ezPUkFWtnx/trace_pipe-2.gz
>
> Please note: the trace_pipe is quite big in size, but it covers a
> full-RAM to unused-RAM within just ~24 hours,
> the measurements were initiated right after echo 3 > drop_caches and
> stopped when the RAM was unused
> aka re-used after another echo 3 in the end.
>
> This issue is alive for about half a year now, any suggestions, hints
> or solutions are greatly appreciated,
> again, I can not possibly be the only one experiencing this, I just
> may be among the few ones who actually
> notice this and are indeed suffering from very poor performance with
> lots of I/O on cache/buffers.
>
> Also, I'd like to ask for a workaround until this is fixed someday:
> echo 3 > drop_caches can take a very
> long time when the host is busy with I/O in the background. According
> to some resources in the net I discovered
> that dropping caches operates until some lower threshold is reached,
> which is less and less likely, when the
> host is really busy. Could one point out what threshold this is perhaps?
> I was thinking of e.g. mm/vmscan.c
>
>  549 void drop_slab_node(int nid)
>  550 {
>  551         unsigned long freed;
>  552
>  553         do {
>  554                 struct mem_cgroup *memcg = NULL;
>  555
>  556                 freed = 0;
>  557                 do {
>  558                         freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
>  559                 } while ((memcg = mem_cgroup_iter(NULL, memcg,
> NULL)) != NULL);
>  560         } while (freed > 10);
>  561 }
>
> ..would it make sense to increase > 10 here with, for example, > 100 ?
> I could easily adjust this, or any other relevant threshold, since I
> am compiling the kernel in use.
>
> I'd just like it to be able to finish dropping caches to achieve the
> workaround here until this issue is fixed,
> which as mentioned, can take hours on a busy host, causing the host to
> hang (having low performance) since
> buffers/caches are not used at that time while drop_caches is being
> set to 3, until that freeing up is finished.

by the way, it seems to happen on the one mentioned host on a daily
basis now, like dropping
to 100M/10G every 24 hours, so it is actually a lot easier now to
capture relevant data/stats, since
it occurs again and again right now.

strangely, other hosts are currently not affected for days.
So if there is anything you need to know, beside the vmstat and
trace_pipe files, please let me know.
