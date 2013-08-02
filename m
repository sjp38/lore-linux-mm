Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7E84F6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 11:40:07 -0400 (EDT)
Message-ID: <51FBD2DF.50506@parallels.com>
Date: Fri, 2 Aug 2013 19:40:15 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru> <20130629174525.20175.18987.stgit@maximpc.sw.ru> <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
In-Reply-To: <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

07/19/2013 08:50 PM, Miklos Szeredi D?D,N?DuN?:
> On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlasov wrote:
>> From: Pavel Emelyanov <xemul@openvz.org>
>>
>> The .writepages one is required to make each writeback request carry more than
>> one page on it. The patch enables optimized behaviour unconditionally,
>> i.e. mmap-ed writes will benefit from the patch even if fc->writeback_cache=0.
> I rewrote this a bit, so we won't have to do the thing in two passes, which
> makes it simpler and more robust.  Waiting for page writeback here is wrong
> anyway, see comment above fuse_page_mkwrite().  BTW we had a race there because
> fuse_page_mkwrite() didn't take the page lock.  I've also fixed that up and
> pushed a series containing these patches up to implementing ->writepages() to
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git writepages
>
> Passed some trivial testing but more is needed.

Thanks a lot for efforts. The approach you implemented looks promising, 
but it introduces the following assumption: a page cannot become dirty 
before we have a chance to wait on fuse writeback holding the page 
locked. This is already true for mmap-ed writes (due to your fixes) and 
it seems doable for cached writes as well (like we do in 
fuse_perform_write). But the assumption seems to be broken in case of 
direct read from local fs (e.g. ext4) to a memory region mmap-ed to a 
file on fuse fs. See how dio_bio_submit() marks pages dirty by 
bio_set_pages_dirty(). I can't see any solution for this use-case. Do you?

Thanks,
Maxim

>
> I'll get to the rest of the patches next week.
>
> Thanks,
> Miklos
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
