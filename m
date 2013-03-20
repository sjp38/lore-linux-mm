Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 753FD6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 03:07:54 -0400 (EDT)
Message-ID: <51496041.4090900@parallels.com>
Date: Wed, 20 Mar 2013 11:07:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] memcg: Don't account root memcg CACHE/RSS stats
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com> <1363082977-3753-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363082977-3753-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

On 03/12/2013 02:09 PM, Sha Zhengju wrote:
> If memcg is enabled and no non-root memcg exists, all allocated pages
> belong to root_mem_cgroup and go through root memcg statistics routines
> which brings some overheads.
> 
> So for the sake of performance, we can give up accounting stats of root
> memcg for MEM_CGROUP_STAT_CACHE/RSS and instead we pay special attention
> to memcg_stat_show() while showing root memcg numbers:
> as we don't account root memcg stats anymore, the root_mem_cgroup->stat
> numbers are actually 0. So we fake these numbers by using stats of global
> state and all other memcg. That is for root memcg:
> 
> 	nr(MEM_CGROUP_STAT_CACHE) = global_page_state(NR_FILE_PAGES) -
>                               sum_of_all_memcg(MEM_CGROUP_STAT_CACHE);
> 
> Rss pages accounting are in the similar way.
> 

Well,

The problem is that statistics is not the only cause for overhead. We
will still incur in in the whole charging operation, and the same for
uncharge. There is memory overhead from page_cgroup, etc.

So my view is that this patch is far from complete.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
