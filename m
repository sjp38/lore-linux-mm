Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5F96B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 06:51:28 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so2707140wiw.1
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 03:51:28 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id cd10si12891832wib.15.2015.01.08.03.51.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 03:51:27 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id l2so2143393wgh.7
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 03:51:27 -0800 (PST)
Date: Thu, 8 Jan 2015 12:51:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 5/5] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20150108115124.GA6027@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-6-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417797707-31699-6-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Fri 05-12-14 17:41:47, Michal Hocko wrote:
[...]
> +bool oom_killer_disable(void)
> +{
> +	/*
> +	 * Make sure to not race with an ongoing OOM killer
> +	 * and that the current is not the victim.
> +	 */
> +	down_write(&oom_sem);
> +	if (test_thread_flag(TIF_MEMDIE)) {
> +		up_write(&oom_sem);
> +		return false;
> +	}
> +
> +	oom_killer_disabled = true;
> +	up_write(&oom_sem);
> +
> +	wait_event(oom_victims_wait, atomic_read(&oom_victims));

Ups brainfart... Should be !atomic_read(&oom_victims). Condition says
for what we are waiting not when we are waiting.

> +
> +	return true;
> +}
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
