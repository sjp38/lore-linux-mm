Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 482056B0276
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:13:14 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t10-v6so1819232ywc.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 02:13:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l130-v6sor2483929ywe.10.2018.07.24.02.13.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 02:13:12 -0700 (PDT)
Date: Tue, 24 Jul 2018 02:12:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <20180723225454.GC18236@bombadil.infradead.org>
Message-ID: <alpine.LSU.2.11.1807240121590.1105@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org> <alpine.LSU.2.11.1807221856350.5536@eggly.anvils> <20180723140150.GA31843@bombadil.infradead.org> <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org> <alpine.LSU.2.11.1807231531240.2545@eggly.anvils> <20180723225454.GC18236@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> On Mon, Jul 23, 2018 at 03:42:22PM -0700, Hugh Dickins wrote:
> > On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> > > I figured out a fix and pushed it to the 'ida' branch in
> > > git://git.infradead.org/users/willy/linux-dax.git
> > 
> > Great, thanks a lot for sorting that out so quickly. But I've cloned
> > the tree and don't see today's patch, so assume you've folded the fix
> > into an existing commit? If possible, please append the diff of today's
> > fix to this thread so that we can try it out. Or if that's difficult,
> > please at least tell which files were modified, then I can probably
> > work it out from the diff of those files against mmotm.
> 
> Sure!  It's just this:
> 
> diff --git a/lib/xarray.c b/lib/xarray.c
> index 32a9c2a6a9e9..383c410997eb 100644
> --- a/lib/xarray.c
> +++ b/lib/xarray.c
> @@ -660,6 +660,8 @@ void xas_create_range(struct xa_state *xas)
>  	unsigned char sibs = xas->xa_sibs;
>  
>  	xas->xa_index |= ((sibs + 1) << shift) - 1;
> +	if (!xas_top(xas->xa_node) && xas->xa_node->shift == xas->xa_shift)
> +		xas->xa_offset |= sibs;
>  	xas->xa_shift = 0;
>  	xas->xa_sibs = 0;

Yes, that's a big improvement, the huge "cp" is now fine, thank you.

I've updated my xfstests tree, and tried that on mmotm with this patch.
The few failures are exactly the same as on 4.18-rc6, whether mounting
tmpfs as huge or not. But four of the tests, generic/{340,345,346,354}
crash (oops) on 4.18-rc5-mm1 + your patch above, but pass on 4.18-rc6.

That was simply with non-huge tmpfs: I just patched them out and didn't
try for whether they crash with huge tmpfs too: probably they do, but
that won't be very interesting until the non-huge crashes are fixed.

I paid no attention to where the crashes were, I was just pressing on
to skip the problem tests to get as full a run as possible, with that
list of what's problematic and needs further investigation.

To test non-huge tmpfs (as root), I wrap xfstests' check script as
follows (you'll want to mkdir or substitute somewhere else for /xft):

export FSTYP=tmpfs
export DISABLE_UDF_TEST=1
export TEST_DEV=tmpfs1:
export TEST_DIR=/xft
export SCRATCH_DEV=tmpfs2:
export SCRATCH_MNT=/mnt
mount -t $FSTYP -o size=1088M $TEST_DEV $TEST_DIR || exit $?
./check "$@" # typically "-g auto"
umount /xft /mnt 2>/dev/null

But don't bother with "-g auto" for the moment: I have workarounds in
for a few of them, generic/{027,213,449}, which we need not get into
right now (without them, two of those tests can take close to forever).

To test huge tmpfs (as root), I wrap xfstests' check script as:

export FSTYP=tmpfs
export DISABLE_UDF_TEST=1
export TEST_DEV=tmpfs1:
export TEST_DIR=/xft
export SCRATCH_DEV=tmpfs2:
export SCRATCH_MNT=/mnt
export TMPFS_MOUNT_OPTIONS="-o size=1088M,huge=always"
mount -t $FSTYP $TMPFS_MOUNT_OPTIONS $TEST_DEV $TEST_DIR || exit $?
./check "$@" # typically "-g auto"
umount /xft /mnt 2>/dev/null

Hugh
