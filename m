Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 205E66B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 21:34:51 -0500 (EST)
Received: by mail-oa0-f48.google.com with SMTP id h2so15296763oag.7
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 18:34:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DCEA3D.1030501@jp.fujitsu.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456156-14535-1-git-send-email-handai.szj@taobao.com>
	<50DCEA3D.1030501@jp.fujitsu.com>
Date: Sat, 5 Jan 2013 10:34:50 +0800
Message-ID: <CAFj3OHWJhaghOQ_xT7+rWOGiY0b2KLm68QHz4+yiOqtNf=Sz7A@mail.gmail.com>
Subject: Re: [PATCH V3 2/8] Make TestSetPageDirty and dirty page accounting in
 one func
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

Hi Kame,

Sorry for the late response, I'm just back from vocation. : )

On Fri, Dec 28, 2012 at 8:39 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/12/26 2:22), Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
>> extracts TestSetPageDirty from __set_page_dirty and is far away from
>> account_page_dirtied. But it's better to make the two operations in one single
>> function to keep modular. So in order to avoid the potential race mentioned in
>> commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
>> There's no deadlock between ->private_lock and ->tree_lock after confirmation.
>> It's a prepare patch for following memcg dirty page accounting patches.
>>
>>
>> Here is some test numbers that before/after this patch:
>> Test steps(Mem-4g, ext4):
>> drop_cache; sync
>> fio (ioengine=sync/write/buffered/bs=4k/size=1g/numjobs=2/group_reporting/thread)
>>
>> We test it for 10 times and get the average numbers:
>> Before:
>> write: io=2048.0MB, bw=254117KB/s, iops=63528.9 , runt=  8279msec
>> lat (usec): min=1 , max=742361 , avg=30.918, stdev=1601.02
>> After:
>> write: io=2048.0MB, bw=254044KB/s, iops=63510.3 , runt=  8274.4msec
>> lat (usec): min=1 , max=856333 , avg=31.043, stdev=1769.32
>>
>> Note that the impact is little(<1%).
>>
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Hmm,..this change should be double-checked by vfs, I/O guys...
>

Now it seems they haven't paid attention here... I'll push it soon for
more review.

> increasing hold time of mapping->private_lock doesn't affect performance ?
>
>

Yes, pointed by Fengguang in the previous round, mapping->private_lock and
mapping->tree_lock are often contented locks that in a dd testcase
they have the top
 #1 and #2 contention.
So the numbers above are trying to find the impaction of lock
contention by multiple
threads(numjobs=2) writing to the same file in parallel and it seems
the impact is
little (<1%).
I'm not sure if the test case is enough, any advice is welcomed! : )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
