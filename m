Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DA92E6B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 10:24:39 -0400 (EDT)
Date: Fri, 1 Jun 2012 09:24:37 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [PATCH v2] tmpfs not interleaving properly
Message-ID: <20120601142437.GA13739@gulag1.americas.sgi.com>
References: <20120531143916.GA16162@gulag1.americas.sgi.com> <4FC7CFEB.5040009@gmail.com> <20120531132515.6af60152.akpm@linux-foundation.org> <4FC7D629.3090801@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC7D629.3090801@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, hughd@google.com, npiggin@gmail.com, cl@linux.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, riel@redhat.com

On Thu, May 31, 2012 at 04:35:53PM -0400, KOSAKI Motohiro wrote:
> (5/31/12 4:25 PM), Andrew Morton wrote:
>> On Thu, 31 May 2012 16:09:15 -0400
>> KOSAKI Motohiro<kosaki.motohiro@gmail.com>  wrote:
>>
>>>> --- a/mm/shmem.c
>>>> +++ b/mm/shmem.c
>>>> @@ -929,7 +929,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>>>>    	/*
>>>>    	 * alloc_page_vma() will drop the shared policy reference
>>>>    	 */
>>>> -	return alloc_page_vma(gfp,&pvma, 0);
>>>> +	return alloc_page_vma(gfp,&pvma, info->node_offset<<   PAGE_SHIFT );
>>>
>>> 3rd argument of alloc_page_vma() is an address. This is type error.
>>
>> Well, it's an unsigned long...
>>
>> But yes, it is conceptually wrong and *looks* weird.  I think we can
>> address that by overcoming our peculair aversion to documenting our
>> code, sigh.  This?
>
> Sorry, no.
>
> addr agrument of alloc_pages_vma() have two meanings.
>
> 1) interleave node seed
> 2) look-up key of shmem policy
>
> I think this patch break (2). shmem_get_policy(pol, addr) assume caller honor to
> pass correct address.

But the pseudo vma we generated in shmem_alloc_page the vm_ops are set to NULL.
So get_vma_policy will return the policy provided by the pseudo vma and not reach
the shmem_get_policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
