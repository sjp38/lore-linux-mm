Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C500F6B005D
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:35:56 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so964081qcs.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 13:35:55 -0700 (PDT)
Message-ID: <4FC7D629.3090801@gmail.com>
Date: Thu, 31 May 2012 16:35:53 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] tmpfs not interleaving properly
References: <20120531143916.GA16162@gulag1.americas.sgi.com> <4FC7CFEB.5040009@gmail.com> <20120531132515.6af60152.akpm@linux-foundation.org>
In-Reply-To: <20120531132515.6af60152.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Nathan Zimmer <nzimmer@sgi.com>, hughd@google.com, npiggin@gmail.com, cl@linux.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, riel@redhat.com

(5/31/12 4:25 PM), Andrew Morton wrote:
> On Thu, 31 May 2012 16:09:15 -0400
> KOSAKI Motohiro<kosaki.motohiro@gmail.com>  wrote:
>
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -929,7 +929,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>>>    	/*
>>>    	 * alloc_page_vma() will drop the shared policy reference
>>>    	 */
>>> -	return alloc_page_vma(gfp,&pvma, 0);
>>> +	return alloc_page_vma(gfp,&pvma, info->node_offset<<   PAGE_SHIFT );
>>
>> 3rd argument of alloc_page_vma() is an address. This is type error.
>
> Well, it's an unsigned long...
>
> But yes, it is conceptually wrong and *looks* weird.  I think we can
> address that by overcoming our peculair aversion to documenting our
> code, sigh.  This?

Sorry, no.

addr agrument of alloc_pages_vma() have two meanings.

1) interleave node seed
2) look-up key of shmem policy

I think this patch break (2). shmem_get_policy(pol, addr) assume caller honor to
pass correct address.

Oh, yes. *NOW*, we are discussing shmem policy removing. but it haven't be removed.
Please don't break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
