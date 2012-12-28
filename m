Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id D5A096B005A
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 08:29:18 -0500 (EST)
Date: Fri, 28 Dec 2012 14:29:11 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50D24AF3.1050809@iskon.hr> <20121220111208.GD10819@suse.de> <20121220125802.23e9b22d.akpm@linux-foundation.org> <50D601C9.9060803@iskon.hr> <50D71166.6030608@iskon.hr> <50DB129E.7010000@iskon.hr> <50DD0106.7040001@iskon.hr> <20121228024928.GA19720@blaptop>
In-Reply-To: <20121228024928.GA19720@blaptop>
Message-ID: <50DD9EA7.6050309@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: fix null pointer dereference in wait_iff_congested()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhouping Liu <zliu@redhat.com>, Sedat Dilek <sedat.dilek@gmail.com>

On 28.12.2012 03:49, Minchan Kim wrote:
> Hello Zlatko,
>
> On Fri, Dec 28, 2012 at 03:16:38AM +0100, Zlatko Calusic wrote:
>> From: Zlatko Calusic <zlatko.calusic@iskon.hr>
>>
>> The unintended consequence of commit 4ae0a48b is that
>> wait_iff_congested() can now be called with NULL struct zone*
>> producing kernel oops like this:
>
> For good description, it would be better to write simple pseudo code
> flow to show how NULL-zone pass into wait_iff_congested because
> kswapd code flow is too complex.
>
> As I see the code, we have following line above wait_iff_congested.
>
> if (!unbalanced_zone || blah blah)
>          break;
>
> How can NULL unbalanced_zone reach wait_iff_congested?
>

Hello Minchan, and thanks for the comment.

That line was there before commit 4ae0a48b got in, and you're right, 
it's what was protecting wait_iff_congested() from being called with 
NULL zone*. But then all that logic got colapsed to a simple 
pgdat_balanced() call and that's when I introduced the bug, I lost the 
protection.

What I _think_ is happening (pseudo code following...) is that after 
scanning the zone in the dma->highmem direction, and concluding that all 
zones are balanced (unbalanced_zone remains NULL!), 
wake_up(&pgdat->pfmemalloc_wait) wakes up a lot of memory hungry 
processes (especially true in various aggressive test/benchmarks) that 
immediately drain and unbalance one or more zones. Then pgdat_balanced() 
call which immediately follows will be false, but we still have 
unbalanced_zone = NULL, rememeber? Oops...

But, all that is a speculation that I can't prove atm. Of course, if 
anybody thinks that's a credible explanation, I could add it as a commit 
comment, or even as a code comment, but I didn't want to be overly 
imaginative. The fix itself is simple and real.

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
