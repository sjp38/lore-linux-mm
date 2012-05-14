Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id AEBC16B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 22:18:32 -0400 (EDT)
Message-ID: <4FB06B91.1080008@kernel.org>
Date: Mon, 14 May 2012 11:18:57 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com> <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com> <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org> <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org> <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org> <20120511192831.GC3785@phenom.dumpdata.com>
In-Reply-To: <20120511192831.GC3785@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/12/2012 04:28 AM, Konrad Rzeszutek Wilk wrote:

>> Please look.
>>
>> struct zs_handle {
>> 	void *handle
>> };
>>
>> 1)
>>
>> static struct zv_hdr *zv_create(..)
>> {
>> 	struct zs_handle handle;
>> 	..
>> 	handle = zs_malloc(pool, size);
>> 	..
>> 	return handle;
> 
> Compiler will complain that you are returning incorrect type.


My bad. &handle.

> 
>> }
>>
>> handle is on stack so it can't be used by index for slot of radix tree.
> 
> The fix is of course to return a pointer (which your function
> declared), and instead do this:
> 
> {
> 	struct zs_handle *handle;
> 
> 	handle = zs_malloc(pool, size);


It's not a good idea.
For it, zs_malloc needs memory space to keep zs_handle internally.
Why should zsallocator do it? Just for zcache?
It's not good abstraction.


> 	return handle;
> }
> 
>>
>> 2)
>>
>> static struct zv_hdr *zv_create(..)
>> {
>> 	struct zs_handle handle;
>> 	..
>> 	handle = zs_malloc(pool, size);
>> 	..
>> 	return handle.handle;
>> }
>>
>> Okay. Now it works but zcache coupled with zsmalloc tightly.
>> User of zsmalloc should never know internal of zs_handle.
> 
> OK. Then it can just forward declare it:
> 
> struct zs_handle;
> 
> and zsmalloc will treat it as an opaque pointer.
> 
>>
>> 3)
>>
>> - zsmalloc.h
>> void *zs_handle_to_ptr(struct zs_handle handle)
>> {
>> 	return handle.hanle;
>> }
>>
>> static struct zv_hdr *zv_create(..)
>> {
>> 	struct zs_handle handle;
>> 	..
>> 	handle = zs_malloc(pool, size);
>> 	..
>> 	return zs_handle_to_ptr(handle);
> 
>> }
> 
>>
>> Why should zsmalloc support such interface?
> 
> Why not? It is better than a 'void *' or a typedef.
> 
> It is modeled after a pte_t.


It's not same with pte_t.
We normally don't use pte_val to (void*) for unique index of slot.
The problem is that zcache assume handle of zsmalloc is a sizeof(void*)'s
unique value but zcache never assume it's a sizeof(void*).

> 
> 
>> It's a zcache problem so it's desriable to solve it in zcache internal.
> 
> Not really. We shouldn't really pass any 'void *' pointers around.
> 
>> And in future, if we can add/remove zs_handle's fields, we can't make
>> sure such API.
> 
> Meaning ... what exactly do you mean? That the size of the structure
> will change and we won't return the right value? Why not?
> If you use the 'zs_handle_to_ptr' won't that work? Especially if you
> add new values to the end of the struct it won't cause issues.


I mean we might change zs_handle to following as, in future.
(It's insane but who know it?)

struct zs_handle {
	int upper;
	int middle;
	int lower;
};

How could you handle this for zs_handle_to_ptr?

> 
>>
>>
>>>> Its true that making it a real struct would prevent accidental casts
>>>> to void * but due to the above problem, I think we have to stick
>>>> with unsigned long.
> 
> So the problem you are seeing is that you don't want 'struct zs_handle'
> be present in the drivers/staging/zsmalloc/zsmalloc.h header file?
> It looks like the proper place.


No. What I want is to remove coupling zsallocator's handle with zram/zcache.
They shouldn't know internal of handle and assume it's a pointer.

If Nitin confirm zs_handle's format can never change in future, I prefer "unsigned long" Nitin suggested than (void *).
It can prevent confusion that normal allocator's return value is pointer for address so the problem is easy.
But I am not sure he can make sure it.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
