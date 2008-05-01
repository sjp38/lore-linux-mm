Date: Wed, 30 Apr 2008 20:07:38 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080501030738.GA4911@suse.de>
References: <20080424071352.GB14543@wotan.suse.de> <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de> <20080429181415.GF24967@us.ibm.com> <20080429182613.GA17373@suse.de> <20080429234839.GA10967@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429234839.GA10967@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 04:48:39PM -0700, Nishanth Aravamudan wrote:
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
> 
> Great thanks!
> 
> > > Are you referring to kobj_attr_show/kobj_attr_store? Should I just be
> > > using kobj_sysfs_ops, then, most likely?
> > 
> > See the above examples for more details.
> 
> Will do -- I think we'll need our own store, at least, though, because
> of locking issues? And I'm guessing if we provide our own store, we're
> going to need to provide our own show?

Yes, but see below...

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
> Again, I'm not sure what you want me to clean-up? The examples in
> samples/ are freeing dynamically allocated objects containing the
> kobject in question -- but /sys/kernel/hugepages only dynamically
> allocates the kobject itself... Although, I guess I should free the name
> string since I used kasprintf()...

Ugh.

Embed a kobject into a structure if you want it to control the lifetime
rules of that structure.  And that includes tearing it down.

If you _only_ want to use a kobject to create some sysfs trees and
files, then just use the dynamic kobject functions, as documented.  Then
you only have a pointer to a kobject, it does not control the lifetime
of your structure, you don't have to write your own show/store wrappers,
and life is oh so much more easier.

So you might want to rethink your current patch :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
