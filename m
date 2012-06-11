Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DE1B36B00D8
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:02:37 -0400 (EDT)
Date: Mon, 11 Jun 2012 11:02:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 13/16] hugetlb/cgroup: add hugetlb cgroup control
 files
Message-ID: <20120611090234.GE12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-14-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat 09-06-12 14:29:58, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Add the control files for hugetlb controller
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
[...]
> +int __init hugetlb_cgroup_file_init(int idx)
> +{
> +	char buf[32];
> +	struct cftype *cft;
> +	struct hstate *h = &hstates[idx];
> +
> +	/* format the size */
> +	mem_fmt(buf, 32, huge_page_size(h));
> +
> +	/* Add the limit file */
> +	cft = &h->cgroup_files[0];
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.limit_in_bytes", buf);
> +	cft->private = MEMFILE_PRIVATE(idx, RES_LIMIT);
> +	cft->read = hugetlb_cgroup_read;
> +	cft->write_string = hugetlb_cgroup_write;
> +
> +	/* Add the usage file */
> +	cft = &h->cgroup_files[1];
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
> +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
> +	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
> +	cft->trigger  = hugetlb_cgroup_reset;
> +	cft->read = hugetlb_cgroup_read;
> +
> +	/* NULL terminate the last cft */
> +	cft = &h->cgroup_files[4];
> +	memset(cft, 0, sizeof(*cft));
> +
> +	WARN_ON(cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files));
> +
> +	return 0;
> +}
> +

I am not so familiar with the recent changes in the generic cgroup
infrastructure but isn't this somehow automated?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
