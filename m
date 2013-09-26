Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BA2CF6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:23:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so1455688pab.32
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:23:56 -0700 (PDT)
Message-ID: <52445174.70409@linux.intel.com>
Date: Thu, 26 Sep 2013 08:23:32 -0700
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com> <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org>
In-Reply-To: <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/25/2013 6:21 PM, Andrew Morton wrote:
> On Wed, 25 Sep 2013 18:15:21 -0700 Arjan van de Ven <arjan@linux.intel.com> wrote:
>
>> On 9/25/2013 4:47 PM, Andi Kleen wrote:
>>>> Also, the changelogs don't appear to discuss one obvious downside: the
>>>> latency incurred in bringing a bank out of one of the low-power states
>>>> and back into full operation.  Please do discuss and quantify that to
>>>> the best of your knowledge.
>>>
>>> On Sandy Bridge the memry wakeup overhead is really small. It's on by default
>>> in most setups today.
>>
>> btw note that those kind of memory power savings are content-preserving,
>> so likely a whole chunk of these patches is not actually needed on SNB
>> (or anything else Intel sells or sold)
>
> (head spinning a bit).  Could you please expand on this rather a lot?

so there is two general ways to save power on memory

one way keeps the content of the memory there

the other way loses the content of the memory.

in the first type, there are degrees of power savings (each with their own costs), and the mechanism to enter/exit
tends to be fully automatic, e.g. OS invisible. (and generally very very fast.. measured in low numbers of nanoseconds)

in the later case the OS by nature has to get involved and actively free the content of the memory prior to
setting the power level lower (and thus lose the content).


on the machines Srivatsa has been measuring, only the first type exists... e.g. content is preserved.
at which point, I am skeptical that it is worth spending a lot of CPU time (and thus power!) to move stuff around
or free memory (e.g. reduce disk cache efficiency -> loses power as well).

the patches posted seem to go to great lengths doing these kind of things.


to get the power savings, my deep suspicion (based on some rudimentary experiments done internally to Intel
earlier this year) is that it is more than enough to have "statistical" level of "binding", to get 95%+ of
the max theoretical power savings.... basically what todays NUMA policy would do.



>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
