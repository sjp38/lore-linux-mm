Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id EB5C56B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 20:14:36 -0400 (EDT)
Message-ID: <4FAC59F6.4080503@kernel.org>
Date: Fri, 11 May 2012 09:14:46 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FA33DF6.8060107@kernel.org> <20120509201918.GA7288@kroah.com> <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com> <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com> <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org> <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org> <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org> <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default>
In-Reply-To: <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dan,

On 05/11/2012 08:50 AM, Dan Magenheimer wrote:

>> From: Minchan Kim [mailto:minchan@kernel.org]
>>
>> Okay. Now it works but zcache coupled with zsmalloc tightly.
>> User of zsmalloc should never know internal of zs_handle.
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
>> }
>>
>> Why should zsmalloc support such interface?
>> It's a zcache problem so it's desriable to solve it in zcache internal.
>> And in future, if we can add/remove zs_handle's fields, we can't make
>> sure such API.
> 
> Hi Minchan --
> 
> I'm confused so maybe I am misunderstanding or you can
> explain further.  It seems like you are trying to redesign
> zsmalloc so that it can be a pure abstraction in a library.
> While I understand and value abstractions in software
> designs, the primary use now of zsmalloc is in zcache.  If

> there are other users that require a different interface
> or a more precise abstract API, zsmalloc could then
> evolve to meet the needs of multiple users.  But I think


At least, zram is also primary user and it also has such mess although it's not severe than zcache. zram->table[index].handle sometime has real (void*) handle, sometime (struct page*).
And I assume ramster you sent yesterday will be.

I think there are already many mess and I bet it will prevent going to mainline.
Especially, handle problem is severe because it a arguement of most functions exported in zsmalloc
So, we should clean up before late, IMHO.

> zcache is going to need more access to the internals
> of its allocator, not less.  Zsmalloc is currently missing
> some important functionality that (I believe) will be
> necessary to turn zcache into an enterprise-ready,


If you have such TODO list, could you post it?
It helps direction point of my stuff.

> always-on kernel feature.  If it evolves to add that
> functionality, then it may no longer be able to provide
> generic abstract access... in which case generic zsmalloc
> may then have zero users in the kernel.


Hmm, Do you want to make zsmalloc by zcache owned private allocator?

> 
> So I'd suggest we hold off on trying to make zsmalloc
> "pretty" until we better understand how it will be used
> by zcache (and ramster) and, if there are any, any future
> users.


zcache isn't urgent? I'm okay about zcache but at least, zram is when it merged into mainline, I think.
Many embedded system have a advantage with it so I hope we finish zsmalloc mess as soon as possble.

> 
> That's just my opinion...


Dan, Thanks for sharing your opinion.

> Dan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
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
