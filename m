Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 874266B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 21:21:49 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so6345534pdi.19
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 18:21:49 -0700 (PDT)
Message-ID: <5238FFE8.5080008@asianux.com>
Date: Wed, 18 Sep 2013 09:20:40 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com> <5233CF32.3080409@jp.fujitsu.com> <52367AB0.9000805@asianux.com> <alpine.DEB.2.02.1309161309490.26194@chino.kir.corp.google.com> <5237A615.5050405@asianux.com> <alpine.DEB.2.02.1309171549140.21696@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309171549140.21696@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On 09/18/2013 06:51 AM, David Rientjes wrote:
> On Tue, 17 Sep 2013, Chen Gang wrote:
> 
>>> Rename mpol_to_str() to __mpol_to_str().  Make a static inline function in 
>>> mempolicy.h named mpol_to_str().  That function does BUILD_BUG_ON(maxlen < 
>>> 64) and then calls __mpol_to_str().
>>>
>>> Modify __mpol_to_str() to store "unknown" when mpol->mode does not match 
>>> any known MPOL_* constant.
>>>
>>
>> Can we be sure 'maxlen' should not be less than 64?  For show_numa_map()
>> in fs/proc/task_mmu.c, it use 50 which is less than 64, is it correct?
>>
> 
> Whatever the max string length is that can be stored by mpol_to_str() 
> preferably rounded to the nearest power of two.
> 

Do you mean: show_numa_map() in "fs/proc/task_mmu.c" also need be
'fixed', what it has done (use 50) is incorrect?


>> Can we be sure that our output contents are always less than 64 bytes?
>> Do we need BUG_ON() instead of all '-ENOSPC' in mpol_to_str()?
>>
> 
> You can determine the maximum string length by looking at the 
> implementation of mpol_to_str().
> 

Can we be sure maximum string will be never changed in future?

>> Hmm... If assume what you said above was always correct: "we are always
>> sure 64 bytes is enough, and 'maxlen' should be never less than 64".
>>
>>   It would be better to use a structure (which has a member "char buf[64]") pointer instead of 'buffer' and 'maxlen'.
>>    (and also still need check 64 memory bondary and '\0' within mpol_to_str).
>>
> 
> That's ridiculous, kernel developers who call mpol_to_str() aren't idiots.
> 

It seems, it is not quite polite. ;-)


Hmm... for extern function, caller has duty to understand interface
precisely, but no duty to understand internal implementation.

So if callee wants caller to know about something, it needs 'express' it
through its' interface, callee can not assume that caller should
understand internal implementation.


> I think at this point it will just be best if I propose a patch and ask 
> for it to be merged into the -mm tree rather than continue this thread.
> 
> 

Hmm... you can try to send a related patch for it, but I am not quite
sure whether can pass reviewers' checking or not.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
