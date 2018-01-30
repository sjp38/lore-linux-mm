Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B75F6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:59:49 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id r22so6874408qkr.19
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:59:49 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c126si2548877qkf.259.2018.01.30.03.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 03:59:48 -0800 (PST)
Date: Tue, 30 Jan 2018 11:58:51 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180130115846.GA4720@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
 <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
 <20180129104657.GC21609@dhcp22.suse.cz>
 <20180129191139.GA1121507@devbig577.frc2.facebook.com>
 <20180130085445.GQ21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180130085445.GQ21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 30, 2018 at 09:54:45AM +0100, Michal Hocko wrote:
> On Mon 29-01-18 11:11:39, Tejun Heo wrote:

Hello, Michal!

> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index 2eaed1e2243d..67bdf19f8e5b 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1291,8 +1291,14 @@ This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
>  the memory controller considers only cgroups belonging to the sub-tree
>  of the OOM'ing cgroup.
>  
> -The root cgroup is treated as a leaf memory cgroup, so it's compared
> -with other leaf memory cgroups and cgroups with oom_group option set.
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IMO, this statement is important. Isn't it?

> +Leaf cgroups are compared based on their cumulative memory usage. The
> +root cgroup is treated as a leaf memory cgroup as well, so it's
> +compared with other leaf memory cgroups. Due to internal implementation
> +restrictions the size of the root cgroup is a cumulative sum of
> +oom_badness of all its tasks (in other words oom_score_adj of each task
> +is obeyed). Relying on oom_score_adj (appart from OOM_SCORE_ADJ_MIN)
> +can lead to overestimating of the root cgroup consumption and it is

Hm, and underestimating too. Also OOM_SCORE_ADJ_MIN isn't any different
in this case. Say, all tasks except a small one have OOM_SCORE_ADJ set to
-999, this means the root croup has extremely low chances to be elected.

> +therefore discouraged. This might change in the future, though.

Other than that looks very good to me.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
