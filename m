Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7CDE6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 06:45:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 8so12677101wms.11
        for <linux-mm@kvack.org>; Mon, 29 May 2017 03:45:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si9615886edc.294.2017.05.29.03.45.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 03:45:38 -0700 (PDT)
Date: Mon, 29 May 2017 12:45:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] memory hotplug regression
Message-ID: <20170529104537.GH19725@dhcp22.suse.cz>
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170529085231.GE19725@dhcp22.suse.cz>
 <20170529101128.GA12975@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170529101128.GA12975@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-05-17 12:11:28, Heiko Carstens wrote:
> On Mon, May 29, 2017 at 10:52:31AM +0200, Michal Hocko wrote:
> > > Why is it a problem to change the default for 'online'? As far as I can see
> > > that doesn't have too much to do with the order of zones, no?
> > 
> > `online' (aka MMOP_ONLINE_KEEP) should always inherit its current zone.
> > The previous implementation made an exception to allow to shift to
> > another zone if it is on the border of two zones. This is what I wanted
> > to get rid of because it is just too ugly to live.
> > 
> > But now I am not really sure what is the usecase here. I assume you know
> > how to online the memoery. That's why you had to play tricks with the
> > zones previously. All you need now is to use the proper MMOP_ONLINE*
> 
> Yes, however that implies that existing user space has to be changed to
> achieve the same semantics as before. That's the usecase I'm talking about.

Yes that is really unfortunate. It is even more unfortunate how the
original behavior got merged without a deeper consideration.

> On the other hand this change would finally make s390 behave like all other
> architectures, which is certainly not a bad thing. So, while thinking again
> I think you convinced me to agree with this change.

That is definitely good to hear. Btw. I plan to change the semantic even
further. MMOP_ONLINE_KEEP currently ignores movable_node setting and I
plan to change that. Hopefully this won't break more userspace...

> > > 2) Another oddity is that after a memory block was brought online it's
> > > association to ZONE_NORMAL or ZONE_MOVABLE seems to be fixed. Even if it
> > > is brought offline afterwards:
> > 
> > This is intended behavior because I got rid of the tricky&ugly zone
> > shifting code. Ultimately I would like to allow for overlapping zones
> > so the explicit online_{movable,kernel} will _always_ work.
> 
> Ok, I see. This change (fixed memory block to zone mapping after first
> online) is a bit surprising. On the other hand I can't think of a sane
> usecase why one wants to change the zone a memory block belongs to.

Longeterm I would really like to remove any constrains on where to
online movable or kernel memory. So even if this will be problem it will
be only temporary.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
