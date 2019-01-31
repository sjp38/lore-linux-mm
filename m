Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B30CC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E6C020881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FIiOaO9e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E6C020881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963EF8E0002; Wed, 30 Jan 2019 20:33:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 915618E0001; Wed, 30 Jan 2019 20:33:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82A378E0002; Wed, 30 Jan 2019 20:33:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 559E08E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:33:15 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id w128so752931oie.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:33:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=moC74vQmEJ3d13MbIuiMkLO8lGMcf3VTQM3VO7orQ6Q=;
        b=Hq8Eqd4pyXTAfYikZqp/O+NUEM11YhUMvI5Gw7qAC9g8IlXO/M+GruK0pGEgf7GVFb
         /6vlmBBWhIvJQoixgWz7QxbZ0XfyWag4poirhgY91kJeNnv5+r1BDvt8pKJuDB+ZW/j9
         u3425XNx9uTQFTsQwG9JFnqJtOLv7IEHRxkBuYG53vI4iCK3v3/J9zjDMc1FQ4n/uzeL
         Yx5MbsuWPysNSUBRzpuq3ERPdb1zKuWRyYNPs3qrj/t7dgesnJaPCcUnutqdHVZnPBWy
         yhtjgY/XfCFZeden/jhB8vcnfJb45JGxJIo9SGq1EqPuLnsv6+C8JiCu09ivPWy01hHy
         45Sg==
X-Gm-Message-State: AJcUukfFdNL1YmNw4IOFrykYkb6NqLHpC7IjsdMxVFG1CAQMJlSW2heM
	2KAWJZH8P8NsnPq040hDite1/HnSXAsUzgCdENLSjjf+i2ubiDPYTXj9IFjyMoQhsYF86fmn1nq
	ID8ji4MmX2mCeV+Op848ARX/HKvD0vxvFIl6sfJPJuC1w4Uul8W990lO/NGKuLD3RP1feCp2uwW
	siviYXNUmFbxvbLqdDq4fjDw3vFRP2F4kHBP9tT0as/Oxy2EzZB9Jj1y5h4a2wBd5BlM3mnbFkr
	AIJ06N0nxhtuqmxMwWQy8MsspX6X0iH5UWlb+6g2zIdMbJapqlTq2JbuoSnDew5Bpp4GSyTikqp
	W+QTFf/1BH/ZwjjZ1tAyOdBpeYlYuSUSHDspjfM05OXGqOv0uUhtSPZ2yjTJYqgSFeetJ4ivEGT
	c
X-Received: by 2002:aca:af53:: with SMTP id y80mr14262758oie.170.1548898394937;
        Wed, 30 Jan 2019 17:33:14 -0800 (PST)
X-Received: by 2002:aca:af53:: with SMTP id y80mr14262718oie.170.1548898393701;
        Wed, 30 Jan 2019 17:33:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548898393; cv=none;
        d=google.com; s=arc-20160816;
        b=cB9sOyla1//Nj/8H1/cas+YOv11usJDIE38rI2awKjlcI5ElQGJ99aszUCbIzNpayx
         YkNCWENOB7K2HauUhB7VzwWx15RcLNPOCWQfg0n5NMtDcHwaRl6GzfOLre09aXr7yhDE
         iDkGxfRk4LxdDNO3zQQeLlyID08sIsiFJaYI0oeYcUcW1Emzjr6Z+qM4o6BA4apUDduP
         QWR/23wWNI0mcYSSlqP6+90pmAvYrtKmWiHn9RKZFoM0GQB+GKWUzFO2+0pHGyc5vSVZ
         rJOvEaZtewE7qCB0+RQFp+EutCFU00BC8W2MljXoeK/BF5AqY52gzAz7Vo0CKtaQSFsI
         Q3zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=moC74vQmEJ3d13MbIuiMkLO8lGMcf3VTQM3VO7orQ6Q=;
        b=QHyGk5bpLhikzsEuqzg9bD6Fl0Ppc2OIc17lxUI5KRkyIC9Lcr+M8RL9ytG9N8lflO
         v9N4fQA4VVdW6sk+C4+j0tN923CCv83SvSkWnX1dCzgQrey7C4rfhn3izrGYSHaoLQLd
         Y4W8Sgz94qH6F2/K3lholX6eLGCn3BbNN5LnSuwWXkR8spNHs2XTmqKGIZnRgARvARSK
         xF3fEMgLuHmmpVCf9c1Kic6qjByAP5fKWwpE1rqu0l/sTFC4QD62KzLmiboHt44PKcvc
         byTzy+gPfaSTehiPkbXXQ5LpmEjjeCJQugPLo4faJzYlLzyEJ+KybUqbsT5p5fJVdrvA
         lnWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FIiOaO9e;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor1626805otu.127.2019.01.30.17.33.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 17:33:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FIiOaO9e;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=moC74vQmEJ3d13MbIuiMkLO8lGMcf3VTQM3VO7orQ6Q=;
        b=FIiOaO9elsrSyDQ4ta84tW0vC+Nr9BD24+u47VzdKjgSf939xVmVGpq+9/fiHgxMin
         h4sHyCA1HOHIt+gUyRQgMeU9B67/JYmrFbDr8jvWQ/xs5Tby6wv4+FcF4kmvVTsx2OlP
         +Dg7IkZVczqf1KMfpVbT+UgGgeyQI48oPK+WAoGS7toWwz9yKvk5wHYMEY444IFyZe/m
         YQIWNDhALD5JilqRqtgQE0L/oVhVNDk8sd2SrsnEQMMqlzvp7ck7q0176IF4iQYX1Eun
         uF0XR8UwN6JkSHtttVox/g76pBMm38CUJHB8S1/b/fnG0IrPs8eE4OJYhPLNh9WygFeg
         NOSg==
X-Google-Smtp-Source: ALg8bN6P0P3N91WpZoh6gxZqsmeVGAKjJE5WQ1MApbhk0Gkn687AkstDHkeYwUL0Fct9i095nodZB7FZ8VX6Wb1DgFA=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr22998793otn.95.1548898392781;
 Wed, 30 Jan 2019 17:33:12 -0800 (PST)
MIME-Version: 1.0
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190130190838.GG18811@dhcp22.suse.cz>
In-Reply-To: <20190130190838.GG18811@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 17:33:01 -0800
Message-ID: <CAPcyv4jbQepv-a3Y9mBXs_MmkUBFnY0BJrmS7czjKMBVAi53OQ@mail.gmail.com>
Subject: Re: [PATCH v9 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:08 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 29-01-19 21:02:16, Dan Williams wrote:
> > Randomization of the page allocator improves the average utilization of
> > a direct-mapped memory-side-cache. Memory side caching is a platform
> > capability that Linux has been previously exposed to in HPC
> > (high-performance computing) environments on specialty platforms. In
> > that instance it was a smaller pool of high-bandwidth-memory relative to
> > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > be found on general purpose server platforms where DRAM is a cache in
> > front of higher latency persistent memory [1].
> >
> > Robert offered an explanation of the state of the art of Linux
> > interactions with memory-side-caches [2], and I copy it here:
> >
> >     It's been a problem in the HPC space:
> >     http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/
> >
> >     A kernel module called zonesort is available to try to help:
> >     https://software.intel.com/en-us/articles/xeon-phi-software
> >
> >     and this abandoned patch series proposed that for the kernel:
> >     https://lkml.kernel.org/r/20170823100205.17311-1-lukasz.daniluk@intel.com
> >
> >     Dan's patch series doesn't attempt to ensure buffers won't conflict, but
> >     also reduces the chance that the buffers will. This will make performance
> >     more consistent, albeit slower than "optimal" (which is near impossible
> >     to attain in a general-purpose kernel).  That's better than forcing
> >     users to deploy remedies like:
> >         "To eliminate this gradual degradation, we have added a Stream
> >          measurement to the Node Health Check that follows each job;
> >          nodes are rebooted whenever their measured memory bandwidth
> >          falls below 300 GB/s."
> >
> > A replacement for zonesort was merged upstream in commit cc9aec03e58f
> > "x86/numa_emulation: Introduce uniform split capability". With this
> > numa_emulation capability, memory can be split into cache sized
> > ("near-memory" sized) numa nodes. A bind operation to such a node, and
> > disabling workloads on other nodes, enables full cache performance.
> > However, once the workload exceeds the cache size then cache conflicts
> > are unavoidable. While HPC environments might be able to tolerate
> > time-scheduling of cache sized workloads, for general purpose server
> > platforms, the oversubscribed cache case will be the common case.
> >
> > The worst case scenario is that a server system owner benchmarks a
> > workload at boot with an un-contended cache only to see that performance
> > degrade over time, even below the average cache performance due to
> > excessive conflicts. Randomization clips the peaks and fills in the
> > valleys of cache utilization to yield steady average performance.
> >
> > Here are some performance impact details of the patches:
> >
> > 1/ An Intel internal synthetic memory bandwidth measurement tool, saw a
> > 3X speedup in a contrived case that tries to force cache conflicts. The
> > contrived cased used the numa_emulation capability to force an instance
> > of the benchmark to be run in two of the near-memory sized numa nodes.
> > If both instances were placed on the same emulated they would fit and
> > cause zero conflicts.  While on separate emulated nodes without
> > randomization they underutilized the cache and conflicted unnecessarily
> > due to the in-order allocation per node.
> >
> > 2/ A well known Java server application benchmark was run with a heap
> > size that exceeded cache size by 3X. The cache conflict rate was 8% for
> > the first run and degraded to 21% after page allocator aging. With
> > randomization enabled the rate levelled out at 11%.
> >
> > 3/ A MongoDB workload did not observe measurable difference in
> > cache-conflict rates, but the overall throughput dropped by 7% with
> > randomization in one case.
> >
> > 4/ Mel Gorman ran his suite of performance workloads with randomization
> > enabled on platforms without a memory-side-cache and saw a mix of some
> > improvements and some losses [3].
> >
> > While there is potentially significant improvement for applications that
> > depend on low latency access across a wide working-set, the performance
> > may be negligible to negative for other workloads. For this reason the
> > shuffle capability defaults to off unless a direct-mapped
> > memory-side-cache is detected. Even then, the page_alloc.shuffle=0
> > parameter can be specified to disable the randomization on those
> > systems.
> >
> > Outside of memory-side-cache utilization concerns there is potentially
> > security benefit from randomization. Some data exfiltration and
> > return-oriented-programming attacks rely on the ability to infer the
> > location of sensitive data objects. The kernel page allocator,
> > especially early in system boot, has predictable first-in-first out
> > behavior for physical pages. Pages are freed in physical address order
> > when first onlined.
> >
> > Quoting Kees:
> >     "While we already have a base-address randomization
> >      (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
> >      memory layouts would certainly be using the predictability of
> >      allocation ordering (i.e. for attacks where the base address isn't
> >      important: only the relative positions between allocated memory).
> >      This is common in lots of heap-style attacks. They try to gain
> >      control over ordering by spraying allocations, etc.
> >
> >      I'd really like to see this because it gives us something similar
> >      to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."
> >
> > While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> > caches it leaves vast bulk of memory to be predictably in order
> > allocated.  However, it should be noted, the concrete security benefits
> > are hard to quantify, and no known CVE is mitigated by this
> > randomization.
> >
> > Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> > perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> > when they are initially populated with free memory at boot and at
> > hotplug time. Do this based on either the presence of a
> > page_alloc.shuffle=Y command line parameter, or autodetection of a
> > memory-side-cache (to be added in a follow-on patch).
> >
> > The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> > pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> > 10, 4MB this trades off randomization granularity for time spent
> > shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> > allocator while still showing memory-side cache behavior improvements,
> > and the expectation that the security implications of finer granularity
> > randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
> >
> > The performance impact of the shuffling appears to be in the noise
> > compared to other memory initialization work. Also the bulk of the work
> > is done in the background as a part of deferred_init_memmap().
>
> The last part is not true with this version anymore, right?

True, and given that page_alloc_init_late() is waiting for it complete
the impact is no different from v8 to v9. I'll drop that sentence from
the changelog.

>
> > This initial randomization can be undone over time so a follow-on patch
> > is introduced to inject entropy on page free decisions. It is reasonable
> > to ask if the page free entropy is sufficient, but it is not enough due
> > to the in-order initial freeing of pages. At the start of that process
> > putting page1 in front or behind page0 still keeps them close together,
> > page2 is still near page1 and has a high chance of being adjacent. As
> > more pages are added ordering diversity improves, but there is still
> > high page locality for the low address pages and this leads to no
> > significant impact to the cache conflict rate.
>
> I find mm_shuffle_ctl a bit confusing because the mode of operation is
> either AUTO (enabled when the HW is present) or FORCE_ENABLE when
> explicitly enabled by the command line. Nothing earth shattering though.

Yeah, it's named from the perspective of the kernel internal usage
which is flipped from the user facing interaction. ENABLE is called
from the command line handler and in a follow-on patch the parser of
the platform-firmware table indicating the presence of a cache.
FORCE_DISABLE is only called from the command line handler. I'll add a
comment to this effect.

>
> > [1]: https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> > [2]: https://lkml.kernel.org/r/AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
> > [3]: https://lkml.org/lkml/2018/10/12/309
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Other than that, I haven't spotted any fundamental issues. The feature
> is a hack but I do agree that it might be useful for the specific HW it
> is going to be used for. I still think that shuffling only top orders
> has close to zero security benefits because it is not that hard to
> control the memory fragmentation.
>
> With that
> Acked-by: Michal Hocko <mhocko@suse.com>

Much appreciated.

