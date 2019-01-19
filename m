Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3BC28E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 20:59:01 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j3so5324330itf.5
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:59:01 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j82si3584690itb.63.2019.01.18.17.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 17:59:00 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
Date: Sat, 19 Jan 2019 01:58:48 +0000
Message-ID: <20190119015843.GB15935@castle.DHCP.thefacebook.com>
References: <20190119005022.61321-1-shakeelb@google.com>
In-Reply-To: <20190119005022.61321-1-shakeelb@google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DC4AE722C37E5B4FB770603647BAD67D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Shakeel!

>=20
> On looking further it seems like the process selected to be oom-killed
> has exited even before reaching read_lock(&tasklist_lock) in
> oom_kill_process(). More specifically the tsk->usage is 1 which is due
> to get_task_struct() in oom_evaluate_task() and the put_task_struct
> within for_each_thread() frees the tsk and for_each_thread() tries to
> access the tsk. The easiest fix is to do get/put across the
> for_each_thread() on the selected task.

Please, feel free to add
Reviewed-by: Roman Gushchin <guro@fb.com>
for this part.

>=20
> Now the next question is should we continue with the oom-kill as the
> previously selected task has exited? However before adding more
> complexity and heuristics, let's answer why we even look at the
> children of oom-kill selected task? The select_bad_process() has already
> selected the worst process in the system/memcg. Due to race, the
> selected process might not be the worst at the kill time but does that
> matter matter? The userspace can play with oom_score_adj to prefer
> children to be killed before the parent. I looked at the history but it
> seems like this is there before git history.

I'd totally support you in an attempt to remove this logic,
unless someone has a good example of its usefulness.

I believe it's a very old hack to select children over parents
in case they have the same oom badness (e.g. share most of the memory).

Maybe we can prefer older processes in case of equal oom badness,
and it will be enough.

Thanks!
