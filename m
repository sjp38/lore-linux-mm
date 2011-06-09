Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8216B0012
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 13:56:06 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p59Hu2R2009119
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 10:56:03 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by hpaq11.eem.corp.google.com with ESMTP id p59Hu0m3022099
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 10:56:01 -0700
Received: by qyj19 with SMTP id 19so3063563qyj.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 10:56:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110608203945.GF1150@redhat.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-12-git-send-email-gthelen@google.com> <20110607193835.GD26965@redhat.com>
 <xr93lixdv0df.fsf@gthelen.mtv.corp.google.com> <20110607210540.GB30919@redhat.com>
 <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com> <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
 <20110608203945.GF1150@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 9 Jun 2011 10:55:40 -0700
Message-ID: <BANLkTikg=Gnh7UnLQUTfO7yA3kD3f7MK9YK4EUrbaPBsQBxKuQ@mail.gmail.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup aware
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>

On Wed, Jun 8, 2011 at 1:39 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Tue, Jun 07, 2011 at 09:02:21PM -0700, Greg Thelen wrote:
>
> [..]
>> > As far as I can say, you should not place programs onto ROOT cgroups i=
f you need
>> > performance isolation.
>>
>> Agreed.
>>
>> > From the code, I think if the system hits dirty_ratio, "1" bit of bitm=
ap should be
>> > set and background writeback can work for ROOT cgroup seamlessly.
>> >
>> > Thanks,
>> > -Kame
>>
>> Not quite. =A0The proposed patches do not set the "1" bit (css_id of
>> root is 1). =A0mem_cgroup_balance_dirty_pages() (from patch 10/12)
>> introduces the following balancing loop:
>> + =A0 =A0 =A0 /* balance entire ancestry of current's mem. */
>> + =A0 =A0 =A0 for (; mem_cgroup_has_dirty_limit(mem); mem =3D
>> parent_mem_cgroup(mem)) {
>>
>> The loop terminates when mem_cgroup_has_dirty_limit() is called for
>> the root cgroup. =A0The bitmap is set in the body of the loop. =A0So the
>> root cgroup's bit (bit 1) will never be set in the bitmap. =A0However, I
>> think the effect is the same. =A0The proposed changes in this patch
>> (11/12) have background writeback first checking if the system is over
>> limit and if yes, then b_dirty inodes from any cgroup written. =A0This
>> means that a small system background limit with an over-{fg or
>> bg}-limit cgroup could cause other cgroups that are not over their
>> limit to have their inodes written back. =A0In an system-over-limit
>> situation normal system-wide bdi writeback is used (writing inodes in
>> b_dirty order). =A0For those who want isolation, a simple rule to avoid
>> this is to ensure that that sum of all cgroup background_limits is
>> less than the system background limit.
>
> Ok, we seem to be mixing multiple things.
>
> - First of all, i thought running apps in root group is very valid
> =A0use case. Generally by default we run everything in root group and
> =A0once somebody notices that an application or group of application
> =A0is memory hog, that can be moved out in a cgroup of its own with
> =A0upper limits.
>
> - Secondly, root starvation issue is not present as long as we fall
> =A0back to normal way of writting inodes once we have crossed dirty
> =A0limit. But you had suggested that we move cgroup based writeout
> =A0above so that we always use same scheme for writeout and that
> =A0potentially will have root starvation issue.

To reduce the risk of breaking system writeback (by potentially
starting root inodes), my preference is to to retain this patch's
original ordering (first check and write towards system limits, only
if under system limits write per-cgroup).

> - If we don't move it up, then atleast it will not work for CFQ IO
> =A0controller.

As originally proposed, over_bground_thresh() would check system
background limit, and if over limit then write b_dirty, until under
system limit.  Then over_bground_thresh() checks cgroup background
limits, and if over limit(s) write over-limit-cgroup inodes until
cgroups are under their background limits.

How does the order of the checks in over_bground_thresh() affect CFQ
IO?  Are you referring to recently proposed block throttle patches,
which (AFAIK) throttle the rate at which a cgroup can produce dirty
pages as a way to approximate the rate that async dirty pages will be
written to disk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
