Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 8C2626B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 02:20:39 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3234440bkw.14
        for <linux-mm@kvack.org>; Sun, 11 Mar 2012 23:20:37 -0700 (PDT)
Message-ID: <4F5D95AF.1020108@openvz.org>
Date: Mon, 12 Mar 2012 10:20:31 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: Fwd: Control page reclaim granularity
References: <20120312002806.GA2436@barrios> <20120312020609.GA9610@gmail.com> <20120312051904.GA3831@barrios>
In-Reply-To: <20120312051904.GA3831@barrios>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>

Minchan Kim wrote:
> On Mon, Mar 12, 2012 at 10:06:09AM +0800, Zheng Liu wrote:
>> On Mon, Mar 12, 2012 at 09:29:34AM +0900, Minchan Kim wrote:
>>> I forgot to Ccing you.
>>> Sorry.
>>>
>>> ---------- Forwarded message ----------
>>> From: Minchan Kim<minchan@kernel.org>
>>> Date: Mon, Mar 12, 2012 at 9:28 AM
>>> Subject: Re: Control page reclaim granularity
>>> To: Minchan Kim<minchan@kernel.org>, linux-mm<linux-mm@kvack.org>,
>>> linux-kernel<linux-kernel@vger.kernel.org>, Konstantin Khlebnikov<
>>> khlebnikov@openvz.org>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com
>>>
>>>
>>> On Fri, Mar 09, 2012 at 12:54:03AM +0800, Zheng Liu wrote:
>>>> Hi Minchan,
>>>>
>>>> Sorry, I forgot to say that I don't subscribe linux-mm and linux-kernel
>>>> mailing list.  So please Cc me.
>>>>
>>>> IMHO, maybe we should re-think about how does user use mmap(2).  I
>>>> describe the cases I known in our product system.  They can be
>>>> categorized into two cases.  One is mmaped all data files into memory
>>>> and sometime it uses write(2) to append some data, and another uses
>>>> mmap(2)/munmap(2) and read(2)/write(2) to manipulate the files.  In the
>>>> second case,  the application wants to keep mmaped page into memory and
>>>> let file pages to be reclaimed firstly.  So, IMO, when application uses
>>>> mmap(2) to manipulate files, it is possible to imply that it wants keep
>>>> these mmaped pages into memory and do not be reclaimed.  At least these
>>>> pages do not be reclaimed early than file pages.  I think that maybe we
>>>> can recover that routine and provide a sysctl parameter to let the user
>>>> to set this ratio between mmaped pages and file pages.
>>>
>>> I am not convinced why we should handle mapped page specially.
>>> Sometimem, someone may use mmap by reducing buffer copy compared to read
>>> system call.
>>> So I think we can't make sure mmaped pages are always win.
>>>
>>> My suggestion is that it would be better to declare by user explicitly.
>>> I think we can implement it by madvise and fadvise's WILLNEED option.
>>> Current implementation is just readahead if there isn't a page in memory
>>> but I think
>>> we can promote from inactive to active if there is already a page in
>>> memory.
>>>
>>> It's more clear and it couldn't be affected by kernel page reclaim
>>> algorithm change
>>> like this.
>>
>> Thank you for your advice.  But I still have question about this
>> solution.  If we improve the madvise(2) and fadvise(2)'s WILLNEED
>> option,  it will cause an inconsistently status for pages that be
>> manipulated by madvise(2) and/or fadvise(2).  For example, when I call
>> madvise with WILLNEED flag, some pages will be moved into active list if
>> they already have been in memory, and other pages will be read into
>> memory and be saved in inactive list if they don't be in memory.  Then
>> pages that are in inactive list are possible to be reclaim.  So from the
>> view of users, it is inconsistent because some pages are in memory and
>> some pages are reclaimed.  But actually the user hopes that all of pages
>> can be kept in memory.  IMHO, this inconsistency is weird and makes users
>> puzzled.
>
> Now problem is that
>
> 1. User want to keep pages which are used once in a while in memory.
> 2. Kernel want to reclaim them because they are surely reclaim target
>     pages in point of view by LRU.
>
> The most desriable approach is that user should use mlock to guarantee
> them in memory. But mlock is too big overhead and user doesn't want to keep
> memory all pages all at once.(Ie, he want demand paging when he need the page)
> Right?
>
> madvise, it's a just hint for kernel and kernel doesn't need to make sure madvise's behavior.
> In point of view, such inconsistency might not be a big problem.
>
> Big problem I think now is that user should use madvise(WILLNEED) periodically because such
> activation happens once when user calls madvise. If user doesn't use page frequently after
> user calls it, it ends up moving into inactive list and even could be reclaimed.
> It's not good. :-(
>
> Okay. How about adding new VM_WORKINGSET?
> And reclaimer would give one more round trip in active/inactive list when reclaim happens
> if the page is referenced.
>
> Sigh. We have no room for new VM_FLAG in 32 bit.

It would be nice to mark struct address_space with this flag and export AS_UNEVICTABLE somehow.
Maybe we can reuse file-locking engine for managing these bits =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
