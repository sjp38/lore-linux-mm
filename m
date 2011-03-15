Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C48A48D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 09:51:10 -0400 (EDT)
Received: by pwi10 with SMTP id 10so168610pwi.14
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 06:51:07 -0700 (PDT)
Date: Tue, 15 Mar 2011 22:50:51 +0900 (JST)
Message-Id: <20110315.225051.1663021277549367617.konishi.ryusuke@gmail.com>
Subject: Re: [PATCH v6 4/9] memcg: add kernel calls for memcg dirty page
 stats
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <AANLkTinnfM6_ZhzEq6SAG1H2jDfKdVS2=fe_USi8ArNA@mail.gmail.com>
References: <1299869011-26152-5-git-send-email-gthelen@google.com>
	<20110314151023.GF11699@barrios-desktop>
	<AANLkTinnfM6_ZhzEq6SAG1H2jDfKdVS2=fe_USi8ArNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gthelen@google.com
Cc: minchan.kim@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, arighi@develer.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, hannes@cmpxchg.org, ciju@linux.vnet.ibm.com, rientjes@google.com, fengguang.wu@intel.com, ctalbott@google.com, teravest@google.com, vgoyal@redhat.com, konishi.ryusuke@lab.ntt.co.jp

On Mon, 14 Mar 2011 23:32:38 -0700, Greg Thelen wrote:
> On Mon, Mar 14, 2011 at 8:10 AM, Minchan Kim <minchan.kim@gmail.com> =
wrote:
>> On Fri, Mar 11, 2011 at 10:43:26AM -0800, Greg Thelen wrote:
>>> Add calls into memcg dirty page accounting. =A0Notify memcg when pa=
ges
>>> transition between clean, file dirty, writeback, and unstable nfs.
>>> This allows the memory controller to maintain an accurate view of
>>> the amount of its memory that is dirty.
>>>
>>> Signed-off-by: Greg Thelen <gthelen@google.com>
>>> Signed-off-by: Andrea Righi <arighi@develer.com>
>>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
<snip>
>>
>> At least in mainline, NR_WRITEBACK handling codes are following as.
>>
>> 1) increase
>>
>> * account_page_writeback
>>
>> 2) decrease
>>
>>  * test_clear_page_writeback
>>  * __nilfs_end_page_io
>>
>> I think account_page_writeback name is good to add your account func=
tion into that.
>> The problem is decreasement. Normall we can handle decreasement in t=
est_clear_page_writeback.
>> But I am not sure it's okay in __nilfs_end_page_io.
>> I think if __nilfs_end_page_io is right, __nilfs_end_page_io should =
call
>> mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK).
>>
>> What do you think about it?
>>
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
> =

> I would like to not have any special cases that avoid certain memory.=

> So I think your suggestion is good.
> However, nilfs memcg dirty page accounting was skipped in a previous
> memcg dirty limit effort due to complexity.  See 'clone_page'
> reference in:
>   http://lkml.indiana.edu/hypermail/linux/kernel/1003.0/02997.html
> =

> I admit that I don't follow all of the nilfs code path, but it looks
> like some of the nilfs pages are allocated but not charged to memcg.
> There is code in mem_cgroup_update_page_stat() to gracefully handle
> pages not associated with a memcg.  So perhaps nilfs clone pages dirt=
y
> [un]charge could be attempted.  I have not succeeded in testing in
> exercising these code paths in nilfs.

Sorry for this matter.  The clone_page code paths in nilfs is
exercised only when mmapped pages are written back.

I think the private page allocation used for the current clone_page
code should be altered to eliminate the root cause of these issues.
I would like to try to find some sort of alternative way.


Regards,
Ryusuke Konishi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
