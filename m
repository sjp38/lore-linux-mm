Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1674D6B0316
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:18:19 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 73so1831541pfz.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:18:19 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id r2si1011094pgp.564.2017.12.05.18.18.16
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 18:18:17 -0800 (PST)
Date: Wed, 6 Dec 2017 13:17:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171206021752.GC4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206014536.GA4094@dastard>
 <20171206015108.GB4094@dastard>
 <MWHPR21MB0845A83B9E89E4A9499AEC2FCB320@MWHPR21MB0845.namprd21.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <MWHPR21MB0845A83B9E89E4A9499AEC2FCB320@MWHPR21MB0845.namprd21.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-f2fs-devel@lists.sourceforge.net" <linux-f2fs-devel@lists.sourceforge.net>, "linux-nilfs@vger.kernel.org" <linux-nilfs@vger.kernel.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 06, 2017 at 01:53:41AM +0000, Matthew Wilcox wrote:
> Huh, you've caught a couple of problems that 0day hasn't sent me yet.  Try turning on DAX or TRANSPARENT_HUGEPAGE.  Thanks!

Dax is turned on, CONFIG_TRANSPARENT_HUGEPAGE is not.

Looks like nothing is setting CONFIG_RADIX_TREE_MULTIORDER, which is
what xas_set_order() is hidden under.

Ah, CONFIG_ZONE_DEVICE turns it on, not CONFIG_DAX/CONFIG_FS_DAX.

Hmmmm.  That seems wrong if it's used in fs/dax.c...

$ grep DAX .config
CONFIG_DAX=y
CONFIG_FS_DAX=y
$ grep ZONE_DEVICE .config
CONFIG_ARCH_HAS_ZONE_DEVICE=y
$

So I have DAX enabled, but not ZONE_DEVICE? Shouldn't DAX be
selecting ZONE_DEVICE, not relying on a user to select both of them
so that stuff works properly? Hmmm - there's no menu option to turn
on zone device, so it's selected by something else?  Oh, HMM turns
on ZONE device. But that is "default y", so should be turned on. But
it's not?  And there's no obvious HMM menu config option, either....

What a godawful mess Kconfig has turned into.

I'm just going to enable TRANSPARENT_HUGEPAGE - madness awaits me if
I follow the other path down the rat hole....

Ok, it build this time.

-Dave.

> 
> > -----Original Message-----
> > From: Dave Chinner [mailto:david@fromorbit.com]
> > Sent: Tuesday, December 5, 2017 8:51 PM
> > To: Matthew Wilcox <willy@infradead.org>
> > Cc: Matthew Wilcox <mawilcox@microsoft.com>; Ross Zwisler
> > <ross.zwisler@linux.intel.com>; Jens Axboe <axboe@kernel.dk>; Rehas
> > Sachdeva <aquannie@gmail.com>; linux-mm@kvack.org; linux-
> > fsdevel@vger.kernel.org; linux-f2fs-devel@lists.sourceforge.net; linux-
> > nilfs@vger.kernel.org; linux-btrfs@vger.kernel.org; linux-xfs@vger.kernel.org;
> > linux-usb@vger.kernel.org; linux-kernel@vger.kernel.org
> > Subject: Re: [PATCH v4 00/73] XArray version 4
> > 
> > On Wed, Dec 06, 2017 at 12:45:49PM +1100, Dave Chinner wrote:
> > > On Tue, Dec 05, 2017 at 04:40:46PM -0800, Matthew Wilcox wrote:
> > > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > >
> > > > I looked through some notes and decided this was version 4 of the XArray.
> > > > Last posted two weeks ago, this version includes a *lot* of changes.
> > > > I'd like to thank Dave Chinner for his feedback, encouragement and
> > > > distracting ideas for improvement, which I'll get to once this is merged.
> > >
> > > BTW, you need to fix the "To:" line on your patchbombs:
> > >
> > > > To: unlisted-recipients: ;, no To-header on input <@gmail-
> > pop.l.google.com>
> > >
> > > This bad email address getting quoted to the cc line makes some MTAs
> > > very unhappy.
> > >
> > > >
> > > > Highlights:
> > > >  - Over 2000 words of documentation in patch 8!  And lots more kernel-doc.
> > > >  - The page cache is now fully converted to the XArray.
> > > >  - Many more tests in the test-suite.
> > > >
> > > > This patch set is not for applying.  0day is still reporting problems,
> > > > and I'd feel bad for eating someone's data.  These patches apply on top
> > > > of a set of prepatory patches which just aren't interesting.  If you
> > > > want to see the patches applied to a tree, I suggest pulling my git tree:
> > > >
> > https://na01.safelinks.protection.outlook.com/?url=http%3A%2F%2Fgit.infrade
> > ad.org%2Fusers%2Fwilly%2Flinux-
> > dax.git%2Fshortlog%2Frefs%2Fheads%2Fxarray-2017-12-
> > 04&data=02%7C01%7Cmawilcox%40microsoft.com%7Ca3e721545f8b4b9dff1
> > 608d53c4bd42f%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C6364
> > 81218740341312&sdata=IXNZXXLTf964OQ0eLDpJt2LCv%2BGGWFW%2FQd4Kc
> > KYu6zo%3D&reserved=0
> > > > I also left out the idr_preload removals.  They're still in the git tree,
> > > > but I'm not looking for feedback on them.
> > >
> > > I'll give this a quick burn this afternoon and see what catches fire...
> > 
> > Build warnings/errors:
> > 
> > .....
> > lib/radix-tree.c:700:13: warning: ?radix_tree_free_nodes? defined but not used
> > [-Wunused-function]
> >  static void radix_tree_free_nodes(struct radix_tree_node *node)
> > .....
> > lib/xarray.c: In function ?xas_max?:
> > lib/xarray.c:291:16: warning: unused variable ?mask?
> > [-Wunused-variable]
> >   unsigned long mask, max = xas->xa_index;
> >                   ^~~~
> > ......
> > fs/dax.c: In function ?grab_mapping_entry?:
> > fs/dax.c:305:2: error: implicit declaration of function ?xas_set_order?; did you
> > mean ?xas_set_err??  [-Werror=implicit-function-declaration]
> >   xas_set_order(&xas, index, size_flag ? PMD_ORDER : 0);
> >     ^~~~~~~~~~~~~
> > scripts/Makefile.build:310: recipe for target 'fs/dax.o' failed
> > make[1]: *** [fs/dax.o] Error 1
> > 
> > -Dave.
> > --
> > Dave Chinner
> > david@fromorbit.com

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
