Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 16CC26B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:51:28 -0500 (EST)
Received: by wmec201 with SMTP id c201so21623485wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:51:27 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id n65si7041118wma.13.2015.11.12.00.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 00:51:27 -0800 (PST)
Received: by wmww144 with SMTP id w144so78176573wmw.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:51:26 -0800 (PST)
Date: Thu, 12 Nov 2015 09:51:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151112085125.GD1174@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <20151111155446.GA24431@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151111155446.GA24431@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 11-11-15 10:54:46, Johannes Weiner wrote:
> On Wed, Nov 11, 2015 at 02:48:17PM +0100, mhocko@kernel.org wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_NOFAIL is a big hammer used to ensure that the allocation
> > request can never fail. This is a strong requirement and as such
> > it also deserves a special treatment when the system is OOM. The
> > primary problem here is that the allocation request might have
> > come with some locks held and the oom victim might be blocked
> > on the same locks. This is basically an OOM deadlock situation.
> > 
> > This patch tries to reduce the risk of such a deadlocks by giving
> > __GFP_NOFAIL allocations a special treatment and let them dive into
> > memory reserves after oom killer invocation. This should help them
> > to make a progress and release resources they are holding. The OOM
> > victim should compensate for the reserves consumption.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi,
> > this has been posted previously as a part of larger GFP_NOFS related
> > patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
> > but Andrea was asking basically the same thing at LSF early this year
> > (I cannot seem to find it in any public archive though). I think the
> > patch makes some sense on its own.
> 
> I sent this right after LSF based on Andrea's suggestion:
> 
> https://lkml.org/lkml/2015/3/25/37

Ohh, I completely forgot as it was part of a larger series.
Thanks for the pointer.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
