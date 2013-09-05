Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 359E06B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 07:47:04 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Thu, 05 Sep 2013 13:47:02 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130830215852.3E5D3D66@pobox.sk>, <20130902123802.5B8E8CB1@pobox.sk>, <20130903204850.GA1412@cmpxchg.org>, <20130904114523.A9F0173C@pobox.sk>, <20130904115741.GA28285@dhcp22.suse.cz>, <20130904141000.0F910EFA@pobox.sk>, <20130904122632.GB28285@dhcp22.suse.cz>, <20130905111430.CB1392B4@pobox.sk>, <20130905095331.GA9702@dhcp22.suse.cz>, <20130905121700.546B5881@pobox.sk> <20130905111742.GC9702@dhcp22.suse.cz>
In-Reply-To: <20130905111742.GC9702@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130905134702.C703F65B@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>On Thu 05-09-13 12:17:00, azurIt wrote:
>> >[...]
>> >> My script detected another freezed cgroup today, sending stacks. Is
>> >> there anything interesting?
>> >
>> >3 tasks are sleeping and waiting for somebody to take an action to
>> >resolve memcg OOM. The memcg oom killer is enabled for that group?  If
>> >yes, which task has been selected to be killed? You can find that in oom
>> >report in dmesg.
>> >
>> >I can see a way how this might happen. If the killed task happened to
>> >allocate a memory while it is exiting then it would get to the oom
>> >condition again without freeing any memory so nobody waiting on the
>> >memcg_oom_waitq gets woken. We have a report like that: 
>> >https://lkml.org/lkml/2013/7/31/94
>> >
>> >The issue got silent in the meantime so it is time to wake it up.
>> >It would be definitely good to see what happened in your case though.
>> >If any of the bellow tasks was the oom victim then it is very probable
>> >this is the same issue.
>> 
>> Here it is:
>> http://watchdog.sk/lkml/kern5.log
>
>$ grep "Killed process \<103[168]\>" kern5.log
>$
>
>So none of the sleeping tasks has been killed previously.
>
>> Processes were killed by my script
>
>OK, I am really confused now. The log contains a lot of in-kernel memcg
>oom killer messages:
>$ grep "Memory cgroup out of memory:" kern5.log | wc -l
>809
>
>This suggests that the oom killer is not disabled. What exactly has you
>script done?
>
>> at about 11:05:35.
>
>There is an oom killer striking at 11:05:35:
>Sep  5 11:05:35 server02 kernel: [1751856.433101] Task in /1066/uid killed as a result of limit of /1066
>[...]
>Sep  5 11:05:35 server02 kernel: [1751856.539356] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
>Sep  5 11:05:35 server02 kernel: [1751856.539745] [ 1046]  1066  1046   228537    95491   3       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.539894] [ 1047]  1066  1047   228604    95488   6       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.540043] [ 1050]  1066  1050   228470    95452   5       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.540191] [ 1051]  1066  1051   228592    95521   6       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.540340] [ 1052]  1066  1052   228594    95546   5       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.540489] [ 1054]  1066  1054   228470    95453   5       0             0 apache2
>Sep  5 11:05:35 server02 kernel: [1751856.540646] Memory cgroup out of memory: Kill process 1046 (apache2) score 1000 or sacrifice child
>
>And this doesn't list any of the tasks sleeping and waiting for oom
>resolving so they must have been created after this OOM. Is this the
>same group?




cgroup was 1066. My script is doing this:
1.) It checks memory usage of all cgroups and is searching for those whos memory usage is >= 99% of their limit.
2.) If any are found, they are saved in an array of 'candidates for killing'.
3.) It sleep for 30 seconds.
4.) Do (1) and if any of found cgorups were also found in (2), it kills all processes inside it.
5.) Clear array of saved cgroups and continue.
...

In other words, if any cgroup has memory usage >= 99% of it's limit for more than 30 seconds, it is considered as 'freezed' and all it's processes are killed. This script is tested and was really able to resolve my original problem automatically without need of restarting the server or doing any outage of services. But, of course, i cannot guarantee that the killed cgroup was really freezed (because of bug in linux kernel), there could be some false positives - for example, cgroup has 99% usage of memory, my script detected it, OOM successfully resolved the problem and, after 30 seconds, the same cgroup has again 99% usage of it's memory and my script detected it again. This is why i'm sending stacks here, i simply cannot tell if there was or wasn't a problem. I can disable the script and wait until the problem really occurs but when it happens, our services will go down. Hope i was clear enough - if not, i can post the source code of that script.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
