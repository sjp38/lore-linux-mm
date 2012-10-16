Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 756D46B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 13:14:49 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so7826036obc.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 10:14:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016133439.GI13991@dhcp22.suse.cz>
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
	<20121016133439.GI13991@dhcp22.suse.cz>
Date: Wed, 17 Oct 2012 01:14:48 +0800
Message-ID: <CAFj3OHVW-betpEnauzk-vQEfw_7bJxFneQb2oWpAZzOpZuMDiQ@mail.gmail.com>
Subject: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f64355695fc2504cc304ac6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Sha Zhengju <handai.szj@taobao.com>, David Rientjes <rientjes@google.com>

--e89a8f64355695fc2504cc304ac6
Content-Type: text/plain; charset=ISO-8859-1

On Tuesday, October 16, 2012, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 16-10-12 18:12:08, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Sysctl oom_kill_allocating_task enables or disables killing the
OOM-triggering
>> task in out-of-memory situations, but it only works on overall
system-wide oom.
>> But it's also a useful indication in memcg so we take it into
consideration
>> while oom happening in memcg. Other sysctl such as panic_on_oom has
already
>> been memcg-ware.
>
> Could you be more specific about the motivation for this patch? Is it
> "let's be consistent with the global oom" or you have a real use case
> for this knob.
>

In our environment(rhel6), we encounter a memcg oom 'deadlock' problem.
Simply speaking,
suppose process A is selected to be killed by memcg oom killer, but A is
uninterruptible
sleeping on a page lock. What's worse, the exact page lock is holding by
another memcg
process B which is trapped in mem_croup_oom_lock(proves to be a livelock).
Then A can not
exit successfully to free the memory and both of them can not moving on.
Indeed, we
should dig into these locks to find the solution and in fact the 37b23e05
(x86, mm: make pagefault
killable) and 7d9fdac(Memcg: make oom_lock 0 and 1 based other than
counter) have already solved
the problem, but if oom_killing_allocating_task is memcg aware, enabling
this suicide oom behavior
will be a simpler workaround. What's more, enabling the sysctl can avoid
other potential oom
problems to some extent.


> The primary motivation for oom_kill_allocating_tas AFAIU was to reduce
> search over huge tasklists and reduce task_lock holding times. I am not
> sure whether the original concern is still valid since 6b0c81b (mm,
> oom: reduce dependency on tasklist_lock) as the tasklist_lock usage has
> been reduced conciderably in favor of RCU read locks is taken but maybe
> even that can be too disruptive?
> David?


On the other hand, from the semantic meaning of oom_kill_allocating_task,
it implies to allow
suicide-like oom, which has no obvious relationship with performance
problems(such as huge task lists
or task_lock holding time). So make the sysctl be consistent with global
oom will be better or set an
individual option for memcg oom just as panic_on_oom does.


> Moreover memcg oom killer doesn't iterate over tasklist (it uses
> cgroup_iter*) so this shouldn't cause the performance problem like
> for the global case.
> On the other hand we are taking css_set_lock for reading for the whole
> iteration which might cause some issues as well but those should better
> be described in the changelog.
>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>>  mm/memcontrol.c |    9 +++++++++
>>  1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index e4e9b18..c329940 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1486,6 +1486,15 @@ static void mem_cgroup_out_of_memory(struct
mem_cgroup *memcg, gfp_t gfp_mask,
>>
>>       check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>>       totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>> +     if (sysctl_oom_kill_allocating_task && current->mm &&
>> +         !oom_unkillable_task(current, memcg, NULL) &&
>> +         current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>> +             get_task_struct(current);
>> +             oom_kill_process(current, gfp_mask, order, 0, totalpages,
memcg, NULL,
>> +                              "Memory cgroup out of memory
(oom_kill_allocating_task)");
>> +             return;
>> +     }
>> +
>>       for_each_mem_cgroup_tree(iter, memcg) {
>>               struct cgroup *cgroup = iter->css.cgroup;
>>               struct cgroup_iter it;
>> --
>> 1.7.6.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Michal Hocko
> SUSE Labs
>

--e89a8f64355695fc2504cc304ac6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Tuesday, October 16, 2012, Michal Hocko &lt;<a href=3D"mailto:mh=
ocko@suse.cz">mhocko@suse.cz</a>&gt; wrote:<br>&gt; On Tue 16-10-12 18:12:0=
8, Sha Zhengju wrote:<br>&gt;&gt; From: Sha Zhengju &lt;<a href=3D"mailto:h=
andai.szj@taobao.com">handai.szj@taobao.com</a>&gt;<br>
&gt;&gt;<br>&gt;&gt; Sysctl oom_kill_allocating_task enables or disables ki=
lling the OOM-triggering<br>&gt;&gt; task in out-of-memory situations, but =
it only works on overall system-wide oom.<br>&gt;&gt; But it&#39;s also a u=
seful indication in memcg so we take it into consideration<br>
&gt;&gt; while oom happening in memcg. Other sysctl such as panic_on_oom ha=
s already<br>&gt;&gt; been memcg-ware.<br>&gt;<br>&gt; Could you be more sp=
ecific about the motivation for this patch? Is it<br>&gt; &quot;let&#39;s b=
e consistent with the global oom&quot; or you have a real use case<br>
&gt; for this knob.<br>&gt;<br><br>In our environment(rhel6), we encounter =
a memcg oom &#39;deadlock&#39; problem. Simply speaking,<br>suppose process=
 A is selected to be killed by memcg oom killer, but A is uninterruptible<b=
r>
sleeping on a page lock. What&#39;s worse, the exact page lock is holding b=
y another memcg<br>process B which is trapped in mem_croup_oom_lock(proves =
to be a livelock). Then A can not<br>exit successfully to free the memory a=
nd both of them can not moving on. Indeed, we<br>
should dig into these locks to find the solution and in fact the 37b23e05 (=
x86, mm: make pagefault<br>killable) and 7d9fdac(Memcg: make oom_lock 0 and=
 1 based other than counter) have already solved<br>the problem, but if oom=
_killing_allocating_task is memcg aware, enabling this suicide oom behavior=
<br>
will be a simpler workaround. What&#39;s more, enabling the sysctl can avoi=
d other potential oom<br>problems to some extent.<br><br><br>&gt; The prima=
ry motivation for oom_kill_allocating_tas AFAIU was to reduce<br>&gt; searc=
h over huge tasklists and reduce task_lock holding times. I am not<br>
&gt; sure whether the original concern is still valid since 6b0c81b (mm,<br=
>&gt; oom: reduce dependency on tasklist_lock) as the tasklist_lock usage h=
as<br>&gt; been reduced conciderably in favor of RCU read locks is taken bu=
t maybe<br>
&gt; even that can be too disruptive?<br>&gt; David?<br><br><br>On the othe=
r hand, from the semantic meaning of oom_kill_allocating_task, it implies t=
o allow<br>suicide-like oom, which has no obvious relationship with perform=
ance problems(such as huge task lists<br>
or task_lock holding time). So make the sysctl be consistent with global oo=
m will be better or set an<br>individual option for memcg oom just as panic=
_on_oom does.<br><br><br>&gt; Moreover memcg oom killer doesn&#39;t iterate=
 over tasklist (it uses<br>
&gt; cgroup_iter*) so this shouldn&#39;t cause the performance problem like=
<br>&gt; for the global case.<br>&gt; On the other hand we are taking css_s=
et_lock for reading for the whole<br>&gt; iteration which might cause some =
issues as well but those should better<br>
&gt; be described in the changelog.<br>&gt;<br>&gt;&gt; Signed-off-by: Sha =
Zhengju &lt;<a href=3D"mailto:handai.szj@taobao.com">handai.szj@taobao.com<=
/a>&gt;<br>&gt;&gt; ---<br>&gt;&gt; =A0mm/memcontrol.c | =A0 =A09 +++++++++=
<br>
&gt;&gt; =A01 files changed, 9 insertions(+), 0 deletions(-)<br>&gt;&gt;<br=
>&gt;&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>&gt;&gt; index =
e4e9b18..c329940 100644<br>&gt;&gt; --- a/mm/memcontrol.c<br>&gt;&gt; +++ b=
/mm/memcontrol.c<br>
&gt;&gt; @@ -1486,6 +1486,15 @@ static void mem_cgroup_out_of_memory(struct=
 mem_cgroup *memcg, gfp_t gfp_mask,<br>&gt;&gt;<br>&gt;&gt; =A0 =A0 =A0 che=
ck_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);<br>&gt;&gt; =A0 =
=A0 =A0 totalpages =3D mem_cgroup_get_limit(memcg) &gt;&gt; PAGE_SHIFT ? : =
1;<br>
&gt;&gt; + =A0 =A0 if (sysctl_oom_kill_allocating_task &amp;&amp; current-&=
gt;mm &amp;&amp;<br>&gt;&gt; + =A0 =A0 =A0 =A0 !oom_unkillable_task(current=
, memcg, NULL) &amp;&amp;<br>&gt;&gt; + =A0 =A0 =A0 =A0 current-&gt;signal-=
&gt;oom_score_adj !=3D OOM_SCORE_ADJ_MIN) {<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 get_task_struct(current);<br>&gt;&gt; + =
=A0 =A0 =A0 =A0 =A0 =A0 oom_kill_process(current, gfp_mask, order, 0, total=
pages, memcg, NULL,<br>&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0&quot;Memory cgroup out of memory (oom_kill_allocating_t=
ask)&quot;);<br>
&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&gt; + =A0 =A0 }<br>&gt;&=
gt; +<br>&gt;&gt; =A0 =A0 =A0 for_each_mem_cgroup_tree(iter, memcg) {<br>&g=
t;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgroup =3D iter-&gt;css.c=
group;<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_iter it;<br>
&gt;&gt; --<br>&gt;&gt; 1.7.6.1<br>&gt;&gt;<br>&gt;&gt; --<br>&gt;&gt; To u=
nsubscribe from this list: send the line &quot;unsubscribe cgroups&quot; in=
<br>&gt;&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kern=
el.org">majordomo@vger.kernel.org</a><br>
&gt;&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majord=
omo-info.html">http://vger.kernel.org/majordomo-info.html</a><br>&gt;<br>&g=
t; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs<br>&gt;

--e89a8f64355695fc2504cc304ac6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
