Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA816B02DA
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:02:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26-v6so236393eda.7
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 01:02:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14-v6si1886928edf.70.2018.10.26.01.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 01:02:31 -0700 (PDT)
Date: Fri, 26 Oct 2018 10:01:37 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20181026080019.GX18839@dhcp22.suse.cz>
References: <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>

Sorry for late reply. Busy as always...

On Mon 22-10-18 03:19:57, Marinko Catovic wrote:
[...]
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

I cannot download these. I am getting an invalid certificate and
403 when ignoring it

[...]

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

This is worth a separate discussion. Please start a new email thread.

-- 
Michal Hocko
SUSE Labs
