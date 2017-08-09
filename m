Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 634BC6B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 03:06:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v11so5399756oif.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 00:06:36 -0700 (PDT)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id u126si2184330oig.310.2017.08.09.00.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 00:06:35 -0700 (PDT)
Received: by mail-it0-x22d.google.com with SMTP id 76so14919579ith.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 00:06:34 -0700 (PDT)
MIME-Version: 1.0
From: wang Yu <yuwang668899@gmail.com>
Date: Wed, 9 Aug 2017 15:06:34 +0800
Message-ID: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
Subject: memcg Can't context between v1 and v2 because css->refcnt not released
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello Johannes ,Michal,and Tejun:

  i using memcg v1,  but some reason  i want to context to  memcg v2,
but i can't, here is my step:
#cat /proc/cgroups
#subsys_name hierarchy num_cgroups enabled
 memory 5 1 1
#cd /sys/fs/cgroup/memory
#mkdir a
#echo 0 > a/cgroup.procs
#sleep 1
#echo 0 > cgroup.procs
#cat /proc/cgroups
#subsys_name hierarchy num_cgroups enabled
 memory 5 2 1
the num_cgroups not go to "1"
so it will lead to can't context to memcg 2
#cd ..
#umount memory
umount: /sys/fs/cgroup/memory: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))

  and i have tracked  the root cause, i found that "b2052564e66d mm:
memcontrol: continue cache reclaim from offlined groups"from Johannes
Weiner, remove mem_cgroup_reparent_charges when mem_cgroup_css_offline, so
the css->refcount  not go to "0", so the css_release not call when rmdir
cgroup, and nr_cgroups not released.
  so i want to ask does it reasonable can't context between v1 and v2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
