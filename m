Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A01D46B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 01:20:55 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p585Kp0t022851
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 22:20:52 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by wpaz37.hot.corp.google.com with ESMTP id p585KkYK020081
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 22:20:50 -0700
Received: by qwi4 with SMTP id 4so95435qwi.15
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 22:20:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110608130315.0a365dbb.kamezawa.hiroyu@jp.fujitsu.com>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-12-git-send-email-gthelen@google.com> <20110607193835.GD26965@redhat.com>
 <xr93lixdv0df.fsf@gthelen.mtv.corp.google.com> <20110607210540.GB30919@redhat.com>
 <20110608091815.fdef924d.kamezawa.hiroyu@jp.fujitsu.com> <BANLkTim-sYkuekCcOA+HXhCtED4xKfT=0Q@mail.gmail.com>
 <20110608130315.0a365dbb.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 7 Jun 2011 22:20:26 -0700
Message-ID: <BANLkTinifX7cYX+yaBP+Pp5=oU9EdSHLtg@mail.gmail.com>
Subject: Re: [PATCH v8 11/12] writeback: make background writeback cgroup aware
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>

On Tue, Jun 7, 2011 at 9:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 7 Jun 2011 21:02:21 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> On Tue, Jun 7, 2011 at 5:18 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Tue, 7 Jun 2011 17:05:40 -0400
>> > Vivek Goyal <vgoyal@redhat.com> wrote:
>> >
>> >> On Tue, Jun 07, 2011 at 01:43:08PM -0700, Greg Thelen wrote:
>> >> > Vivek Goyal <vgoyal@redhat.com> writes:
>> >> >
>> >> > > On Fri, Jun 03, 2011 at 09:12:17AM -0700, Greg Thelen wrote:
>> >> > >> When the system is under background dirty memory threshold but a=
 cgroup
>> >> > >> is over its background dirty memory threshold, then only writeba=
ck
>> >> > >> inodes associated with the over-limit cgroup(s).
>> >> > >>
>> >> > >
>> >> > > [..]
>> >> > >> -static inline bool over_bground_thresh(void)
>> >> > >> +static inline bool over_bground_thresh(struct bdi_writeback *wb=
,
>> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct writeback_control *wbc)
>> >> > >> =A0{
>> >> > >> =A0 =A0 =A0 =A0 =A0unsigned long background_thresh, dirty_thresh=
;
>> >> > >>
>> >> > >> =A0 =A0 =A0 =A0 =A0global_dirty_limits(&background_thresh, &dirt=
y_thresh);
>> >> > >>
>> >> > >> - =A0 =A0 =A0 =A0return (global_page_state(NR_FILE_DIRTY) +
>> >> > >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABLE_N=
FS) > background_thresh);
>> >> > >> + =A0 =A0 =A0 =A0if (global_page_state(NR_FILE_DIRTY) +
>> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_UNSTABLE_NFS) > ba=
ckground_thresh) {
>> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wbc->for_cgroup =3D 0;
>> >> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
>> >> > >> + =A0 =A0 =A0 =A0}
>> >> > >> +
>> >> > >> + =A0 =A0 =A0 =A0wbc->for_cgroup =3D 1;
>> >> > >> + =A0 =A0 =A0 =A0wbc->shared_inodes =3D 1;
>> >> > >> + =A0 =A0 =A0 =A0return mem_cgroups_over_bground_dirty_thresh();
>> >> > >> =A0}
>> >> > >
>> >> > > Hi Greg,
>> >> > >
>> >> > > So all the logic of writeout from mem cgroup works only if system=
 is
>> >> > > below background limit. The moment we cross background limit, loo=
ks
>> >> > > like we will fall back to existing way of writting inodes?
>> >> >
>> >> > Correct. =A0If the system is over its background limit then the pre=
vious
>> >> > cgroup-unaware background writeback occurs. =A0I think of the syste=
m
>> >> > limits as those of the root cgroup. =A0If the system is over the gl=
obal
>> >> > limit than all cgroups are eligible for writeback. =A0In this situa=
tion
>> >> > the current code does not distinguish between cgroups over or under
>> >> > their dirty background limit.
>> >> >
>> >> > Vivek Goyal <vgoyal@redhat.com> writes:
>> >> > > If yes, then from design point of view it is little odd that as l=
ong
>> >> > > as we are below background limit, we share the bdi between differ=
ent
>> >> > > cgroups. The moment we are above background limit, we fall back t=
o
>> >> > > algorithm of sharing the disk among individual inodes and forget
>> >> > > about memory cgroups. Kind of awkward.
>> >> > >
>> >> > > This kind of cgroup writeback I think will atleast not solve the =
problem
>> >> > > for CFQ IO controller, as we fall back to old ways of writting ba=
ck inodes
>> >> > > the moment we cross dirty ratio.
>> >> >
>> >> > It might make more sense to reverse the order of the checks in the
>> >> > proposed over_bground_thresh(): the new version would first check i=
f any
>> >> > memcg are over limit; assuming none are over limit, then check glob=
al
>> >> > limits. =A0Assuming that the system is over its background limit an=
d some
>> >> > cgroups are also over their limits, then the over limit cgroups wou=
ld
>> >> > first be written possibly getting the system below its limit. =A0Do=
es this
>> >> > address your concern?
>> >>
>> >> Do you treat root group also as any other cgroup? If no, then above l=
ogic
>> >> can lead to issue of starvation of root group inode. Or unfair writeb=
ack.
>> >> So I guess it will be important to treat root group same as other gro=
ups.
>> >>
>> >
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
>>
>
> Hmm, should we add the rule ?
> How about disallowing to set dirty_ratio bigger than system's one ?

The rule needs to consider all cgroups when adjusting any cgroup (or
the system) effective background limit:

check_rule()
{
  cgroup_bg_bytes =3D 0
  for_each_mem_cgroup_tree(root, mem)
    cgroup_bg_bytes +=3D mem->dirty_param.dirty_background_bytes;

  assert cgroup_bg_bytes < effective_background_limit
}

There may be more aggressive (lower values of cgroup_bg_bytes) if
hierarchy is enabled.  If hierarchy is enabled the cgroup limits may
be more restrictive than just the sum of all.  But the sum of all is
simpler.  Enforcing this rule would disallow background over commit.

If a global dirty ratio (rather than byte count) is set, then the
effective_background_limit is a function of
global_reclaimable_pages(), which can fluctuate as the number lru
pages changes (e.g. mlock may lower effective_background_limit).  So
the rule could be true when the limits are set, but when an mlock
occurs the rule would need to be reevaluated.  This feels way too
complex.  So my thinking is not to enforce this rule in code.  I will
plan to add this guidance to the memcg Documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
