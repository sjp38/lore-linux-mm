Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFE32C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84DDB21738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:43:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Tv4nwW9q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84DDB21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22C1C8E0003; Tue, 23 Jul 2019 10:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DCC28E0002; Tue, 23 Jul 2019 10:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07C598E0003; Tue, 23 Jul 2019 10:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2A2A8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:43:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y66so26302787pfb.21
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CXJioUohNIJ0NhODmyNgtJL+ymWSK/aS70/EguesA7s=;
        b=skJDbOvgeidWy9KXgdUl/xGzExC7kqjPvJkyL0PmjcHP2ImBjpg/7YQI623ASF/74C
         sLxretdgMFrY9lJwToKdRYWavlKPuXfe3d5FBizcEP4HN5CdgsRS4yvamEPD0ib/BsVo
         9lItbYlBveSKIYB4xPYs9+ax6ZAdoKk0pqCG8jvW2sXDn2426Y4pWZbchfDOKGPOjxgw
         exhaCo+nRy381zEy3d4uVIUtYcLRXrr5lxer9fQNFQaYNrVpelPxEWRkFfxamFNLDfaM
         4mtHm3OL8CthjwKXIDZyancQ2rkCYwLJGAUwwB5xS/U0yww6l6QJb7aCZD42DfYOy+5X
         hg5w==
X-Gm-Message-State: APjAAAWZyKwWEIwYry9CIYRy8NE1auTpIG9Q6FjKoe3ZFHYfR+Q4QR20
	pQ3gMH+nUDIa3bHp+XQJkbzN/vRgvIsRLC1EaYdpTDVEiBnHxLYCqsl6TYtDs2eYiVJ2a+3w+Vo
	QJDASSwjU0yawN56pJcblKzG50I5Q+egA6s2GieNfWe+FRq7cqo0OnouFpG305iFpcA==
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr81792466pji.136.1563893002452;
        Tue, 23 Jul 2019 07:43:22 -0700 (PDT)
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr81792425pji.136.1563893001589;
        Tue, 23 Jul 2019 07:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563893001; cv=none;
        d=google.com; s=arc-20160816;
        b=uVuubmpmU/XWJ7f2LpfEkpuC5OQASKP6dqt4WpZ4CkusgSI+Cutb+6otOLiRauI3sG
         hw/bmI5YplRgWIBk0aS0KMac3hqiggCg9e9gSVNsxsmiqE2E80qKLAk+EUXs/0kxIRIW
         FrU9h46EPEmtH04WwIOQHL8AcnWviU3nPQxy8kCmIxwP6LcyNNOUTKaMJgO3fvNsp3CS
         giYWWx3ksakkBXZkf4CGgLfYaLz46zU10ssJdRWZgTvhfyGAB32GYSSgIT9E7SgIcgUA
         /rdK6QChygnciXyXMgGxrWu5Ke22tE5QAIAanJgoaKJvYXswz4dAfmZKJfZGn3O8/9lL
         cAng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CXJioUohNIJ0NhODmyNgtJL+ymWSK/aS70/EguesA7s=;
        b=Jiy4Hh2Iyb4jCb9xeM2X7JF73dGOoq+3Nq0l/Q1PBknT6WPezT2OzAStKpkT2YsWHp
         89CMczDnryV4PgwcetO/pp02ibCbXGRgbUVyv7lQTnjlCnNCQ8CfSRe56HVkqgGfZ/Q4
         gJNFThLlRlWoICeeXzETfK3g3gLsJChWlwlss5Jj3WhIwD+hTkxLtzDWMRr/pYrzw54K
         Rh7kgylirpRt1XJS+AO4PqyqKCU/jz9BfDuR0e/z0Y3lEC1S5OTDTENgyhhLfZ8XWwNl
         N3+PkgLYHhJ4jhV6JTAV24IM0nOt9RCfSzU4PgPdc+MfIOyD+3th0ZtZUhfCVF3VrczG
         VnKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Tv4nwW9q;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor52130587plt.32.2019.07.23.07.43.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 07:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Tv4nwW9q;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CXJioUohNIJ0NhODmyNgtJL+ymWSK/aS70/EguesA7s=;
        b=Tv4nwW9qgJhM1gi/kpZBvJdAFTNRF7o+uiQbdbJA+CEkh0nwv//1WqBl78VW2pztXN
         6XH3F1oxedjEAfMghwEzZjJalzPyL21+Q3og8Z7lcMpWDls0IhHhwkgjSmZD2Nu0h0gQ
         7qNXpRxPi4soMPYIewpFbmfSmFU3zNV61f93I=
X-Google-Smtp-Source: APXvYqxq0XgaN2rBscmyFhGxyiLm9xRaeQ7cSnaC3QUCLqtyr5vXEKfMewiKHzKVKUeilH0kxvA+mw==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr23521616plp.126.1563893001022;
        Tue, 23 Jul 2019 07:43:21 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id 2sm74645858pgm.39.2019.07.23.07.43.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 07:43:20 -0700 (PDT)
Date: Tue, 23 Jul 2019 10:43:18 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@google.com,
	minchan@kernel.org, namhyung@google.com, sspatil@google.com,
	surenb@google.com, Thomas Gleixner <tglx@linutronix.de>,
	timmurray@google.com, tkjos@google.com,
	Vlastimil Babka <vbabka@suse.cz>, wvw@google.com
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-ID: <20190723144318.GF104199@google.com>
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <20190722150639.27641c63b003dd04e187fd96@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722150639.27641c63b003dd04e187fd96@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:06:39PM -0700, Andrew Morton wrote:
> On Mon, 22 Jul 2019 17:32:04 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > The page_idle tracking feature currently requires looking up the pagemap
> > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > This is quite cumbersome and can be error-prone too. If between
> > accessing the per-PID pagemap and the global page_idle bitmap, if
> > something changes with the page then the information is not accurate.
> 
> Well, it's never going to be "accurate" - something could change one
> nanosecond after userspace has read the data...
> 
> Presumably with this approach the data will be "more" accurate.  How
> big a problem has this inaccuracy proven to be in real-world usage?

Has proven to be quite a thorn. But the security issue is the main problem..

> > More over looking up PFN from pagemap in Android devices is not
> > supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> > the PFN.

..as mentioned here.

I should have emphasized on the security issue more, will do so in the next
revision.

> > This patch adds support to directly interact with page_idle tracking at
> > the PID level by introducing a /proc/<pid>/page_idle file. This
> > eliminates the need for userspace to calculate the mapping of the page.
> > It follows the exact same semantics as the global
> > /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> > where looking up PFN is not needed and also does not require SYS_ADMIN.
> > It ended up simplifying userspace code, solving the security issue
> > mentioned and works quite well. SELinux does not need to be turned off
> > since no pagemap look up is needed.
> > 
> > In Android, we are using this for the heap profiler (heapprofd) which
> > profiles and pin points code paths which allocates and leaves memory
> > idle for long periods of time.
> > 
> > Documentation material:
> > The idle page tracking API for virtual address indexing using virtual page
> > frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
> > that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
> > except that it uses virtual instead of physical frame numbers.
> > 
> > This idle page tracking API can be simpler to use than physical address
> > indexing, since the pagemap for a process does not need to be looked up
> > to mark or read a page's idle bit. It is also more accurate than
> > physical address indexing since in physical address indexing, address
> > space changes can occur between reading the pagemap and reading the
> > bitmap. In virtual address indexing, the process's mmap_sem is held for
> > the duration of the access.
> > 
> > ...
> >
> > --- a/mm/page_idle.c
> > +++ b/mm/page_idle.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/page_ext.h>
> >  #include <linux/page_idle.h>
> > +#include <linux/sched/mm.h>
> >  
> >  #define BITMAP_CHUNK_SIZE	sizeof(u64)
> >  #define BITMAP_CHUNK_BITS	(BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
> > @@ -28,15 +29,12 @@
> >   *
> >   * This function tries to get a user memory page by pfn as described above.
> >   */
> 
> Above comment needs updating or moving?
> 
> > -static struct page *page_idle_get_page(unsigned long pfn)
> > +static struct page *page_idle_get_page(struct page *page_in)
> >  {
> >  	struct page *page;
> >  	pg_data_t *pgdat;
> >  
> > -	if (!pfn_valid(pfn))
> > -		return NULL;
> > -
> > -	page = pfn_to_page(pfn);
> > +	page = page_in;
> >  	if (!page || !PageLRU(page) ||
> >  	    !get_page_unless_zero(page))
> >  		return NULL;
> >
> > ...
> >
> > +static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
> > +				unsigned long *start, unsigned long *end)
> > +{
> > +	unsigned long max_frame;
> > +
> > +	/* If an mm is not given, assume we want physical frames */
> > +	max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
> > +
> > +	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
> > +		return -EINVAL;
> > +
> > +	*start = pos * BITS_PER_BYTE;
> > +	if (*start >= max_frame)
> > +		return -ENXIO;
> 
> Is said to mean "The system tried to use the device represented by a
> file you specified, and it couldnt find the device.  This can mean that
> the device file was installed incorrectly, or that the physical device
> is missing or not correctly attached to the computer."
> 
> This doesn't seem appropriate in this usage and is hence possibly
> misleading.  Someone whose application fails with ENXIO will be
> scratching their heads.

This actually keeps it consistent with the current code. I refactored that
code a bit and I'm reusing parts of it to keep lines of code less. See
page_idle_bitmap_write where it returns -ENXIO in current upstream.

However note that I am actually returning 0 if page_idle_bitmap_write()
returns -ENXIO:

+	ret = page_idle_get_frames(pos, count, NULL, &pfn, &end_pfn);
+	if (ret == -ENXIO)
+		return 0;  /* Reads beyond max_pfn do nothing */

The reason I do it this way is, I am using page_idle_get_frames() in the old
code and the new code, a bit confusing I know! But it is the cleanest way I
could find to keep this code common.

> > +	*end = *start + count * BITS_PER_BYTE;
> > +	if (*end > max_frame)
> > +		*end = max_frame;
> > +	return 0;
> > +}
> > +
> >
> > ...
> >
> > +static void add_page_idle_list(struct page *page,
> > +			       unsigned long addr, struct mm_walk *walk)
> > +{
> > +	struct page *page_get;
> > +	struct page_node *pn;
> > +	int bit;
> > +	unsigned long frames;
> > +	struct page_idle_proc_priv *priv = walk->private;
> > +	u64 *chunk = (u64 *)priv->buffer;
> > +
> > +	if (priv->write) {
> > +		/* Find whether this page was asked to be marked */
> > +		frames = (addr - priv->start_addr) >> PAGE_SHIFT;
> > +		bit = frames % BITMAP_CHUNK_BITS;
> > +		chunk = &chunk[frames / BITMAP_CHUNK_BITS];
> > +		if (((*chunk >> bit) & 1) == 0)
> > +			return;
> > +	}
> > +
> > +	page_get = page_idle_get_page(page);
> > +	if (!page_get)
> > +		return;
> > +
> > +	pn = kmalloc(sizeof(*pn), GFP_ATOMIC);
> 
> I'm not liking this GFP_ATOMIC.  If I'm reading the code correctly,
> userspace can ask for an arbitrarily large number of GFP_ATOMIC
> allocations by doing a large read.  This can potentially exhaust page
> reserves which things like networking Rx interrupts need and can make
> this whole feature less reliable.

Ok, I will look into this more and possibly do the allocation another way.
spinlocks are held hence I use GFP_ATOMIC..

thanks,

 - Joel

