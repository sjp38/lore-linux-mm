Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C23236B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 12:25:23 -0400 (EDT)
Received: by mail-qe0-f47.google.com with SMTP id b10so336086qen.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 09:25:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51FBD2DF.50506@parallels.com>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
	<20130629174525.20175.18987.stgit@maximpc.sw.ru>
	<20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
	<51FBD2DF.50506@parallels.com>
Date: Tue, 6 Aug 2013 18:25:22 +0200
Message-ID: <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@parallels.com>
Cc: riel@redhat.com, Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, fuse-devel <fuse-devel@lists.sourceforge.net>, Brian Foster <bfoster@redhat.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, devel@openvz.org, Mel Gorman <mgorman@suse.de>

On Fri, Aug 2, 2013 at 5:40 PM, Maxim Patlasov <mpatlasov@parallels.com> wr=
ote:
> 07/19/2013 08:50 PM, Miklos Szeredi =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>> On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlasov wrote:
>>>
>>> From: Pavel Emelyanov <xemul@openvz.org>
>>>
>>> The .writepages one is required to make each writeback request carry mo=
re
>>> than
>>> one page on it. The patch enables optimized behaviour unconditionally,
>>> i.e. mmap-ed writes will benefit from the patch even if
>>> fc->writeback_cache=3D0.
>>
>> I rewrote this a bit, so we won't have to do the thing in two passes,
>> which
>> makes it simpler and more robust.  Waiting for page writeback here is
>> wrong
>> anyway, see comment above fuse_page_mkwrite().  BTW we had a race there
>> because
>> fuse_page_mkwrite() didn't take the page lock.  I've also fixed that up
>> and
>> pushed a series containing these patches up to implementing ->writepages=
()
>> to
>>
>>    git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git
>> writepages
>>
>> Passed some trivial testing but more is needed.
>
>
> Thanks a lot for efforts. The approach you implemented looks promising, b=
ut
> it introduces the following assumption: a page cannot become dirty before=
 we
> have a chance to wait on fuse writeback holding the page locked. This is
> already true for mmap-ed writes (due to your fixes) and it seems doable f=
or
> cached writes as well (like we do in fuse_perform_write). But the assumpt=
ion
> seems to be broken in case of direct read from local fs (e.g. ext4) to a
> memory region mmap-ed to a file on fuse fs. See how dio_bio_submit() mark=
s
> pages dirty by bio_set_pages_dirty(). I can't see any solution for this
> use-case. Do you?

Hmm.  Direct IO on an mmaped file will do get_user_pages() which will
do the necessary page fault magic and ->page_mkwrite() will be called.
At least AFAICS.

The page cannot become dirty through a memory mapping without first
switching the pte from read-only to read-write first.  Page accounting
logic relies on this too.  The other way the page can become dirty is
through write(2) on the fs.  But we do get notified about that too.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
