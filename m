Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id CAA776B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:00:34 -0400 (EDT)
Received: by lagj9 with SMTP id j9so83377302lag.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 02:00:34 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a19si9027192lbo.175.2015.09.14.02.00.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 02:00:32 -0700 (PDT)
Date: Mon, 14 Sep 2015 12:00:10 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH  1/2] mm: Replace nr_node_ids for loop with for_each_node
 in list lru
Message-ID: <20150914090010.GB30743@esperanza>
References: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1441737107-23103-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Wed, Sep 09, 2015 at 12:01:46AM +0530, Raghavendra K T wrote:
> The functions used in the patch are in slowpath, which gets called
> whenever alloc_super is called during mounts.
> 
> Though this should not make difference for the architectures with
> sequential numa node ids, for the powerpc which can potentially have
> sparse node ids (for e.g., 4 node system having numa ids, 0,1,16,17
> is common), this patch saves some unnecessary allocations for
> non existing numa nodes.
> 
> Even without that saving, perhaps patch makes code more readable.

Do I understand correctly that node 0 must always be in
node_possible_map? I ask, because we currently test
lru->node[0].memcg_lrus to determine if the list is memcg aware.

> 
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  mm/list_lru.c | 23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 909eca2..5a97f83 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -377,7 +377,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
>  {
>  	int i;
>  
> -	for (i = 0; i < nr_node_ids; i++) {
> +	for_each_node(i) {
>  		if (!memcg_aware)
>  			lru->node[i].memcg_lrus = NULL;

So, we don't explicitly initialize memcg_lrus for nodes that are not in
node_possible_map. That's OK, because we allocate lru->node using
kzalloc. However, this partial nullifying in case !memcg_aware looks
confusing IMO. Let's drop it, I mean something like this:

static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
{
	int i;

	if (!memcg_aware)
		return 0;

	for_each_node(i) {
		if (memcg_init_list_lru_node(&lru->node[i]))
			goto fail;
	}

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
