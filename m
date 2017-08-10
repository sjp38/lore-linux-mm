Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0A54C6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:10:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 16so178276pgg.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:10:48 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id q8si3660947pgs.869.2017.08.10.01.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 01:10:46 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id c28so142292pfe.3
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:10:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170810071059.GC23863@dhcp22.suse.cz>
References: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
 <20170810071059.GC23863@dhcp22.suse.cz>
From: wang Yu <yuwang668899@gmail.com>
Date: Thu, 10 Aug 2017 16:10:45 +0800
Message-ID: <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
Subject: Re: memcg Can't context between v1 and v2 because css->refcnt not released
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

at first ,thanks for your reply.
but i also tested what you said, the problem is also.
force_empty only call try_to_free_pages, not all the pages remove
because mem_cgroup_reparent_charges moved
#cd /sys/fs/cgroup/memory
#mkdir a
#echo 0 > a/cgroup.procs
#sleep 1
#echo 0 > a/cgroup.procs
#echo 1 > a/memory.force_empty
#rmdir a
#cat /proc/cgroups
#subsys_name hierarchy num_cgroups enabled
memory 2 2 1
the num_cgroups also not released





2017-08-10 15:10 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 09-08-17 15:06:34, wang Yu wrote:
>> Hello Johannes ,Michal,and Tejun:
>>
>>   i using memcg v1,  but some reason  i want to context to  memcg v2,
>> but i can't, here is my step:
>> #cat /proc/cgroups
>> #subsys_name hierarchy num_cgroups enabled
>>  memory 5 1 1
>> #cd /sys/fs/cgroup/memory
>> #mkdir a
>> #echo 0 > a/cgroup.procs
>> #sleep 1
>> #echo 0 > cgroup.procs
>
> This doesn't do what you think. It will try to add a non-existant pid 0
> to the root cgroup. You need to remove cgroup a. Moreover it is possible
> that the `sleep' command will fault some page cache and that will stay
> in memcg `a' until there is a memory pressure. cgroup v1 had
> force_empty knob which you can use to drain the cgroup before removal.
> Then you should be able to umount the v1 cgroup and mount v2.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
