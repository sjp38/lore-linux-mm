Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 035EC6B0037
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 04:13:04 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so1050570eek.27
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 01:13:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si29831907eep.287.2014.04.30.01.13.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 01:13:03 -0700 (PDT)
Date: Wed, 30 Apr 2014 10:12:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <20140430081256.GA4357@dhcp22.suse.cz>
References: <20140429151910.53f740ef@annuminas.surriel.com>
 <5360AE74.7050100@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5360AE74.7050100@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com

On Wed 30-04-14 12:04:04, Maxim Patlasov wrote:
> Hi Rik!
> 
> On 04/29/2014 11:19 PM, Rik van Riel wrote:
> >It is possible for "limit - setpoint + 1" to equal zero, leading to a
> >divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> >working, so we need to actually test the divisor before calling div64.
> 
> The patch looks correct, but I'm afraid it can hide an actual bug in a
> caller of pos_ratio_polynom(). The latter is not intended for setpoint >
> limit. All callers take pains to ensure that setpoint <= limit. Look, for
> example, at global_dirty_limits():

The bug might trigger even if setpoint < limit because the result is
trucated to s32 and I guess this is what is going on here?
Is (limit - setpoint + 1) > 4G possible?

> 
> >     if (background >= dirty)
> >        background = dirty / 2;
> 
> If you ever encountered "limit - setpoint + 1" equal zero, it may be worthy
> to investigate how you came to setpoint greater than limit.
> 
> Thanks,
> Maxim
> 
> >
> >Signed-off-by: Rik van Riel <riel@redhat.com>
> >Cc: stable@vger.kernel.org
> >---
> >  mm/page-writeback.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> >
> >diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >index ef41349..2682516 100644
> >--- a/mm/page-writeback.c
> >+++ b/mm/page-writeback.c
> >@@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
> >  					  unsigned long dirty,
> >  					  unsigned long limit)
> >  {
> >+	unsigned int divisor;
> >  	long long pos_ratio;
> >  	long x;
> >+	divisor = limit - setpoint;
> >+	if (!divisor)
> >+		divisor = 1;
> >+
> >  	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> >-		    limit - setpoint + 1);
> >+		    divisor);
> >  	pos_ratio = x;
> >  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> >  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
