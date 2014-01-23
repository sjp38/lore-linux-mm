Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7377A6B0036
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 07:12:48 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so1701361pdj.36
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:12:48 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fv4si13896717pbd.242.2014.01.23.04.12.46
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 04:12:46 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Date: Thu, 23 Jan 2014 12:12:43 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE04061DF33@FMSMSX114.amr.corp.intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>,<20140123090133.GR13997@dastard>
In-Reply-To: <20140123090133.GR13997@dastard>
Content-Language: en-CA
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

Are you hitting the same problems with ext4 fsck that we did?  Version 1.42=
.8 reports spurious corruption.  From the 1.42.9 changelog:=0A=
=0A=
  * Fixed a regression introduced in 1.42.8 which would cause e2fsck to=0A=
    erroneously report uninitialized extents past i_size to be invalid.=0A=
=0A=
________________________________________=0A=
From: Dave Chinner [david@fromorbit.com]=0A=
Sent: January 23, 2014 1:01 AM=0A=
To: Wilcox, Matthew R=0A=
Cc: linux-kernel@vger.kernel.org; linux-fsdevel@vger.kernel.org; linux-mm@k=
vack.org; linux-ext4@vger.kernel.org=0A=
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4=
=0A=
=0A=
On Wed, Jan 15, 2014 at 08:24:18PM -0500, Matthew Wilcox wrote:=0A=
> This series of patches add support for XIP to ext4.  Unfortunately,=0A=
> it turns out to be necessary to rewrite the existing XIP support code=0A=
> first due to races that are unfixable in the current design.=0A=
>=0A=
> Since v4 of this patchset, I've improved the documentation, fixed a=0A=
> couple of warnings that a newer version of gcc emitted, and fixed a=0A=
> bug where we would read/write the wrong address for I/Os that were not=0A=
> aligned to PAGE_SIZE.=0A=
>=0A=
> I've dropped the PMD fault patch from this set since there are some=0A=
> places where we would need to split a PMD page and there's no way to do=
=0A=
> that right now.  In its place, I've added a patch which attempts to add=
=0A=
> support for unwritten extents.  I'm still in two minds about this; on the=
=0A=
> one hand, it's clearly a win for reads and writes.  On the other hand,=0A=
> it adds a lot of complexity, and it probably isn't a win for pagefaults.=
=0A=
=0A=
I ran this through xfstests, but ext4 in default configuration fails=0A=
too many of the tests with filesystem corruption and other cascading=0A=
failures on the quick group tests (generic/013, generic/070,=0A=
generic/075, generic/091, etc)  for me to be able to tell if adding=0A=
MOUNT_OPTIONS=3D"-o xip" adds any problems or not....=0A=
=0A=
XIP definitely caused generic/001 to fail, but other than that I=0A=
can't really tell. Still, it looks like it functions enough to be=0A=
able to add XFS support on top of. I'll get back to you with that ;)=0A=
=0A=
Cheers,=0A=
=0A=
Dave.=0A=
--=0A=
Dave Chinner=0A=
david@fromorbit.com=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
