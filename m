Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AE4C26B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:00:12 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so120078bkw.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:00:11 -0700 (PDT)
Message-ID: <4F5ED458.5070301@openvz.org>
Date: Tue, 13 Mar 2012 09:00:08 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: Fwd: Control page reclaim granularity
References: <4F5D95AF.1020108@openvz.org> <20120312081413.GA10923@gmail.com> <20120312134226.GA5120@barrios> <4F5E05AD.20200@openvz.org> <20120313024818.GA7125@barrios> <4F5ECF01.2000402@openvz.org>
In-Reply-To: <4F5ECF01.2000402@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

Konstantin Khlebnikov wrote:
> Minchan Kim wrote:
>> On Mon, Mar 12, 2012 at 06:18:21PM +0400, Konstantin Khlebnikov wrote:
>>> Minchan Kim wrote:
>>>> On Mon, Mar 12, 2012 at 04:14:14PM +0800, Zheng Liu wrote:
>>>>> On 03/12/2012 02:20 PM, Konstantin Khlebnikov wrote:
>>>>>> Minchan Kim wrote:
>>>>>>> On Mon, Mar 12, 2012 at 10:06:09AM +0800, Zheng Liu wrote:
> <CUT>
>>>>>>>
>>>>>>> Now problem is that
>>>>>>>
>>>>>>> 1. User want to keep pages which are used once in a while in memory.
>>>>>>> 2. Kernel want to reclaim them because they are surely reclaim target
>>>>>>> pages in point of view by LRU.
>>>>>>>
>>>>>>> The most desriable approach is that user should use mlock to guarantee
>>>>>>> them in memory. But mlock is too big overhead and user doesn't want to
>>>>>>> keep
>>>>>>> memory all pages all at once.(Ie, he want demand paging when he need
>>>>>>> the page)
>>>>>>> Right?
>>>>>>>
>>>>>>> madvise, it's a just hint for kernel and kernel doesn't need to make
>>>>>>> sure madvise's behavior.
>>>>>>> In point of view, such inconsistency might not be a big problem.
>>>>>>>
>>>>>>> Big problem I think now is that user should use madvise(WILLNEED)
>>>>>>> periodically because such
>>>>>>> activation happens once when user calls madvise. If user doesn't use
>>>>>>> page frequently after
>>>>>>> user calls it, it ends up moving into inactive list and even could be
>>>>>>> reclaimed.
>>>>>>> It's not good. :-(
>>>>>>>
>>>>>>> Okay. How about adding new VM_WORKINGSET?
>>>>>>> And reclaimer would give one more round trip in active/inactive list
>>>>>>> erwhen reclaim happens
>>>>>>> if the page is referenced.
>>>>>>>
>>>>>>> Sigh. We have no room for new VM_FLAG in 32 bit.
>>>>>> p
>>>>>> It would be nice to mark struct address_space with this flag and export
>>>>>> AS_UNEVICTABLE somehow.
>>>>>> Maybe we can reuse file-locking engine for managing these bits =)
>>>>>
>>>>> Make sense to me. We can mark this flag in struct address_space and check
>>>>> it in page_refereneced_file(). If this flag is set, it will be cleard and
>>>>
>>>> Disadvantage is that we could set reclaim granularity as per-inode.
>>>> I want to set it as per-vma, not per-inode.
>>>
>>> But with per-inode flag we can tune all files, not only memory-mapped.
>>
>> I don't oppose per-inode setting but I believe we need file range or mmapped vma,
>> still. One file may have different characteristic part, something is working set
>> something is streaming part.
>>
>>> See, attached patch. Currently I thinking about managing code,
>>> file-locking engine really fits perfectly =)
>>
>> file-locking engine?
>> You consider fcntl as interface for it?
>> What do you mean?
>>
>
> If we set bits on inode we somehow account its users and clear AS_WORKINGSET and AS_UNEVICTABLE
> at last file close. We can use file-locking engine for locking inodes in memory -- file lock automatically
> release inode at last fput(). Maybe it's too tricky and we should add couple simple atomic counters to
> generic strict inode (like i_writecount/i_readcount) but in this case we will add new code on fast-path.
> So, looks like invention new kind of struct file_lock is best approach.
> I don't want implement range-locking for now, but I can do it if somebody really wants this.
>
> Yes, we can use fcntl(), but fadvise() is much better.

Another mad idea: if we mark vma, then we can add fake vma (belong init_mm for example) to
inode rmap to lock inode's pages range in memory without actually mapping file.
In page_referenced_one() we should handle this fake vma differently,
because page_check_address() will always fail for it.
Thus we can effectively implement AS_WORKINGSET and AS_UNEVICTABLE for arbitrary page ranges.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
