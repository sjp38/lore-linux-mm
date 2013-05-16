Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BD7AE6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 03:52:09 -0400 (EDT)
From: Oskar Andero <oskar.andero@sonymobile.com>
Date: Thu, 16 May 2013 09:52:05 +0200
Subject: Re: [RFC PATCH 0/2] return value from shrinkers
Message-ID: <20130516075205.GD24072@caracas.corpusers.net>
References: <1368454595-5121-1-git-send-email-oskar.andero@sonymobile.com>
 <20130515160532.c965e92707c354100e25f79b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20130515160532.c965e92707c354100e25f79b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Lekanovic, Radovan" <Radovan.Lekanovic@sonymobile.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>

On 01:05 Thu 16 May     , Andrew Morton wrote:
> On Mon, 13 May 2013 16:16:33 +0200 Oskar Andero <oskar.andero@sonymobile.com> wrote:
> 
> > In a previous discussion on lkml it was noted that the shrinkers use the
> > magic value "-1" to signal that something went wrong.
> > 
> > This patch-set implements the suggestion of instead using errno.h values
> > to return something more meaningful.
> > 
> > The first patch simply changes the check from -1 to any negative value and
> > updates the comment accordingly.
> > 
> > The second patch updates the shrinkers to return an errno.h value instead
> > of -1. Since this one spans over many different areas I need input on what is
> > a meaningful return value. Right now I used -EBUSY on everything for consitency.
> > 
> > What do you say? Is this a good idea or does it make no sense at all?
> 
> I don't see much point in it, really.  Returning an errno implies that
> the errno will eventually be returned to userspace.  But that isn't the
> case, so such a change is somewhat misleading.

Yes. Glauber Costa pointed that out and I agree - errno.h is probably not
the right way to go.

> If we want the capability to return more than a binary yes/no message
> to callers then yes, we could/should enumerate the shrinker return
> values.  But as that is a different concept from errnos, it should be
> done with a different and shrinker-specific namespace.

Agreed, but even if there right now is only a binary return message, is a
hardcoded -1 considered to be acceptable for an interface? IMHO, it is not
very readable nor intuitive for the users of the interface. Why not, as you
mention, add a define or enum in shrinker.h instead, e.g. SHRINKER_STOP or
something.

-Oskar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
