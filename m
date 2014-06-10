Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF366B00F5
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:42:22 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q108so10377723qgd.33
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 07:42:22 -0700 (PDT)
Received: from mail.siteground.com (mail.siteground.com. [67.19.240.234])
        by mx.google.com with ESMTPS id y9si27845435qat.45.2014.06.10.07.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 07:42:21 -0700 (PDT)
Message-ID: <5397194B.9010606@1h.com>
Date: Tue, 10 Jun 2014 17:42:19 +0300
From: Marian Marinov <mm@1h.com>
MIME-Version: 1.0
Subject: Re: [RFC] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
References: <5396ED66.7090401@1h.com> <20140610115254.GA25631@dhcp22.suse.cz>
In-Reply-To: <20140610115254.GA25631@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 06/10/2014 02:52 PM, Michal Hocko wrote:
> [More people to CC] On Tue 10-06-14 14:35:02, Marian Marinov wrote:
>> -----BEGIN PGP SIGNED MESSAGE----- Hash: SHA1
>> 
>> Hello,
> 
> Hi,
> 
>> a while back in 2012 there was a request for this functionality. oom, memcg: handle sysctl
>> oom_kill_allocating_task while memcg oom happening
>> 
>> This is the thread: https://lkml.org/lkml/2012/10/16/168
>> 
>> Now we run a several machines with around 10k processes on each machine, using containers.
>> 
>> Regularly we see OOM from within a container that causes performance degradation.
> 
> What kind of performance degradation and which parts of the system are affected?

The responsiveness to SSH terminals and DB queries on the host machine is significantly slowed.
I'm still unsure what exactly to measure.

> 
> memcg oom killer happens outside of any locks currently so the only bottleneck I can see is the per-cgroup
> container which iterates all tasks in the group. Is this what is going on here?

When the container has 1000s of processes it seams that there is a problem. But I'm not sure, and will be happy to put
some diagnostic lines of code there.

> 
>> We are running 3.12.20 with the following OOM configuration and memcg oom enabled:
>> 
>> vm.oom_dump_tasks = 0 vm.oom_kill_allocating_task = 1 vm.panic_on_oom = 0
>> 
>> When OOM occurs we see very high numbers for the loadavg and the overall responsiveness of the machine degrades.
> 
> What is the system waiting for?

I don't know, since I was not the one to actually handle the case. However, my guys are instructed to collect iostat
and vmstat information from the machines, the next time this happens.

> 
>> During these OOM states the load of the machine gradualy increases from 25 up to 120 in the interval of
>> 10minutes.
>> 
>> Once we manually bring down the memory usage of a container(killing some tasks) the load drops down to 25 within
>> 5 to 7 minutes.
> 
> So the OOM killer is not able to find a victim to kill?

It was constantly killing tasks. 245 oom invocations in less then 6min for that particular cgroup. With top 61 oom
invocations in one minute.

It was killing... In that particular case, the problem was a web server that was under attack. New php processes was
spawned very often and instead of killing each newly created process(which is allocating memory) the kernel tries to
find more suitable task. Which in this case was not desired.

> 
>> I read the whole thread from 2012 but I do not see the expected behavior that is described by the people that
>> commented the issue.
> 
> Why do you think that killing the allocating task would be helpful in your case?

As mentioned above, the usual case with the hosting companies is that, the allocating task should not be allowed to
run. So killing it is the proper solution there.

Essentially we solved the issue by setting a process limit to that particular cgroup using the task-limit patches of
Dwight Engen.

> 
>> In this case, with real usage for this patch, would it be considered for inclusion?
> 
> I would still prefer to fix the real issue which is not clear from your description yet.

I would love to have a better way to solve the issue.

Marian



- -- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman@jabber.org
ICQ: 7556201
Mobile: +359 886 660 270
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOXGUsACgkQ4mt9JeIbjJR1YACgysnzxg9IPzcwQRmBZVVV6cp3
N4YAoKygaqbqcuz6dkmtMfI/pu2Br5H/
=3pZj
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
