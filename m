Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C92D6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 22:29:48 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id u16so7901852iet.33
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 19:29:48 -0700 (PDT)
Message-ID: <5240F8D8.5040809@asianux.com>
Date: Tue, 24 Sep 2013 10:28:40 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <20130919003142.B72EC1840296@intranet.asianux.com> <alpine.DEB.2.02.1309231439360.11167@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309231439360.11167@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/24/2013 05:46 AM, David Rientjes wrote:
> On Thu, 19 Sep 2013, Chen,Gang( e??a??) wrote:
> 
>> Please search BUG_ON() in kernel wide source code, we can know whether
>> it is commonly used or not.
>>
>> Please search BUG in arch/ sub-system, we can know which architectures
>> customize BUG/BUG_ON.
>>
>> After do the 2 things, In my opinion, we can treat BUG/BUG_ON() is common
>> implementation, and most of architectures uses the default one.
>>
>> Please check again, thanks.
>>
> 
> BUG_ON() is used for fatal conditions where continuing could potentially 
> be harmful.  Obviously it is commonly used in a kernel.  That doesn't mean 
> we BUG_ON() when a string hasn't been defined for a mempolicy mode.  
> mpol_to_str() is not critical.
> 
> It is not a fatal condition, and nothing you say is going to convince 
> anybody on this thread that it's a fatal condition.
> 

If mpol_to_str() fail, the buffer passed to next seq_printf() may cause
memory over flow.

So in current implementation, if mpol_to_str() fails, it may cause
critical issue ("it's a fatal condition").

My original fix is "check and return if fail", but related members think
it shouldn't fail, so use BUG_ON(): "when fails, means OS is continuing
blindly, and next, may cause direct critical issue".

>>>  That's absolutely insane.  If code is not allocating enough memory for the 
>>>  maximum possible length of a string to be stored by mpol_to_str(), it's a 
>>>  bug in the code.  We do not panic and reboot the user's machine for such a 
>>>  bug.  Instead, we break the build and require the broken code to be fixed.
>>>  
>>
>> Please say in polite.
>>
> 
> You want a polite response when you're insisting that we declare absolute 
> failure, BUG_ON(), stop, and reboot the kernel because a mempolicy mode 
> isn't defined as a string in mpol_to_str()?  That sounds like an impolite 
> response to the user, so see my politeness to you as coming from the users 
> of the systems you just crashed.
> 

Hmm... Except God, we (everyone, include real users) only can discuss
judge, and check things and actions based on the proves, but has no
right to discuss, judge and check persons.

When it is just discussing (not get a conclusion), it is impolite to
make a conclusion forcefully by oneself with his/her own feelings.

And when we really get a conclusion, we need use the words which only
can express the result clearly (e.g. correct, incorrect) to make a
conclusion, not use words also contents his/her own feelings.


> This is a compile-time problem, not run-time.
> 

Hmm... I am not quite familiar with the details, but at least for me,
what you said is acceptable (at least, we can try).

Current mpol_to_str() interface leads all readers have to treat it as
run-time problem, not as compile-time problem.

So in my opinion, if really try the compile-time fix, the interface need
be changed: "need use struct (have a member buf[64];) pointer instead of
'buffer' and 'maxlen' parameters".


>> Can you be sure, the "maxlen == 50" in "fs/proc/task_mmu()", must be a bug??
>>
> 
> I asked you to figure out the longest string possible to be stored by 
> mpol_to_str().  There's nothing mysterious about that function.  It's 
> deterministic.  If you really can't figure out the value this should be, 
> then you shouldn't be touching mpol_to_str().
> 

At present, it seems easy to get longest string, so you can try, don't
need me; in future, I don't know whether it will be changed, maybe you
know (need give a length long enough for future using).


I don't plan to touch mpol_to_str(), in my opinion, just treat it as
run-time problem is still acceptable: it is clear enough for readers and
writers.

Hmm... at last, I still welcome you to try to send your compile-time fix
patch for it (although I am not quite sure whether it will be acceptable
by other members).


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
