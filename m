Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F02306B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 20:30:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so15952146pab.14
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 17:30:40 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id la16si8124380pab.171.2014.09.02.17.30.39
        for <linux-mm@kvack.org>;
        Tue, 02 Sep 2014 17:30:40 -0700 (PDT)
Message-ID: <5406612E.8040802@sr71.net>
Date: Tue, 02 Sep 2014 17:30:38 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <20140902221814.GA18069@cmpxchg.org> <5406466D.1020000@sr71.net> <20140903001009.GA25970@cmpxchg.org>
In-Reply-To: <20140903001009.GA25970@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 09/02/2014 05:10 PM, Johannes Weiner wrote:
> On Tue, Sep 02, 2014 at 03:36:29PM -0700, Dave Hansen wrote:
>> On 09/02/2014 03:18 PM, Johannes Weiner wrote:
>>> Accounting new pages is buffered through per-cpu caches, but taking
>>> them off the counters on free is not, so I'm guessing that above a
>>> certain allocation rate the cost of locking and changing the counters
>>> takes over.  Is there a chance you could profile this to see if locks
>>> and res_counter-related operations show up?
>>
>> It looks pretty much the same, although it might have equalized the
>> charge and uncharge sides a bit.  Full 'perf top' output attached.
> 
> That looks like a partial profile, where did the page allocator, page
> zeroing etc. go?  Because the distribution among these listed symbols
> doesn't seem all that crazy:

Perf was only outputting the top 20 functions.  Believe it or not, page
zeroing and the rest of the allocator path wasn't even in the path of
the top 20 functions because there is so much lock contention.

Here's a longer run of 'perf top' along with the top 100 functions:

	http://www.sr71.net/~dave/intel/perf-top-1409702817.txt.gz

you can at least see copy_page_rep in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
