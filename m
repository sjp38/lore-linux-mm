Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF576B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 02:44:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so56451538pgd.12
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 23:44:42 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id i72si2121533pfj.386.2017.08.08.23.44.40
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 23:44:41 -0700 (PDT)
Date: Wed, 09 Aug 2017 14:44:23 +0800
Subject: memcg Can't context between v1 and v2 because css->refcnt not
 released
From: "=?GBK?B?0/fN+w==?=" <yuwang.yuwang@alibaba-inc.com>
Message-ID: <D5B0D047.344%yuwang.yuwang@alibaba-inc.com>
Mime-version: 1.0
Content-type: text/plain;
	charset="US-ASCII"
Content-transfer-encoding: 7bit
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
