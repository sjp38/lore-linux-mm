Message-ID: <41131862.5050000@yahoo.com.au>
Date: Fri, 06 Aug 2004 15:34:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 3/4: writeout watermarks
References: <41130FB1.5020001@yahoo.com.au>	<41130FD2.5070608@yahoo.com.au>	<41131105.8040108@yahoo.com.au> <20040805222733.477b3017.akpm@osdl.org>
In-Reply-To: <20040805222733.477b3017.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:

>>  	background = (background_ratio * total_pages) / 100;
>>  	dirty = (dirty_ratio * total_pages) / 100;
> 
> 
> Look, these are sysadmin-settable sysctls.  The admin can set them to
> whatever wild and whacky values he wants - it's his computer.

Yes I know. That was the problem with my earlier patches.

> 
> The only reason the check is there at all is because background_ratio >
> dirty_ratio has never been even tested, and could explode, and I don't want
> to have to test and support it.  Plus if the admin is in the process of
> setting both tunables there might be a transient period of time when
> they're in a bad state.
> 
> That's all!  Please, just pretend the code isn't there at all.  What the
> admin sets, the admin gets, end of story.
> 

No, it is not that code I am worried about, you're actually doing
this too (disregarding the admin's wishes):

         dirty_ratio = vm_dirty_ratio;
         if (dirty_ratio > unmapped_ratio / 2)
                 dirty_ratio = unmapped_ratio / 2;

         if (dirty_ratio < 5)
                 dirty_ratio = 5;


So if the admin wants a dirty_ratio of 40 and dirty_background_ratio of 10
then that's good, but I'm sure if they knew you're moving dirty_ratio to 10
here, they'd want something like 2 for the dirty_background_ratio.

I contend that the ratio between these two values is more important than
their absolue values -- especially considering one gets twiddled here.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
