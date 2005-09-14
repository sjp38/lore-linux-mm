Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j8ELmeLZ325508
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 17:48:41 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8ELme0D535532
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 15:48:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8ELmdU9030067
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 15:48:39 -0600
Date: Thu, 15 Sep 2005 03:13:09 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough
Message-ID: <20050914214309.GB6237@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20050911105709.GA16369@thunk.org> <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050914213404.GC9808@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050914213404.GC9808@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Bharata B Rao <bharata@in.ibm.com>, Theodore Ts'o <tytso@mit.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 14, 2005 at 06:34:04PM -0300, Marcelo Tosatti wrote:
> On Tue, Sep 13, 2005 at 02:17:52PM +0530, Bharata B Rao wrote:
> > On Sun, Sep 11, 2005 at 11:16:36PM -0400, Theodore Ts'o wrote:
> > 
> > Ted,
> > 
> > I am sending two patches here.
> > 
> > First is dentry_stats patch which collects some dcache statistics
> > and puts it into /proc/meminfo. This patch provides information 
> > about how dentries are distributed in dcache slab pages, how many
> > free and in use dentries are present in dentry_unused lru list and
> > how prune_dcache() performs with respect to freeing the requested
> > number of dentries.
> 
> Hi Bharata,
> 
> +void get_dstat_info(void)
> +{
> +       struct dentry *dentry;
> +
> +       lru_dentry_stat.nr_total = lru_dentry_stat.nr_inuse = 0;
> +       lru_dentry_stat.nr_ref = lru_dentry_stat.nr_free = 0;
> +
> +       spin_lock(&dcache_lock);
> +       list_for_each_entry(dentry, &dentry_unused, d_lru) {
> +               if (atomic_read(&dentry->d_count))
> +                       lru_dentry_stat.nr_inuse++;
> 
> Dentries on dentry_unused list with d_count positive? Is that possible 
> at all? As far as my limited understanding goes, only dentries with zero 
> count can be part of the dentry_unused list.

That changed during the lock-free dcache implementation during
2.5. If we strictly update the lru list, we will have to acquire
the dcache_lock in __d_lookup() on a successful lookup. So we
did lazy-lru, leave the dentries with non-zero refcounts
and clean them up later when we acquire dcache_lock for other
purposes.

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
