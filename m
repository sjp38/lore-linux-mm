Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 0034F6B0044
	for <linux-mm@kvack.org>; Sat, 11 Aug 2012 23:28:46 -0400 (EDT)
Date: Sun, 12 Aug 2012 05:28:44 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Message-ID: <20120812032844.GE11413@one.firstfloor.org>
References: <m21ujdd6it.fsf@firstfloor.org> <1344719674-7267-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344719674-7267-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > That function uses a global lock. fdatawait is quite common. This will
> > likely cause performance problems in IO workloads.
> 
> OK, I should avoid it.

Maybe just RCU the hash table.
 
> > You need to get that lock out of the hot path somehow.
> > 
> > Probably better to try to put the data into a existing data structure,
> > or if you cannot do that you would need some way to localize the lock.
> 
> Yes, I have thought about adding some data like new pagecache tag or
> new members in struct address_space, but it makes the size of heavily
> used data structure larger so I'm not sure it's acceptable.
> And localizing the lock is worth trying, I think.

It's cheaper than a hash table lookup in the hot path.
 
> > Or at least make it conditional of hwpoison errors being around. 
> 
> I'll try to do your suggestions, but I'm not sure your point of the
> last one. Can you explain more about 'make it conditional' option?

The code should check some flag first that is only set when hwpoison
happened on the address space (or global, but that would mean that 
performance can go down globally when any error is around)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
