Date: Mon, 6 May 2002 18:44:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] dcache and rmap
Message-ID: <20020507014414.GL15756@holomorphy.com>
References: <200205052117.16268.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <200205052117.16268.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 05, 2002 at 09:17:16PM -0400, Ed Tomlinson wrote:
> I got tired of finding my box with 50-60% percent of memory tied up
> in dentry/inode caches every morning after update-db runs or after
> doing a find / -name "*" to generate a list of files for backups.
> So I decided to make a stab at fixing this.

I would only consider this a problem if the size of the cache were so
poorly controlled that it would trigger pageout of in-core user data.
Also, the cacheing algorithm doesn't seem to take into account turnover
rates and expansion rate.. e.g. if turnover is too rapid, expand, if
expansion is too fast, try directly reclaiming largely unused entries.


On Sun, May 05, 2002 at 09:17:16PM -0400, Ed Tomlinson wrote:
> The problem is that when there is not much memory pressure the vm is
> happy to let the above caches expand and expand...  What I did was
> factored the shrink calls out of > do_try_to_free_pages and placed an
> additional call to shrink in kswapd which can get called if kswapd
> does not need to use do_try_to_free_pages.

Well, the VM doesn't really have anything to do with this; it's just a
random structure floating out in filesystem code that needs notification
of when memory gets low to shrink itself. But anyway, all the VM really
cares about is memory is running low and it wants to get some from
somewhere. Bad space behavior is either the cacheing algorithm's fault
or its implementation's.

Abstracting this out to a "cache shrinking driver" might open up useful
possibilities, for instance, dynamic registration for per-object caches.


On Sun, May 05, 2002 at 09:17:16PM -0400, Ed Tomlinson wrote:
> The issue then becomes when to call the new shrink_caches function?
> I changed the dcache logic to estimate and track the number of new
> pages alloced to dentries.  Once a threshold is exceeded, kswapd
> calls shrink_caches. Using a threshold of 32 pages works well here.

Well, I think there are three major design issues. The first is the
magic number of 32 pages. This (compile-time!) tunable is almost
guaranteed not to work for everyone. The second is that in order to
address the issue you're actually concerned about, it seems you would
have to present some method for caches to know their allocation requests
would require evicting other useful data to satisfy; for instance,
evicting pagecache holding useful (but clean) user data to allocate
dcache. Third, the distinguished position of the dcache is suspicious
to me; I feel that a greater degree of generality is in order.

In short, I don't think you went far enough. How do you feel about
GFP_SPECULATIVE (a.k.a. GFP_DONT_TRY_TOO_HARD), cache priorities and
cache shrinking drivers?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
