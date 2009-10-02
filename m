Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B847060021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:41:09 -0400 (EDT)
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id n92MfJId004407
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 23:41:19 +0100
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by zps35.corp.google.com with ESMTP id n92MeRg5007134
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 15:41:16 -0700
Received: by pzk16 with SMTP id 16so2178307pzk.6
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 15:41:16 -0700 (PDT)
Date: Fri, 2 Oct 2009 15:41:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/10] hugetlb:  derive huge pages nodes allowed from task
 mempolicy
In-Reply-To: <20091002101105.GM21906@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0910021540090.16083@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain> <20091002101105.GM21906@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, Mel Gorman wrote:

> > Index: linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.31-mmotm-090925-1435.orig/mm/hugetlb.c	2009-09-30 12:48:45.000000000 -0400
> > +++ linux-2.6.31-mmotm-090925-1435/mm/hugetlb.c	2009-10-01 12:13:25.000000000 -0400
> > @@ -1334,29 +1334,71 @@ static struct hstate *kobj_to_hstate(str
> >  	return NULL;
> >  }
> >  
> > -static ssize_t nr_hugepages_show(struct kobject *kobj,
> > +static ssize_t nr_hugepages_show_common(struct kobject *kobj,
> >  					struct kobj_attribute *attr, char *buf)
> >  {
> >  	struct hstate *h = kobj_to_hstate(kobj);
> >  	return sprintf(buf, "%lu\n", h->nr_huge_pages);
> >  }
> > -static ssize_t nr_hugepages_store(struct kobject *kobj,
> > -		struct kobj_attribute *attr, const char *buf, size_t count)
> > +static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
> > +			struct kobject *kobj, struct kobj_attribute *attr,
> > +			const char *buf, size_t len)
> >  {
> >  	int err;
> > -	unsigned long input;
> > +	unsigned long count;
> >  	struct hstate *h = kobj_to_hstate(kobj);
> > +	NODEMASK_ALLOC(nodemask, nodes_allowed);
> >  
> > -	err = strict_strtoul(buf, 10, &input);
> > +	err = strict_strtoul(buf, 10, &count);
> >  	if (err)
> >  		return 0;
> >  
> > -	h->max_huge_pages = set_max_huge_pages(h, input, &node_online_map);
> > +	if (!(obey_mempolicy && init_nodemask_of_mempolicy(nodes_allowed))) {
> > +		NODEMASK_FREE(nodes_allowed);
> > +		nodes_allowed = &node_states[N_HIGH_MEMORY];
> > +	}
> > +	h->max_huge_pages = set_max_huge_pages(h, count, &node_online_map);
> >  
> 
> Should that node_online_map not have changed to nodes_allowed?
> 

Looks like that's done in patch 6/10 of the series, but I agree it's more 
applicable here for review purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
