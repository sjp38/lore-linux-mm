Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 03EC36B00A1
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 08:29:29 -0400 (EDT)
Date: Sat, 30 Jun 2012 14:29:23 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
Message-ID: <20120630122919.GB3036@stainedmachine.redhat.com>
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com>
 <20120629141759.3312b49e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120629141759.3312b49e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 29 Jun 2012, Andrew Morton wrote:

> On Fri, 29 Jun 2012 13:49:52 +0200
> Petr Holasek <pholasek@redhat.com> wrote:
> 
> > Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes
> > which control merging pages across different numa nodes.
> > When it is set to zero only pages from the same node are merged,
> > otherwise pages from all nodes can be merged together (default behavior).
> > 
> > Typical use-case could be a lot of KVM guests on NUMA machine
> > and cpus from more distant nodes would have significant increase
> > of access latency to the merged ksm page. Sysfs knob was choosen
> > for higher scalability.
> > 
> > Every numa node has its own stable & unstable trees because
> > of faster searching and inserting. Changing of merge_nodes
> > value is possible only when there are not any ksm shared pages in system.
> 
> It would be neat to have a knob which enables KSM for all anon
> mappings.  ie: pretend that MADV_MERGEABLE is always set.  For testing
> coverage purposes.

Interesting idea, I'll try to add it in next release if /sys/kernel/mm/ksm
directory is the right place for such debug knob.

> > --- a/Documentation/vm/ksm.txt
> > +++ b/Documentation/vm/ksm.txt
> > @@ -58,6 +58,12 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
> >                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
> >                     Default: 20 (chosen for demonstration purposes)
> >  
> > +merge_nodes      - specifies if pages from different numa nodes can be merged.
> > +                   When set to 0, ksm merges only pages which physically
> > +                   resides in the memory area of same NUMA node. It brings
> > +                   lower latency to access to shared page.
> > +                   Default: 1
> 
> s/resides/reside/.
> 
> This doc should mention that /sys/kernel/mm/ksm/run should be zeroed to
> alter merge_nodes.  Otherwise confusion will reign.
> 

Oh, forgot to mention it. I'll fix it.

> >
> > ...
> >
> > +static ssize_t merge_nodes_store(struct kobject *kobj,
> > +				   struct kobj_attribute *attr,
> > +				   const char *buf, size_t count)
> > +{
> > +	int err;
> > +	unsigned long knob;
> > +
> > +	err = kstrtoul(buf, 10, &knob);
> > +	if (err)
> > +		return err;
> > +	if (knob > 1)
> > +		return -EINVAL;
> > +
> > +	if (ksm_run & KSM_RUN_MERGE)
> > +		return -EBUSY;
> > +
> > +	mutex_lock(&ksm_thread_mutex);
> > +	if (ksm_merge_nodes != knob) {
> > +		if (ksm_pages_shared > 0)
> > +			return -EBUSY;
> > +		else
> > +			ksm_merge_nodes = knob;
> > +	}
> > +	mutex_unlock(&ksm_thread_mutex);
> > +
> > +	return count;
> > +}
> 
> Seems a bit racy.  Shouldn't the test of ksm_run be inside the locked
> region?
> 

Agreed.

Thanks for your review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
