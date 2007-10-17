From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	<200710160956.58061.borntraeger@de.ibm.com>
	<200710171814.01717.borntraeger@de.ibm.com>
	<m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	<1192648456.15717.7.camel@think.oraclecorp.com>
	<m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	<1192654481.15717.16.camel@think.oraclecorp.com>
	<m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
	<1192661889.15717.27.camel@think.oraclecorp.com>
Date: Wed, 17 Oct 2007 17:28:51 -0600
In-Reply-To: <1192661889.15717.27.camel@think.oraclecorp.com> (Chris Mason's
	message of "Wed, 17 Oct 2007 18:58:09 -0400")
Message-ID: <m16415cocs.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason <chris.mason@oracle.com> writes:

> So, the problem is using the Dirty bit to indicate pinned.  You're
> completely right that our current setup of buffer heads and pages and
> filesystpem metadata is complex and difficult.
>
> But, moving the buffer heads off of the page cache pages isn't going to
> make it any easier to use dirty as pinned, especially in the face of
> buffer_head users for file data pages.

Let me specific.  Not moving buffer_heads off of page cache pages,
moving buffer_heads off of the block devices page cache pages.

My problem is the coupling of how block devices are cached and the
implementation of buffer heads, and by removing that coupling
we can generally make things better.  Currently that coupling
means silly things like all block devices are cached in low memory.
Which probably isn't what you want if you actually have a use
for block devices.

For the ramdisk case in particular what this means is that there
are no more users that create buffer_head mappings on the block
device cache so using the dirty bit will be safe. 

Further it removes the nasty possibility of user space messing with
metadata buffer head state.  So the only way those cases can happen is
a code bug, or a hardware bug.

So I think by removing these unnecessary code paths things will
become easier to work with.

> You've already seen Nick fsblock code, but you can see my general
> approach to replacing buffer heads here:
>
> http://oss.oracle.com/mercurial/mason/btrfs-unstable/file/f89e7971692f/extent_map.h
>
> (alpha quality implementation in extent_map.c and users in inode.c)  The
> basic idea is to do extent based record keeping for mapping and state of
> things in the filesystem, and to avoid attaching these things to the
> page.

Interesting.  Something to dig into.

> Don't get me wrong, I'd love to see a simple and coherent fix for what
> reiserfs and ext3 do with buffer head state, but I think for the short
> term you're best off pinning the ramdisk pages via some other means.

Yes.  And the problem is hard enough to trigger that a short term fix
is actually of debatable value.  The reason this hasn't shown up more
frequently is that it only ever triggers if you are in the buffer head
reclaim state, which on a 64bit box means you have to use < 4K buffers
and have your ram cache another block device.  That plus most people
use initramfs these days.

For the short term we have Christian's other patch which simply
disables calling try_to_free_buffers.  Although that really feels
like a hack to me.

For 2.6.25 I think I have a shot at fixing these things cleanly.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
