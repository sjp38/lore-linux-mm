Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BEF016B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:37:30 -0500 (EST)
Received: by qafl39 with SMTP id l39so1775551qaf.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 16:37:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4CD231.907@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-2-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD231.907@parallels.com>
Date: Tue, 28 Feb 2012 16:37:29 -0800
Message-ID: <CABCjUKAmM+DaNFuoUP_BiGdQ=SoWOXHijy8jmSPoEozBD-_JhA@mail.gmail.com>
Subject: Re: [PATCH 01/10] memcg: Kernel memory accounting infrastructure.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 5:10 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
>>
>> Enabled with CONFIG_CGROUP_MEM_RES_CTLR_KMEM.
>>
>> Adds the following files:
>> =A0 =A0 - memory.kmem.independent_kmem_limit
>> =A0 =A0 - memory.kmem.usage_in_bytes
>> =A0 =A0 - memory.kmem.limit_in_bytes
>>
>> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
>> ---
>> =A0mm/memcontrol.c | =A0121
>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>> =A01 files changed, 120 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 228d646..11e31d6 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -235,6 +235,10 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0struct res_counter memsw;
>> =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0* the counter to account for kernel memory usage.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 struct res_counter kmem_bytes;
>> + =A0 =A0 =A0 /*
>
> Not terribly important, but I find this name inconsistent. I like
> just kmem better.

I will change it.

>> =A0 =A0 =A0 =A0 * Per cgroup active and inactive list, similar to the
>> =A0 =A0 =A0 =A0 * per zone LRU lists.
>> =A0 =A0 =A0 =A0 */
>> @@ -293,6 +297,7 @@ struct mem_cgroup {
>> =A0#ifdef CONFIG_INET
>> =A0 =A0 =A0 =A0struct tcp_memcontrol tcp_mem;
>> =A0#endif
>> + =A0 =A0 =A0 int independent_kmem_limit;
>> =A0};
>
> bool ?
>
> But that said, we are now approaching some 4 or 5 selectables in the memc=
g
> structure. How about we turn them into flags?

The only other selectable (that is a boolean) I see is use_hierarchy.
Or do you also mean oom_lock and memsw_is_minimum?

Either way, I'll try to make them into flags.

>> @@ -4587,6 +4647,10 @@ static int register_kmem_files(struct cgroup *con=
t,
>> struct cgroup_subsys *ss)
>> =A0static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cg=
roup *cont)
>> =A0{
>> + =A0 =A0 =A0 struct mem_cgroup *memcg;
>> +
>> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_cont(cont);
>> + =A0 =A0 =A0 BUG_ON(res_counter_read_u64(&memcg->kmem_bytes, RES_USAGE)=
 !=3D 0);
>
> That does not seem to make sense, specially if you are doing lazy creatio=
n.
> What happens if you create a cgroup, don't put any tasks into it (therefo=
re,
> usage =3D=3D 0), and then destroy it right away?
>
> Or am I missing something?

The BUG_ON will only trigger if there is any remaining kernel memory,
so the situation you describe should not be a problem.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
