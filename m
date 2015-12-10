Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id E71E96B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:24:55 -0500 (EST)
Received: by pfv76 with SMTP id 76so582089pfv.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:24:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e87si22266867pfj.20.2015.12.10.12.24.55
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 12:24:55 -0800 (PST)
Date: Thu, 10 Dec 2015 13:24:38 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3 3/7] mm: add find_get_entries_tag()
Message-ID: <20151210202438.GA6590@linux.intel.com>
References: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
 <1449602325-20572-4-git-send-email-ross.zwisler@linux.intel.com>
 <CAA9_cmeVYinm4mMiDU4oz8fW4HQ3n1RqEbPHBW7A3OGmi9eXtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmeVYinm4mMiDU4oz8fW4HQ3n1RqEbPHBW7A3OGmi9eXtw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, "H. Peter Anvin" <hpa@zytor.com>, Jeff Layton <jlayton@poochiereds.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, ext4 hackers <linux-ext4@vger.kernel.org>, xfs@oss.sgi.com, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Wed, Dec 09, 2015 at 11:44:16AM -0800, Dan Williams wrote:
> On Tue, Dec 8, 2015 at 11:18 AM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > Add find_get_entries_tag() to the family of functions that include
> > find_get_entries(), find_get_pages() and find_get_pages_tag().  This is
> > needed for DAX dirty page handling because we need a list of both page
> > offsets and radix tree entries ('indices' and 'entries' in this function)
> > that are marked with the PAGECACHE_TAG_TOWRITE tag.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
<> 
> Why does this mostly duplicate find_get_entries()?
> 
> Surely find_get_entries() can be implemented as a special case of
> find_get_entries_tag().

I'm adding find_get_entries_tag() to the family of functions that already
exist and include find_get_entries(), find_get_pages(),
find_get_pages_contig() and find_get_pages_tag().

These functions all contain very similar code with small changes to the
internal looping based on whether you're looking through all radix slots or
only the ones that match a certain tag (radix_tree_for_each_slot() vs
radix_tree_for_each_tagged()).

We already have find_get_page() to get all pages in a range and
find_get_pages_tag() to get all pages in the range with a certain tag.  We
have find_get_entries() to get all pages and indices for a given range, but we
are currently missing find_get_entries_tag() to do that same search based on a
tag, which is what I'm adding.

I agree that we could probably figure out a way to combine the code for
find_get_entries() with find_get_entries_tag(), as we could do for the
existing functions find_get_pages() and find_get_pages_tag().  I think we
should probably add find_get_entries_tag() per this patch, though, and then
decide whether to do any combining later as a separate step.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
