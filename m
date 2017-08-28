Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87E8A6B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 08:35:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p14so514080wrg.7
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 05:35:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si236125wrd.381.2017.08.28.05.35.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 05:35:44 -0700 (PDT)
Date: Mon, 28 Aug 2017 14:35:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170828123542.GJ17097@dhcp22.suse.cz>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
 <20170825213936.GA13576@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825213936.GA13576@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 25-08-17 23:39:36, Pavel Machek wrote:
> On Fri 2017-08-25 10:04:42, Michal Hocko wrote:
> > On Fri 25-08-17 09:28:19, Pavel Machek wrote:
> > > On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
> > > > On Wed 23-08-17 19:57:09, Pavel Machek wrote:
> > [...]
> > > > > Dunno. < 1msec probably is temporary, 1 hour probably is not. If it causes
> > > > > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide replace,
> > > > > and then starting again goes not look attractive to me.
> > > > 
> > > > I do not think we want a highlevel GFP_TEMPORARY without any meaning.
> > > > This just supports spreading the flag usage without a clear semantic
> > > > and it will lead to even bigger mess. Once we can actually define what
> > > > the flag means we can also add its users based on that new semantic.
> > > 
> > > It has real meaning.
> > 
> > Which is?
> 
> "This allocation is temporary. It lasts milliseconds, not hours."

And why would such a semantic make any sense what so ever? We certainly
do not try to wait for a pinned memory for $TIMEOUT when somebody really
needs a larger memory block and there is a temporary allocation standing
in the way. We simply do not know that an object is a temporary one.

> > > You can define more exact meaning, and then adjust the usage. But
> > > there's no need to do treewide replacement...
> > 
> > I have checked most of them and except for the initially added onces the
> > large portion where added without a good reasons or even break an
> > intuitive meaning by taking locks.
> 
> I don't see it. kmalloc() itself takes locks. Of course everyone takes
> locks. I don't think that's intuitive meaning.

I was talking about users of the flag. I have seen some to take a lock
right after they allocated GFP_TEMPORARY object.

> > Seriously, if we need a short term semantic it should be clearly defined
> > first.
> 
> "milliseconds, not hours."
> 
> > Is there any specific case why you think this patch is in a wrong
> > direction? E.g. a measurable regression?
> 
> Not playing that game. You should argue why it is improvement. And I
> don't believe you did.

Please read the whole changelog where I was quite verbose about how the
current flag is abused and how its semantic is weak and encourages a
wrong usage pattern. Moreover it is not even clear whether it helps
anything. I haven't seen any actual counter argument from you other than
"milliseconds not hours" without actually explaining how that would be
useful for any decisions done in the core MM layer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
