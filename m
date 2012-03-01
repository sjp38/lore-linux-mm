Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 965466B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 02:30:39 -0500 (EST)
Received: by dakp5 with SMTP id p5so503320dak.8
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 23:30:38 -0800 (PST)
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1202290922210.32268@router.home>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>
	 <alpine.DEB.2.00.1202290922210.32268@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Mar 2012 16:30:31 +0900
Message-ID: <1330587031.1762.46.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Namhyung Kim <namhyung.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

2012-02-29, 09:24 -0600, Christoph Lameter wrote:
> On Wed, 29 Feb 2012, Namhyung Kim wrote:
> 
> > Unlike SLAB, SLUB doesn't set PG_slab on tail pages, so if a user would
> > call free_pages() incorrectly on a object in a tail page, she will get
> > confused with the undefined result. Setting the flag would help her by
> > emitting a warning on bad_page() in such a case.
> 
> NAK
> 
> You cannot free a tail page of a compound higher order page independently.
> You must free the whole compound.
> 

I meant freeing a *slab object* resides in a compound page using buddy
system API (e.g. free_pages). I know it's definitely a programming
error. However there's no safety net to protect and/or warn such a
misbehavior AFAICS - except for head page which has PG_slab set - when
it happened by any chance.

Without it, it might be possible to free part of tail pages silently,
and cause unexpected not-so-funny results some time later. It should be
hard to find out.

When I ran such a bad code using SLAB, I was able to be notified
immediately. That's why I'd like to add this patch to SLUB too. In
addition, it will give more correct value for slab pages when
using /proc/kpageflags IMHO.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
