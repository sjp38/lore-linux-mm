Date: Mon, 5 Nov 2007 15:17:23 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC Patch] Thrashing notification
Message-ID: <20071105151723.71b3faaf@bree.surriel.com>
In-Reply-To: <20071105183025.GA4984@dmt>
References: <op.t1bp13jkk4ild9@bingo>
	<20071105183025.GA4984@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: Daniel =?UTF-8?B?U3DDpW5n?= <daniel.spang@gmail.com>, linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

On Mon, 5 Nov 2007 13:30:25 -0500
Marcelo Tosatti <marcelo@kvack.org> wrote:

> Hooking into try_to_free_pages() makes the scheme suspectible to
> specifics such as:

The specific of where the hook is can be changed.  I am sure the
two of you can come up with the best way to do things.  Just keep
shooting holes in each other's ideas until one idea remains which
neither of you can find a problem with[1] :)

> Remember that notifications are sent to applications which can allocate
> globally... 

This is the bigger problem with the sysfs code: every task that
watches the sysfs node will get woken up.  That could be a big
problem when there are hundreds of processes watching that file.

Marcelo's code, which only wakes up one task at a time, has the
potential to work much better.  That code can also be enhanced
to wake up tasks that use a lot of memory on the specific NUMA
node that has a memory shortage.

[1] Yes, that is how I usually come up with VM ideas :)
-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
