Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3B9206B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 10:47:35 -0400 (EDT)
Received: by yhr47 with SMTP id 47so2259785yhr.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 07:47:34 -0700 (PDT)
Message-ID: <4FABD503.4030808@vflare.org>
Date: Thu, 10 May 2012 10:47:31 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org> <4FA28907.9020300@vflare.org> <4FA2A2F0.3030509@linux.vnet.ibm.com> <4FA33DF6.8060107@kernel.org> <20120509201918.GA7288@kroah.com> <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com>
In-Reply-To: <20120510140215.GC26152@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 5/10/12 10:02 AM, Konrad Rzeszutek Wilk wrote:
> On Thu, May 10, 2012 at 11:03:19AM +0900, Minchan Kim wrote:
>> On 05/10/2012 05:19 AM, Greg Kroah-Hartman wrote:
>>
>>> On Fri, May 04, 2012 at 11:24:54AM +0900, Minchan Kim wrote:
>>>> On 05/04/2012 12:23 AM, Seth Jennings wrote:
>>>>
>>>>> On 05/03/2012 08:32 AM, Nitin Gupta wrote:
>>>>>
>>>>>> On 5/3/12 2:40 AM, Minchan Kim wrote:
>>>>>>> We should use zs_handle instead of void * to avoid any
>>>>>>> confusion. Without this, users may just treat zs_malloc return value as
>>>>>>> a pointer and try to deference it.
>>>>>>>
>>>>>>> Cc: Dan Magenheimer<dan.magenheimer@oracle.com>
>>>>>>> Cc: Konrad Rzeszutek Wilk<konrad.wilk@oracle.com>
>>>>>>> Signed-off-by: Minchan Kim<minchan@kernel.org>
>>>>>>> ---
>>>>>>>    drivers/staging/zcache/zcache-main.c     |    8 ++++----
>>>>>>>    drivers/staging/zram/zram_drv.c          |    8 ++++----
>>>>>>>    drivers/staging/zram/zram_drv.h          |    2 +-
>>>>>>>    drivers/staging/zsmalloc/zsmalloc-main.c |   28
>>>>>>> ++++++++++++++--------------
>>>>>>>    drivers/staging/zsmalloc/zsmalloc.h      |   15 +++++++++++----
>>>>>>>    5 files changed, 34 insertions(+), 27 deletions(-)
>>>>>>
>>>>>> This was a long pending change. Thanks!
>>>>>
>>>>>
>>>>> The reason I hadn't done it before is that it introduces a checkpatch
>>>>> warning:
>>>>>
>>>>> WARNING: do not add new typedefs
>>>>> #303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
>>>>> +typedef void * zs_handle;
>>>>>
>>>>
>>>>
>>>> Yes. I did it but I think we are (a) of chapter 5: Typedefs in Documentation/CodingStyle.
>>>>
>>>>   (a) totally opaque objects (where the typedef is actively used to _hide_
>>>>       what the object is).
>>>>
>>>> No?
>>>
>>> No.
>>>
>>> Don't add new typedefs to the kernel.  Just use a structure if you need
>>> to.
>>
>>
>> I tried it but failed because there were already tightly coupling between [zcache|zram]
>> and zsmalloc.
>> They already knows handle's internal well so they used it as pointer, even zcache keeps
>> handle's value as some key in tmem_put and tmem_get
>> AFAIK, ramster also will use zsmalloc sooner or later and add more coupling codes. Sigh.
>> Please fix it as soon as possible.
>>
>> Dan, Seth
>> Any ideas?
>
> struct zs {
> 	void *ptr;
> };
>
> And pass that structure around?
>

A minor problem is that we store this handle value in a radix tree node. 
If we wrap it as a struct, then we will not be able to store it directly 
in the node -- the node will have to point to a 'struct zs'. This will 
unnecessarily waste sizeof(void *) for every object stored.

We could 'memcpy' struct zs to a void * and then store that directly in 
the radix node but not sure if that would be less ugly than just 
returning the handle as a void * as is done currently.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
