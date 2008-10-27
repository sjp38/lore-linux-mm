Message-ID: <49055FDE.7040709@sgi.com>
Date: Mon, 27 Oct 2008 17:29:50 +1100
From: Lachlan McIlroy <lachlan@sgi.com>
Reply-To: lachlan@sgi.com
MIME-Version: 1.0
Subject: Re: deadlock with latest xfs
References: <4900412A.2050802@sgi.com> <20081023205727.GA28490@infradead.org> <49013C47.4090601@sgi.com> <20081024052418.GO25906@disturbed> <20081024064804.GQ25906@disturbed> <20081026005351.GK18495@disturbed> <20081026025013.GL18495@disturbed> <49051C71.9040404@sgi.com> <20081027053004.GF11948@disturbed>
In-Reply-To: <20081027053004.GF11948@disturbed>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>, Christoph Hellwig <hch@infradead.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Chinner wrote:
> On Mon, Oct 27, 2008 at 12:42:09PM +1100, Lachlan McIlroy wrote:
>> Dave Chinner wrote:
>>> On Sun, Oct 26, 2008 at 11:53:51AM +1100, Dave Chinner wrote:
>>>> On Fri, Oct 24, 2008 at 05:48:04PM +1100, Dave Chinner wrote:
>>>>> OK, I just hung a single-threaded rm -rf after this completed:
>>>>>
>>>>> # fsstress -p 1024 -n 100 -d /mnt/xfs2/fsstress
>>>>>
>>>>> It has hung with this trace:
> ....
>>> Got it now. I can reproduce this in a couple of minutes now that both
>>> the test fs and the fs hosting the UML fs images are using lazy-count=1
>>> (and the frequent 10s long host system freezes have gone away, too).
>>>
>>> Looks like *another* new memory allocation problem [1]:
> .....
>>> We've entered memory reclaim inside the xfsdatad while trying to do
>>> unwritten extent completion during I/O completion, and that memory
>>> reclaim is now blocked waiting for I/o completion that cannot make
>>> progress.
>>>
>>> Nasty.
>>>
>>> My initial though is to make _xfs_trans_alloc() able to take a KM_NOFS argument
>>> so we don't re-enter the FS here. If we get an ENOMEM in this case, we should
>>> then re-queue the I/O completion at the back of the workqueue and let other
>>> I/o completions progress before retrying this one. That way the I/O that
>>> is simply cleaning memory will make progress, hence allowing memory
>>> allocation to occur successfully when we retry this I/O completion...
>> It could work - unless it's a synchronous I/O in which case the I/O is not
>> complete until the extent conversion takes place.
> 
> Right. Pushing unwritten extent conversion onto a different
> workqueue is probably the only way to handle this easily.
> That's the same solution Irix has been using for a long time
> (the xfsc thread)....

Would that be a workqueue specific to one filesystem?  Right now our
workqueues are per-cpu so they can contain I/O completions for multiple
filesystems.

> 
>> Could we allocate the memory up front before the I/O is issued?
> 
> Possibly, but that will create more memory pressure than
> allocation in I/O completion because now we could need to hold
> thousands of allocations across an I/O - think of the case where
> we are running low on memory and have a disk subsystem capable of
> a few hundred thousand I/Os per second. the allocation failing would
> prevent the I/os from being issued, and if this is buffered writes
> into unwritten extents we'd be preventing dirty pages from being
> cleaned....

The allocation has to be done sometime - if have a few hundred thousand
I/Os per second then the queue of unwritten extent conversion requests
is going to grow very quickly.  If a separate workqueue will fix this
then that's a better solution anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
