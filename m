Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B34276B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 19:24:36 -0500 (EST)
Subject: Re: [patch] slub: fix a code merge error
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
References: <1320912260.22361.247.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111101218140.21036@chino.kir.corp.google.com>
	 <CAOJsxLH7Fss8bBR+ERBOsb=1ZbwbLi+EkS-7skC1CbBmkMpvKA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Nov 2011 08:33:48 +0800
Message-ID: <1320971628.22361.248.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>

On Fri, 2011-11-11 at 04:30 +0800, Pekka Enberg wrote:
> On Thu, Nov 10, 2011 at 10:18 PM, David Rientjes <rientjes@google.com> wrote:
> > On Thu, 10 Nov 2011, Shaohua Li wrote:
> >
> >> Looks there is a merge error in the slub tree. DEACTIVATE_TO_TAIL != 1.
> >> And this will cause performance regression.
> >>
> >> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> >>
> >> diff --git a/mm/slub.c b/mm/slub.c
> >> index 7d2a996..60e16c4 100644
> >> --- a/mm/slub.c
> >> +++ b/mm/slub.c
> >> @@ -1904,7 +1904,8 @@ static void unfreeze_partials(struct kmem_cache *s)
> >>                               if (l == M_PARTIAL)
> >>                                       remove_partial(n, page);
> >>                               else
> >> -                                     add_partial(n, page, 1);
> >> +                                     add_partial(n, page,
> >> +                                             DEACTIVATE_TO_TAIL);
> >>
> >>                               l = m;
> >>                       }
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> >
> > Not sure where the "merge error" is, though, this is how it was proposed
> > on linux-mm each time the patch was posted.  Probably needs a better title
> > and changelog.
> 
> Indeed. Please resend with proper subject and changelog with
> Christoph's and David's ACKs included.

Subject: slub: use correct parameter to add a page to partial list tail

unfreeze_partials() needs add the page to partial list tail, since such page
hasn't too many free objects. We now explictly use DEACTIVATE_TO_TAIL for this,
while DEACTIVATE_TO_TAIL != 1. This will cause performance regression (eg, more
lock contention in node->list_lock) without below fix.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: David Rientjes <rientjes@google.com>

diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..60e16c4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1904,7 +1904,8 @@ static void unfreeze_partials(struct kmem_cache *s)
 				if (l == M_PARTIAL)
 					remove_partial(n, page);
 				else
-					add_partial(n, page, 1);
+					add_partial(n, page,
+						DEACTIVATE_TO_TAIL);
 
 				l = m;
 			}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
