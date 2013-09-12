Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C8DD86B0036
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 23:14:08 -0400 (EDT)
Message-ID: <5231313D.5040504@asianux.com>
Date: Thu, 12 Sep 2013 11:13:01 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com>
In-Reply-To: <523124B7.8070408@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/12/2013 10:19 AM, KOSAKI Motohiro wrote:
> (9/11/13 8:33 PM), David Rientjes wrote:
>> On Tue, 10 Sep 2013, Chen Gang wrote:
>>
>>>> Why?  It can just store the string into the buffer pointed to by the
>>>> char *buffer and terminate it appropriately while taking care that it
>>>> doesn't exceed maxlen.  Why does the caller need to know the number of
>>>> bytes written?  If it really does, you could just do strlen(buffer).
>>>>
>>>> If there's a real reason for it, then that's fine, I just think it
>>>> can be
>>>> made to always succeed and never return < 0.  (And why is nobody
>>>> checking
>>>> the return value today if it's so necessary?)
>>>>
>>>
>>> For common printing functions: sprintf(), snprintf(), scnprintf().
>>>
>>> For some of specific printing functions: drivers/usb/host/uhci-debug.c.
>>>
>>> at least they can let caller easy use.
>>>
>>
>> Nobody needs mpol_to_str() to return the number of characters written,
>> period.  It's one of the most trivial functions you're going to see in
>> the
>> mempolicy code, it takes a pointer to a buffer and it stores
>> characters to
>> it for display.  Nobody is going to use it for anything else.  Let's not
>> overcomplicate this trivial function.
>>
>>>> Nobody is using mpol_to_str() to determine if a mempolicy mode is
>>>> valid :)
>>>> If the struct mempolicy really has a bad mode, then just store
>>>> "unknown"
>>>> or store a 0.  If maxlen is insufficient for the longest possible
>>>> string
>>>> stored by mpol_to_str(), then it should be a compile-time error.
>>>>
>>>>
>>>
>>> Hmm... what you said sounds reasonable if mpol_to_str() is a normal
>>> static funciton (only used within a file).
>>>
>>> For extern function, callee (inside) can not assume anything of caller
>>> (outside) beyond the interface. So if failure occurs, better to report
>>> to caller only, and let caller to check what to do next.
>>>
>>
>> Are you just preaching about the best practices of software engineering?
>> mpol_to_str() should never fail at runtime, plain and simple.  If
>> somebody
>> introduces a new mode and doesn't update it to print correctly, let's not
>> fail the read().  Let's just print "unknown".  And if someone passes too
>> small of a buffer, break it at compile time so it gets noticed and fixed.
>>
>> I guarantee you that any kernel developer who writes code to call
>> mpol_to_str() will be happy it never fails at runtime.  Really.
> 
> Agreed. Even though we don't change mpol_to_str() interface, please just
> add BUG_ON into shmem_show_mpol(). It is much simpler than current
> proposal.
> 

Hmm... that is simpler and clearer for writers, but may not for readers.

> At least, currently mpol_to_str() already have following assertion. I mean,
> the code assume every developer know maximum length of mempolicy. I have no
> seen any reason to bring addional complication to shmem area.
> 
> 
>     /*
>      * Sanity check:  room for longest mode, flag and some nodes
>      */
>     VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
> 
> Thanks.
> 

Hmm... *BUG_ON() is for protecting the OS continue blindly, can we be
sure: "in current condition, OS is continuing blindly?"

If an extern function's parameter is invalid, it mainly means caller
incorrectly use the function (which need return -EINVAL), not means "the
OS is continuing blindly".


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
