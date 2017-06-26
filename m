Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1488E6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:12:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so21894130wry.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:12:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s30si3732003wrc.116.2017.06.26.02.12.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 02:12:56 -0700 (PDT)
Date: Mon, 26 Jun 2017 11:12:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20170626091254.GG11534@dhcp22.suse.cz>
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
 <20170623071324.GD5308@dhcp22.suse.cz>
 <3541d6c3-6c41-8210-ee94-fef313ecd83d@gmail.com>
 <20170623113837.GM5308@dhcp22.suse.cz>
 <a373c35d-7d83-973c-126e-a08c411115cb@gmail.com>
 <20170626054623.GC31972@dhcp22.suse.cz>
 <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7b78db49-e0d8-9ace-bada-a48c9392a8ca@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alkis Georgopoulos <alkisg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 26-06-17 10:02:23, Alkis Georgopoulos wrote:
> IGBPI?I1I? 26/06/2017 08:46 I?I 1/4 , I? Michal Hocko I-I3I?I+-I?Iu:
> >Unfortunatelly, this is not something that can be applied in general.
> >This can lead to a premature OOM killer invocations. E.g. a direct write
> >to the block device cannot use highmem, yet there won't be anything to
> >throttle those writes properly. Unfortunately, our documentation is
> >silent about this setting. I will post a patch later.
> 
> 
> I should also note that highmem_is_dirtyable was 0 in all the 3.x kernel
> tests that I did; yet they didn't have the "slow disk writes" issue.

Yes this is possible. There were some changes in the dirty memory
throttling that could lead to visible behavior changes. I remember that
ab8fabd46f81 ("mm: exclude reserved pages from dirtyable memory") had
noticeable effect. The patch is something that we really want and it is
unnfortunate it has eaten some more from the dirtyable lowmem.

> I.e. I think that setting highmem_is_dirtyable=1 works around the issue, but
> is not the exact point which caused the regression that we see in 4.x
> kernels...

yes as I've said this is a workaround for for something that is an
inherent 32b lowmem/highmem issue.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
