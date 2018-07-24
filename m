Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4646B0280
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:05:38 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id h81-v6so1365993vke.13
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:05:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 1-v6sor3996426uap.282.2018.07.24.03.05.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 03:05:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz> <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com> <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
From: Bruce Merry <bmerry@ska.ac.za>
Date: Tue, 24 Jul 2018 12:05:35 +0200
Message-ID: <CAOm-9aqYLExQZUvfk9ucCoSPoaA67D6ncEDR2+UZBMLhv4-r_A@mail.gmail.com>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some machines
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 18 July 2018 at 19:40, Bruce Merry <bmerry@ska.ac.za> wrote:
>> Yes, very easy to produce zombies, though I don't think kernel
>> provides any way to tell how many zombies exist on the system.
>>
>> To create a zombie, first create a memcg node, enter that memcg,
>> create a tmpfs file of few KiBs, exit the memcg and rmdir the memcg.
>> That memcg will be a zombie until you delete that tmpfs file.
>
> Thanks, that makes sense. I'll see if I can reproduce the issue.

Hi

I've had some time to experiment with this issue, and I've now got a
way to reproduce it fairly reliably, including with a stock 4.17.8
kernel. However, it's very phase-of-the-moon stuff, and even
apparently trivial changes (like switching the order in which the
files are statted) makes the issue disappear.

To reproduce:
1. Start cadvisor running. I use the 0.30.2 binary from Github, and
run it with sudo ./cadvisor-0.30.2 --logtostderr=true
2. Run the Python 3 script below, which repeatedly creates a cgroup,
enters it, stats some files in it, and leaves it again (and removes
it). It takes a few minutes to run.
3. time cat /sys/fs/cgroup/memory/memory.stat. It now takes about 20ms for me.
4. sudo sysctl vm.drop_caches=2
5. time cat /sys/fs/cgroup/memory/memory.stat. It is back to 1-2ms.

I've also added some code to memcg_stat_show to report the number of
cgroups in the hierarchy (iterations in for_each_mem_cgroup_tree).
Running the script increases it from ~700 to ~41000. The script
iterates 250,000 times, so only some fraction of the cgroups become
zombies.

I also tried the suggestion of force_empty: it makes the problem go
away, but is also very, very slow (about 0.5s per iteration), and
given the sensitivity of the test to small changes I don't know how
meaningful that is.

Reproduction code (if you have tqdm installed you get a nice progress
bar, but not required). Hopefully Gmail doesn't do any format
mangling:


#!/usr/bin/env python3
import os

try:
    from tqdm import trange as range
except ImportError:
    pass


def clean():
    try:
        os.rmdir(name)
    except FileNotFoundError:
        pass


def move_to(cgroup):
    with open(cgroup + '/tasks', 'w') as f:
        print(pid, file=f)


pid = os.getpid()
os.chdir('/sys/fs/cgroup/memory')
name = 'dummy'
N = 250000
clean()
try:
    for i in range(N):
        os.mkdir(name)
        move_to(name)
        for filename in ['memory.stat', 'memory.swappiness']:
            os.stat(os.path.join(name, filename))
        move_to('user.slice')
        os.rmdir(name)
finally:
    move_to('user.slice')
    clean()


Regards
Bruce
-- 
Bruce Merry
Senior Science Processing Developer
SKA South Africa
