Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7EB66B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 20:16:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 65so27424707pgi.7
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 17:16:51 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 69si2701058pgc.364.2017.02.22.17.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 17:16:51 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 1so2547681pgz.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 17:16:51 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 23 Feb 2017 12:16:44 +1100
Subject: Re: [PATCH 2/2] mm/cgroup: delay soft limit data allocation
Message-ID: <20170223011644.GB8841@balbir.ozlabs.ibm.com>
References: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 22, 2017 at 04:58:11PM +0100, Laurent Dufour wrote:
> Until a soft limit is set to a cgroup, the soft limit data are useless
> so delay this allocation when a limit is set.
> 
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
<snip>
> @@ -3000,6 +3035,8 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>  		}
>  		break;
>  	case RES_SOFT_LIMIT:
> +		if (!soft_limit_initialized)
> +			soft_limit_initialize();

What happens if this fails? Do we disable this interface?
It's a good idea, but I wonder if we can deal with certain
memory cgroups not supporting soft limits due to memory
shortage at the time of using them.

>  		memcg->soft_limit = nr_pages;
>  		ret = 0;
>  		break;

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
