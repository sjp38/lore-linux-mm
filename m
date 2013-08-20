Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C12CF6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 04:10:24 -0400 (EDT)
Message-ID: <52132432.3050308@asianux.com>
Date: Tue, 20 Aug 2013 16:09:22 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: mempolicy: the failure processing about mpol_to_str()
References: <5212E8DF.5020209@asianux.com> <20130820053036.GB18673@moon> <52130194.4030903@asianux.com> <20130820064730.GD18673@moon> <52131F48.1030002@asianux.com> <52132011.60501@asianux.com>
In-Reply-To: <52132011.60501@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 08/20/2013 03:51 PM, Chen Gang wrote:
> On 08/20/2013 03:48 PM, Chen Gang wrote:
>> On 08/20/2013 02:47 PM, Cyrill Gorcunov wrote:
>>> On Tue, Aug 20, 2013 at 01:41:40PM +0800, Chen Gang wrote:
>>>>
>>>>> sure you'll have to change shmem_show_mpol statement to return int code.
>>>>> Won't this be more short and convenient?
>>>>>
>>>>>
>>>>
>>>> Hmm... if return -ENOSPC, in common processing, it still need continue
>>>> (but need let outside know about the string truncation).
>>>>
>>>> So I still suggest to give more check for it.
>>>
>>> I still don't like adding additional code like
>>>
>>> +	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
>>> +	if (ret < 0)
>>> +               switch (ret) {
>>> +               case -ENOSPC:
>>> +                       printk(KERN_WARNING
>>> +                               "in %s: string is truncated in mpol_to_str().\n",
>>> +                               __func__);
> 
> Oh, that need 'break' in my original patch. :-)
> 
>>> +               default:
>>> +                       printk(KERN_ERR
>>> +                               "in %s: call mpol_to_str() fail, errcode: %d. buffer: %p, size: %zu, pol: %p\n",
>>> +                               __func__, ret, buffer, sizeof(buffer), mpol);
>>> +                       return;
>>> +               }
>>>
>>> this code is pretty neat for debugging purpose I think but in most case (if
>>> only I've not missed something obvious) it simply won't be the case.
>>>
>>
>> For mpol_to_str(), it is for printing string, I suggest to fill buffer
>> as full as possible like another printing string functions, -ENOSPC is
>> not critical error, callers may can bear it, and still want to continue.
>>
>> For 2 callers, I still suggest to process '-ENOSPC' and continue, it is
>> really not a critical error, they can continue.
>>
>> For the 'default' error processing:
>>
>>   I still suggest to 'printk' in shmem_show_mpol(), because when failure occurs, it has no return value to mark the failure to upper caller.
>>   Hmm... but for show_numa_map(), may remove the 'printk', only return the error code is OK. :-)
>>
>>
>> Thanks.
>>

Oh, for '-ENOSPC', it means critical error, it is my fault.

So, for simplify thinking and implementation, use your patch below is OK
to me (but I suggest to print error information in the none return value
function).

:-)

>>> Won't somthing like below do the same but with smaller code change?
>>> Note I've not even compiled it but it shows the idea.
>>> ---
>>>  fs/proc/task_mmu.c |    4 +++-
>>>  mm/shmem.c         |   17 +++++++++--------
>>>  2 files changed, 12 insertions(+), 9 deletions(-)
>>>
>>> Index: linux-2.6.git/fs/proc/task_mmu.c
>>> ===================================================================
>>> --- linux-2.6.git.orig/fs/proc/task_mmu.c
>>> +++ linux-2.6.git/fs/proc/task_mmu.c
>>> @@ -1402,8 +1402,10 @@ static int show_numa_map(struct seq_file
>>>  	walk.mm = mm;
>>>  
>>>  	pol = get_vma_policy(task, vma, vma->vm_start);
>>> -	mpol_to_str(buffer, sizeof(buffer), pol);
>>> +	n = mpol_to_str(buffer, sizeof(buffer), pol);
>>>  	mpol_cond_put(pol);
>>> +	if (n < 0)
>>> +		return n;
>>>  
>>>  	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
>>>  
>>> Index: linux-2.6.git/mm/shmem.c
>>> ===================================================================
>>> --- linux-2.6.git.orig/mm/shmem.c
>>> +++ linux-2.6.git/mm/shmem.c
>>> @@ -883,16 +883,20 @@ redirty:
>>>  
>>>  #ifdef CONFIG_NUMA
>>>  #ifdef CONFIG_TMPFS
>>> -static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>> +static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>>  {
>>>  	char buffer[64];
>>> +	int ret;
>>>  
>>>  	if (!mpol || mpol->mode == MPOL_DEFAULT)
>>> -		return;		/* show nothing */
>>> +		return 0;	/* show nothing */
>>>  
>>> -	mpol_to_str(buffer, sizeof(buffer), mpol);
>>> +	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
>>> +	if (ret < 0)
>>> +		return ret;
>>>  
>>>  	seq_printf(seq, ",mpol=%s", buffer);
>>> +	return 0;
>>>  }
>>>  
>>>  static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
>>> @@ -951,9 +955,7 @@ static struct page *shmem_alloc_page(gfp
>>>  }
>>>  #else /* !CONFIG_NUMA */
>>>  #ifdef CONFIG_TMPFS
>>> -static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>> -{
>>> -}
>>> +static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol) { return 0; }
>>>  #endif /* CONFIG_TMPFS */
>>>  
>>>  static inline struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
>>> @@ -2577,8 +2579,7 @@ static int shmem_show_options(struct seq
>>>  	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
>>>  		seq_printf(seq, ",gid=%u",
>>>  				from_kgid_munged(&init_user_ns, sbinfo->gid));
>>> -	shmem_show_mpol(seq, sbinfo->mpol);
>>> -	return 0;
>>> +	return shmem_show_mpol(seq, sbinfo->mpol);
>>>  }
>>>  #endif /* CONFIG_TMPFS */
>>>  
>>>
>>>
>>
>>
> 
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
