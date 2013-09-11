Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 45A156B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 19:59:09 -0400 (EDT)
Message-ID: <523103BA.7010202@sr71.net>
Date: Wed, 11 Sep 2013 16:58:50 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: percpu pages: up batch size to fix arithmetic??
 errror
References: <20130911220859.EB8204BB@viggo.jf.intel.com> <5230F7DD.90905@linux.vnet.ibm.com>
In-Reply-To: <5230F7DD.90905@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On 09/11/2013 04:08 PM, Cody P Schafer wrote:
> So we have this variable called "batch", and the code is trying to store
> the _average_ number of pcp pages we want into it (not the batchsize),
> and then we divide our "average" goal by 4 to get a batchsize. All the
> comments refer to the size of the pcp pagesets, not to the pcp pageset
> batchsize.

That's a good point, I guess.  I was wondering the same thing.

> Looking further, in current code we don't refill the pcp pagesets unless
> they are completely empty (->low was removed a while ago), and then we
> only add ->batch pages.
> 
> Has anyone looked at what type of average pcp sizing the current code
> results in?

It tends to be within a batch of either ->high (when we are freeing lots
of pages) or ->low (when alloc'ing lots).  I don't see a whole lot of
bouncing around in the middle.  For instance, there aren't a lot of gcc
or make instances during a kernel compile that fit in to the ~0.75MB
->high limit.

Just a dumb little thing like this during a kernel compile on my 4-cpu
laptop:

 while true; do cat /proc/zoneinfo  | egrep 'count:' | tail -4; done >
pcp-counts.1.txt
cat pcp-counts.1.txt | awk '{print $2}' | sort -n | uniq -c | sort -n

says that at least ~1/2 of the time we have <=10 pages.  That makes
sense since the compile spends all of its runtime (relatively slowly)
doing allocations.  It frees all its memory really quickly when it
exits, so the window to see the times when the pools are full is smaller
than when they are empty.

I'm struggling to think of a case where the small batch sizes make sense
these days.  Maybe if you're running a lot of little programs like ls or
awk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
