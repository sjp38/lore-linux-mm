Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1171C6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 16:12:56 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 128so27937851wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:12:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id xt10si17738082wjb.4.2016.01.28.13.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 13:12:55 -0800 (PST)
Date: Thu, 28 Jan 2016 16:12:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: why do we do ALLOC_WMARK_HIGH before going out_of_memory
Message-ID: <20160128211240.GA4163@cmpxchg.org>
References: <20160128163802.GA15953@dhcp22.suse.cz>
 <20160128190204.GJ12228@redhat.com>
 <20160128201123.GB621@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128201123.GB621@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jan 28, 2016 at 09:11:23PM +0100, Michal Hocko wrote:
> On Thu 28-01-16 20:02:04, Andrea Arcangeli wrote:
> > It's not immediately apparent if there is a new OOM killer upstream
> > logic that would prevent the risk of a second OOM killer invocation
> > despite another OOM killing already happened while we were stuck in
> > reclaim. In absence of that, the high wmark check would be still
> > needed.
> 
> Well, my oom detection rework [1] strives to make the OOM detection more
> robust and the retry logic performs the watermark check. So I think the
> last attempt is no longer needed after that patch. I will then remove
> it.

Hm? I don't have the same conclusion from what Andrea said.

When you have many allocations racing at the same time, they can all
enter __alloc_pages_may_oom() in quick succession. We don't want a
cavalcade of OOM kills when one could be enough, so we have to make
sure that in between should_alloc_retry() giving up and acquiring the
OOM lock nobody else already issued a kill and released enough memory.

It's a race window that gets yanked wide open when hundreds of threads
race in __alloc_pages_may_oom(). Your patches don't fix that, AFAICS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
