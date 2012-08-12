Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0FB216B0044
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 11:19:38 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Date: Sun, 12 Aug 2012 11:19:21 -0400
Message-Id: <1344784761-6183-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120812032844.GE11413@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Sun, Aug 12, 2012 at 05:28:44AM +0200, Andi Kleen wrote:
> > > That function uses a global lock. fdatawait is quite common. This will
> > > likely cause performance problems in IO workloads.
> > 
> > OK, I should avoid it.
> 
> Maybe just RCU the hash table.

OK.

> > > You need to get that lock out of the hot path somehow.
> > > 
> > > Probably better to try to put the data into a existing data structure,
> > > or if you cannot do that you would need some way to localize the lock.
> > 
> > Yes, I have thought about adding some data like new pagecache tag or
> > new members in struct address_space, but it makes the size of heavily
> > used data structure larger so I'm not sure it's acceptable.
> > And localizing the lock is worth trying, I think.
> 
> It's cheaper than a hash table lookup in the hot path.
>  
> > > Or at least make it conditional of hwpoison errors being around. 
> > 
> > I'll try to do your suggestions, but I'm not sure your point of the
> > last one. Can you explain more about 'make it conditional' option?
> 
> The code should check some flag first that is only set when hwpoison
> happened on the address space (or global, but that would mean that 
> performance can go down globally when any error is around)

I defined hwpoison_file_range() and hwpoison_partial_write() as wrapper
functions of __hwpoison_* variants, and they hold hwp_dirty_lock only
if AS_HWPOISON flag in mapping is set. So I hope we already did it.
But yes, I understand that in general a global lock is not good,
so I'll try to do other options.

Thank you,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
