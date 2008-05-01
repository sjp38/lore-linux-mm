Date: Wed, 30 Apr 2008 20:08:44 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080501030844.GB4911@suse.de>
References: <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de> <20080429181415.GF24967@us.ibm.com> <20080429182613.GA17373@suse.de> <20080430191941.GC8597@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430191941.GC8597@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 12:19:41PM -0700, Nishanth Aravamudan wrote:
> On 29.04.2008 [11:26:13 -0700], Greg KH wrote:
> > On Tue, Apr 29, 2008 at 11:14:15AM -0700, Nishanth Aravamudan wrote:
> > > On 29.04.2008 [10:22:43 -0700], Greg KH wrote:
> > > > On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> > > > > +struct hstate_attribute {
> > > > > +	struct attribute attr;
> > > > > +	ssize_t (*show)(struct hstate *h, char *buf);
> > > > > +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> > > > > +};
> > > > 
> > > > Do you need your own attribute type with show and store?  Can't you just
> > > > use the "default" kobject attributes?
> > > 
> > > Hrm, I don't know? Probably. Like I said, I was using the
> > > /sys/kernel/slab code as my reference. Can you explain this more? Or
> > > just point me to the source/documentation I should read for info.
> > 
> > Documentation/kobject.txt, with sample examples in samples/kobject/ for
> > you to copy and use.
> > 
> > > Are you referring to kobj_attr_show/kobj_attr_store? Should I just be
> > > using kobj_sysfs_ops, then, most likely?
> > 
> > See the above examples for more details.
> > 
> > > > Also, you have no release function for your kobject to be cleaned up,
> > > > that's a major bug.
> > > 
> > > Well, these kobjects never go away? They will be statically initialized
> > > at boot-time and then stick around until the kernel goes away. Looking
> > > at /sys/kernel/slab's code, again, the release() function there does a
> > > kfree() on the containing kmem_cache, but for hugetlb, the hstates are
> > > static... If we do move to dynamic allocations ever (or allow adding
> > > hugepage sizes at run-time somehow), then perhaps we'll need a release
> > > method then?
> > 
> > Yes you will.  Please always create one, what happens when you want to
> > clean them up at shut-down time...
> 
> Does this look better? I really appreciate the review, Greg.

See my previous email, you should not embed a kobject into this
structure.  Just use a pointer to one, it will shrink this patch a lot.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
