Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3AD0F6B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:47:56 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 09:47:54 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C5B286E8040
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:47:50 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07ElplY64880832
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 09:47:51 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07EloQQ014298
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 09:47:51 -0500
Message-ID: <50EAE015.1000702@linux.vnet.ibm.com>
Date: Mon, 07 Jan 2013 08:47:49 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com> <26bb76b3-308e-404f-b2bf-3d19b28b393a@default> <50E4C1FA.4070701@linux.vnet.ibm.com> <640d712e-0217-456a-a2d1-d03dd7914a55@default> <50E6F862.2030703@linux.vnet.ibm.com> <f66f40b3-6568-4183-b592-2990d4cd2083@default>
In-Reply-To: <f66f40b3-6568-4183-b592-2990d4cd2083@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Dave Hansen <dave@linux.vnet.ibm.com>

On 01/04/2013 04:45 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCH 7/8] zswap: add to mm/
>>
>> On 01/03/2013 04:33 PM, Dan Magenheimer wrote:
>>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>>>
>>>> However, once the flushing code was introduced and could free an entry
>>>> from the zswap_fs_store() path, it became necessary to add a per-entry
>>>> refcount to make sure that the entry isn't freed while another code
>>>> path was operating on it.
>>>
>>> Hmmm... doesn't the refcount at least need to be an atomic_t?
>>
>> An entry's refcount is only ever changed under the tree lock, so
>> making them atomic_t would be redundantly atomic.
> 
> Maybe I'm missing something still but then I think you also
> need to evaluate and act on the refcount (not just read it) while
> your treelock is held.  I.e., in:
> 
>> +		/* page is already in the swap cache, ignore for now */
>> +		spin_lock(&tree->lock);
>> +		refcount = zswap_entry_put(entry);
>> +		spin_unlock(&tree->lock);
>> +
>> +		if (likely(refcount))
>> +			return 0;
>> +
>> +		/* if the refcount is zero, invalidate must have come in */
>> +		/* free */
>> +		zs_free(tree->pool, entry->handle);
>> +		zswap_entry_cache_free(entry);
>> +		atomic_dec(&zswap_stored_pages);
> 
> the entry's refcount may be changed by another processor
> immediately after the unlock, and then the "if (refcount)"
> is testing a stale value and you will get (I think) a memory leak.

It is true that the refcount could be stale by the time we do the
check. However, all functions that do a zswap_entry_put(), which
potentially drops the refcount to 0, check the refcount and free the
entry if they need to.  All the functions that do a zswap_entry_put()
that result in the refcount being 0 also ensure that there is no way
for another thread to gain a reference to entry by either the tree or
lru list before releasing the lock.  That way the cleanup can happen
outside the lock with the risk of someone gaining access to the entry
being freed in the meantime.

<snip>
> A nit: Even I, steeped in tmem terminology, was confused by
> your use of "fs"... to nearly all readers it will
> be translated as "filesystem" which is mystifying.
> Just spell it out "frontswap", even if it causes a few
> lines to be wrapped.

Sound good. I'll queue it up.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
