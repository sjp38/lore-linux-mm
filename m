Date: Sat, 17 Mar 2007 19:13:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: FADV_DONTNEED on hugetlbfs files broken
Message-ID: <20070318021324.GJ8915@holomorphy.com>
References: <20070317051308.GA5522@us.ibm.com> <20070317061322.GI8915@holomorphy.com> <20070317193729.GA11449@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070317193729.GA11449@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: kenchen@google.com, linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On 16.03.2007 [23:13:22 -0700], William Lee Irwin III wrote:
>> Well, setting the pages always dirty like that will prevent things
>> from dropping them because they think they still need to be written
>> back. It is, however, legitimate and/or permissible to ignore
>> fadvise() and/or madvise(); they are by definition only advisory. I
>> think this is more of a "please add back FADV_DONTNEED support"
>> affair.

On Sat, Mar 17, 2007 at 12:37:29PM -0700, Nishanth Aravamudan wrote:
> Yes, that could be :) Sorry if my e-mail indicated I was asking
> otherwise. I don't want Ken's commit to be reverted, as that would make
> hugepages very nearly unusable on x86 and x86_64. But I had found a
> functional change and wanted it to be documented. If hugepages can no
> longer be dropped from the page cache, then we should make sure that is
> clear (and expected/desired).
> Now, even if I call fsync() on the file descriptor, I still don't get
> the pages out of the page cache. It seems to me like fsync() would clear
> the dirty state -- although perhaps with Ken's patch, writable hugetlbfs
> pages will *always* be dirty? I'm still trying to figure out what ever
> clears that dirty state (in hugetlbfs or anywhere else). Seems like
> hugetlbfs truncates call cancel_dirty_page(), but the comment there
> indicates it's only for truncates.

I'm not so convinced drop_pagecache_sb() semantics have such drastic
effects on usability. It's not a standard API, and it is as of yet
unclear to me how "safe" its semantics are intended to be as a root-only
back door into kernel internals.


On 16.03.2007 [23:13:22 -0700], William Lee Irwin III wrote:
>> Perhaps we should ask what ramfs, tmpfs, et al would do. Or, for that
>> matter, if they suffer from the same issue as Ken Chen identified for
>> hugetlbfs. Perhaps the issue is not hugetlb's dirty state, but
>> drop_pagecache_sb() failing to check the bdi for BDI_CAP_NO_WRITEBACK.
>> Or perhaps what safety guarantees drop_pagecache_sb() is supposed to
>> have or lack.

On Sat, Mar 17, 2007 at 12:37:29PM -0700, Nishanth Aravamudan wrote:
> A good point, and one I hadn't considered. I'm less concerned by the
> drop_pagecache_sb() path (which is /proc/sys/vm/drop_caches, yes?),
> although it appears that it and the FADV_DONTNEED code both end up
> calling into invalidate_mapping_pages(). I'm still pretty new to this
> part of the kernel code, and am trying to follow along as best I can.
> In any case, if the problem were in drop_pagecache_sb(), it seems like
> it wouldn't help the DONTNEED case, since that's a level above the call
> to invalidate_mapping_pages().
> I'll keep looking through the code and thinking, and if anyone has any
> patches they'd like me to test, I'll be glad to.

Well, ramfs, tmpfs, et al don't do this sort of false dirtiness. So
there must be some other method they have of coping, or otherwise, they
let drop_pagecache_sb() have the rather user-hostile semantics our fix
was intended to repair, possibly even intentionally.

Best to wait until Monday so Ken Chen can chime in. Flagging down
whoever has some notion of drop_pagecache_sb()'s intended semantics
esp. wrt. "safety" would also be a good idea here.

It should be clear that the actual code surrounding all this is not so
involved; it's more an issue of clarifying intentions and/or what should
be done in the first place.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
