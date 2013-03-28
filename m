Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id D035F6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 01:34:13 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id c10so2981665wiw.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 22:34:12 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
Date: Thu, 28 Mar 2013 07:34:03 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com>
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

Hi Hugh,

"immediately" say in ~1s after allocation /via krobes/ftrace logs/,=20
and you are correct - that is in case large streaming io in Lustre - =
like 3-4GB/s in read.
ftrace logs (with additional trace points) say page allocated, mark page =
accessed..
and nothing until that page will found in isolate_lru_page in =
shrink_inactive_list=20
/that point to set kprobe/
if someone need a logs i may provide it's as it's easy to collect.=20

But may be that is more generic question when ext4 code, some important =
metadata exist=20
in block device page cache in that case calling lru_page_drain() here =
move these pages
in active LRU so will accessible easy.


On Mar 27, 2013, at 21:24, Hugh Dickins wrote:

> [Cc'ing linux-mm: "buddy cache" here is cache of some ext4 metadata]
>=20
> On Wed, 27 Mar 2013, Theodore Ts'o wrote:
>> Hi Andrew,
>>=20
>> Thanks for your analysis!  Since I'm not a mm developer, I'm not sure
>> what's the best way to more aggressively mark a page as one that we'd
>> really like to keep in the page cache --- whether it's calling
>> lru_add_drain(), or calling activate_page(page), etc.
>>=20
>> So I've added Andrew Morton and Hugh Dickens to the cc list as mm
>> experts in the hopes they could give us some advice about the best =
way
>> to achieve this goal.  Andrew, Hugh, could you give us some quick
>> words of wisdom?
>=20
> Hardly from me: I'm dissatisfied with answer below, Cc'ed linux-mm.
>=20
>>=20
>> Thanks,
>>=20
>> 					- Ted
>> On Mon, Mar 25, 2013 at 04:59:44PM +0400, Andrew Perepechko wrote:
>>> Hello!
>>>=20
>>> Our recent investigation has found that pages from
>>> the buddy cache are evicted too often as compared
>>> to the expectation from their usage pattern. This
>>> introduces additional reads during large writes under
>>> our workload and really hurts overall performance.
>>>=20
>>> ext4 uses find_get_page() and find_or_create_page()
>>> to look for buddy cache pages, but these pages don't
>>> get a chance to become activated until the following
>>> lru_add_drain() call, because mark_page_accessed()
>>> does not activate pages which are not PageLRU().
>>>=20
>>> As can be found from a kprobe-based test, these pages
>>> are often moved on the inactive LRU as a result of
>>> shrink_inactive_list()->lru_add_drain() and immediately
>>> evicted.
>=20
> Not quite like that, I think.
>=20
> Cache pages are intentionally put on the inactive list initially,
> so that streaming I/O does not push out more useful pages: it is
> intentional that the first call to mark_page_accessed() merely
> marks the page referenced, but does not move it to active LRU.
>=20
> You're right that the pagevec confuses things here, but I'm
> surprised if these pages are "immediately evicted": they won't
> be evicted while they remain on a pagevec, and can only be evicted
> after reaching the LRU.  And they should be put on the hot end of
> the inactive LRU, and only evicted once they reach the cold end.
>=20
> But maybe you have lots of dirty or otherwise-un-immediately-evictable
> data pages in between, so that page reclaim reaches these ones too =
soon.
>=20
> IIUC the pages you are discussing here are important metadata pages,
> which you would much prefer to retain longer than streaming data.
>=20
> While I question "immediately evicted", I don't doubt that they
> get evicted sooner than you wish: one way or another, they arrive
> at the cold end of the inactive LRU too soon.
>=20
> You would like a way to mark these as more important to retain than
> data pages: you would like to put them directly on the active list,
> but are frustrated by the pagevec.
>=20
>>>=20
>>> =46rom a quick look into linux-2.6.git, the issue seems
>>> to exist in the current code as well.
>>>=20
>>> A possible and, perhaps, non-optimal solution would be
>>> to call lru_add_drain() each time a buddy cache page
>>> is used.
>=20
> mark_page_accessed() should be enough each time one is actually used,
> but yes, it looks like you need more than that when first added to =
cache.
>=20
> It appears that at the moment you need to do:
>=20
> 	mark_page_accessed(page);	/* to SetPageReferenced */
> 	lru_add_drain();		/* to SetPageLRU */
> 	mark_page_accessed(page);	/* to SetPageActive */
>=20
> but I agree that we would really prefer a filesystem not to have to
> call lru_add_drain().
>=20
> I quite like the idea of
> 	mark_page_accessed(page);
> 	mark_page_accessed(page);
> as a sequence to use on important metadata (nicely reminiscent of
> "sync; sync;"), but maybe not everybody will agree with me on that!
>=20
> As currently implemented, a page is put on to a pagevec specific to
> the LRU it is destined for, and we cannot change that destination
> before it is flushed to that LRU.  But at this moment I cannot see
> a fundamental reason why we should not allow PageActive to be set
> while in the pagevec, and destination LRU adjusted accordingly.
>=20
> However, I could easily be missing something (probably some VM_BUG_ONs
> at the least); and changing this might uncover unwanted side-effects -
> perhaps some code paths which already call mark_page_accessed() twice
> in quick succession unintentionally, and would now be given an Active
> page when Inactive has actually been more appropriate.
>=20
> Though I'd like to come back to this, I am very unlikely to find time
> for it in the near future: perhaps someone else might take it further.
>=20
> Hugh
>=20
>>>=20
>>> Any other suggestions?
>>>=20
>>> Thank you,
>>> Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
