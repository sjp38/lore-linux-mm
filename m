Date: Mon, 14 Jan 2008 21:15:40 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] mmaped copy too slow?
Message-ID: <20080114211540.284df4fb@bree.surriel.com>
In-Reply-To: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008 10:45:47 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> the problem is when almost page is mapped and PTE access bit on,
> page reclaim process below steps.
> 
>   1) page move to inactive list -> active list
>   2) page move to active list   -> inactive list
>   3) really pageout
> 
> It is too roundabout and unnecessary memory pressure happend.
> if you don't mind, please discuss.

While being able to deal with used-once mappings in page reclaim
could be a good idea, this would require us to be able to determine
the difference between a page that was accessed once since it was
faulted in and a page that got accessed several times.

That kind of infrastructure could end up adding more overhead than
an immediate reclaim of these streaming mmap pages would save.

Given that page faults have overhead too, it does not surprise me
that read+write is faster than mmap+memcpy.

In threaded applications, page fault overhead will be worse still,
since the TLBs need to be synchronized between CPUs (at least at
reclaim time).

Maybe we should just advise people to use read+write, since it is
faster than mmap+memcpy?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
