Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 90D3A6B0039
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 17:25:42 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id a108so5201360qge.18
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 14:25:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si34939118qar.46.2014.07.02.14.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 14:25:41 -0700 (PDT)
Date: Wed, 2 Jul 2014 17:25:29 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [patch] mm, hugetlb: generalize writes to nr_hugepages
Message-ID: <20140702172529.347f2dd2@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 30 Jun 2014 16:57:06 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Three different interfaces alter the maximum number of hugepages for an
> hstate:
> 
>  - /proc/sys/vm/nr_hugepages for global number of hugepages of the default
>    hstate,
> 
>  - /sys/kernel/mm/hugepages/hugepages-X/nr_hugepages for global number of
>    hugepages for a specific hstate, and
> 
>  - /sys/kernel/mm/hugepages/hugepages-X/nr_hugepages/mempolicy for number of
>    hugepages for a specific hstate over the set of allowed nodes.
> 
> Generalize the code so that a single function handles all of these writes 
> instead of duplicating the code in two different functions.
> 
> This decreases the number of lines of code, but also reduces the size of
> .text by about half a percent since set_max_huge_pages() can be inlined.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/hugetlb.c | 61 ++++++++++++++++++++++++++----------------------------------
>  1 file changed, 26 insertions(+), 35 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1734,21 +1734,13 @@ static ssize_t nr_hugepages_show_common(struct kobject *kobj,
>  	return sprintf(buf, "%lu\n", nr_huge_pages);
>  }
>  
> -static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> -			struct kobject *kobj, struct kobj_attribute *attr,
> -			const char *buf, size_t len)
> +static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
> +					   struct hstate *h, int nid,
> +					   unsigned long count, size_t len)
>  {
>  	int err;
> -	int nid;
> -	unsigned long count;
> -	struct hstate *h;
>  	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>  
> -	err = kstrtoul(buf, 10, &count);
> -	if (err)
> -		goto out;
> -
> -	h = kobj_to_hstate(kobj, &nid);
>  	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
>  		err = -EINVAL;
>  		goto out;
> @@ -1784,6 +1776,23 @@ out:
>  	return err;
>  }
>  
> +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> +					 struct kobject *kobj, const char *buf,
> +					 size_t len)
> +{
> +	struct hstate *h;
> +	unsigned long count;
> +	int nid;
> +	int err;
> +
> +	err = kstrtoul(buf, 10, &count);
> +	if (err)
> +		return err;
> +
> +	h = kobj_to_hstate(kobj, &nid);
> +	return __nr_hugepages_store_common(obey_mempolicy, h, nid, count, len);
> +}
> +
>  static ssize_t nr_hugepages_show(struct kobject *kobj,
>  				       struct kobj_attribute *attr, char *buf)
>  {
> @@ -1793,7 +1802,7 @@ static ssize_t nr_hugepages_show(struct kobject *kobj,
>  static ssize_t nr_hugepages_store(struct kobject *kobj,
>  	       struct kobj_attribute *attr, const char *buf, size_t len)
>  {
> -	return nr_hugepages_store_common(false, kobj, attr, buf, len);
> +	return nr_hugepages_store_common(false, kobj, buf, len);
>  }
>  HSTATE_ATTR(nr_hugepages);
>  
> @@ -1812,7 +1821,7 @@ static ssize_t nr_hugepages_mempolicy_show(struct kobject *kobj,
>  static ssize_t nr_hugepages_mempolicy_store(struct kobject *kobj,
>  	       struct kobj_attribute *attr, const char *buf, size_t len)
>  {
> -	return nr_hugepages_store_common(true, kobj, attr, buf, len);
> +	return nr_hugepages_store_common(true, kobj, buf, len);
>  }
>  HSTATE_ATTR(nr_hugepages_mempolicy);
>  #endif
> @@ -2248,36 +2257,18 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  			 void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	struct hstate *h = &default_hstate;
> -	unsigned long tmp;
> +	unsigned long tmp = h->max_huge_pages;
>  	int ret;
>  
> -	if (!hugepages_supported())
> -		return -ENOTSUPP;

Shouldn't you add this check to __nr_hugepages_store_common()? Otherwise
looks good to me.

> -
> -	tmp = h->max_huge_pages;
> -
> -	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return -EINVAL;
> -
>  	table->data = &tmp;
>  	table->maxlen = sizeof(unsigned long);
>  	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
>  	if (ret)
>  		goto out;
>  
> -	if (write) {
> -		NODEMASK_ALLOC(nodemask_t, nodes_allowed,
> -						GFP_KERNEL | __GFP_NORETRY);
> -		if (!(obey_mempolicy &&
> -			       init_nodemask_of_mempolicy(nodes_allowed))) {
> -			NODEMASK_FREE(nodes_allowed);
> -			nodes_allowed = &node_states[N_MEMORY];
> -		}
> -		h->max_huge_pages = set_max_huge_pages(h, tmp, nodes_allowed);
> -
> -		if (nodes_allowed != &node_states[N_MEMORY])
> -			NODEMASK_FREE(nodes_allowed);
> -	}
> +	if (write)
> +		ret = __nr_hugepages_store_common(obey_mempolicy, h,
> +						  NUMA_NO_NODE, tmp, *length);
>  out:
>  	return ret;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
