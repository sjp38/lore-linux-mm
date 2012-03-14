Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C0D456B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:49:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 10:42:39 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EAmo9h1491142
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 21:48:50 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EAmo8M029910
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 21:48:50 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 4/8] memcg: track resource index in cftype private
In-Reply-To: <4F5F4CD0.3080207@parallels.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F5F4CD0.3080207@parallels.com>
Date: Wed, 14 Mar 2012 16:18:44 +0530
Message-ID: <87obrz8nlf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 17:34:08 +0400, Glauber Costa <glommer@parallels.com> wrote:
> On 03/13/2012 11:07 AM, Aneesh Kumar K.V wrote:
> >   		if (type == _MEM)
> >   			ret = mem_cgroup_resize_limit(memcg, val);
> > -		else
> > +		else if (type == _MEMHUGETLB) {
> > +			int idx = MEMFILE_IDX(cft->private);
> > +			ret = res_counter_set_limit(&memcg->hugepage[idx], val);
> > +		} else
> >   			ret = mem_cgroup_resize_memsw_limit(memcg, val);
> >   		break;
> >   	case RES_SOFT_LIMIT:
> 
> What if a user try to set limit < usage ? Isn't there any reclaim that 
> we could possibly do, like it is done by normal memcg ?

No, HugeTLB doesn't support reclaim. If we set the limit to a value
below current usage, future allocations will fail, but we don't reclaim.


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
