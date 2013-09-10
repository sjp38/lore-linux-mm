Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id D176D6B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 03:02:42 -0400 (EDT)
Message-ID: <522EC3D1.4010806@asianux.com>
Date: Tue, 10 Sep 2013 15:01:37 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/10/2013 02:43 PM, David Rientjes wrote:
> On Tue, 10 Sep 2013, Chen Gang wrote:
> 
>>> I think it would be better to keep mpol_to_str() returning void, and hence 
>>> avoiding the need for this patch, and make it so it cannot fail.  If the 
>>> mode is invalid, just store a 0 to the buffer (or "unknown"); and if 
>>> maxlen isn't large enough, make it a compile-time error (let's avoid 
>>> trying to be fancy and allocating less than 64 bytes on the stack if a 
>>> given context is known to have short mempolicy strings).
>>>
>>
>> Hmm... at least, like most of print functions, it need return a value
>> to tell the length it writes, so in my opinion, I still suggest it can
>> return a value.
>>
> 
> Why?  It can just store the string into the buffer pointed to by the 
> char *buffer and terminate it appropriately while taking care that it 
> doesn't exceed maxlen.  Why does the caller need to know the number of 
> bytes written?  If it really does, you could just do strlen(buffer).
> 
> If there's a real reason for it, then that's fine, I just think it can be 
> made to always succeed and never return < 0.  (And why is nobody checking 
> the return value today if it's so necessary?)
> 

For common printing functions: sprintf(), snprintf(), scnprintf().

For some of specific printing functions: drivers/usb/host/uhci-debug.c.

at least they can let caller easy use.


>> For common printing functions, caller knows about the string format and
>> all parameters, and also can control them,  so for callee, it is not
>> 'quite polite' to return any failures to caller.  :-)
>>
>> But for our function, caller may not know about the string format and
>> parameters' details, so callee has duty to check and process them:
>>
>>   e.g. "if related parameter is invalid, it is neccessary to notifiy to caller".
>>
> 
> Nobody is using mpol_to_str() to determine if a mempolicy mode is valid :)  
> If the struct mempolicy really has a bad mode, then just store "unknown" 
> or store a 0.  If maxlen is insufficient for the longest possible string 
> stored by mpol_to_str(), then it should be a compile-time error.
> 
> 

Hmm... what you said sounds reasonable if mpol_to_str() is a normal
static funciton (only used within a file).

For extern function, callee (inside) can not assume anything of caller
(outside) beyond the interface. So if failure occurs, better to report
to caller only, and let caller to check what to do next.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
