Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A38B8D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 00:33:04 -0500 (EST)
Received: by iyi20 with SMTP id 20so972271iyi.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 21:33:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110128111833.GD5054@balbir.in.ibm.com>
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
	<20110125051015.13762.13429.stgit@localhost6.localdomain6>
	<AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
	<AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
	<AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
	<20110128064851.GB5054@balbir.in.ibm.com>
	<AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
	<20110128111833.GD5054@balbir.in.ibm.com>
Date: Thu, 10 Feb 2011 14:33:00 +0900
Message-ID: <AANLkTin4JM6phwy0wuV6fV-i-3UwP_GGmXh1vN=Wz2u=@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

Sorry for late response.

On Fri, Jan 28, 2011 at 8:18 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * MinChan Kim <minchan.kim@gmail.com> [2011-01-28 16:24:19]:
>
>> >
>> > But the assumption for LRU order to change happens only if the page
>> > cannot be successfully freed, which means it is in some way active..
>> > and needs to be moved no?
>>
>> 1. holded page by someone
>> 2. mapped pages
>> 3. active pages
>>
>> 1 is rare so it isn't the problem.
>> Of course, in case of 3, we have to activate it so no problem.
>> The problem is 2.
>>
>
> 2 is a problem, but due to the size aspects not a big one. Like you
> said even lumpy reclaim affects it. May be the reclaim code could
> honour may_unmap much earlier.

Even if it is, it's a trade-off to get a big contiguous memory. I
don't want to add new mess. (In addition, lumpy is weak by compaction
as time goes by)
What I have in mind for preventing LRU ignore is that put the page
into original position instead of head of lru. Maybe it can help the
situation both lumpy and your case. But it's another story.

How about the idea?

I borrow the idea from CFLRU[1]
- PCFLRU(Page-Cache First LRU)

When we allocates new page for page cache, we adds the page into LRU's tail=
