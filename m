Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBCA6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 10:03:34 -0500 (EST)
Received: by wmec201 with SMTP id c201so35083004wme.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:03:34 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id f19si14154953wjr.157.2015.11.26.07.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 07:03:33 -0800 (PST)
Received: by wmvv187 with SMTP id v187so35270964wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 07:03:33 -0800 (PST)
Date: Thu, 26 Nov 2015 16:03:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151126150330.GH7953@dhcp22.suse.cz>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20151125120021.GA27342@dhcp22.suse.cz>
 <20151126015612.GB13138@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126015612.GB13138@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org

On Thu 26-11-15 10:56:12, Joonsoo Kim wrote:
> On Wed, Nov 25, 2015 at 01:00:22PM +0100, Michal Hocko wrote:
> > On Tue 24-11-15 15:22:03, Joonsoo Kim wrote:
> > > When I tested compaction in low memory condition, I found that
> > > my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> > > This stuck last for 1 sec and after then it can escape. More investigation
> > > shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> > > so it is stuck for 1 sec.
> > 
> > Wouldn't it be sufficient to use zone_page_state_snapshot in
> > too_many_isolated?
> 
> Yes, it would work in this case. But, I prefer this patch because
> all zone_page_state() users get this benefit.

Just to make it clear, I am not against your patch in general. I am just
not sure it would help for too_many_isolated case where a significant
drift might occur on remote cpus as well so I am not really sure that is
appropriate for the issue you are seeing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
