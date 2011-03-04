Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BBB098D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 19:31:02 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p240UiTS010792
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 16:30:44 -0800
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq13.eem.corp.google.com with ESMTP id p240URwf027114
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 16:30:43 -0800
Received: by qyl38 with SMTP id 38so1431440qyl.8
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 16:30:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302231727.GG2547@redhat.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-10-git-send-email-gthelen@google.com> <20110302231727.GG2547@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 3 Mar 2011 16:30:23 -0800
Message-ID: <AANLkTinSrmH-XGuFMBve9SczdXsmKzJbFN4cZ234=z9A@mail.gmail.com>
Subject: Re: [PATCH v5 9/9] memcg: check memcg dirty limits in page writeback
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Wed, Mar 2, 2011 at 3:17 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Fri, Feb 25, 2011 at 01:36:00PM -0800, Greg Thelen wrote:
>
> [..]
>> @@ -500,18 +527,27 @@ static void balance_dirty_pages(struct address_spa=
ce *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 };
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&sys_info);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg_dirty_info(NULL, &memcg_info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_info =3D sys_info;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Throttle it only when the background wr=
iteback cannot
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* catch-up. This avoids (excessively) sma=
ll writeouts
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* when the bdi limits are ramping up.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (dirty_info_reclaimable(&sys_info) + sys_in=
fo.nr_writeback <=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 if ((dirty_info_reclaimable(&sys_info) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.nr_writeback <=3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sys_info.ba=
ckground_thresh +
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.di=
rty_thresh) / 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sys_info.di=
rty_thresh) / 2) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (dirty_info_reclaimable(&memcg_info) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg_info.nr_writeback <=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (memcg_info.ba=
ckground_thresh +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg_info.=
dirty_thresh) / 2))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi, sys_info.d=
irty_thresh);
>> + =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D bdi_dirty_limit(bdi,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 min(sys_info.d=
irty_thresh,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_=
info.dirty_thresh));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_thresh =3D task_dirty_limit(current, bdi=
_thresh);
>
> Greg, so currently we seem to have per_bdi/per_task dirty limits and
> now with this patch it will sort of become per_cgroup/per_bdi/per_task
> dirty limits? I think that kind of makes sense to me.
>
> Thanks
> Vivek
>

Vivek,  you are correct.  This patch adds per_cgroup limits to the
existing system, bdi, and system dirty memory limits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
