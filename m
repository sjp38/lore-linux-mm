Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DDAF78D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 00:41:46 -0500 (EST)
Received: by iyi20 with SMTP id 20so977317iyi.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 21:41:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTin4JM6phwy0wuV6fV-i-3UwP_GGmXh1vN=Wz2u=@mail.gmail.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
	<AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
	<20110128111833.GD5054@balbir.in.ibm.com>
	<AANLkTin4JM6phwy0wuV6fV-i-3UwP_GGmXh1vN=Wz2u=@mail.gmail.com>
Date: Thu, 10 Feb 2011 14:41:44 +0900
Message-ID: <AANLkTi=hhKJGXwe1OyFsGF9StLJnYFX+QqUpNLXmfVc=@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

I don't know why the part of message is deleted only when I send you.
Maybe it's gmail bug.

I hope mail sending is successful in this turn. :)

On Thu, Feb 10, 2011 at 2:33 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Sorry for late response.
>
> On Fri, Jan 28, 2011 at 8:18 PM, Balbir Singh <balbir@linux.vnet.ibm.com>=
 wrote:
>> * MinChan Kim <minchan.kim@gmail.com> [2011-01-28 16:24:19]:
>>
>>> >
>>> > But the assumption for LRU order to change happens only if the page
>>> > cannot be successfully freed, which means it is in some way active..
>>> > and needs to be moved no?
>>>
>>> 1. holded page by someone
>>> 2. mapped pages
>>> 3. active pages
>>>
>>> 1 is rare so it isn't the problem.
>>> Of course, in case of 3, we have to activate it so no problem.
>>> The problem is 2.
>>>
>>
>> 2 is a problem, but due to the size aspects not a big one. Like you
>> said even lumpy reclaim affects it. May be the reclaim code could
>> honour may_unmap much earlier.
>
> Even if it is, it's a trade-off to get a big contiguous memory. I
> don't want to add new mess. (In addition, lumpy is weak by compaction
> as time goes by)
> What I have in mind for preventing LRU ignore is that put the page
> into original position instead of head of lru. Maybe it can help the
> situation both lumpy and your case. But it's another story.
>
> How about the idea?
>
> I borrow the idea from CFLRU[1]
> - PCFLRU(Page-Cache First LRU)
>
> When we allocates new page for page cache, we adds the page into LRU's ta=
il.
> When we map the page cache into page table, we rotate the page into LRU's=
 head.
>
> So, inactive list's result is following as.
>
> M.P : mapped page
> N.P : none-mapped page
>
> HEAD-M.P-M.P-M.P-M.P-N.P-N.P-N.P-N.P-N.P-TAIL
>
> Admin can set threshold window size which determines stop reclaiming
> none-mapped page contiguously.
>
> I think it needs some tweak of page cache/page mapping functions but
> we can use kswapd/direct reclaim without change.
>
> Also, it can change page reclaim policy totally but it's just what you
> want, I think.
>
> [1] http://citeseerx.ist.psu.edu/viewdoc/download?doi=3D10.1.1.100.6188&r=
ep=3Drep1&type=3Dpdf
>
>>
>> --
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Three Cheers,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Balbir
>>
>
>
>
> --
> Kind regards,
> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
