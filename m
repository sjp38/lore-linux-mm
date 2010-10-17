Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DE1436B0171
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 01:35:48 -0400 (EDT)
Received: by iwn1 with SMTP id 1so3286298iwn.14
        for <linux-mm@kvack.org>; Sat, 16 Oct 2010 22:35:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimDRuE9oBpj6h13wFKazuOzOm8UbFdM+qhbc0On@mail.gmail.com>
References: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
	<20101015171225.70d4ca8f.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimDRuE9oBpj6h13wFKazuOzOm8UbFdM+qhbc0On@mail.gmail.com>
Date: Sun, 17 Oct 2010 14:35:47 +0900
Message-ID: <AANLkTikTMhf9NrLxdrw4Sqi8QiqaVOcfVBQWZWw6s6Vw@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/2] memcg: new lock for mutual execution of
 account_move and file stats
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 17, 2010 at 2:33 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Oct 15, 2010 at 5:12 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> When we try to enhance page's status update to support other flags,
>> one of problem is updating status from IRQ context.
>>
>> Now, mem_cgroup_update_file_stat() takes lock_page_cgroup() to avoid
>> race with _account move_. IOW, there are no races with charge/uncharge
>> in nature. Considering an update from IRQ context, it seems better
>> to disable IRQ at lock_page_cgroup() to avoid deadlock.
>>
>> But lock_page_cgroup() is used too widerly and adding IRQ disable
>> there makes the performance bad. To avoid the big hammer, this patch
>> adds a new lock for update_stat().
>>
>> This lock is for mutual execustion of updating stat and accout moving.
>> This adds a new lock to move_account..so, this makes move_account slow.
>> But considering trade-off, I think it's acceptable.
>>
>> A score of moving 8GB anon pages, 8cpu Xeon(3.1GHz) is here.
>>
>> [before patch] (mmotm + optimization patch (#1 in this series)
>> [root@bluextal kamezawa]# time echo 2257 > /cgroup/B/tasks
>>
>> real =A0 =A00m0.694s
>> user =A0 =A00m0.000s
>> sys =A0 =A0 0m0.683s
>>
>> [After patch]
>> [root@bluextal kamezawa]# time echo 2238 > /cgroup/B/tasks
>>
>> real =A0 =A00m0.741s
>> user =A0 =A00m0.000s
>> sys =A0 =A0 0m0.730s
>>
>> This moves 8Gbytes =3D=3D 2048k pages. But no bad effects to codes
>> other than "move".
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> It looks good than old approach.
> Just a below nitpick.
>
>> ---
>> =A0include/linux/page_cgroup.h | =A0 29 +++++++++++++++++++++++++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 +++++++++--
>> =A02 files changed, 38 insertions(+), 2 deletions(-)
>>
>> Index: mmotm-1013/include/linux/page_cgroup.h
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-1013.orig/include/linux/page_cgroup.h
>> +++ mmotm-1013/include/linux/page_cgroup.h
>> @@ -36,6 +36,7 @@ struct page_cgroup *lookup_page_cgroup(s
>> =A0enum {
>> =A0 =A0 =A0 =A0/* flags for mem_cgroup */
>> =A0 =A0 =A0 =A0PCG_LOCK, =A0/* page cgroup is locked */
>> + =A0 =A0 =A0 PCG_LOCK_STATS, /* page cgroup's stat accounting flags are=
 locked */
>
> Hmm, I think naming isn't a good. Aren't both for stat?
> As I understand, Both are used for stat.
> One is just used by charge/uncharge and the other is used by
> pdate_file_stat/move_account.
> If you guys who are expert in mcg feel it with easy, I am not against.
> But at least, mcg-not-familiar people like me don't feel it comfortable.
>

And I think this patch would be better to be part of Greg Thelen's series.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
