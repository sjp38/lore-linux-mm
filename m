Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2C16C9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 16:44:18 -0400 (EDT)
Message-ID: <4E823571.6060001@parallels.com>
Date: Tue, 27 Sep 2011 17:43:29 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-3-git-send-email-glommer@parallels.com> <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com> <4E7A342B.5040608@parallels.com> <CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com> <CAKTCnz=59HuEg9T-USi5oKSK=F+vr2QxCA17+i-rGj73k49rzw@mail.gmail.com> <4E7DECF0.9050804@parallels.com> <20110926195213.12da87b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110926195213.12da87b4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: multipart/mixed;
	boundary="------------070208030404050102060306"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

--------------070208030404050102060306
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 09/26/2011 07:52 AM, KAMEZAWA Hiroyuki wrote:
> On Sat, 24 Sep 2011 11:45:04 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> On 09/22/2011 12:09 PM, Balbir Singh wrote:
>>> On Thu, Sep 22, 2011 at 11:30 AM, Greg Thelen<gthelen@google.com>   wrote:
>>>> On Wed, Sep 21, 2011 at 11:59 AM, Glauber Costa<glommer@parallels.com>   wrote:
>>>>> Right now I am working under the assumption that tasks are long lived inside
>>>>> the cgroup. Migration potentially introduces some nasty locking problems in
>>>>> the mem_schedule path.
>>>>>
>>>>> Also, unless I am missing something, the memcg already has the policy of
>>>>> not carrying charges around, probably because of this very same complexity.
>>>>>
>>>>> True that at least it won't EBUSY you... But I think this is at least a way
>>>>> to guarantee that the cgroup under our nose won't disappear in the middle of
>>>>> our allocations.
>>>>
>>>> Here's the memcg user page behavior using the same pattern:
>>>>
>>>> 1. user page P is allocate by task T in memcg M1
>>>> 2. T is moved to memcg M2.  The P charge is left behind still charged
>>>> to M1 if memory.move_charge_at_immigrate=0; or the charge is moved to
>>>> M2 if memory.move_charge_at_immigrate=1.
>>>> 3. rmdir M1 will try to reclaim P (if P was left in M1).  If unable to
>>>> reclaim, then P is recharged to parent(M1).
>>>>
>>>
>>> We also have some magic in page_referenced() to remove pages
>>> referenced from different containers. What we do is try not to
>>> penalize a cgroup if another cgroup is referencing this page and the
>>> page under consideration is being reclaimed from the cgroup that
>>> touched it.
>>>
>>> Balbir Singh
>> Do you guys see it as a showstopper for this series to be merged, or can
>> we just TODO it ?
>>
>
> In my experience, 'I can't rmdir cgroup.' is always an important/difficult
> problem. The users cannot know where the accouting is leaking other than
> kmem.usage_in_bytes or memory.usage_in_bytes. and can't fix the issue.
>
> please add EXPERIMENTAL to Kconfig until this is fixed.
>
>> I can push a proposal for it, but it would be done in a separate patch
>> anyway. Also, we may be in better conditions to fix this when the slab
>> part is merged - since it will likely have the same problems...
>>
>
> Yes. considering sockets which can be shared between tasks(cgroups)
> you'll finally need
>    - owner task of socket
>    - account moving callback
>
> Or disallow task moving once accounted.
>

So,

I tried to come up with proper task charge moving here, and the locking 
easily gets quite complicated. (But I have the feeling I am overlooking 
something...) So I think I'll really need more time for that.

What do you guys think of this following patch, + EXPERIMENTAL ?


--------------070208030404050102060306
Content-Type: text/plain; name="foo.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="foo.patch"

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f784cb7..684c090 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -257,6 +257,7 @@ struct mem_cgroup;
 struct tcp_memcontrol {
 	/* per-cgroup tcp memory pressure knobs */
 	int tcp_max_memory;
+	atomic_t refcnt;
 	atomic_long_t tcp_memory_allocated;
 	struct percpu_counter tcp_sockets_allocated;
 	/* those two are read-mostly, leave them at the end */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6937f20..b594a9a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -361,34 +361,21 @@ static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 
 void sock_update_memcg(struct sock *sk)
 {
-	/* right now a socket spends its whole life in the same cgroup */
-	BUG_ON(sk->sk_cgrp);
-
 	rcu_read_lock();
 	sk->sk_cgrp = mem_cgroup_from_task(current);
-
-	/*
-	 * We don't need to protect against anything task-related, because
-	 * we are basically stuck with the sock pointer that won't change,
-	 * even if the task that originated the socket changes cgroups.
-	 *
-	 * What we do have to guarantee, is that the chain leading us to
-	 * the top level won't change under our noses. Incrementing the
-	 * reference count via cgroup_exclude_rmdir guarantees that.
-	 */
-	cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));
 	rcu_read_unlock();
 }
 
 void sock_release_memcg(struct sock *sk)
 {
-	cgroup_release_and_wakeup_rmdir(mem_cgroup_css(sk->sk_cgrp));
 }
 
 void memcg_sock_mem_alloc(struct mem_cgroup *mem, struct proto *prot,
 			  int amt, int *parent_failure)
 {
+	atomic_inc(&mem->tcp.refcnt);
 	mem = parent_mem_cgroup(mem);
+
 	for (; mem != NULL; mem = parent_mem_cgroup(mem)) {
 		long alloc;
 		long *prot_mem = prot->prot_mem(mem);
@@ -406,9 +393,12 @@ EXPORT_SYMBOL(memcg_sock_mem_alloc);
 
 void memcg_sock_mem_free(struct mem_cgroup *mem, struct proto *prot, int amt)
 {
-	mem = parent_mem_cgroup(mem);
-	for (; mem != NULL; mem = parent_mem_cgroup(mem))
-		atomic_long_sub(amt, prot->memory_allocated(mem));
+	struct mem_cgroup *parent;
+	parent = parent_mem_cgroup(mem);
+	for (; parent != NULL; parent = parent_mem_cgroup(parent))
+		atomic_long_sub(amt, prot->memory_allocated(parent));
+
+	atomic_dec(&mem->tcp.refcnt);
 }
 EXPORT_SYMBOL(memcg_sock_mem_free);
 
@@ -541,6 +531,7 @@ int tcp_init_cgroup(struct proto *prot, struct cgroup *cgrp,
 
 	cg->tcp.tcp_memory_pressure = 0;
 	atomic_long_set(&cg->tcp.tcp_memory_allocated, 0);
+	atomic_set(&cg->tcp.refcnt, 0);
 	percpu_counter_init(&cg->tcp.tcp_sockets_allocated, 0);
 
 	limit = nr_free_buffer_pages() / 8;
@@ -5787,6 +5778,9 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 	int ret = 0;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
 
+	if (atomic_read(&mem->tcp.refcnt))
+		return 1;
+
 	if (mem->move_charge_at_immigrate) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);
@@ -5957,6 +5951,11 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
 				struct task_struct *p)
 {
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
+
+	if (atomic_read(&mem->tcp.refcnt))
+		return 1;
+
 	return 0;
 }
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,

--------------070208030404050102060306--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
