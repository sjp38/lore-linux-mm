Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 86C8A900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:54:58 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <040a7fa3-14dd-4960-a296-cfdd061e015f@default>
Date: Fri, 15 Apr 2011 11:53:28 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
References: <83ef8b69-f041-43e6-a5a9-880ff3da26f2@default>
 <20110415081054.79a164d3.akpm@linux-foundation.org
 871v135xvj.fsf@devron.myhome.or.jp>
In-Reply-To: <871v135xvj.fsf@devron.myhome.or.jp>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

> From: OGAWA Hirofumi [mailto:hirofumi@mail.parknet.co.jp]
>=20
> Andrew Morton <akpm@linux-foundation.org> writes:
>=20
> >> > Before I suggested a thing about cleancache_flush_page,
> >> > cleancache_flush_inode.
> >> >
> >> > what's the meaning of flush's semantic?
> >> > I thought it means invalidation.
> >> > AFAIC, how about change flush with invalidate?
> >>
> >> I'm not sure the words "flush" and "invalidate" are defined
> >> precisely or used consistently everywhere in computer
> >> science, but I think that "invalidate" is to destroy
> >> a "pointer" to some data, but not necessarily destroy the
> >> data itself.   And "flush" means to actually remove
> >> the data.  So one would "invalidate a mapping" but one
> >> would "flush a cache".
> >>
> >> Since cleancache_flush_page and cleancache_flush_inode
> >> semantically remove data from cleancache, I think flush
> >> is a better name than invalidate.
> >>
> >> Does that make sense?
> >
> > nope ;)
> >
> > Kernel code freely uses "flush" to refer to both invalidation and to
> > writeback, sometimes in confusing ways.  In this case,
> > cleancache_flush_inode and cleancache_flush_page rather sound like
> they
> > might write those things to backing store.
>=20
> I'd like to mention about *_{get,put}_page too. In linux get/put is not
> meaning read/write. There is {get,put}_page those are refcount stuff
> (Yeah, and I felt those methods does refcount by quick read. But it
> seems to be false. There is no xen codes, so I don't know actually
> though.).
>=20
> And I agree, I also think the needing thing is consistency on the linux
> codes (term).
>=20
> Thanks.
> --
> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

Hmmm, yes, that's a point of confusion also.  No, cleancache put/get
do not have any relationship with reference counting.

Andrew, I wonder if you would be so kind as to read the following
and make a "ruling".  If you determine a preferable set of names,
I will abide by your decision and repost (if necessary).

The problem is this: The English language has a limited number
of words that can be used to represent data motion and mapping
and most/all of them are already used in the kernel, often,
to quote Andrew, "in confusing ways."  Complicating this, I
think the semantics of the cleancache operations are different
from the semantics of any other kernel operation... intentionally
so, because the value of cleancache is a direct result of those
differing semantics.  And the cleancache semantics
are fairly complex (again intentionally) so a single function
name can't possibly describe the semantics.

The cleancache operations are:
- put (page)
- get (page)
- flush page
- flush inode
- init fs
- flush fs

I think these names are reasonable representations of the
semantics of the operations performed... but I'm not a kernel
expert so there is certainly room for disagreement.  Though I
absolutely recognize the importance of a "name", I am primarily
interested in merging the semantics of the operations and
would happily accept any name that kernel developers could
agree on.  However, I fear that there will be NO name that
will satisfy all, so would prefer to keep the existing names.
If some renaming is eventually agreed upon, this could be done
post-merge.

Here's a brief description of the semantics:

The cleancache operation currently known as "put" has the
following semantics:  If *possible*, please take the data
contained in the pageframe referred to by this struct page
into cleancache and associate it with the filesystem-determined
"handle" derived from the struct page.

The cleancache operation currently known as "get" has the
following semantics:  Derive the filesystem-determined handle
from this struct page.  If cleancache contains a page matching
that handle, recreate the page of data from cleancache and
place the results in the pageframe referred to by the
struct page.  Then delete in cleancache any record of the
handle and any data associated with it, so that a
subsequent "get" will no longer find a match for the handle;
any space used for the data can also be freed.

(Note that "take the data" and "recreate the page of data" are
similar in semantics to "copy to" and "copy from", but since
the cleancache operation may perform an "inflight" transformation
on the data, and "copy" usually means a byte-for-byte replication,
the word "copy" is also misleading.)

The cleancache operation currently known as "flush" has the
following semantics:  Derive the filesystem-determined handle
from this struct page and struct mapping.  If cleancache
contains a page matching that handle, delete in cleancache any
record of the handle and any data associated with it, so that a
subsequent "get" will no longer find a match for the handle;
any space used for the data can also be freed

The cleancache operation currently known as "flush inode" has
the following semantics: Derive the filesystem-determined filekey
from this struct mapping.  If cleancache contains ANY handles
matching that filekey, delete in cleancache any record of
any matching handle and any data associated with those handles;
any space used for the data can also be freed.

The cleancache operation currently known as "init fs" has
the following semantics: Create a unique poolid to refer
to this filesystem and save it in the superblock's
cleancache_poolid field.

The cleancache operation currently known as "flush fs" has
the following semantics: Get the cleancache_poolid field
from this superblock.  If cleancache contains ANY handles
associated with that poolid, delete in cleancache any
record of any matching handles and any data associated with
those handles; any space used for the data can also be freed.
Also, set the superblock's cleancache_poolid to be invalid
and, in cleancache, recycle the poolid so a subsequent init_fs
operation can reuse it.

That's all!

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
