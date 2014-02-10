Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 20D2E6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 10:28:35 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so4423918wes.27
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 07:28:34 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id ep15si7800513wjd.3.2014.02.10.07.28.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 07:28:31 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id l18so2646168wgh.5
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 07:28:31 -0800 (PST)
Date: Mon, 10 Feb 2014 16:28:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/8] memcg: sanitize __mem_cgroup_try_charge() call
 protocol
Message-ID: <20140210152829.GL7117@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:25, Johannes Weiner wrote:
> Some callsites pass a memcg directly, some callsites pass a mm that
> first has to be translated to an mm.  This makes for a terrible
> function interface.
> 
> Just push the mm-to-memcg translation into the respective callsites
> and always pass a memcg to mem_cgroup_try_charge().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

OK if you really think that repeating the same pattern when charging
against mm is better then I can live with that. It is a trivial amount
of code.

[...]
> @@ -3923,21 +3895,17 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  	 */
>  	if (PageCgroupUsed(pc))
>  		return 0;

I think that we should set *memcgp in this path rather than rely on
caller to do the right thing. Both current callers do so but it is not
nice. And the detail why we need NULL is quite subtle so a comment
mentioning that __mem_cgroup_commit_charge_swapin has to ignore such a
page would be more than welcome.
[...]

Other than that looks good to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
