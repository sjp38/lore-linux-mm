Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B0A956B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:09:05 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so906233qcs.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 12:09:04 -0700 (PDT)
Message-ID: <4FC7C1CD.7020701@gmail.com>
Date: Thu, 31 May 2012 15:09:01 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch] fs: implement per-file drop caches
References: <1338385120-14519-1-git-send-email-amwang@redhat.com>   <4FC6393B.7090105@draigBrady.com> <1338445233.19369.21.camel@cr0>  <4FC70FFE.50809@gmail.com> <1338466281.19369.44.camel@cr0>
In-Reply-To: <1338466281.19369.44.camel@cr0>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, =?UTF-8?B?UMOhZHJhaWcgQnI=?= =?UTF-8?B?YWR5?= <P@draigBrady.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

(5/31/12 8:11 AM), Cong Wang wrote:
> On Thu, 2012-05-31 at 02:30 -0400, KOSAKI Motohiro wrote:
>> (5/31/12 2:20 AM), Cong Wang wrote:
>>> On Wed, 2012-05-30 at 16:14 +0100, PA!draig Brady wrote:
>>>> On 05/30/2012 02:38 PM, Cong Wang wrote:
>>>>> This is a draft patch of implementing per-file drop caches.
>>>>>
>>>>> It introduces a new fcntl command  F_DROP_CACHES to drop
>>>>> file caches of a specific file. The reason is that currently
>>>>> we only have a system-wide drop caches interface, it could
>>>>> cause system-wide performance down if we drop all page caches
>>>>> when we actually want to drop the caches of some huge file.
>>>>
>>>> This is useful functionality.
>>>> Though isn't it already provided with POSIX_FADV_DONTNEED?
>>>
>>> Thanks for teaching this!
>>>
>>> However, from the source code of madvise_dontneed() it looks like it is
>>> using a totally different way to drop page caches, that is to invalidate
>>> the page mapping, and trigger a re-mapping of the file pages after a
>>> page fault. So, yeah, this could probably drop the page caches too (I am
>>> not so sure, haven't checked the code in details), but with my patch, it
>>> flushes the page caches directly, what's more, it can also prune
>>> dcache/icache of the file.
>>
>> madvise should work. I don't think we need duplicate interface. Moreomover
>> madvise(2) is cleaner than fcntl(2).
>>
>
> I think madvise(DONTNEED) attacks the problem in a different approach,
> it munmaps the file mapping and by the way drops the page caches, my
> approach is to drop the page caches directly similar to what sysctl
> drop_caches.
>
> What about private file mapping? Could madvise(DONTNEED) drop the page
> caches too even when the other process is doing the same private file
> mapping? At least my patch could do this.

Right. But a process can makes another mappings if a process have enough
permission. and if it doesn't, a process shouldn't be able to drop a shared
cache.


> I am not sure if fcntl() is a good interface either, this is why the
> patch is marked as RFC. :-D

But, if you can find certain usecase, I'm not against anymore.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
