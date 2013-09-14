Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D7EFE6B0031
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 06:48:33 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Sat, 14 Sep 2013 12:48:31 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130910201222.GA25972@cmpxchg.org>, <20130910230853.FEEC19B5@pobox.sk>, <20130910211823.GJ856@cmpxchg.org>, <20130910233247.9EDF4DBA@pobox.sk>, <20130910220329.GK856@cmpxchg.org>, <20130911143305.FFEAD399@pobox.sk>, <20130911180327.GL856@cmpxchg.org>, <20130911205448.656D9D7C@pobox.sk>, <20130911191150.GN856@cmpxchg.org>, <20130911214118.7CDF2E71@pobox.sk> <20130911200426.GO856@cmpxchg.org>
In-Reply-To: <20130911200426.GO856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130914124831.4DD20346@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> CC: "Andrew Morton" <akpm@linux-foundation.org>, "Michal Hocko" <mhocko@suse.cz>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Wed, Sep 11, 2013 at 09:41:18PM +0200, azurIt wrote:
>> >On Wed, Sep 11, 2013 at 08:54:48PM +0200, azurIt wrote:
>> >> >On Wed, Sep 11, 2013 at 02:33:05PM +0200, azurIt wrote:
>> >> >> >On Tue, Sep 10, 2013 at 11:32:47PM +0200, azurIt wrote:
>> >> >> >> >On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
>> >> >> >> >> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
>> >> >> >> >> >> Here is full kernel log between 6:00 and 7:59:
>> >> >> >> >> >> http://watchdog.sk/lkml/kern6.log
>> >> >> >> >> >
>> >> >> >> >> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
>> >> >> >> >> >more show up!
>> >> >> >> >> 
>> >> >> >> >> 
>> >> >> >> >> 
>> >> >> >> >> Yeah, it's supposed to do this ;)
>> >> >> >
>> >> >> >How are you expecting the machine to recover from an OOM situation,
>> >> >> >though?  I guess I don't really understand what these machines are
>> >> >> >doing.  But if you are overloading them like crazy, isn't that the
>> >> >> >expected outcome?
>> >> >> 
>> >> >> 
>> >> >> 
>> >> >> 
>> >> >> 
>> >> >> There's no global OOM, server has enough of memory. OOM is occuring only in cgroups (customers who simply don't want to pay for more memory).
>> >> >
>> >> >Yes, sure, but when the cgroups are thrashing, they use the disk and
>> >> >CPU to the point where the overall system is affected.
>> >> 
>> >> 
>> >> 
>> >> 
>> >> Didn't know that there is a disk usage because of this, i never noticed anything yet.
>> >
>> >You said there was heavy IO going on...?
>> 
>> 
>> 
>> Yes, there usually was a big IO but it was related to that
>> deadlocking bug in kernel (or i assume it was). I never saw a big IO
>> in normal conditions even when there were lots of OOM in
>> cgroups. I'm even not using swap because of this so i was assuming
>> that lacks of memory is not doing any additional IO (or am i
>> wrong?). And if you mean that last problem with IO from Monday, i
>> don't exactly know what happens but it's really long time when we
>> had so big problem with IO that it disables also root login on
>> console.
>
>The deadlocking problem should be separate from this.
>
>Even without swap, the binaries and libraries of the running tasks can
>get reclaimed (and immediately faulted back from disk, i.e thrashing).
>
>Usually the OOM killer should kick in before tasks cannibalize each
>other like that.
>
>The patch you were using did in fact have the side effect of widening
>the window between tasks entering heavy reclaim and the OOM killer
>kicking in, so it could explain the IO worsening while fixing the dead
>lock problem.
>
>That followup patch tries to narrow this window by quite a bit and
>tries to stop concurrent reclaim when the group is already OOM.



Johannes,

the problem happened again, twice, but i have little more info than before.

Here is the first occurence, this night between 5:15 and 5:25:
 - this time i kept opened terminal from other server to this problematic one with htop running
 - when server went down i opened it and saw one process of one user running at the top and taking 97% of CPU (cgroup 1304)
 - everything was stucked so that htop didn't help me much
 - luckily, my new 'load check' script, which i was mentioning before, was able to kill apache and everything went to normal (success with it's very first version, wow ;) )
 - i checked some other logs and everything seems to point to cgroup 1304, also kernel log at 5:14-15 is showing hard OOM in that cgroup:
http://watchdog.sk/lkml/kern7.log


Second time it happend between 12:01 and 12:09 but it was in the middle of the day so i'm not attaching any logs (there will be lots of other junk so it will be harded to read something from it). It was related to different cgroup than in first time.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
