Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id CC8216B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 04:15:44 -0400 (EDT)
Received: by mail-vb0-f50.google.com with SMTP id w15so1054213vbb.9
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 01:15:43 -0700 (PDT)
Message-ID: <5166712C.7040802@gmail.com>
Date: Thu, 11 Apr 2013 04:15:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org> <5165CA22.6080808@gmail.com> <20130411065546.GA10303@blaptop> <5166643E.6050704@gmail.com> <20130411080243.GA12626@blaptop>
In-Reply-To: <20130411080243.GA12626@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

(4/11/13 4:02 AM), Minchan Kim wrote:
> On Thu, Apr 11, 2013 at 03:20:30AM -0400, KOSAKI Motohiro wrote:
>>>>>   DONTNEED makes sure user always can see zero-fill pages after
>>>>>   he calls madvise while vrange can see data or encounter SIGBUS.
>>>>
>>>> For replacing DONTNEED, user want to zero-fill pages like DONTNEED
>>>> instead of SIGBUS. So, new flag option would be nice.
>>>
>>> If userspace people want it, I can do it. 
>>> But not sure they want it at the moment becaue vrange is rather
>>> different concept of madvise(DONTNEED) POV usage.
>>>
>>> As you know well, in case of DONTNEED, user calls madvise _once_ and
>>> VM releases memory as soon as he called system call.
>>> But vrange is same with delayed free when the system memory pressure
>>> happens so user can't know OS frees the pages anytime.
>>> It means user should call pair of system call both VRANGE_VOLATILE
>>> and VRANGE_NOVOLATILE for right usage of volatile range
>>> (for simple, I don't want to tell SIGBUS fault recovery method).
>>> If he took a mistake(ie, NOT to call VRANGE_NOVOLATILE) on the range
>>> which is used by current process, pages used by some process could be
>>> disappeared suddenly.
>>>
>>> In summary, I don't think vrange is a replacement of madvise(DONTNEED)
>>> but could be useful with madvise(DONTNEED) friend. For example, we can
>>> make return 1 in vrange(VRANGE_VOLATILE) if memory pressure was already
>>
>> Do you mean vrange(VRANGE_UNVOLATILE)?
> 
> I meant VRANGE_VOLATILE. It seems my explanation was poor. Here it goes, again.
> Now vrange's semantic return just 0 if the system call is successful, otherwise,
> return error. But we can change it as folows
> 
> 1. return 0 if the system call is successful and memory pressure isn't severe
> 2. return 1 if the system call is successful and memory pressure is severe
> 3. return -ERRXXX if the system call is failed by some reason
> 
> So the process can know system-wide memory pressure without peeking the vmstat
> and then call madvise(DONTNEED) right after vrange call. The benefit is system
> can zap all pages instantly.

Do you mean your patchset is not latest? and when do you use this feature? what's
happen VRANGE_VOLATILE return 0 and purge the range just after returning syscall.


>> btw, assign new error number to asm-generic/errno.h is better than strange '1'.
> 
> I can and admit "1" is rather weired.
> But it's not error, either.

If this is really necessary, I don't oppose it. However I am still not convinced.



>>> severe so user can catch up memory pressure by return value and calls
>>> madvise(DONTNEED) if memory pressure was already severe. Of course, we
>>> can handle it vrange system call itself(ex, change vrange system call to
>>> madvise(DONTNEED) but don't want it because I want to keep vrange hinting
>>> sytem call very light at all times so user can expect latency.
>>
>> For allocator usage, vrange(UNVOLATILE) is annoying and don't need at all.
>> When data has already been purged, just return new zero filled page. so,
>> maybe adding new flag is worthwhile. Because malloc is definitely fast path
> 
> I really want it and it's exactly same with madvise(MADV_FREE).
> But for implementation, we need page granularity someting in address range
> in system call context like zap_pte_range(ex, clear page table bits and
> mark something to page flags for reclaimer to detect it).
> It means vrange system call is still bigger although we are able to remove
> lazy page fault.
> 
> Do you have any idea to remove it? If so, I'm very open to implement it.

Hm. Maybe I am missing something. I'll look the code closely after LFS.


>> and adding new syscall invokation is unwelcome.
> 
> Sure. But one more system call could be cheaper than page-granuarity
> operation on purged range.

I don't think vrange(VOLATILE) cost is the related of this discusstion.
Whether sending SIGBUS or just nuke pte, purge should be done on vmscan,
not vrange() syscall.









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
