Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C57C16B0265
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 13:55:50 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so98593883wib.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:55:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pa6si36363800wjb.84.2015.07.20.10.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 10:55:48 -0700 (PDT)
Date: Mon, 20 Jul 2015 18:55:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Message-ID: <20150720175538.GJ2561@suse.de>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de>
 <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

On Mon, Jul 20, 2015 at 09:43:02PM +0530, PINTU KUMAR wrote:
> Hi,
> 
> Thank you all for reviewing the patch and providing your valuable comments and
> suggestions.
> During the ELC conference many people suggested to release the patch to
> mainline, so this patch, to get others opinion.
> 

Unfortunately, in my opinion it runs the risk of creating a different
set of problems. Either it needs to be run frequently to keep memory free
which incurs one set of penalties or it is used too late when there are
unmovable/unreclaimable pages preventing allocations succeeding in which
case you are back at the original problem. I see what you did and why it
would work in some cases but I think the main reason it works is because
it's run frequently enough so memory is never used. Grouping pages by
mobility actually took advantage of a similar property when it increased
min_free_kbytes but that was much more limited than adding a giant hammer
for userspace to reclaim the world.

> If you have any more suggestions to experiment and verify please let me know.
> 

I believe I already did. If it's high-order reliability that is important
then you need to either reserve the memory or look at protecting the pages
using grouping pages by mobility. I pointed out what series to look at and
the leader explains how it could be adjusted further for the embedded case
if necessary.

If it's latency you are interested in then reclaim/compaction needs to
be modified to be more aggressive when it is somehow detected that the
high-order allocation must succeed for functional correctness. In that case
the relational starting point would be to look at should_continue_reclaim
and how it relates to compaction.

> The suggestion was only to open up the shrink_all_memory API for some use cases.
> 
> I am not saying that it needs to be called continuously. It can be used only on
> certain condition and only when deemed necessary.
> The same technique is already used in hibernation to reduce the RAM snapshot
> image size.

Reducing memory usage is not the same as guaranteeing that high-order
pages are available for allocation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
