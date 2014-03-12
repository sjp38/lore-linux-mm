Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 55D3B6B00BE
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 12:09:35 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so605052pdj.22
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 09:09:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xn1si2778757pbc.278.2014.03.12.09.09.33
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 09:09:34 -0700 (PDT)
Message-ID: <532085E3.5030904@linux.intel.com>
Date: Wed, 12 Mar 2014 09:05:55 -0700
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: implement POSIX_FADV_NOREUSE
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>	 <20140311140655.GD28292@dhcp22.suse.cz> <531F2ABA.6060804@linux.intel.com>	 <20140311142729.1e3e4e51186db4c8ee49a9f4@linux-foundation.org> <1394625592.543.52.camel@dinghy>
In-Reply-To: <1394625592.543.52.camel@dinghy>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Senger <lukas@fridolin.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Matthias Wirth <matthias.wirth@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fengguang Wu <fengguang.wu@intel.com>, Shaohua Li <shli@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Jiang Liu <liuj97@gmail.com>, David Rientjes <rientjes@google.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, i4passt <i4passt@lists.cs.fau.de>

On 03/12/2014 04:59 AM, Lukas Senger wrote:
>> This also looks to ignore the reuse flag for existing pages.  Have you
>> thought about what the semantics should be there?
> 
> The idea is to only treat the pages special when they are first read
> from disk. This way we achieve the main goal of not displacing useful
> cache content.
> 
>> Also, *should* readahead pages really have this flag set?  If a very
>> important page gets brought in via readahead, doesn't this put it at a
>> disadvantage for getting aged out?
> 
> If the flag is not set on readahead pages, the advise barely has any
> effect at all, since most of the file gets read through readahead. Of
> course that very important page has a disadvantage at the beginning, but
> as soon as it has been moved into the active list the NOREUSE doesn't
> affect it anymore. Worst case it gets read once more without the flag.

That's a good point, and it's a much more important change to the
existing code than the fadvise bits are.  Probably best to make a bigger
deal about it in the patch description.

> On Tue, 2014-03-11 at 14:27 -0700, Andrew Morton wrote:
>> And it sets PG_noreuse on new pages whether or not they were within the
>> fadvise range (offset...offset+len).  It's not really an fadvise
>> operation at all.
> 
> NORMAL, SEQUENTIAL and RANDOM don't honor the range either. So we
> figured it would be ok to do so for the sake of keeping the
> implementation simple.
> 
>>> page flags are really scarce and I am not sure this is the best
>> usage of
>>> the few remaining slots.
>>
>> Yeah, especially since the use so so transient.  I can see why using a
>> flag is nice for a quick prototype, but this is a far cry from needing
>> one. :)  You might be able to reuse a bit like PageReadahead.  You
>> could
>> probably also use a bit in the page pointer of the lruvec, or even
>> have
>> a percpu variable that stores a pointer to the 'struct page' you want
>> to
>> mark as NOREUSE.
> 
> Ok, we understand that we can't add a page flag. We tried to find a flag
> to recycle but did not succeed. lruvec doesn't have page pointers and we
> don't have access to a pagevec and the file struct at the same time. We
> don't really understand the last suggestion, as we need to save this
> information for more than one page and going over a list every time we
> add something to an lru list doesn't seem like a good idea.

Yeah, you're right.  I was ignoring the readahead code here.

But, why wouldn't this work there?  Define a percpu variable, and assign
it to the target page in readahead's read_pages() and in
do_generic_file_read() which deal with pages one at a time and not in lists.

struct page *read_me_once;
void hint_page_read_once(struct page *page)
{
	read_me_once = page;
}

Then check for (read_me_once == page) in add_page_to_lru_list() instead
of the page flag.  Then, make read_me_once per-cpu.  This won't be
preempt safe, but we're talking about readahead and hints here, so we
can probably just bail in the cases where we race.

> Would it be acceptable to add a member to struct page for our purpose?

'struct page' must be aligned to two pointers due to constraints from
the slub allocator.  Adding a single byte to it would bloat it by 16
bytes for me, which translates in to 2GB of lost space on my 1TB system.
 There are 6TB systems out there today which would lose 12GB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
