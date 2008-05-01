Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m41IPsiK027635
	for <linux-mm@kvack.org>; Thu, 1 May 2008 14:25:54 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m41IPrLb190492
	for <linux-mm@kvack.org>; Thu, 1 May 2008 12:25:54 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m41IPrlr021566
	for <linux-mm@kvack.org>; Thu, 1 May 2008 12:25:53 -0600
Date: Thu, 1 May 2008 11:25:51 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] hugetlb: add information and interface in sysfs
	[Was Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs
	ABI]
Message-ID: <20080501182551.GA11519@us.ibm.com>
References: <20080427034942.GB12129@us.ibm.com> <20080427051029.GA22858@suse.de> <20080428172239.GA24169@us.ibm.com> <20080428172951.GA764@suse.de> <20080429171115.GD24967@us.ibm.com> <20080429172243.GA16176@suse.de> <20080429181415.GF24967@us.ibm.com> <20080429182613.GA17373@suse.de> <20080429234839.GA10967@us.ibm.com> <20080501030738.GA4911@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080501030738.GA4911@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2008 [20:07:38 -0700], Greg KH wrote:
> On Tue, Apr 29, 2008 at 04:48:39PM -0700, Nishanth Aravamudan wrote:
> > On 29.04.2008 [11:26:13 -0700], Greg KH wrote:
> > > On Tue, Apr 29, 2008 at 11:14:15AM -0700, Nishanth Aravamudan wrote:
> > > > On 29.04.2008 [10:22:43 -0700], Greg KH wrote:
> > > > > On Tue, Apr 29, 2008 at 10:11:15AM -0700, Nishanth Aravamudan wrote:
> > > > > > +struct hstate_attribute {
> > > > > > +	struct attribute attr;
> > > > > > +	ssize_t (*show)(struct hstate *h, char *buf);
> > > > > > +	ssize_t (*store)(struct hstate *h, const char *buf, size_t count);
> > > > > > +};
> > > > > 
> > > > > Do you need your own attribute type with show and store?  Can't you just
> > > > > use the "default" kobject attributes?
> > > > 
> > > > Hrm, I don't know? Probably. Like I said, I was using the
> > > > /sys/kernel/slab code as my reference. Can you explain this more? Or
> > > > just point me to the source/documentation I should read for info.
> > > 
> > > Documentation/kobject.txt, with sample examples in samples/kobject/ for
> > > you to copy and use.
> > 
> > Great thanks!
> > 
> > > > Are you referring to kobj_attr_show/kobj_attr_store? Should I just be
> > > > using kobj_sysfs_ops, then, most likely?
> > > 
> > > See the above examples for more details.
> > 
> > Will do -- I think we'll need our own store, at least, though, because
> > of locking issues? And I'm guessing if we provide our own store, we're
> > going to need to provide our own show?
> 
> Yes, but see below...
> 
> > > > > Also, you have no release function for your kobject to be cleaned up,
> > > > > that's a major bug.
> > > > 
> > > > Well, these kobjects never go away? They will be statically initialized
> > > > at boot-time and then stick around until the kernel goes away. Looking
> > > > at /sys/kernel/slab's code, again, the release() function there does a
> > > > kfree() on the containing kmem_cache, but for hugetlb, the hstates are
> > > > static... If we do move to dynamic allocations ever (or allow adding
> > > > hugepage sizes at run-time somehow), then perhaps we'll need a release
> > > > method then?
> > > 
> > > Yes you will.  Please always create one, what happens when you want to
> > > clean them up at shut-down time...
> > 
> > Again, I'm not sure what you want me to clean-up? The examples in
> > samples/ are freeing dynamically allocated objects containing the
> > kobject in question -- but /sys/kernel/hugepages only dynamically
> > allocates the kobject itself... Although, I guess I should free the name
> > string since I used kasprintf()...
> 
> Ugh.
> 
> Embed a kobject into a structure if you want it to control the
> lifetime rules of that structure.  And that includes tearing it down.
> 
> If you _only_ want to use a kobject to create some sysfs trees and
> files, then just use the dynamic kobject functions, as documented.
> Then you only have a pointer to a kobject, it does not control the
> lifetime of your structure, you don't have to write your own
> show/store wrappers, and life is oh so much more easier.
> 
> So you might want to rethink your current patch :)

Ok, I get this now, and have started moving over to it. However, I see a
few problems, or have a few questions:

1) I do need my own store() wrapper due to locking, right? We can't
change the writable values here without grabbing the hugetlb_lock. And
the examples in samples/kobject/kobject-sample.c, at least, do have
their own show/store methods (or do you mean something else by wrapper)?
Oh, maybe you are referring to hstate_attr_store()/hstate_attr_show()?
Those no longer exist in this patch...

2) I will need a kobject pointer for each hstate, right? So what I have
now is:

static struct kobject *hstate_kobj[HUGE_MAX_HSTATE];

and then I use kobject_create_and_add() for each of them. How do I then
refer back to which hstate I'm dealing with (because I want to
manipulate that hstate's values in the show/store methods) -- would I
need to iterate through hstate_kobj until I find the kobject that was
passed in and then use that index into hstates() to find the
corresponding hstate? I guess unlike in the embedding case, I don't see
the link between the structure I'm trying to represent and the
kobject...

3) Each hstate is going to have the same set of attributes. Let's say I
use sysfs_create_group() on each of the hstate_kobj's array members.
Will I then actually need duplicates of the set of attributes so that
there is a static set of attributes per-hstate? This directly relates to
2), actually -- if I can get to the hstate from the kobject then I can
do that with one set of attributes.

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
