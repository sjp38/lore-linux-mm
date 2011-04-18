Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB81900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 01:32:14 -0400 (EDT)
Received: by iwg8 with SMTP id 8so5426708iwg.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 22:32:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <040a7fa3-14dd-4960-a296-cfdd061e015f@default>
References: <83ef8b69-f041-43e6-a5a9-880ff3da26f2@default>
	<871v135xvj.fsf@devron.myhome.or.jp>
	<040a7fa3-14dd-4960-a296-cfdd061e015f@default>
Date: Mon, 18 Apr 2011 14:32:08 +0900
Message-ID: <BANLkTikDQ_PuYPJEZRX_24uUi1DYWbvpzQ@mail.gmail.com>
Subject: Re: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

On Sat, Apr 16, 2011 at 3:53 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: OGAWA Hirofumi [mailto:hirofumi@mail.parknet.co.jp]
>>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>>
>> >> > Before I suggested a thing about cleancache_flush_page,
>> >> > cleancache_flush_inode.
>> >> >
>> >> > what's the meaning of flush's semantic?
>> >> > I thought it means invalidation.
>> >> > AFAIC, how about change flush with invalidate?
>> >>
>> >> I'm not sure the words "flush" and "invalidate" are defined
>> >> precisely or used consistently everywhere in computer
>> >> science, but I think that "invalidate" is to destroy
>> >> a "pointer" to some data, but not necessarily destroy the
>> >> data itself. =C2=A0 And "flush" means to actually remove
>> >> the data. =C2=A0So one would "invalidate a mapping" but one
>> >> would "flush a cache".
>> >>
>> >> Since cleancache_flush_page and cleancache_flush_inode
>> >> semantically remove data from cleancache, I think flush
>> >> is a better name than invalidate.
>> >>
>> >> Does that make sense?
>> >
>> > nope ;)
>> >
>> > Kernel code freely uses "flush" to refer to both invalidation and to
>> > writeback, sometimes in confusing ways. =C2=A0In this case,
>> > cleancache_flush_inode and cleancache_flush_page rather sound like
>> they
>> > might write those things to backing store.
>>
>> I'd like to mention about *_{get,put}_page too. In linux get/put is not
>> meaning read/write. There is {get,put}_page those are refcount stuff
>> (Yeah, and I felt those methods does refcount by quick read. But it
>> seems to be false. There is no xen codes, so I don't know actually
>> though.).
>>
>> And I agree, I also think the needing thing is consistency on the linux
>> codes (term).
>>
>> Thanks.
>> --
>> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
>
> Hmmm, yes, that's a point of confusion also. =C2=A0No, cleancache put/get
> do not have any relationship with reference counting.
>
> Andrew, I wonder if you would be so kind as to read the following
> and make a "ruling". =C2=A0If you determine a preferable set of names,
> I will abide by your decision and repost (if necessary).
>
> The problem is this: The English language has a limited number
> of words that can be used to represent data motion and mapping
> and most/all of them are already used in the kernel, often,
> to quote Andrew, "in confusing ways." =C2=A0Complicating this, I
> think the semantics of the cleancache operations are different
> from the semantics of any other kernel operation... intentionally
> so, because the value of cleancache is a direct result of those
> differing semantics. =C2=A0And the cleancache semantics
> are fairly complex (again intentionally) so a single function
> name can't possibly describe the semantics.
>
> The cleancache operations are:
> - put (page)
> - get (page)
> - flush page
> - flush inode
> - init fs
> - flush fs
>
> I think these names are reasonable representations of the
> semantics of the operations performed... but I'm not a kernel
> expert so there is certainly room for disagreement. =C2=A0Though I
> absolutely recognize the importance of a "name", I am primarily
> interested in merging the semantics of the operations and
> would happily accept any name that kernel developers could
> agree on. =C2=A0However, I fear that there will be NO name that
> will satisfy all, so would prefer to keep the existing names.
> If some renaming is eventually agreed upon, this could be done
> post-merge.
>
> Here's a brief description of the semantics:
>
> The cleancache operation currently known as "put" has the
> following semantics: =C2=A0If *possible*, please take the data
> contained in the pageframe referred to by this struct page
> into cleancache and associate it with the filesystem-determined
> "handle" derived from the struct page.
>
> The cleancache operation currently known as "get" has the
> following semantics: =C2=A0Derive the filesystem-determined handle
> from this struct page. =C2=A0If cleancache contains a page matching
> that handle, recreate the page of data from cleancache and
> place the results in the pageframe referred to by the
> struct page. =C2=A0Then delete in cleancache any record of the
> handle and any data associated with it, so that a
> subsequent "get" will no longer find a match for the handle;
> any space used for the data can also be freed.
>
> (Note that "take the data" and "recreate the page of data" are
> similar in semantics to "copy to" and "copy from", but since
> the cleancache operation may perform an "inflight" transformation
> on the data, and "copy" usually means a byte-for-byte replication,
> the word "copy" is also misleading.)
>
> The cleancache operation currently known as "flush" has the
> following semantics: =C2=A0Derive the filesystem-determined handle
> from this struct page and struct mapping. =C2=A0If cleancache
> contains a page matching that handle, delete in cleancache any
> record of the handle and any data associated with it, so that a
> subsequent "get" will no longer find a match for the handle;
> any space used for the data can also be freed
>
> The cleancache operation currently known as "flush inode" has
> the following semantics: Derive the filesystem-determined filekey
> from this struct mapping. =C2=A0If cleancache contains ANY handles
> matching that filekey, delete in cleancache any record of
> any matching handle and any data associated with those handles;
> any space used for the data can also be freed.
>
> The cleancache operation currently known as "init fs" has
> the following semantics: Create a unique poolid to refer
> to this filesystem and save it in the superblock's
> cleancache_poolid field.
>
> The cleancache operation currently known as "flush fs" has
> the following semantics: Get the cleancache_poolid field
> from this superblock. =C2=A0If cleancache contains ANY handles
> associated with that poolid, delete in cleancache any
> record of any matching handles and any data associated with
> those handles; any space used for the data can also be freed.
> Also, set the superblock's cleancache_poolid to be invalid
> and, in cleancache, recycle the poolid so a subsequent init_fs
> operation can reuse it.
>
> That's all!
>
> Thanks,
> Dan
>

At least, I didn't confused your semantics except just flush. That's
why I suggested only flush but after seeing your explaining, there is
another thing I want to change. The get/put is common semantic of
reference counting in kernel but in POV your semantics, it makes sense
to me but get has a exclusive semantic so I want to represent it with
API name. Maybe cleancache_get_page_exclusive.

The summary is that I don't want to change all API name. Just two thing.
(I am not sure you and others agree on me. It's just suggestion).

1. cleancache_flush_page -> cleancache_[invalidate|remove]_page
2. cleancache_get_page -> cleancache_get_page_exclusive

BTW, Nice description.
Please include it in documentation if we can't reach the conclusion.
It will help others to understand semantic of cleancache.

Thanks, Dan.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
