Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8338A6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:30:16 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so63861312wib.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:30:16 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id z17si11395785wij.0.2015.08.07.07.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 07:30:15 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so62531839wic.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:30:14 -0700 (PDT)
Date: Fri, 7 Aug 2015 16:30:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-ID: <20150807143012.GG30785@dhcp22.suse.cz>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
 <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On Fri 07-08-15 18:16:47, PINTU KUMAR wrote:
[...]
> > On Fri 07-08-15 12:38:54, Pintu Kumar wrote:
> > > This patch add new counter slowpath_entered in /proc/vmstat to track
> > > how many times the system entered into slowpath after first allocation
> > > attempt is failed.
> > 
> > This is too lowlevel to be exported in the regular user visible interface IMO.
> > 
> I think its ok because I think this interface is for lowlevel debugging itself.

Yes but this might change in future implementations where the counter
might be misleading or even lacking any meaning. This is a user visible
interface which has to be maintained practically for ever. We have made
those mistakes in the past...

[...]
> This information is good for kernel developers.

Then make it a trace point and you can dump even more information. E.g.
timestamps, gfp_mask, order...

[...]

> Regarding trace points, I am not sure if we can attach counter to it.

You do not need to have a counter. You just watch for the tracepoint
while debugging your particular problem.

> Also trace may have more over-head 

Tracepoints should be close to 0 overhead when disabled and certainly
not a performance killer during the debugging session.

> and requires additional configs to be enabled to debug.

This is to be expected for the debugging sessions. And I am pretty
sure that the static event tracepoints do not require anything really
excessive.

> Mostly these configs will not be enabled by default (at least in embedded, low
> memory device).

Are you sure? I thought that CONFIG_TRACING should be sufficient for
EVENT_TRACING but I am not familiar with this too deeply...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
