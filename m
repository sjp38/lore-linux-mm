Message-ID: <4518886F.3060001@yahoo.com.au>
Date: Tue, 26 Sep 2006 11:54:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Make invalidate_inode_pages2() work again
References: <20060925231557.32226.66866.stgit@ingres.dsl.sfldmi.ameritech.net>	<45186D4A.70009@yahoo.com.au>	<1159233613.5442.61.camel@lade.trondhjem.org> <20060925184213.11c7387c.akpm@osdl.org>
In-Reply-To: <20060925184213.11c7387c.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Chuck Lever <chucklever@gmail.com>, linux-mm@kvack.org, steved@redhat.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>On Mon, 25 Sep 2006 21:20:13 -0400
>Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>
>
>>On Tue, 2006-09-26 at 09:59 +1000, Nick Piggin wrote:
>>
>>>Chuck Lever wrote:
>>>
>>>
>>>>A recent change to fix a problem with invalidate_inode_pages() has weakened
>>>>the behavior of invalidate_inode_pages2() inadvertently.  Add a flag to
>>>>tell the helper routines when stronger invalidation semantics are desired.
>>>>
>>>>
>>>Question: if invalidate_inode_pages2 cares about not invalidating dirty
>>>pages, how can one avoid the page_count check and it still be correct
>>>(ie. not randomly lose dirty bits in some situations)?
>>>
>>Tests of page_count _suck_ 'cos they are 100% non-specific. Is there no
>>way to set a page flag or something to indicate that the page may have
>>been remapped while we were sleeping?
>>
>
>Its a question of "what are these functions supposed to do"?
>
>I'd suggest:
>
>invalidate_inode_pages() -> best-effort, remove-it-if-it-isn't-busy
>
>truncate_inode_pages() -> guaranteed, data-destroying takedown.
>
>invalidate_inode_pages2() -> Somewhere in between.  Any takers?
>
>I'd suggest "guaranteed, non-data-destroying takedown".  Maybe.  So it
>doesn't remove dirty pages, but it does remove otherwise-busy pages.
>
>As definitions go, that really sucks.
>

What I want to know is, can invalidate_inode_pages2 ever be allowed to
throw out a dirty page?

>I think testing page_count() makes sense for invalidate_inode_pages(),
>because that page is clearly in use by someone for something and we
>shouldn't go and whip it out of pagecache under that someone's feet.  It
>is, after all, "pinned".
>

Definitely.

>For invalidate_inode_pages2(), proper behaviour would be to block until
>whoever is busying that page stops being busy on it.
>
>I perhaps we could do a wake_up(page_waitqueue(page)) in vmscan when it
>drops the ref on a page.  But that would mean that
>invalidate_inode_pages2() would get permanently stuck on a
>permanently-pinned page.
>
>It's a bit of a pickle.  Perhaps we just add the
>invalidate_complete_page2().  That re-adds the direct-io race, which is
>fixable by locking the page in the pagefault handler.  argh.
>

And AFAIKS, it will re add the race where it can be possible to invalidate
a dirty page. Which is fixable by my previous suggestion (having
get_user_pages for write somehow marking the page until put_user_pages).

Not a small job either, especially going through the callers. It will
simplify things though, if we know the page is guaranteed not to be marked
clean until we're finished with it.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
