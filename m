Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 740666B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:19:52 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j47so3748913ota.16
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:19:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 74-v6si11694508oie.75.2018.10.10.07.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 07:19:51 -0700 (PDT)
Subject: Re: INFO: rcu detected stall in shmem_fault
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
 <20181010113500.GH5873@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <127c73bd-2c7b-6ef0-3c6d-5e01d43bdf5b@i-love.sakura.ne.jp>
Date: Wed, 10 Oct 2018 23:19:21 +0900
MIME-Version: 1.0
In-Reply-To: <20181010113500.GH5873@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>

On 2018/10/10 20:35, Michal Hocko wrote:
>>>> What should we do if memcg-OOM found no killable task because the allocating task
>>>> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
>>>> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
>>>> OOM header when no eligible victim left") because syzbot was terminating the test
>>>> upon WARN(1) removed by that commit) is not a good behavior.
>>>
>>> We definitely want to inform about ineligible oom victim. We might
>>> consider some rate limiting for the memcg state but that is a valuable
>>> information to see under normal situation (when you do not have floods
>>> of these situations).
>>>
>>
>> But if the caller cannot be noticed by SIGKILL from the OOM killer,
>> allowing the caller to trigger the OOM killer again and again (until
>> global OOM killer triggers) is bad.
> 
> There is simply no other option. Well, except for failing the charge
> which has been considered and refused because it could trigger
> unexpected error paths and that breaking the isolation on rare cases
> when of the misconfiguration is acceptable. We can reconsider that
> but you should bring really good arguments on the table. I was very
> successful doing that.
> 

By the way, how do we avoid this flooding? Something like this?

 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 977cb57..58eff50 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -723,6 +723,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_MEMCG
 	unsigned			in_user_fault:1;
+	unsigned			memcg_oom_no_eligible_warned:1;
 #ifdef CONFIG_MEMCG_KMEM
 	unsigned			memcg_kmem_skip_account:1;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..ff0fa65 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1106,6 +1106,13 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
+#ifdef CONFIG_MEMCG
+		if (is_memcg_oom(oc)) {
+			if (current->memcg_oom_no_eligible_warned)
+				return false;
+			current->memcg_oom_no_eligible_warned = 1;
+		}
+#endif
 		dump_header(oc, NULL);
 		pr_warn("Out of memory and no killable processes...\n");
 		/*
@@ -1115,6 +1122,10 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
 			panic("System is deadlocked on memory\n");
+#ifdef CONFIG_MEMCG
+	} else if (is_memcg_oom(oc)) {
+		current->memcg_oom_no_eligible_warned = 0;
+#endif
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-- 
1.8.3.1
