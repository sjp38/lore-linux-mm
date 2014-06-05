Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 846216B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 10:19:40 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so1223352wes.27
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 07:19:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ey4si15302610wid.15.2014.06.05.07.19.36
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 07:19:37 -0700 (PDT)
Date: Thu, 5 Jun 2014 16:18:41 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
	has listeners
Message-ID: <20140605141841.GA23796@redhat.com>
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401976841-3899-2-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On 06/05, Richard Weinberger wrote:
>
> +int mem_cgroup_has_listeners(struct mem_cgroup *memcg)
> +{
> +	int ret = 0;
> +
> +	if (!memcg)
> +		goto out;
> +
> +	spin_lock(&memcg_oom_lock);
> +	ret = !list_empty(&memcg->oom_notify);
> +	spin_unlock(&memcg_oom_lock);
> +
> +out:
> +	return ret;
> +}

Do we really need memcg_oom_lock to check list_empty() ? With or without
this lock we can race with list_add/del anyway, and I guess we do not care.

And perhaps the caller should check memcg != NULL. but this is subjective,
I won't argue.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
