Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 44D596B0031
	for <linux-mm@kvack.org>; Sat, 13 Jul 2013 21:38:35 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld11so10155756pab.22
        for <linux-mm@kvack.org>; Sat, 13 Jul 2013 18:38:34 -0700 (PDT)
Message-ID: <51E2010F.8070801@gmail.com>
Date: Sun, 14 Jul 2013 09:38:23 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
References: <1372901537-31033-1-git-send-email-ccross@android.com> <87txkaq600.fsf@xmission.com>
In-Reply-To: <87txkaq600.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Eric,
On 07/04/2013 12:54 PM, Eric W. Biederman wrote:
> Colin Cross <ccross@android.com> writes:
>
>> Userspace processes often have multiple allocators that each do
>> anonymous mmaps to get memory.  When examining memory usage of
>> individual processes or systems as a whole, it is useful to be
>> able to break down the various heaps that were allocated by
>> each layer and examine their size, RSS, and physical memory
>> usage.
> What is the advantage of this?  It looks like it is going to add cache
> line contention (atomic_inc/atomic_dec) to every vma operation

How to guarantee atomic operation cacheline? atomic_inc/atomic_dec will 
lock cacheline or....?

> especially in the envision use case of heavy vma_name sharing.
>
> I would expect this will result in a bloated vm_area_struct and a slower
> mm subsystem.
>
> Have you done any benchmarks that stress the mm subsystem?
>
> How can adding glittler to /proc/<pid>/maps and /proc/<pid>/smaps
> justify putting a hand break on the linux kernel?
>
> Eric
>
>> +/**
>> + * vma_name_get
>> + *
>> + * Increment the refcount of an existing vma_name.  No locks are needed because
>> + * the caller should already be holding a reference, so refcount >= 1.
>> + */
>> +void vma_name_get(struct vma_name *vma_name)
>> +{
>> +	if (WARN_ON(!vma_name))
>> +		return;
>> +
>> +	WARN_ON(!atomic_read(&vma_name->refcount));
>> +
>> +	atomic_inc(&vma_name->refcount);
>> +}
>> +
>> +/**
>> + * vma_name_put
>> + *
>> + * Decrement the refcount of an existing vma_name and free it if necessary.
>> + * No locks needed, takes the cache lock if it needs to remove the vma_name from
>> + * the cache.
>> + */
>> +void vma_name_put(struct vma_name *vma_name)
>> +{
>> +	int ret;
>> +
>> +	if (WARN_ON(!vma_name))
>> +		return;
>> +
>> +	WARN_ON(!atomic_read(&vma_name->refcount));
>> +
>> +	/* fast path: refcount > 1, decrement and return */
>> +	if (atomic_add_unless(&vma_name->refcount, -1, 1))
>> +		return;
>> +
>> +	/* slow path: take the lock, decrement, and erase node if count is 0 */
>> +	write_lock(&vma_name_cache_lock);
>> +
>> +	ret = atomic_dec_return(&vma_name->refcount);
>> +	if (ret == 0)
>> +		rb_erase(&vma_name->rb_node, &vma_name_cache);
>> +
>> +	write_unlock(&vma_name_cache_lock);
>> +
>> +	if (ret == 0)
>> +		kfree(vma_name);
>> +}
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
