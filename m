Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 6FD086B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 11:01:58 -0400 (EDT)
Message-ID: <52050474.8040608@parallels.com>
Date: Fri, 9 Aug 2013 19:02:12 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru> <20130629174525.20175.18987.stgit@maximpc.sw.ru> <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu> <51FBD2DF.50506@parallels.com> <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
In-Reply-To: <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: riel@redhat.com, Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, fuse-devel <fuse-devel@lists.sourceforge.net>, Brian Foster <bfoster@redhat.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, devel@openvz.org, Mel Gorman <mgorman@suse.de>

Hi Miklos,

08/06/2013 08:25 PM, Miklos Szeredi D?D,N?DuN?:
> On Fri, Aug 2, 2013 at 5:40 PM, Maxim Patlasov <mpatlasov@parallels.com> wrote:
>> 07/19/2013 08:50 PM, Miklos Szeredi D?D,N?DuN?:
>>
>>> On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlasov wrote:
>>>> From: Pavel Emelyanov <xemul@openvz.org>
>>>>
>>>> The .writepages one is required to make each writeback request carry more
>>>> than
>>>> one page on it. The patch enables optimized behaviour unconditionally,
>>>> i.e. mmap-ed writes will benefit from the patch even if
>>>> fc->writeback_cache=0.
>>> I rewrote this a bit, so we won't have to do the thing in two passes,
>>> which
>>> makes it simpler and more robust.  Waiting for page writeback here is
>>> wrong
>>> anyway, see comment above fuse_page_mkwrite().  BTW we had a race there
>>> because
>>> fuse_page_mkwrite() didn't take the page lock.  I've also fixed that up
>>> and
>>> pushed a series containing these patches up to implementing ->writepages()
>>> to
>>>
>>>     git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git
>>> writepages
>>>
>>> Passed some trivial testing but more is needed.
>>
>> Thanks a lot for efforts. The approach you implemented looks promising, but
>> it introduces the following assumption: a page cannot become dirty before we
>> have a chance to wait on fuse writeback holding the page locked. This is
>> already true for mmap-ed writes (due to your fixes) and it seems doable for
>> cached writes as well (like we do in fuse_perform_write). But the assumption
>> seems to be broken in case of direct read from local fs (e.g. ext4) to a
>> memory region mmap-ed to a file on fuse fs. See how dio_bio_submit() marks
>> pages dirty by bio_set_pages_dirty(). I can't see any solution for this
>> use-case. Do you?
> Hmm.  Direct IO on an mmaped file will do get_user_pages() which will
> do the necessary page fault magic and ->page_mkwrite() will be called.
> At least AFAICS.

Yes, I agree.

>
> The page cannot become dirty through a memory mapping without first
> switching the pte from read-only to read-write first.  Page accounting
> logic relies on this too.  The other way the page can become dirty is
> through write(2) on the fs.  But we do get notified about that too.

Yes, that's correct, but I don't understand why you disregard two other 
cases of marking page dirty (both related to direct AIO read from a file 
to a memory region mmap-ed to a fuse file):

1. dio_bio_submit() -->
       bio_set_pages_dirty() -->
         set_page_dirty_lock()

2. dio_bio_complete() -->
       bio_check_pages_dirty() -->
          bio_dirty_fn() -->
             bio_set_pages_dirty() -->
                set_page_dirty_lock()

As soon as a page became dirty through a memory mapping (exactly as you 
explained), nothing would prevent it to be written-back. And fuse will 
call end_page_writeback almost immediately after copying the real page 
to a temporary one. Then dio_bio_submit may re-dirty page speculatively 
w/o notifying fuse. And again, since then nothing would prevent it to be 
written-back once more. Hence we can end up in more then one temporary 
page in fuse write-back. And similar concern for dio_bio_complete() 
re-dirty.

This make me think that we do need fuse_page_is_writeback() in 
fuse_writepages_fill(). But it shouldn't be harmful because it will 
no-op practically always due to waiting for fuse writeback in 
->page_mkwrite() and in course of handling write(2).

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
