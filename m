Date: Mon, 25 Nov 2002 08:37:59 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: [PATCH] Really start using the page walking API
Message-ID: <20021125083759.G5263@nightmaster.csn.tu-chemnitz.de>
References: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Sun, Nov 24, 2002 at 11:34:49PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
hi lkmm,

On Sun, Nov 24, 2002 at 11:34:49PM +0100, Ingo Oeser wrote:
> First: make_pages_present() would do an infinite recursion, if
>    used in find_extend_vma(). I fixed this. Might as well have
>    caused the ntp crash, that has been observed. 
>    So these make_pages_present parts are really important.

Ok, I looked deeper and saw, that the original code had the same
"problem", but it was always ensured, that this recursion is not
triggered.

find_extend_vma() returns right before calling make_pages_present(), if
that vma is not a growable stack. For the second call of
find_extend_vma() (in old get_user_pages() code) this vma has
already been successfully grown, so recursion is limited to one
level and it works by magic ;-)

My latest patch just made that more explicit, by passing the vma
directly from the make_pages_present caller down to the
walk_user_pages() and thus skipping the vma search.

If sth. goes wrong we still catch the BUG_ON() checks, so no harm
will be done to data.

In short: I made deep magic more visible here and reduced stack
   usage again. But I did NOT fix the ntp BUG, because it wasn't
   caused by this code.

Regards
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
