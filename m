Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 757BC6B007B
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 00:02:46 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p5842g5N014548
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 21:02:42 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by wpaz1.hot.corp.google.com with ESMTP id p5842Dff010064
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 21:02:41 -0700
Received: by qwb7 with SMTP id 7so61495qwb.40
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 21:02:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-12-git-send-email-gthelen@google.com> <20110607193835.GD26965@redhat.com>
 <xr93lixdv0df.fsf@gthelen.mtv.corp.google.com> <20110607210540.GB30919@redhat.com>
 <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 7 Jun 2011 21:02:21 -0700
Message-ID: <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup aware
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>

On Tue, Jun 7, 2011 at 5:18 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 7 Jun 2011 17:05:40 -0400
> Vivek Goyal <vgoyal@redhat.com> wrote:
>
>> On Tue, Jun 07, 2011 at 01:43:08PM -0700, Greg Thelen wrote:
>> > Vivek Goyal <vgoyal@redhat.com> writes:
>> >
>> > > On Fri, Jun 03, 2011 at 09:12:17AM -0700, Greg Thelen wrote:
>> > >> When the system is under background dirty memory threshold but a cg=
roup
>> > >> is over its background dirty memory threshold, then only writeback
>> > >> inodes associated with the over-limit cgroup(s).
>> > >>
>> > >
>> > > [..]
>> > >> -static inline bool over_bground_thresh(void)
>> > >> +static inline bool over_bground_thresh(struct bdi_writeback *wb,
>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct writeback_control *wbc)
>> > >> =A0{
>> > >> =A0 =A0 =A0 =A0 =A0unsigned long background_thresh, dirty_thresh;
>> > >>
>> > >> =A0 =A0 =A0 =A0 =A0global_dirty_limits(&background_thresh, &dirty_t=
hresh);
>> > >>
>> > >> - =A0 =A0 =A0 =A0return (global_page_state(NR_FILE_DIRTY) +
>> > >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABLE_NFS)=
 > background_thresh);
>> > >> + =A0 =A0 =A0 =A0if (global_page_state(NR_FILE_DIRTY) +
>> > >> + =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABLE_NFS) > backg=
round_thresh) {
>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wbc->for_cgroup =3D 0;
>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
>> > >> + =A0 =A0 =A0 =A0}
>> > >> +
>> > >> + =A0 =A0 =A0 =A0wbc->for_cgroup =3D 1;
>> > >> + =A0 =A0 =A0 =A0wbc->shared_inodes =3D 1;
>> > >> + =A0 =A0 =A0 =A0return mem_cgroups_over_bground_dirty_thresh();
>> > >> =A0}
>> > >
>> > > Hi Greg,
>> > >
>> > > So all the logic of writeout from mem cgroup works only if system is
>> > > below background limit. The moment we cross background limit, looks
>> > > like we will fall back to existing way of writting inodes?
>> >
>> > Correct. =A0If the system is over its background limit then the previo=
us
>> > cgroup-unaware background writeback occurs. =A0I think of the system
>> > limits as those of the root cgroup. =A0If the system is over the globa=
l
>> > limit than all cgroups are eligible for writeback. =A0In this situatio=
n
>> > the current code does not distinguish between cgroups over or under
>> > their dirty background limit.
>> >
>> > Vivek Goyal <vgoyal@redhat.com> writes:
>> > > If yes, then from design point of view it is little odd that as long
>> > > as we are below background limit, we share the bdi between different
>> > > cgroups. The moment we are above background limit, we fall back to
>> > > algorithm of sharing the disk among individual inodes and forget
>> > > about memory cgroups. Kind of awkward.
>> > >
>> > > This kind of cgroup writeback I think will atleast not solve the pro=
blem
>> > > for CFQ IO controller, as we fall back to old ways of writting back =
inodes
>> > > the moment we cross dirty ratio.
>> >
>> > It might make more sense to reverse the order of the checks in the
>> > proposed over_bground_thresh(): the new version would first check if a=
ny
>> > memcg are over limit; assuming none are over limit, then check global
>> > limits. =A0Assuming that the system is over its background limit and s=
ome
>> > cgroups are also over their limits, then the over limit cgroups would
>> > first be written possibly getting the system below its limit. =A0Does =
this
>> > address your concern?
>>
>> Do you treat root group also as any other cgroup? If no, then above logi=
c
>> can lead to issue of starvation of root group inode. Or unfair writeback=
.
>> So I guess it will be important to treat root group same as other groups=
.
>>
>
> As far as I can say, you should not place programs onto ROOT cgroups if y=
ou need
> performance isolation.

Agreed.

> From the code, I think if the system hits dirty_ratio, "1" bit of bitmap =
should be
> set and background writeback can work for ROOT cgroup seamlessly.
>
> Thanks,
> -Kame

Not quite.  The proposed patches do not set the "1" bit (css_id of
root is 1).  mem_cgroup_balance_dirty_pages() (from patch 10/12)
introduces the following balancing loop:
+       /* balance entire ancestry of current's mem. */
+       for (; mem_cgroup_has_dirty_limit(mem); mem =3D
parent_mem_cgroup(mem)) {

The loop terminates when mem_cgroup_has_dirty_limit() is called for
the root cgroup.  The bitmap is set in the body of the loop.  So the
root cgroup's bit (bit 1) will never be set in the bitmap.  However, I
think the effect is the same.  The proposed changes in this patch
(11/12) have background writeback first checking if the system is over
limit and if yes, then b_dirty inodes from any cgroup written.  This
means that a small system background limit with an over-{fg or
bg}-limit cgroup could cause other cgroups that are not over their
limit to have their inodes written back.  In an system-over-limit
situation normal system-wide bdi writeback is used (writing inodes in
b_dirty order).  For those who want isolation, a simple rule to avoid
this is to ensure that that sum of all cgroup background_limits is
less than the system background limit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
