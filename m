Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 433FA6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:46:15 -0400 (EDT)
Message-ID: <5237A615.5050405@asianux.com>
Date: Tue, 17 Sep 2013 08:45:09 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com> <5233CF32.3080409@jp.fujitsu.com> <52367AB0.9000805@asianux.com> <alpine.DEB.2.02.1309161309490.26194@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309161309490.26194@chino.kir.corp.google.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On 09/17/2013 04:13 AM, David Rientjes wrote:
> On Mon, 16 Sep 2013, Chen Gang wrote:
> 
>> Hmm... I am not quite sure: a C compiler is clever enough to know about
>> that.
>>
>> At least, for ANSI C definition, the C compiler has no duty to know
>> about that.
>>
>> And it is not for an optimization, either, so I guess the C compiler has
>> no enought interests to support this features (know about that).
>>
> 
> What on earth are we talking about in this thread?
> 

??

> Rename mpol_to_str() to __mpol_to_str().  Make a static inline function in 
> mempolicy.h named mpol_to_str().  That function does BUILD_BUG_ON(maxlen < 
> 64) and then calls __mpol_to_str().
> 
> Modify __mpol_to_str() to store "unknown" when mpol->mode does not match 
> any known MPOL_* constant.
> 

Can we be sure 'maxlen' should not be less than 64?  For show_numa_map()
in fs/proc/task_mmu.c, it use 50 which is less than 64, is it correct?


> Both functions can now return void.
> 
> This is like a ten line diff.  Seriously.
> 
> 

Can we be sure that our output contents are always less than 64 bytes?
Do we need BUG_ON() instead of all '-ENOSPC' in mpol_to_str()?


Hmm... If assume what you said above was always correct: "we are always
sure 64 bytes is enough, and 'maxlen' should be never less than 64".

  It would be better to use a structure (which has a member "char buf[64]") pointer instead of 'buffer' and 'maxlen'.
   (and also still need check 64 memory bondary and '\0' within mpol_to_str).


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
