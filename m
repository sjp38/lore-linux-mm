Date: Sat, 22 Mar 2003 04:12:51 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [CHECKER] races in 2.5.65/mm/swapfile.c?
Message-Id: <20030322041251.7720e42f.akpm@digeo.com>
In-Reply-To: <200303221145.h2MBjAW09391@csl.stanford.edu>
References: <200303221145.h2MBjAW09391@csl.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dawson Engler <engler@csl.stanford.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dawson Engler <engler@csl.stanford.edu> wrote:
>
> Hi All,
> 
> mm/swapfile.c seems to have three potential races.
> 
> The first two are in 
>         linux-2.5.62/mm/swap_state.c:87:add_to_swap_cache
> 
> which seems reachable without a lock from the callchain:
> 
>         mm/swapfile.c:sys_swapoff:998->
>               sys_swapoff:1026->
>                 try_to_unuse:591->
>                         mm/swap_state.c:read_swap_cache_async:377->
>                             add_to_swap_cache
> 
> add_to_swap_cache increments two global variables without a lock:
>         INC_CACHE_INFO(add_total);
> and
>         INC_CACHE_INFO(exist_race);

These are just instrumentation.  If they're a bit inaccurate nobody cares,
and they're not worth locking.

So yes, that is a positive.

> The final one is in
>         linux-2.5.62/mm/swapfile.c:213:swap_entry_free
> which seems to increment
>         nr_swap_pages++;
> without a lock.

swap_entry_free() is called after swap_info_get(), which locks the swap
device list and the particular swap device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
