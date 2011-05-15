Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00CBB6B0011
	for <linux-mm@kvack.org>; Sun, 15 May 2011 15:53:34 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4FJrXW3029439
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:33 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz29.hot.corp.google.com with ESMTP id p4FJrSQD019001
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:32 -0700
Received: by qwj9 with SMTP id 9so2707313qwj.35
        for <linux-mm@kvack.org>; Sun, 15 May 2011 12:53:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110513184120.0f9444bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
 <1305276473-14780-9-git-send-email-gthelen@google.com> <20110513184120.0f9444bc.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Sun, 15 May 2011 12:53:08 -0700
Message-ID: <BANLkTi=t+Wn5GWR49f++be_AeZ9fjGACTA@mail.gmail.com>
Subject: Re: [RFC][PATCH v7 08/14] writeback: add memcg fields to writeback_control
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, May 13, 2011 at 2:41 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 13 May 2011 01:47:47 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Add writeback_control fields to differentiate between bdi-wide and
>> per-cgroup writeback. =A0Cgroup writeback is also able to differentiate
>> between writing inodes isolated to a particular cgroup and inodes shared
>> by multiple cgroups.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Personally, I want to see new flags with their usage in a patch...

Ok.  Next version will merge the flag definition with first usage of the fl=
ag.

>> ---
>> =A0include/linux/writeback.h | =A0 =A02 ++
>> =A01 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index d10d133..4f5c0d2 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -47,6 +47,8 @@ struct writeback_control {
>> =A0 =A0 =A0 unsigned for_reclaim:1; =A0 =A0 =A0 =A0 /* Invoked from the =
page allocator */
>> =A0 =A0 =A0 unsigned range_cyclic:1; =A0 =A0 =A0 =A0/* range_start is cy=
clic */
>> =A0 =A0 =A0 unsigned more_io:1; =A0 =A0 =A0 =A0 =A0 =A0 /* more io to be=
 dispatched */
>> + =A0 =A0 unsigned for_cgroup:1; =A0 =A0 =A0 =A0 =A0/* enable cgroup wri=
teback */
>> + =A0 =A0 unsigned shared_inodes:1; =A0 =A0 =A0 /* write inodes spanning=
 cgroups */
>> =A0};
>
>
> If shared_inode is really rare case...we don't need to have this shared_i=
nodes
> flag and do writeback shared_inode always.....No ?
>
> Thanks,
> -Kame

The shared_inodes field is present to avoid punishing cgroups that are
not sharing, if they are run on a system that also includes sharing.

This issue is being debated in another thread: "[RFC][PATCH v7 00/14]
memcg: per cgroup dirty page accounting".  Depending on the decision,
we may be able to delete the shared_inode fields if we choose to
always write shared inodes in both cgroup foreground and cgroup
background writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
