Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 902A56B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:15:17 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so2318852iak.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:15:16 -0700 (PDT)
Message-ID: <5089F22D.70007@gmail.com>
Date: Fri, 26 Oct 2012 10:15:09 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121025205213.GB4771@cmpxchg.org> <alpine.LNX.2.00.1210251429080.3623@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1210251429080.3623@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/26/2012 05:48 AM, Hugh Dickins wrote:
> On Thu, 25 Oct 2012, Johannes Weiner wrote:
>> On Wed, Oct 24, 2012 at 09:36:27PM -0700, Hugh Dickins wrote:
>>> On Wed, 24 Oct 2012, Dave Jones wrote:
>>>
>>>> Machine under significant load (4gb memory used, swap usage fluctuating)
>>>> triggered this...
>>>>
>>>> WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
>>>> Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
>>>>
>>>> 1148                         error = shmem_add_to_page_cache(page, mapping, index,
>>>> 1149                                                 gfp, swp_to_radix_entry(swap));
>>>> 1150                         /* We already confirmed swap, and make no allocation */
>>>> 1151                         VM_BUG_ON(error);
>>>> 1152                 }
>>> That's very surprising.  Easy enough to handle an error there, but
>>> of course I made it a VM_BUG_ON because it violates my assumptions:
>>> I rather need to understand how this can be, and I've no idea.
>> Could it be concurrent truncation clearing out the entry between
>> shmem_confirm_swap() and shmem_add_to_page_cache()?  I don't see
>> anything preventing that.
>>
>> The empty slot would not match the expected swap entry this call
>> passes in and the returned error would be -ENOENT.
> Excellent notion, many thanks Hannes, I believe you've got it.
>
> I've hit that truncation problem in swapoff (and commented on it
> in shmem_unuse_inode), but never hit it or considered it here.
> I think of the page lock as holding it stable, but truncation's
> free_swap_and_cache only does a trylock on the swapcache page,
> so we're not secured against that possibility.

Hi Hugh,

Even though free_swap_and_cache only does a trylock on the swapcache 
page, but it doens't call delete_from_swap_cache and the associated 
entry should still be there, I am interested in what you have already 
introduce to protect it?

>
> So I'd like to change it to VM_BUG_ON(error && error != -ENOENT),
> but there's a little tidying up to do in the -ENOENT case, which

Do you mean radix_tree_insert will return -ENOENT if the associated 
entry is not present? Why I can't find this return value in the function 
radix_tree_insert?

> needs more thought.  A delete_from_swap_cache(page) - though we
> can be lazy and leave that to reclaim for such a rare occurrence -
> and probably a mem_cgroup uncharge; but the memcg hooks are always
> the hardest to get right, I'll have think about that one carefully.
>
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
