Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9893B6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 23:33:14 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v14so41692pde.32
        for <linux-mm@kvack.org>; Mon, 15 Apr 2013 20:33:13 -0700 (PDT)
Message-ID: <516CC675.8020903@linaro.org>
Date: Mon, 15 Apr 2013 20:33:09 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v7 00/11] Support vrange for anonymous page
References: <1363073915-25000-1-git-send-email-minchan@kernel.org> <5165CA22.6080808@gmail.com> <20130411065546.GA10303@blaptop> <5166643E.6050704@gmail.com> <20130411080243.GA12626@blaptop> <5166712C.7040802@gmail.com> <20130411083146.GB12626@blaptop> <5166D037.6040405@gmail.com> <20130414074204.GC8241@blaptop>
In-Reply-To: <20130414074204.GC8241@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kernel.2@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/14/2013 12:42 AM, Minchan Kim wrote:
> Hi KOSAKI,
>
> On Thu, Apr 11, 2013 at 11:01:11AM -0400, KOSAKI Motohiro wrote:
>>>>>> and adding new syscall invokation is unwelcome.
>>>>> Sure. But one more system call could be cheaper than page-granuarity
>>>>> operation on purged range.
>>>> I don't think vrange(VOLATILE) cost is the related of this discusstion.
>>>> Whether sending SIGBUS or just nuke pte, purge should be done on vmscan,
>>>> not vrange() syscall.
>>> Again, please see the MADV_FREE. http://lwn.net/Articles/230799/
>>> It does changes pte and page flags on all pages of the range through
>>> zap_pte_range. So it would make vrange(VOLASTILE) expensive and
>>> the bigger cost is, the bigger range is.
>> This haven't been crossed my mind. now try_to_discard_one() insert vrange
>> for making SIGBUS. then, we can insert pte_none() as the same cost too. Am
>> I missing something?
> For your requirement, we need some tracking model to detect some page is
> using by the process currently before VM discards it *if* we don't give
> vrange(NOVOLATILE) pair system call(Look at below). So the tracking model
> should be formed in vrange(VOLATILE) system call context.

To further clarify Minchan's note here, the reason its important for the 
application to use vrange(NOVOLATILE), its really to help define _when 
the range stops being volatile_.

In your libc hack to use vrange(), you see the benfit of not immediately 
purging the memory as you do with MADV_DONTNEED. However, if the heap 
grows again, and those address are re-used, nothing has stopped those 
pages from continuing to be volatile. Thus the kernel could then decide 
to purge those pages after they start to be used again, and you'd lose 
data. I suspect that's not what you want. :)

Rik's MADV_FREE implementation is very similar to vrange(VOLATILE), but 
has an implicit vrange(NOVOLATILE) on any page write. So by dirtying a 
page, it stops the kernel from later purging it.

This MADV_FREE semantic works very well if you always want zerofill (as 
in the case of malloc/free). But for other data, its important to know 
something was lost (as a zero page could be valid data), and that's why 
we provide the SIGBUS, as well as the purged notification on 
vrange(NOVOLATILE).

In other-words, as long as you do a vrange(NOVOLATILE) when you grow the 
heap again (before its used), it should be very similar to the MADV_FREE 
behavior, but is more flexible for other use cases.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
