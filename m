Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDD46B0005
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 22:17:58 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id z6so6484252iob.3
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 19:17:58 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [69.252.207.35])
        by mx.google.com with ESMTPS id h67si1114194ioe.327.2018.02.22.19.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 19:17:57 -0800 (PST)
Date: Thu, 22 Feb 2018 21:16:55 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
In-Reply-To: <20180222135345.epm6e34cvxzaxn74@quack2.suse.cz>
Message-ID: <alpine.DEB.2.20.1802222112280.6687@nuc-kabylake>
References: <20180221030101.221206-1-shakeelb@google.com> <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake> <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com> <alpine.DEB.2.20.1802211155500.13845@nuc-kabylake>
 <20180222135345.epm6e34cvxzaxn74@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 22 Feb 2018, Jan Kara wrote:

> I don't see how task work can be used here. Firstly I don't know of a case
> where task work would be used for something else than the current task -
> and that is substantial because otherwise you have to deal with lots of
> problems like races with task exit, when work gets executed (normally it
> gets executed once task exits to userspace) etc. Or do you mean that you'd
> queue task work for current task and then somehow magically switch memcg
> there? In that case this magic switching isn't clear to me...

Thats surprising since one can specify the task. If its only for current
then why do you need a parameter?

I think a capability of executing a function in the context of another
running task could simplify a lot. In particular if something triggers
behavior that is related to another task from the kernel like whats
happening here.

It should not be that difficult to do proper synchronization on the list
of work and then set some flag (maybe SIGPENDING) to make the task execute
whats on the tasklist. Signal delivery is after all similar.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
