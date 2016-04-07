Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C2B5A6B025F
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 13:41:15 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id 184so59828668pff.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:41:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id yx4si1194385pac.109.2016.04.07.10.41.14
        for <linux-mm@kvack.org>;
        Thu, 07 Apr 2016 10:41:14 -0700 (PDT)
Date: Thu, 7 Apr 2016 13:41:11 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH] x86 get_unmapped_area: Add PMD alignment for DAX PMD mmap
Message-ID: <20160407174111.GG2781@linux.intel.com>
References: <1459951089-14911-1-git-send-email-toshi.kani@hpe.com>
 <20160406165027.GA2781@linux.intel.com>
 <1459964672.20338.41.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1459964672.20338.41.camel@hpe.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mingo@kernel.org, bp@suse.de, hpa@zytor.com, tglx@linutronix.de, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Wed, Apr 06, 2016 at 11:44:32AM -0600, Toshi Kani wrote:
> > The NVML chooses appropriate addresses and gets a properly aligned
> > address without any kernel code.
>=20
> An application like NVML can continue to specify a specific address to
> mmap(). =A0Most existing applications, however, do not specify an addre=
ss to
> mmap(). =A0With this patch, specifying an address will remain optional.

The point is that this *can* be done in userspace.  You need to sell us
on the advantages of doing it in the kernel.

> > I think this is the wrong place for it, if we decide that this is the
> > right thing to do.=A0=A0The filesystem has a get_unmapped_area() whic=
h
> > should be used instead.
>=20
> Yes, I considered adding a filesystem entry point, but decided going th=
is
> way because:
> =A0-=A0arch_get_unmapped_area() and=A0arch_get_unmapped_area_topdown() =
are arch-
> specific code. =A0Therefore, this filesystem entry point will need arch=
-
> specific implementation.=A0
> =A0- There is nothing filesystem specific about requesting PMD alignmen=
t.

See http://article.gmane.org/gmane.linux.kernel.mm/149227 for Hugh's
approach for shmem.  I strongly believe that if we're going to do this
i the kernel, we should build on this approach, and not hack something
into each architecture's generic get_unmapped_area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
