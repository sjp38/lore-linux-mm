Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 88A466B0027
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 03:09:40 -0400 (EDT)
Message-ID: <514960AD.5010606@parallels.com>
Date: Wed, 20 Mar 2013 11:09:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] memcg: disable memcg page stat accounting
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com> <1363083103-3907-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1363083103-3907-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

On 03/12/2013 02:11 PM, Sha Zhengju wrote:
> Use jump label to patch the memcg page stat accounting code
> in or out when not used. when the first non-root memcg comes to
> life the code is patching in otherwise it is out.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  include/linux/memcontrol.h |   23 +++++++++++++++++++++++
>  mm/memcontrol.c            |   34 +++++++++++++++++++++++++++++++++-
>  2 files changed, 56 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d6183f0..99dca91 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -42,6 +42,14 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +
> +extern struct static_key memcg_in_use_key;
> +
> +static inline bool mem_cgroup_in_use(void)
> +{
> +	return static_key_false(&memcg_in_use_key);
> +}
> +

I believe the big advantage of the approach I've taken, including this
test in mem_cgroup_disabled(), is that we patch out a lot of things for
free.

We just need to be careful because some code expected that decision to
be permanent and now that status can change.

But I would still advocate for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
