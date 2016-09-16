Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1DDC6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 01:36:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 20so34210002itx.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 22:36:40 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id d16si3260129oig.162.2016.09.15.22.36.35
        for <linux-mm@kvack.org>;
        Thu, 15 Sep 2016 22:36:39 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:36:32 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/3] mm, dax: add VM_DAX flag for DAX VMAs
Message-ID: <20160916053632.GT30497@dastard>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160915082615.GA9772@lst.de>
 <CAPcyv4jTw3cXpmmJRh7t16Xy2uYofDe+fJ+X_jnz+Q=o0uGneg@mail.gmail.com>
 <20160915230748.GS30497@dastard>
 <CAPcyv4jvcWEc2TkRh6-MoKb_-1VbFoiKUJEB=svQO+BVN8s-Sg@mail.gmail.com>
 <20160916012458.GW22388@dastard>
 <CAPcyv4hoTNw8OM-hoYOqzCS04ZNh+Tv_xhLAiP3AXVcGK6H_mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hoTNw8OM-hoYOqzCS04ZNh+Tv_xhLAiP3AXVcGK6H_mg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, XFS Developers <xfs@oss.sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 15, 2016 at 07:04:27PM -0700, Dan Williams wrote:
> On Thu, Sep 15, 2016 at 6:24 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Thu, Sep 15, 2016 at 05:16:42PM -0700, Dan Williams wrote:
> >> On Thu, Sep 15, 2016 at 4:07 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> > On Thu, Sep 15, 2016 at 10:01:03AM -0700, Dan Williams wrote:
> >> >> On Thu, Sep 15, 2016 at 1:26 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> >> > On Wed, Sep 14, 2016 at 11:54:38PM -0700, Dan Williams wrote:
> >> >> >> The DAX property, page cache bypass, of a VMA is only detectable via the
> >> >> >> vma_is_dax() helper to check the S_DAX inode flag.  However, this is
> >> >> >> only available internal to the kernel and is a property that userspace
> >> >> >> applications would like to interrogate.
> >> >> >
> >> >> > They have absolutely no business knowing such an implementation detail.
> >> >>
> >> >> Hasn't that train already left the station with FS_XFLAG_DAX?
> >> >
> >> > No, that's an admin flag, not a runtime hint for applications. Just
> >> > because that flag is set on an inode, it does not mean that DAX is
> >> > actually in use - it will be ignored if the backing dev is not dax
> >> > capable.
> >>
> >> What's the point of an admin flag if an admin can't do cat /proc/<pid
> >> of interest>/smaps, or some other mechanism, to validate that the
> >> setting the admin cares about is in effect?
> >
> > Sorry, I don't follow - why would you be looking at mapping file
> > regions in /proc to determine if some file somewhere in a filesystem
> > has a specific flag set on it or not?
> >
> > FS_XFLAG_DAX is an inode attribute flag, not something you can
> > query or administrate through mmap:
> >
> > I.e.
> > # xfs_io -c "lsattr" -c "chattr +x" -c lsattr -c "chattr -x" -c "lsattr" foo
> >  --------------- foo
> >  --------------x foo
> >  --------------- foo
> > #
> >
> > What happens when that flag is set on an inode is determined by a
> > whole bunch of other things that are completely separate to the
> > management of the inode flag itself.
> 
> Right, I understand that, but how does an admin audit those "bunch of
> other things"

Filesystem mounts checks all the various stuff that determines
whether DAX can be used. It logs to the console that it is "Dax
capable". Any file that then has FS_XFLAG_DAX set will result in DAX
being used. There is no other possibility when these two things are
reported.

/me points at runtime diagnostic tracepoints like
trace_xfs_file_dax_read() and notes that dax is sadly lacking in
diagnostic tracepoints.

Besides, userspace can't do anything useful with this information,
because the FS_XFLAG_DAX can be changed /at any time/ by an admin.
And the filesystem is free to remove it at any time, too, if it
needs to (e.g. file gets reflinked or snapshotted).

That's right, an inode can dynamically change from DAX to non-DAX
underneath the application, and the application /will not notice/.
That's because changing the flag will sync and invalidate the
existing mappings and the next application access will simply fault
it back in using whatever mechanism the inode is now configured
with.

Plain and simple: userspace has absolutely no fucking idea of
whether DAX is enabled or not, and whatever the kernel returns to
userspace above the DAX configuration is stale before it even got
out of the kernel....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
