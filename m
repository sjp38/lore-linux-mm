Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 092266B025A
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:38:10 -0500 (EST)
Received: by wmww144 with SMTP id w144so48326829wmw.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:38:09 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id f6si9293117wma.122.2015.11.27.01.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 01:38:08 -0800 (PST)
Received: by wmec201 with SMTP id c201so62157668wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:38:08 -0800 (PST)
Date: Fri, 27 Nov 2015 10:38:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
Message-ID: <20151127093807.GD2493@dhcp22.suse.cz>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz>
 <20151110125101.GA8440@dhcp22.suse.cz>
 <564C8801.2090202@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564C8801.2090202@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 18-11-15 15:15:29, Vlastimil Babka wrote:
> On 11/10/2015 01:51 PM, Michal Hocko wrote:
> > On Mon 09-11-15 23:04:15, Vlastimil Babka wrote:
> >> On 5.11.2015 17:15, mhocko@kernel.org wrote:
> >> > From: Michal Hocko <mhocko@suse.com>
> >> > 
> >> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> >> > around 2.6.12 it has been ignored for low order allocations. Yet we have
> >> > the full kernel tree with its usage for apparently order-0 allocations.
> >> > This is really confusing because __GFP_REPEAT is explicitly documented
> >> > to allow allocation failures which is a weaker semantic than the current
> >> > order-0 has (basically nofail).
> >> > 
> >> > Let's simply reap out __GFP_REPEAT from those places. This would allow
> >> > to identify place which really need allocator to retry harder and
> >> > formulate a more specific semantic for what the flag is supposed to do
> >> > actually.
> >> 
> >> So at first I thought "yeah that's obvious", but then after some more thinking,
> >> I'm not so sure anymore.
> > 
> > Thanks for looking into this! The primary purpose of this patch series was
> > to start the discussion. I've only now realized I forgot to add RFC, sorry
> > about that.
> > 
> >> I think we should formulate the semantic first, then do any changes. Also, let's
> >> look at the flag description (which comes from pre-git):
> > 
> > It's rather hard to formulate one without examining the current users...
> 
> Sure, but changing existing users is a different thing :)

Chicken & Egg I guess?

> >>  * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
> >>  * _might_ fail.  This depends upon the particular VM implementation.
> >> 
> >> So we say it's implementation detail, and IIRC the same is said about which
> >> orders are considered costly and which not, and the associated rules. So, can we
> >> blame callers that happen to use __GFP_REPEAT essentially as a no-op in the
> >> current implementation? And is it a problem that they do that?
> > 
> > Well, I think that many users simply copy&pasted the code along with the
> > flag. I have failed to find any justification for adding this flag for
> > basically all the cases I've checked.
> > 
> > My understanding is that the overal motivation for the flag was to
> > fortify the allocation requests rather than weaken them. But if we were
> > literal then __GFP_REPEAT is in fact weaker than GFP_KERNEL for lower
> > orders. It is true that the later one is so only implicitly - and as an
> > implementation detail.
> 
> OK I admit I didn't realize fully that __GFP_REPEAT is supposed to be weaker,
> although you did write it quite explicitly in the changelog. It's just
> completely counterintuitive given the name of the flag!

Yeah, I guess this is basically because this has always been for costly
allocations.

[...]

I am not sure whether we found any conclusion here. Are there any strong
arguments against patch 1? I think that should be relatively
non-controversial. What about patch 2? I think it should be ok as well
as we are basically removing the flag which has never had any effect.

I would like to proceed with this further by going through remaining users.
Most of them depend on a variable size and I am not familiar with the
code so I will talk to maintainer to find out reasoning behind using the
flag. Once we have reasonable number of them I would like to go on and
rename the flag to __GFP_BEST_AFFORD and make it independent on the
order. It would still trigger OOM killer where applicable but wouldn't
retry endlessly.

Does this sound like a reasonable plan?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
