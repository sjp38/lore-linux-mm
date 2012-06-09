Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 22C796B006E
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 07:19:52 -0400 (EDT)
Received: by qafl39 with SMTP id l39so1510639qaf.9
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 04:19:51 -0700 (PDT)
Date: Sat, 9 Jun 2012 07:19:47 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH -V8 13/16] hugetlb/cgroup: add hugetlb cgroup control
 files
Message-ID: <20120609111946.GC16034@localhost.localdomain>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

>  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> @@ -1916,6 +1917,13 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
>  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
>  					huge_page_size(h)/1024);
> +	/*
> +	 * Add cgroup control files only if the huge page consists
> +	 * of more than two normal pages. This is because we use

Not three? I thought the earlier patches said three?
> +	 * page[2].lru.next for storing cgoup details.

cgoup?
> +	 */
> +	if (order >= 2)
> +		hugetlb_cgroup_file_init(hugetlb_max_hstate - 1);
>  
>  	parsed_hstate = h;
>  }
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 9458fe3..2a4881d 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -18,6 +18,11 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  
> +/* lifted from mem control */

And you can also life the comment from mem control explaining
what these defines are good for.

> +#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
> +#define MEMFILE_IDX(val)	(((val) >> 16) & 0xffff)
> +#define MEMFILE_ATTR(val)	((val) & 0xffff)
> +
>  struct cgroup_subsys hugetlb_subsys __read_mostly;
>  struct hugetlb_cgroup *root_h_cgroup __read_mostly;
>  
> @@ -269,6 +274,131 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
>  	return;
>  }
>  
> +static ssize_t hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft,
> +				   struct file *file, char __user *buf,
> +				   size_t nbytes, loff_t *ppos)
> +{
> +	u64 val;
> +	char str[64];

Why no #define? Wait a minute - didn't I provide a similar comment last
time? So why the reason to stick without the #define's?

> +	int idx, name, len;
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +
> +	idx = MEMFILE_IDX(cft->private);
> +	name = MEMFILE_ATTR(cft->private);
> +
> +	val = res_counter_read_u64(&h_cg->hugepage[idx], name);
> +	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
> +	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
> +}
> +
> +static int hugetlb_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
> +				const char *buffer)
> +{
> +	int idx, name, ret;
> +	unsigned long long val;
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +
> +	idx = MEMFILE_IDX(cft->private);
> +	name = MEMFILE_ATTR(cft->private);
> +
> +	switch (name) {
> +	case RES_LIMIT:
> +		if (hugetlb_cgroup_is_root(h_cg)) {
> +			/* Can't set limit on root */
> +			ret = -EINVAL;
> +			break;
> +		}
> +		/* This function does all necessary parse...reuse it */
> +		ret = res_counter_memparse_write_strategy(buffer, &val);
> +		if (ret)
> +			break;
> +		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
> +		break;
> +	default:
> +		ret = -EINVAL;
> +		break;
> +	}
> +	return ret;
> +}
> +
> +static int hugetlb_cgroup_reset(struct cgroup *cgroup, unsigned int event)
> +{
> +	int idx, name, ret = 0;
> +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> +
> +	idx = MEMFILE_IDX(event);
> +	name = MEMFILE_ATTR(event);
> +
> +	switch (name) {
> +	case RES_MAX_USAGE:
> +		res_counter_reset_max(&h_cg->hugepage[idx]);
> +		break;
> +	case RES_FAILCNT:
> +		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
> +		break;
> +	default:
> +		ret = -EINVAL;
> +		break;
> +	}
> +	return ret;
> +}
> +
> +static char *mem_fmt(char *buf, int size, unsigned long hsize)
> +{
> +	if (hsize >= (1UL << 30))
> +		snprintf(buf, size, "%luGB", hsize >> 30);
> +	else if (hsize >= (1UL << 20))
> +		snprintf(buf, size, "%luMB", hsize >> 20);
> +	else
> +		snprintf(buf, size, "%luKB", hsize >> 10);
> +	return buf;
> +}
> +
> +int __init hugetlb_cgroup_file_init(int idx)
> +{
> +	char buf[32];

Ditto.

> +	struct cftype *cft;
> +	struct hstate *h = &hstates[idx];
> +
> +	/* format the size */
> +	mem_fmt(buf, 32, huge_page_size(h));

Ditto.

> +
> +	/* Add the limit file */
> +	cft = &h->cgroup_files[0];

Can't this be just:
	cfg = &h->cgroup_files;

> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.limit_in_bytes", buf);
> +	cft->private = MEMFILE_PRIVATE(idx, RES_LIMIT);
> +	cft->read = hugetlb_cgroup_read;
> +	cft->write_string = hugetlb_cgroup_write;
> +
> +	/* Add the usage file */
> +	cft = &h->cgroup_files[1];
and this be:
	cft++;

> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.usage_in_bytes", buf);
> +	cft->private = MEMFILE_PRIVATE(idx, RES_USAGE);
> +	cft->read = hugetlb_cgroup_read;
> +
> +	/* Add the MAX usage file */
> +	cft = &h->cgroup_files[2];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.max_usage_in_bytes", buf);
> +	cft->private = MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
> +	cft->trigger = hugetlb_cgroup_reset;
> +	cft->read = hugetlb_cgroup_read;
> +
> +	/* Add the failcntfile */
> +	cft = &h->cgroup_files[3];

and so for this one.
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
> +	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
> +	cft->trigger  = hugetlb_cgroup_reset;
> +	cft->read = hugetlb_cgroup_read;
> +
> +	/* NULL terminate the last cft */
> +	cft = &h->cgroup_files[4];

and for that one?

> +	memset(cft, 0, sizeof(*cft));
> +
> +	WARN_ON(cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files));
> +
> +	return 0;
> +}
> +
>  struct cgroup_subsys hugetlb_subsys = {
>  	.name = "hugetlb",
>  	.create     = hugetlb_cgroup_create,
> -- 
> 1.7.10
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
