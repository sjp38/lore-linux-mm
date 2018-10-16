Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8EF6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 20:55:39 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id i15-v6so20871122itb.0
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 17:55:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w133-v6si8977031itf.106.2018.10.15.17.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 17:55:37 -0700 (PDT)
Message-Id: <201810160055.w9G0t62E045154@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH] memcg, oom: throttle =?ISO-2022-JP?B?ZHVtcF9oZWFkZXIgZm9y?=
 =?ISO-2022-JP?B?IG1lbWNnIG9vbXMgd2l0aG91dCBlbGlnaWJsZSB0YXNrcw==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 16 Oct 2018 09:55:06 +0900
References: <6c0a57b3-bfd4-d832-b0bd-5dd3bcae460e@i-love.sakura.ne.jp> <20181015133524.GM18839@dhcp22.suse.cz>
In-Reply-To: <20181015133524.GM18839@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On 2018/10/15 22:35, Michal Hocko wrote:
>> Nobody can prove that it never kills some machine. This is just one example result of
>> one example stress tried in my environment. Since I am secure programming man from security
>> subsystem, I really hate your "Can you trigger it?" resistance. Since this is OOM path
>> where nobody tests, starting from being prepared for the worst case keeps things simple.
> 
> There is simply no way to be generally safe this kind of situation. As
> soon as your console is so slow that you cannot push the oom report
> through there is only one single option left and that is to disable the
> oom report altogether. And that might be a viable option.

There is a way to be safe this kind of situation. The way is to make sure that printk()
is called with enough interval. That is, count the interval between the end of previous
printk() messages and the beginning of next printk() messages.

And you are misunderstanding my patch. Although my patch does not ratelimit the first
occurrence of memcg OOM in each memcg domain (because the first

 		dump_header(oc, NULL);
 		pr_warn("Out of memory and no killable processes...\n");

output is usually a useful information to get) which is serialized by oom_lock mutex,
my patch cannot cause lockup because my patch ratelimits subsequent outputs in any
memcg domain. That is, my patch might cause

  "** %u printk messages dropped **\n"

when we have hundreds of different memcgs triggering this path around the same time,
my patch refrains from "keep disturbing administrator's manual recovery operation from
console by printing

  "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
  "Out of memory and no killable processes...\n"

on each page fault event from hundreds of different memcgs triggering this path".

There is no need to print

  "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
  "Out of memory and no killable processes...\n"

lines on evey page fault event. A kernel which consumes multiple milliseconds on each page
fault event (due to printk() messages from the defunctional OOM killer) is stupid.

>                                                           But fiddling
> with per memcg limit is not going to fly. Just realize what will happen
> if you have hundreds of different memcgs triggering this path around the
> same time.

You have just said that "No killable process should be a rare event which
requires a seriously misconfigured memcg to happen so wildly." and now you
refer to a very bad case "Just realize what will happen if you have hundreds
of different memcgs triggering this path around the same time." which makes
your former comment suspicious.

> 
> So can you start being reasonable and try to look at a wider picture
> finally please?
> 

Honestly, I can't look at a wider picture because I have never been shown a picture from you.
What we are doing is endless loop of "let's do ... because ..." and "hmm, our assumption
was wrong because ..."; that is, making changes without firstly considering the worst case.
For example, OOM victims which David Rientjes is complaining is that our assumption that
"__oom_reap_task_mm() can reclaim majority of memory" was wrong. (And your proposal to
hand over is getting no response.) For another example, __set_oom_adj() which Yong-Taek Lee
is trying to optimize is that our assumption that "we already succeeded enforcing same
oom_score_adj among multiple thread groups" was wrong. For yet another example,
CVE-2018-1000200 and CVE-2016-10723 are caused by ignoring my concern. And funny thing
is that you negated the rationale of "mm, oom: remove sleep from under oom_lock" by
"mm, oom: remove oom_lock from oom_reaper" after only 4 days...

Anyway, I'm OK if we apply _BOTH_ your patch and my patch. Or I'm OK with simplified
one shown below (because you don't like per memcg limit).

---
 mm/oom_kill.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..9056f9b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1106,6 +1106,11 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! */
 	if (!oc->chosen) {
+		static unsigned long last_warned;
+
+		if ((is_sysrq_oom(oc) || is_memcg_oom(oc)) &&
+		    time_in_range(jiffies, last_warned, last_warned + 60 * HZ))
+			return false;
 		dump_header(oc, NULL);
 		pr_warn("Out of memory and no killable processes...\n");
 		/*
@@ -1115,6 +1120,7 @@ bool out_of_memory(struct oom_control *oc)
 		 */
 		if (!is_sysrq_oom(oc) && !is_memcg_oom(oc))
 			panic("System is deadlocked on memory\n");
+		last_warned = jiffies;
 	}
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
-- 
1.8.3.1
