Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3TIC6rg003920
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 14:12:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3TIEh6H139504
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:14:46 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3TIERWM015862
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 12:14:28 -0600
Date: Tue, 29 Apr 2008 11:14:15 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080429181415.GF24967@us.ibm.com>
References: <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de> <20080423183252.GA10548@us.ibm.com> <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429172243.GA16176@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.04.2008 [10:22:43 -0700], Greg KH wrote:
> On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> > +struct hstate_attribute {
> > +	struct attribute attr;
> > +	ssize_t (*show)(struct hstate *h, char *buf);
> > +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> > +};
> 
> Do you need your own attribute type with show and store?  Can't you just
> use the "default" kobject attributes?

Hrm, I don't know? Probably. Like I said, I was using the
/sys/kernel/slab code as my reference. Can you explain this more? Or
just point me to the source/documentation I should read for info. Are
you referring to kobj_attr_show/kobj_attr_store? Should I just be using
kobj_sysfs_ops, then, most likely?

> Also, you have no release function for your kobject to be cleaned up,
> that's a major bug.

Well, these kobjects never go away? They will be statically initialized
at boot-time and then stick around until the kernel goes away. Looking
at /sys/kernel/slab's code, again, the release() function there does a
kfree() on the containing kmem_cache, but for hugetlb, the hstates are
static... If we do move to dynamic allocations ever (or allow adding
hugepage sizes at run-time somehow), then perhaps we'll need a release
method then?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
