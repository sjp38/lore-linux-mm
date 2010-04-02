Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C97E56B01F4
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 11:08:42 -0400 (EDT)
Date: Fri, 2 Apr 2010 16:01:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH] __isolate_lru_page:skip unneeded "not"
Message-Id: <20100402160125.87ebb3ba.akpm@linux-foundation.org>
In-Reply-To: <y2tcf18f8341004021525wa44a76ev8f4372a7191e0240@mail.gmail.com>
References: <1270129055-3656-1-git-send-email-lliubbo@gmail.com>
	<20100402150511.6f71fbfd.akpm@linux-foundation.org>
	<y2tcf18f8341004021525wa44a76ev8f4372a7191e0240@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Sat, 3 Apr 2010 06:25:08 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> >> -	/*
> >> -	 * When checking the active state, we need to be sure we are
> >> -	 * dealing with comparible boolean values.  Take the logical not
> >> -	 * of each.
> >> -	 */
> >
> > You deleted a spelling mistake too!
> >
> >> -	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> >> -		return ret;
> >> -
> >> -	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
> >> -		return ret;
> >> +	if (mode != ISOLATE_BOTH) {
> >> +		if ((PageActive(page) != mode) ||
> >> +			(page_is_file_cache(page) != file))
> >> +				return ret;
> >> +	}
> >
> > The compiler should be able to avoid testing for ISOLATE_BOTH twice,
> 
> Thanks for your kindly reply.
> then is the two "not" able to avoid by the compiler ?
> if yes, this patch is meanless and should be ignore.

I very much doubt if the compiler knows that these two variables can
only ever have values 0 or 1, so I expect that removing the !'s will
reduce text size.

That being said, it wouldn't be a good and maintainable change - 
one point in using enumerations such as ISOLATE_* is to hide their real
values.  Adding code which implicitly "knows" that a particular
enumerated identifier has a particular underlying value is rather
grubby and fragile.

But the code's already doing that.

It's also a bit fragile to assume that a true/false-returning C
function (PageActive) will always return 0 or 1.  It's a common C idiom
for such functions to return 0 or non-zero (not necessarily 1).


So a clean and maintainable implementation of

	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
		return ret;

would be

	if (mode != ISOLATE_BOTH &&
			((PageActive(page) && mode == ISOLATE_ACTIVE) ||
			 (!PageActive(page) && mode == ISOLATE_INACTIVE)))
		return ret;

which is just dying for an optimisation trick such as the one which is
already there ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
