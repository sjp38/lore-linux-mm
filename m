Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20B3D6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 11:18:41 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id x189so196114714ywe.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 08:18:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 199si15014837qhk.92.2016.05.02.08.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 08:18:40 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com> <20160425232552.GD18496@dastard>
	<1461628381.1421.24.camel@intel.com> <20160426004155.GF18496@dastard>
Date: Mon, 02 May 2016 11:18:36 -0400
In-Reply-To: <20160426004155.GF18496@dastard> (Dave Chinner's message of "Tue,
	26 Apr 2016 10:41:55 +1000")
Message-ID: <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, "Dan J. Williams" <dan.j.williams@intel.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

Dave Chinner <david@fromorbit.com> writes:

> On Mon, Apr 25, 2016 at 11:53:13PM +0000, Verma, Vishal L wrote:
>> On Tue, 2016-04-26 at 09:25 +1000, Dave Chinner wrote:
> You're assuming that only the DAX aware application accesses it's
> files.  users, backup programs, data replicators, fileystem
> re-organisers (e.g.  defragmenters) etc all may access the files and
> they may throw errors. What then?

I'm not sure how this is any different from regular storage.  If an
application gets EIO, it's up to the app to decide what to do with that.

>> > Where does the application find the data that was lost to be able to
>> > rewrite it?
>>=20
>> The data that was lost is gone -- this assumes the application has some
>> ability to recover using a journal/log or other redundancy - yes, at the
>> application layer. If it doesn't have this sort of capability, the only
>> option is to restore files from a backup/mirror.
>
> So the architecture has a built in assumption that only userspace
> can handle data loss?

Remember that the proposed programming model completely bypasses the
kernel, so yes, it is expected that user-space will have to deal with
the problem.

> What about filesytsems like NOVA, that use log structured design to
> provide DAX w/ update atomicity and can potentially also provide
> redundancy/repair through the same mechanisms? Won't pmem native
> filesystems with built in data protection features like this remove
> the need for adding all this to userspace applications?

I don't think we'll /only/ support NOVA for pmem.  So we'll have to deal
with this for existing file systems, right?

> If so, shouldn't that be the focus of development rahter than
> placing the burden on userspace apps to handle storage repair
> situations?

It really depends on the programming model.  In the model Vishal is
talking about, either the applications themselves or the libraries they
link to are expected to implement the redundancies where necessary.

>> > There's an implicit assumption that applications will keep redundant
>> > copies of their data at the /application layer/ and be able to
>> > automatically repair it?

That's one way to do things.  It really depends on the application what
it will do for recovery.

>> > And then there's the implicit assumption that it will unlink and
>> > free the entire file before writing a new copy

I think Vishal was referring to restoring from backup.  cp itself will
truncate the file before overwriting, iirc.

>> To summarize, the two cases we want to handle are:
>> 1. Application has inbuilt recovery:
>> =C2=A0 - hits badblock
>> =C2=A0 - figures out it is able to recover the data
>> =C2=A0 - handles SIGBUS or EIO
>> =C2=A0 - does a (sector aligned) write() to restore the data
>
> The "figures out" step here is where >95% of the work we'd have to
> do is. And that's in filesystem and block layer code, not
> userspace, and userspace can't do that work in a signal handler.
> And it  can still fall down to the second case when the application
> doesn't have another copy of the data somewhere.

I read that "figures out" step as the application determining whether or
not it had a redundant copy.

> FWIW, we don't have a DAX enabled filesystem that can do
> reverse block mapping, so we're a year or two away from this being a
> workable production solution from the filesystem perspective. And
> AFAICT, it's not even on the roadmap for dm/md layers.

Do we even need that?  What if we added an FIEMAP flag for determining
bad blocks.  The file system could simply walk the list of extents for
the file and check the corresponding disk blocks.  No reverse mapping
required.  Also note that DM/MD don't support direct_access(), either,
so I don't think they're relevant for this discussion.

>> 2. Application doesn't have any inbuilt recovery mechanism
>> =C2=A0 - hits badblock
>> =C2=A0 - gets SIGBUS (or EIO) and crashes
>> =C2=A0 - Sysadmin restores file from backup
>
> Which is no different to an existing non-DAX application getting an
> EIO/sigbus from current storage technologies.
>
> Except: in the existing storage stack, redundancy and correction has
> already had to have failed for the application to see such an error.
> Hence this is normally considered a DR case as there's had to be
> cascading failures (e.g.  multiple disk failures in a RAID) to get
> to this stage, not a single error in a single sector in
> non-redundant storage.
>
> We need some form of redundancy and correction in the PMEM stack to
> prevent single sector errors from taking down services until an
> administrator can correct the problem. I'm trying to understand
> where this is supposed to fit into the picture - at this point I
> really don't think userspace applications are going to be able to do
> this reliably....

Not all storage is configured into a RAID volume, and in some instances,
the application is better positioned to recover the data (gluster/ceph,
for example).  It really comes down to whether applications or libraries
will want to implement redundancy themselves in order to get a bump in
performance by not going through the kernel.  And I think I know what
your opinion is on that front.  :-)

Speaking of which, did you see the numbers Dan shared at LSF on how much
overhead there is in calling into the kernel for syncing?  Dan, can/did
you publish that spreadsheet somewhere?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
