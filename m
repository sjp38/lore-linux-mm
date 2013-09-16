Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 87F056B0087
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 10:01:22 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 16 Sep 2013 16:01:19 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130910211823.GJ856@cmpxchg.org>, <20130910233247.9EDF4DBA@pobox.sk>, <20130910220329.GK856@cmpxchg.org>, <20130911143305.FFEAD399@pobox.sk>, <20130911180327.GL856@cmpxchg.org>, <20130911205448.656D9D7C@pobox.sk>, <20130911191150.GN856@cmpxchg.org>, <20130911214118.7CDF2E71@pobox.sk>, <20130911200426.GO856@cmpxchg.org>, <20130914124831.4DD20346@pobox.sk> <20130916134014.GA3674@dhcp22.suse.cz>
In-Reply-To: <20130916134014.GA3674@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130916160119.2E76C2A1@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Sat 14-09-13 12:48:31, azurIt wrote:
>[...]
>> Here is the first occurence, this night between 5:15 and 5:25:
>>  - this time i kept opened terminal from other server to this problematic one with htop running
>>  - when server went down i opened it and saw one process of one user running at the top and taking 97% of CPU (cgroup 1304)
>
>I guess you do not have a stack trace(s) for that process? That would be
>extremely helpful.



I'm afraid it won't be possible as server is completely not responding when it happens. Anyway, i don't think it was a fault of one process or one user.




>>  - everything was stucked so that htop didn't help me much
>>  - luckily, my new 'load check' script, which i was mentioning before, was able to kill apache and everything went to normal (success with it's very first version, wow ;) )
>>  - i checked some other logs and everything seems to point to cgroup 1304, also kernel log at 5:14-15 is showing hard OOM in that cgroup:
>> http://watchdog.sk/lkml/kern7.log
>
>I am not sure what you mean by hard OOM because there is no global OOM
>in that log:
>$ grep "Kill process" kern7.log | sed 's@.*]\(.*Kill process\>\).*@\1@' | sort -u
> Memory cgroup out of memory: Kill process
>
>But you had a lot of memcg OOMs in that group (1304) during that time
>(and even earlier):



I meant OOM inside cgroup 1304. I'm sure this cgroup created the problem.




>$ grep "\<1304\>" kern7.log 
>Sep 14 05:03:45 server01 kernel: [188287.778020] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:03:46 server01 kernel: [188287.871427] [30433]  1304 30433   181781    66426   7       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.871594] [30808]  1304 30808   169111    53866   4       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.871742] [30809]  1304 30809   181168    65992   2       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.871890] [30811]  1304 30811   168684    53399   3       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.872041] [30814]  1304 30814   181102    65924   3       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.872189] [30815]  1304 30815   168814    53451   4       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.877731] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:03:46 server01 kernel: [188287.973155] [30808]  1304 30808   169111    53918   3       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.973155] [30809]  1304 30809   181168    65992   2       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.973155] [30811]  1304 30811   168684    53399   3       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.973155] [30814]  1304 30814   181102    65924   3       0             0 apache2
>Sep 14 05:03:46 server01 kernel: [188287.973155] [30815]  1304 30815   168815    53558   0       0             0 apache2
>Sep 14 05:03:47 server01 kernel: [188289.137540] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:03:47 server01 kernel: [188289.231873] [30809]  1304 30809   182662    67534   7       0             0 apache2
>Sep 14 05:03:47 server01 kernel: [188289.232021] [30811]  1304 30811   171920    56781   4       0             0 apache2
>Sep 14 05:03:47 server01 kernel: [188289.232171] [30814]  1304 30814   182596    67470   3       0             0 apache2
>Sep 14 05:03:47 server01 kernel: [188289.232319] [30815]  1304 30815   171920    56778   1       0             0 apache2
>Sep 14 05:03:47 server01 kernel: [188289.232478] [30896]  1304 30896   171918    56761   0       0             0 apache2
>[...]
>Sep 14 05:14:00 server01 kernel: [188902.666893] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:14:00 server01 kernel: [188902.742928] [ 7806]  1304  7806   178891    64008   6       0             0 apache2
>Sep 14 05:14:00 server01 kernel: [188902.743080] [ 7910]  1304  7910   175318    60302   2       0             0 apache2
>Sep 14 05:14:00 server01 kernel: [188902.743228] [ 7911]  1304  7911   174943    59878   1       0             0 apache2
>Sep 14 05:14:00 server01 kernel: [188902.743376] [ 7912]  1304  7912   171568    56404   3       0             0 apache2
>Sep 14 05:14:00 server01 kernel: [188902.743524] [ 7914]  1304  7914   174911    59879   5       0             0 apache2
>Sep 14 05:14:00 server01 kernel: [188902.743673] [ 7915]  1304  7915   173472    58386   2       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.249749] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7910]  1304  7910   176278    61211   6       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7911]  1304  7911   176278    61211   7       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7912]  1304  7912   173732    58655   3       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7914]  1304  7914   176269    61211   7       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7915]  1304  7915   176269    61211   7       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.336276] [ 7966]  1304  7966   170385    55164   7       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.340992] Task in /1304/uid killed as a result of limit of /1304
>Sep 14 05:14:02 server01 kernel: [188904.424284] [ 7911]  1304  7911   176340    61332   2       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.424284] [ 7912]  1304  7912   173996    58901   1       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.424284] [ 7914]  1304  7914   176331    61331   4       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.424284] [ 7915]  1304  7915   176331    61331   2       0             0 apache2
>Sep 14 05:14:02 server01 kernel: [188904.424284] [ 7966]  1304  7966   170385    55164   7       0             0 apache2
>[...]
>
>The only thing that is clear from this is that there is always one
>process killed and a new one is spawned and that leads to the same
>out of memory situation. So this is precisely what Johannes already
>described as a Hydra load.



I can't do anything with this, the processes are visitors on web sites of that user.




>There is a silence in the logs:
>Sep 14 05:14:39 server01 kernel: [188940.869639] Killed process 8453 (apache2) total-vm:710732kB, anon-rss:245680kB, file-rss:4588kB
>Sep 14 05:21:24 server01 kernel: [189344.518699] grsec: From 95.103.217.66: failed fork with errno EAGAIN by /bin/dash[sh:10362] uid/euid:1387/1387 g
>id/egid:100/100, parent /usr/sbin/cron[cron:10144] uid/euid:0/0 gid/egid:0/0
>
>Myabe that is what you are referring to as a stuck situation. Is pid
>8453 the task you have seen consuming the CPU? If yes, then we would
>need a stack for that task to find out what is going on.




Unfortunately i don't know the PID but i don't think it's important. I just wanted to tell that cgroup 1304 was doing problem in this particular case (there were several signes pointing to it). As you can see in the logs, too much memcg OOM is creating huge I/O which is taking down the whole server for no reason.

The same thing is happennig several times per day *if* i'm running kernel with Joahnnes latest patch.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
