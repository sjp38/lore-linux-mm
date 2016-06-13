Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88BE66B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:23:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so3326475lfl.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:23:51 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s20si14468007wmb.51.2016.06.13.04.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 04:23:50 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n184so14073615wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:23:50 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:23:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v4] Handle oom bypass more gracefully
Message-ID: <20160613112348.GC6518@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 09-06-16 13:52:07, Michal Hocko wrote:
> I would like to explore ways how to remove kthreads (use_mm) special
> case. It shouldn't be that hard, we just have to teach the page fault
> handler to recognize oom victim mm and enforce EFAULT for kthreads
> which have borrowed that mm.

So I was trying to come up with solution for this which would require to
hook into the pagefault an enforce EFAULT when the mm is being reaped
by the oom_repaer. Not hard but then I have checked the current users
and none of them is really needing to read from the userspace (aka
copy_from_user/get_user). So we actually do not need to do anything
special. Copying _to_ the userspace should be OK because there is no
risk of the corruption. So I believe we should be able to simply do the
following. Or is anybody seeing a reason this would be unsafe?
---
