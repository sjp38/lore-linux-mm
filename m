Message-ID: <45D8C43A.3060800@redhat.com>
Date: Sun, 18 Feb 2007 16:25:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu> <20070218125307.4103c04a.akpm@linux-foundation.org>
In-Reply-To: <20070218125307.4103c04a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sun, 18 Feb 2007 19:28:18 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
>> I was testing the new fuse shared writable mmap support, and finding
>> that bash-shared-mapping deadlocks (which isn't so strange ;).  What
>> is more strange is that this is not an OOM situation at all, with
>> plenty of free and cached pages.
>>
>> A little more investigation shows that a similar deadlock happens
>> reliably with bash-shared-mapping on a loopback mount, even if only
>> half the total memory is used.
>>
>> The cause is slightly different in the two cases:
>>
>>   - loopback mount: allocation by the underlying filesystem is stalled
>>     on throttle_vm_writeout()
>>
>>   - fuse-loop: page dirtying on the underlying filesystem is stalled on
>>     balance_dirty_pages()
>>
>> In both cases the underlying fs is totally innocent, with no
>> dirty/writback pages, yet it's waiting for the global dirty+writeback
>> to go below the threshold, which obviously won't, until the
>> allocation/dirtying succeeds.
>>
>> I'm not quite sure what the solution is, and asking for thoughts.
> 
> But....  these things don't just throttle.  They also perform large amounts
> of writeback, which causes the dirty levels to subside.
> 
>>From your description it appears that this writeback isn't happening, or
> isn't working.  How come?

Is the fuse daemon trying to do writeback to itself, perhaps?

That is, trying to write out data to the FUSE filesystem, for which
it is also the server.


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
