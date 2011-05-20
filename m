Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 437216B0012
	for <linux-mm@kvack.org>; Fri, 20 May 2011 00:20:18 -0400 (EDT)
Received: by qyk2 with SMTP id 2so79961qyk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 21:20:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
	<BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
	<BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
Date: Fri, 20 May 2011 13:20:15 +0900
Message-ID: <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, May 20, 2011 at 12:38 PM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Thu, May 19, 2011 at 11:12 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> Right after that happened, I hit ctrl-c to kill test_mempressure.sh.
>>> The system was OK until I typed sync, and then everything hung.
>>>
>>> I'm really confused. =C2=A0shrink_inactive_list in
>>> RECLAIM_MODE_LUMPYRECLAIM will call one of the isolate_pages functions
>>> with ISOLATE_BOTH. =C2=A0The resulting list goes into shrink_page_list,
>>> which does VM_BUG_ON(PageActive(page)).
>>>
>>> How is that supposed to work?
>>
>> Usually clear_active_flags() clear PG_active before calling
>> shrink_page_list().
>>
>> shrink_inactive_list()
>> =C2=A0 =C2=A0isolate_pages_global()
>> =C2=A0 =C2=A0update_isolated_counts()
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0clear_active_flags()
>> =C2=A0 =C2=A0shrink_page_list()
>>
>>
>
> That makes sense. =C2=A0And I have CONFIG_COMPACTION=3Dy, so the lumpy mo=
de
> doesn't get set anyway.

Could you see the problem with disabling CONFIG_COMPACTION?

>
> But the pages I'm seeing have flags=3D100000000008005D. =C2=A0If I'm read=
ing
> it right, that means locked,referenced,uptodate,dirty,active. =C2=A0How
> does a page like that end up in shrink_page_list? =C2=A0I don't see how a
> page that's !PageLRU can get marked Active. =C2=A0Nonetheless, I'm hittin=
g
> that VM_BUG_ON.

Thanks for proving that it's not a problem of latest my patch.

>
> Is there a race somewhere?

First of all, let's finish your first problem about hang. :)
And let's make another thread to fix this problem.

I think this is a severe problem because 2.6.39 includes my deactivate_page=
s
(http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcom=
mit;h=3D315601809d124d046abd6c3ffa346d0dbd7aa29d)

It touches page states more and more. (2.6.38.6 doesn't include it so
it's not a problem of my deactivate_pages problem)
And now inorder-putback series which I will push for 2.6.40 touches it
more and more.

So I want to resolve your problem asap.
We don't have see report about that. Could you do git-bisect?
FYI, Recently, big change of mm is compaction,transparent huge pages.
Kame, could you point out thing related to memcg if you have a mind?

>
> --Andy
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
