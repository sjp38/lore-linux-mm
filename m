Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 3DF316B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:59:20 -0400 (EDT)
Received: by eaan1 with SMTP id n1so3135139eaa.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:59:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120620085301.GF27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
	<20120619112901.GC27816@cmpxchg.org>
	<CALWz4iyC2di8ueaHnCE-ENv5td4buK9DOWF5rLfN0bhR68bSAw@mail.gmail.com>
	<20120620085301.GF27816@cmpxchg.org>
Date: Wed, 20 Jun 2012 07:59:17 -0700
Message-ID: <CALWz4iw3k2vSnBfyUejeOxKoeXS5U-RSyRbKhaH-gC_dm_WY2w@mail.gmail.com>
Subject: Re: [PATCH V5 1/5] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Jun 20, 2012 at 1:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Tue, Jun 19, 2012 at 08:45:03PM -0700, Ying Han wrote:
>> On Tue, Jun 19, 2012 at 4:29 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Mon, Jun 18, 2012 at 09:47:27AM -0700, Ying Han wrote:
>> >> +{
>> >> + =A0 =A0 if (mem_cgroup_disabled())
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> >> +
>> >> + =A0 =A0 /*
>> >> + =A0 =A0 =A0* We treat the root cgroup special here to always reclai=
m pages.
>> >> + =A0 =A0 =A0* Now root cgroup has its own lru, and the only chance t=
o reclaim
>> >> + =A0 =A0 =A0* pages from it is through global reclaim. note, root cg=
roup does
>> >> + =A0 =A0 =A0* not trigger targeted reclaim.
>> >> + =A0 =A0 =A0*/
>> >> + =A0 =A0 if (mem_cgroup_is_root(memcg))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> >
>> > With the soft limit at 0, the comment is no longer accurate because
>> > this check turns into a simple optimization. =A0We could check the
>> > res_counter soft limit, which would always result in the root group
>> > being above the limit, but we take the short cut.
>>
>> For root group, my intention here is always reclaim pages from it
>> regardless of the softlimit setting. And the reason is exactly the one
>> in the comment. If the softlimit is set to 0 as default, I agree this
>> is then a short cut.
>>
>> Anything you suggest that I need to change here?
>
> Well, not in this patch as it stands. =A0But once you squash the '0 per
> default', it may be good to note that this is a shortcut.

Will include some notes next time.

>
>> >> + =A0 =A0 for (; memcg; memcg =3D parent_mem_cgroup(memcg)) {
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 /* This is global reclaim, stop at root cgr=
oup */
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_is_root(memcg))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >
>> > I don't see why you add this check and the comment does not help.
>>
>> The root cgroup would have softlimit set to 0 ( in most of the cases
>> ), and not skipping root will make everyone reclaimable here.
>
> Only if root_mem_cgroup->use_hierarchy is set. =A0At the same time, we
> usually behave as if this was the case, in accounting and reclaim.
>
> Right now we allow setting the soft limit in root_mem_cgroup but it
> does not make any sense. =A0After your patch, even less so, because of
> these shortcut checks that now actually change semantics. =A0Could we
> make this more consistent to users and forbid setting as soft limit in
> root_mem_cgroup? =A0Patch below.
>
> The reason this behaves differently from hard limits is because the
> soft limits now have double meaning; they are upper limit and minimum
> guarantee at the same time. =A0The unchangeable defaults in the root
> cgroup should be "no guarantee" and "unlimited soft limit" at the same
> time, but that is obviously not possible if these are opposing range
> ends of the same knob. =A0So we pick no guarantees, always up for
> reclaim when looking top down but also behave as if the soft limit was
> unlimited in the root cgroup when looking bottom up.
>
> This is what the second check does. =A0But I think it needs a clearer
> comment.
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: memcg: forbid setting soft limit on root cgroup
>
> Setting a soft limit in the root cgroup does not make sense, as soft
> limits are enforced hierarchically and the root cgroup is the
> hierarchical parent of every other cgroup. =A0It would not provide the
> discrimination between groups that soft limits are usually used for.
>
> With the current implementation of soft limits, it would only make
> global reclaim more aggressive compared to target reclaim, but we
> absolutely don't want anyone to rely on this behaviour.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ac35bcc..21c45a0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3905,6 +3967,10 @@ static int mem_cgroup_write(struct cgroup *cont, s=
truct cftype *cft,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_resize_=
memsw_limit(memcg, val);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case RES_SOFT_LIMIT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_is_root(memcg)) { /* Can't s=
et limit on root */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D res_counter_memparse_write_strateg=
y(buffer, &val);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;

Thanks, the patch makes sense to me and I will include in the next post.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
