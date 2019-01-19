Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12BB38E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 04:01:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so9604813plb.1
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 01:01:35 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a1si7307558pld.249.2019.01.19.01.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 01:01:33 -0800 (PST)
Date: Sat, 19 Jan 2019 10:01:29 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
Message-ID: <20190119090129.GC10836@kroah.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jan 18, 2019 at 01:08:02PM -0800, Dan Williams wrote:
> On Thu, Jan 17, 2019 at 3:41 AM Rafael J. Wysocki <rafael@kernel.org> wrote:
> >
> > On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> > >
> > > Add entries for memory initiator and target node class attributes.
> > >
> > > Signed-off-by: Keith Busch <keith.busch@intel.com>
> >
> > I would recommend combining this with the previous patch, as the way
> > it is now I need to look at two patches at the time. :-)
> >
> > > ---
> > >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> > >  1 file changed, 24 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > > --- a/Documentation/ABI/stable/sysfs-devices-node
> > > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > > @@ -90,4 +90,27 @@ Date:                December 2009
> > >  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
> > >  Description:
> > >                 The node's huge page size control/query attributes.
> > > -               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > \ No newline at end of file
> > > +               See Documentation/admin-guide/mm/hugetlbpage.rst
> > > +
> > > +What:          /sys/devices/system/node/nodeX/classY/
> > > +Date:          December 2018
> > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > +Description:
> > > +               The node's relationship to other nodes for access class "Y".
> > > +
> > > +What:          /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > > +Date:          December 2018
> > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > +Description:
> > > +               The node list of memory initiators that have class "Y" access
> > > +               to this node's memory. CPUs and other memory initiators in
> > > +               nodes not in the list accessing this node's memory may have
> > > +               different performance.
> >
> > This does not follow the general "one value per file" rule of sysfs (I
> > know that there are other sysfs files with more than one value in
> > them, but it is better to follow this rule as long as that makes
> > sense).
> >
> > > +
> > > +What:          /sys/devices/system/node/nodeX/classY/target_nodelist
> > > +Date:          December 2018
> > > +Contact:       Keith Busch <keith.busch@intel.com>
> > > +Description:
> > > +               The node list of memory targets that this initiator node has
> > > +               class "Y" access. Memory accesses from this node to nodes not
> > > +               in this list may have differet performance.
> > > --
> >
> > Same here.
> >
> > And if you follow the recommendation given in the previous message
> > (add "initiators" and "targets" subdirs under "classX"), you won't
> > even need the two files above.
> 
> This recommendation is in conflict with Greg's feedback about kobject
> usage. If these are just "vanity" subdirs I think it's better to have
> a multi-value sysfs file. This "list" style is already commonplace for
> the /sys/devices/system hierarchy.

If you do a subdirectory "correctly" (i.e. a name for an attribute
group), that's fine.  Just do not ever create a kobject just for a
subdir, that will mess up userspace.

And I hate the "multi-value" sysfs files, where at all possible, please
do not copy past bad mistakes there.  If you can make them individual
files, please do that, it makes it easier to maintain and code the
kernel for.

thanks,

greg k-h
