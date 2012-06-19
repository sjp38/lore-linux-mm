Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 509EF6B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 15:29:28 -0400 (EDT)
Message-ID: <4FE0D319.6070606@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 15:29:29 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com> <CAHGf_=pq_UJfr22kYC=vCyEDRKx75zt5eZ27+VcqFZFqc-KHTw@mail.gmail.com> <alpine.DEB.2.00.1206182321160.27620@chino.kir.corp.google.com> <4FE0B79E.1060601@jp.fujitsu.com> <alpine.DEB.2.00.1206191157050.12425@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206191157050.12425@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

On 6/19/2012 2:59 PM, David Rientjes wrote:
> On Tue, 19 Jun 2012, KOSAKI Motohiro wrote:
> 
>>> The killed process may exit but it does not guarantee that its memory will 
>>> be freed if it's shared with current.  This is the case that the patch is 
>>> addressing, where right now we unnecessarily schedule if current has been 
>>> killed or is already along the exit path.  We want to retry as soon as 
>>> possible so that either the allocation now succeeds or we can recall the 
>>> oom killer as soon as possible and get TIF_MEMDIE set because we have a 
>>> fatal signal so current may exit in a timely way as well.  The point is 
>>> that if current has either a SIGKILL or is already exiting as it returns 
>>> from the oom killer, it does no good to continue to stall and prevent that 
>>> memory freeing.
>>
>> You missed live lock risk. immediate retry makes immediate fail if no one
>> freed any memory. Even if the task call out_of_memory() again, select_bad_process()
>> may return -1 and don't makes any forward progress.
>>
> 
> I missed a livelock?  You missed the fact that the oom killer is 
> short-circuited by this before anything else gets done:
> 
> 	if (fatal_signal_pending(current)) {
> 		set_thread_flag(TIF_MEMDIE);
> 		return;
> 	}
> 

I talked about PF_EXITING. fatal signal is no problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
