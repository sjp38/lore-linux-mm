Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 0D2246B0044
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 19:43:36 -0400 (EDT)
Date: Wed, 14 Mar 2012 16:43:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V3 2/8] memcg: Add HugeTLB extension
Message-Id: <20120314164334.5e35f3b6.akpm@linux-foundation.org>
In-Reply-To: <87zkbj8ou9.fsf@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120313143316.0ef74d0e.akpm@linux-foundation.org>
	<87zkbj8ou9.fsf@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, 14 Mar 2012 15:51:50 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> On Tue, 13 Mar 2012 14:33:16 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Tue, 13 Mar 2012 12:37:06 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > 
> > > +static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
> > > +{
> > > +	int idx;
> > > +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> > > +		if (memcg->hugepage[idx].usage > 0)
> > > +			return memcg->hugepage[idx].usage;
> > > +	}
> > > +	return 0;
> > > +}
> > 
> > Please document the function?  Had you done this, I might have been
> > able to work out why the function bales out on the first used hugepage
> > size, but I can't :(
> 
> I guess the function is named wrongly. I will rename it to
> mem_cgroup_have_hugetlb_usage() in the next iteration ? The function
> will return (bool) 1 if it has any hugetlb resource usage.
> 
> > 
> > This could have used for_each_hstate(), had that macro been better
> > designed (or updated).
> > 
> 
> Can you explain this ?. for_each_hstate allows to iterate over
> different hstates. But here we need to look at different hugepage
> rescounter in memcg. I can still use for_each_hstate() and find the
> hstate index (h - hstates) and use that to index memcg rescounter
> array. But that would make it more complex ?

If the for_each_hstate() macro took an additional arg which holds the
base address of the array, that macro could have been used here.

Or perhaps not - I didn't look too closely ;)  It isn't important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
