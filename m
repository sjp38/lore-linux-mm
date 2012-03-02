Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 971C66B00EA
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 02:12:57 -0500 (EST)
Message-ID: <4F5072F4.3030505@lge.com>
Date: Fri, 02 Mar 2012 16:12:52 +0900
From: Namhyung Kim <namhyung.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>  <alpine.DEB.2.00.1202290922210.32268@router.home> <1330587031.1762.46.camel@leonhard> <alpine.DEB.2.00.1203010901020.5004@router.home>
In-Reply-To: <alpine.DEB.2.00.1203010901020.5004@router.home>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Namhyung Kim <namhyung@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2012-03-02 12:03 AM, Christoph Lameter wrote:
> On Thu, 1 Mar 2012, Namhyung Kim wrote:
>
>>> You cannot free a tail page of a compound higher order page independently.
>>> You must free the whole compound.
>>>
>>
>> I meant freeing a *slab object* resides in a compound page using buddy
>> system API (e.g. free_pages). I know it's definitely a programming
>> error. However there's no safety net to protect and/or warn such a
>> misbehavior AFAICS - except for head page which has PG_slab set - when
>> it happened by any chance.
>
> ?? One generally passed a struct page pointer to the page allocator. Slab
> allocator takes pointers to object. The calls that take a pointer to an
> object must have a page aligned value.
>

Please see free_pages(). It converts the pointer using virt_to_page().


>> Without it, it might be possible to free part of tail pages silently,
>> and cause unexpected not-so-funny results some time later. It should be
>> hard to find out.
>
> Ok then fix the page allocator to BUG() on tail pages. That is an issue
> with the page allocator not the slab allocator.
>
> Adding PG_tail to the flags checked on free should do the trick (at least
> for 64 bit).
>

Yeah, but doing it requires to change free path of compound pages. It seems 
freeing normal compound pages would not clear PG_head/tail bits before 
free_pages_check() called. I guess moving destroy_compound_page() into 
free_pages_prepare() will solved this issue but I want to make sure it's the 
right approach since I have no idea how it affects huge page behaviors.

Besides, as it has no effect on 32 bit kernels I still want add the PG_slab 
flag to those pages. If you care about the performance of hot path, how about 
adding it under debug configurations at least?


Thanks,
Namhyung Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
