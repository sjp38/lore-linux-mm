Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80ECF8D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 18:45:13 -0500 (EST)
Received: by iyi20 with SMTP id 20so1794966iyi.14
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 15:45:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110213173336.GC23919@balbir.in.ibm.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
	<AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
	<20110128111833.GD5054@balbir.in.ibm.com>
	<AANLkTin4JM6phwy0wuV6fV-i-3UwP_GGmXh1vN=Wz2u=@mail.gmail.com>
	<AANLkTi=hhKJGXwe1OyFsGF9StLJnYFX+QqUpNLXmfVc=@mail.gmail.com>
	<20110213173336.GC23919@balbir.in.ibm.com>
Date: Thu, 17 Feb 2011 08:45:11 +0900
Message-ID: <AANLkTik4pXr_3hY3QoivMHHA6zq-k35f4HPNLZZC8bge@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

On Mon, Feb 14, 2011 at 2:33 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * MinChan Kim <minchan.kim@gmail.com> [2011-02-10 14:41:44]:
>
>> I don't know why the part of message is deleted only when I send you.
>> Maybe it's gmail bug.
>>
>> I hope mail sending is successful in this turn. :)
>>
>> On Thu, Feb 10, 2011 at 2:33 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> > Sorry for late response.
>> >
>> > On Fri, Jan 28, 2011 at 8:18 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> >> * MinChan Kim <minchan.kim@gmail.com> [2011-01-28 16:24:19]:
>> >>
>> >>> >
>> >>> > But the assumption for LRU order to change happens only if the page
>> >>> > cannot be successfully freed, which means it is in some way active..
>> >>> > and needs to be moved no?
>> >>>
>> >>> 1. holded page by someone
>> >>> 2. mapped pages
>> >>> 3. active pages
>> >>>
>> >>> 1 is rare so it isn't the problem.
>> >>> Of course, in case of 3, we have to activate it so no problem.
>> >>> The problem is 2.
>> >>>
>> >>
>> >> 2 is a problem, but due to the size aspects not a big one. Like you
>> >> said even lumpy reclaim affects it. May be the reclaim code could
>> >> honour may_unmap much earlier.
>> >
>> > Even if it is, it's a trade-off to get a big contiguous memory. I
>> > don't want to add new mess. (In addition, lumpy is weak by compaction
>> > as time goes by)
>> > What I have in mind for preventing LRU ignore is that put the page
>> > into original position instead of head of lru. Maybe it can help the
>> > situation both lumpy and your case. But it's another story.
>> >
>> > How about the idea?
>> >
>> > I borrow the idea from CFLRU[1]
>> > - PCFLRU(Page-Cache First LRU)
>> >
>> > When we allocates new page for page cache, we adds the page into LRU's tail.
>> > When we map the page cache into page table, we rotate the page into LRU's head.
>> >
>> > So, inactive list's result is following as.
>> >
>> > M.P : mapped page
>> > N.P : none-mapped page
>> >
>> > HEAD-M.P-M.P-M.P-M.P-N.P-N.P-N.P-N.P-N.P-TAIL
>> >
>> > Admin can set threshold window size which determines stop reclaiming
>> > none-mapped page contiguously.
>> >
>> > I think it needs some tweak of page cache/page mapping functions but
>> > we can use kswapd/direct reclaim without change.
>> >
>> > Also, it can change page reclaim policy totally but it's just what you
>> > want, I think.
>> >
>
> I am not sure how this would work, moreover the idea behind
> min_unmapped_pages is to keep sufficient unmapped pages around for the
> FS metadata and has been working with the existing code for zone
> reclaim. What you propose is more drastic re-org of the LRU and I am
> not sure I have the apetite for it.

Yes. My suggestion can change LRU order totally but it can't meet your
goal so it was a bad idea. Sorry for bothering you.

I can add reviewed-by [1/3],[2/3], but still doubt [3/3].
LRU ordering problem as I mentioned is not only your problem but it's
general problem these day(ex, more aggressive compaction/lumpy
reclaim). So we may need general solution if it is real problem.
Okay. I don't oppose your approach from now on until I can prove how
much LRU-reordering makes bad effect. (But still I  raise my eyebrow
on implementation [3/3] but I don't oppose it until I suggest better
approach)

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
