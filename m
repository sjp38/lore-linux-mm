Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2F0CC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:10:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43BF42075B
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 13:10:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="saBskzTk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43BF42075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A01B06B0003; Mon,  5 Aug 2019 09:10:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B1236B0005; Mon,  5 Aug 2019 09:10:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A0676B0006; Mon,  5 Aug 2019 09:10:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5387F6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 09:10:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so46255904pla.18
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 06:10:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iKjp1sxUDmAX2wgfYH2j9XCohNundn8m7dMqKgSLwMI=;
        b=EHaZ+XSOJecMPLq3gJoGSCPPOccFNAt+AYHXvxObeS2KdIfop2ataqc8+B6CNS9m2U
         EHIRvar+OHTIi9GNJqCl6GQ8YsMzRFtomOqs1CqpMeA+rak+cucHzxVI1FNtbjbG16/q
         Wd4sTv4e6pa2HkGibSzJ+aVzSzlGSzPtuVzpuFtaRhuTyjLphV7bU8+itk47n5Xr8K56
         RCwQf7eIK2+uXooeTKAjJwcqees0fYoLiAcoOt6BncuiZQNpW4emwSFt5qn2+DvcMYFE
         wcFdzdPNqkeBsMeoIeSf58LCBqh9K9EClRFUFvKMZrPtgRCXHHXKu3c6Qo/o98mkQONe
         FfJQ==
X-Gm-Message-State: APjAAAX8nJWCBxh0HbPmMtiUGxtwieJoF/QuF9lkT8qP9unj6uj62750
	3IfPuTK3wX/iR33TEIs52vZXw7LXg8kTjv9y2SbPuVikWZj5sj4kOtN7RdKn5ogFhQWpc2LCJUD
	onRnE/e4y2lPdSUVFkV4uA8gTknKq+2NmQu6KWJrTDOCWHV+zSLaz7ujMuOPpFe7LmA==
X-Received: by 2002:a62:27c2:: with SMTP id n185mr62312826pfn.79.1565010656848;
        Mon, 05 Aug 2019 06:10:56 -0700 (PDT)
X-Received: by 2002:a62:27c2:: with SMTP id n185mr62312711pfn.79.1565010655327;
        Mon, 05 Aug 2019 06:10:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565010655; cv=none;
        d=google.com; s=arc-20160816;
        b=XrWgWN6CKxBcuAy2f2wDKKZC6R6Cz3i6ipEmJI5CNAfTkQUK1f8wlzuTSd/FbaztG1
         NT8n5sa1DfEcbZyNuGFZvSCpv6l44uT0ULj15o05OZbkxxEAU7WeKzp8Tx50j3d5eBSS
         HgTYR8zCxhGrkKu+uIN3N3eqQHoiU/8QunAIUKOhU2+I2sOt1vfh7pulCVWTe5KMs2tR
         u+sx/VKde8u6skbP0NF+2Ww93+HVnBT/qXDuSH1uMlma0O968FSCV23th9MHTeVn8p5o
         GgNbo1EepFx3PfhQJnRfp8faHuPRAuB8KGTTmB3e2QLsDhm5Bm5DV1rIxVUaZVqR5SWz
         WYwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iKjp1sxUDmAX2wgfYH2j9XCohNundn8m7dMqKgSLwMI=;
        b=L94Idts9PyB8YglvucxPImE06pmRGGD7Ou8JzT+20HGQNxawzfIB1HRR79ECyl26g1
         0AAq56dra/PZRQ0sAin5ZrnaRBYP84DFGxjW+Kk0eGtsqaXeuCHomnn+WSZq2M9NERi3
         LJwnEjPAtZoOJyImusNACyNXtT/g24XkyMvtSK+uA8DNUJIbZ2R+QXXSGca+ssNn+4rI
         k2P7UlSIBYZrrjbWBnJtLhAMlQbaTBYOMNXORnpc16wpth6vddpS6qT/sRAoJO9P0b/+
         +rSsuRwDIpSB8F4zX/asnfPRsfNXHryuQ7EZKeUlKxP56UOuaQblcDoWX11KnpRXnmeE
         6i2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=saBskzTk;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor38358502pgd.65.2019.08.05.06.10.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 06:10:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=saBskzTk;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iKjp1sxUDmAX2wgfYH2j9XCohNundn8m7dMqKgSLwMI=;
        b=saBskzTkvd5+FOutbmH6Dqo7LDxB6j1lLBCs9c9SMjidr9mCGA3JZWUpgJ24D1jEWP
         BYegX6h+4En4gHMNnjD2hkiM6LzR+gIgnvCH+Qv7kghjhnQ196JBcG8u6X82QA91+dxZ
         AT0bQGPEEfkSIGpd4JlN2XA3pwAzzkgJGuH/g=
X-Google-Smtp-Source: APXvYqz6u3cCDYJg+E3Gaw42gMUYLq5q2x4d2s7eKbbvOoyG04W78eoEyJ1/Ww27pKnvOKH8Zeg+QQ==
X-Received: by 2002:a63:3006:: with SMTP id w6mr14611039pgw.440.1565010654596;
        Mon, 05 Aug 2019 06:10:54 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id d129sm89649753pfc.168.2019.08.05.06.10.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 06:10:53 -0700 (PDT)
Date: Mon, 5 Aug 2019 09:10:52 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Brendan Gregg <bgregg@netflix.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, joaodias@google.com,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	kernel-team@android.com, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	tkjos@google.com, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, wvw@google.com
Subject: Re: [PATCH v3 1/2] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-ID: <20190805131052.GA208558@google.com>
References: <20190726152319.134152-1-joel@joelfernandes.org>
 <20190731085335.GD155569@google.com>
 <20190731171937.GA75376@google.com>
 <20190805075547.GA196934@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805075547.GA196934@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 04:55:47PM +0900, Minchan Kim wrote:
> Hi Joel,

Hi Minchan,

> On Wed, Jul 31, 2019 at 01:19:37PM -0400, Joel Fernandes wrote:
> > > > -static struct page *page_idle_get_page(unsigned long pfn)
> > > > +static struct page *page_idle_get_page(struct page *page_in)
> > > 
> > > Looks weird function name after you changed the argument.
> > > Maybe "bool check_valid_page(struct page *page)"?
> > 
> > 
> > I don't think so, this function does a get_page_unless_zero() on the page as well.
> > 
> > > >  {
> > > >  	struct page *page;
> > > >  	pg_data_t *pgdat;
> > > >  
> > > > -	if (!pfn_valid(pfn))
> > > > -		return NULL;
> > > > -
> > > > -	page = pfn_to_page(pfn);
> > > > +	page = page_in;
> > > >  	if (!page || !PageLRU(page) ||
> > > >  	    !get_page_unless_zero(page))
> > > >  		return NULL;
> > > > @@ -51,6 +49,18 @@ static struct page *page_idle_get_page(unsigned long pfn)
> > > >  	return page;
> > > >  }
> > > >  
> > > > +/*
> > > > + * This function tries to get a user memory page by pfn as described above.
> > > > + */
> > > > +static struct page *page_idle_get_page_pfn(unsigned long pfn)
> > > 
> > > So we could use page_idle_get_page name here.
> > 
> > 
> > Based on above comment, I prefer to keep same name. Do you agree?
> 
> Yes, I agree. Just please add a comment about refcount in the description
> on page_idle_get_page.

Ok.


> > > > +	return page_idle_get_page(pfn_to_page(pfn));
> > > > +}
> > > > +
> > > >  static bool page_idle_clear_pte_refs_one(struct page *page,
> > > >  					struct vm_area_struct *vma,
> > > >  					unsigned long addr, void *arg)
> > > > @@ -118,6 +128,47 @@ static void page_idle_clear_pte_refs(struct page *page)
> > > >  		unlock_page(page);
> > > >  }
> > > >  
> > > > +/* Helper to get the start and end frame given a pos and count */
> > > > +static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
> > > > +				unsigned long *start, unsigned long *end)
> > > > +{
> > > > +	unsigned long max_frame;
> > > > +
> > > > +	/* If an mm is not given, assume we want physical frames */
> > > > +	max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
> > > > +
> > > > +	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
> > > > +		return -EINVAL;
> > > > +
> > > > +	*start = pos * BITS_PER_BYTE;
> > > > +	if (*start >= max_frame)
> > > > +		return -ENXIO;
> > > > +
> > > > +	*end = *start + count * BITS_PER_BYTE;
> > > > +	if (*end > max_frame)
> > > > +		*end = max_frame;
> > > > +	return 0;
> > > > +}
> > > > +
> > > > +static bool page_really_idle(struct page *page)
> > > 
> > > Just minor:
> > > Instead of creating new API, could we combine page_is_idle with
> > > introducing furthere argument pte_check?
> > 
> > 
> > I cannot see in the code where pte_check will be false when this is called? I
> > could rename the function to page_idle_check_ptes() if that's Ok with you.
> 
> What I don't like is _*really*_ part of the funcion name.
> 
> I see several page_is_idle calls in huge_memory.c, migration.c, swap.c.
> They could just check only page flag so they could use "false" with pte_check.

I will rename it to page_idle_check_ptes(). If you want pte_check argument,
that can be a later patch if/when there are other users for it in other
files. Hope that's reasonable.


> > > > +ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
> > > > +			       size_t count, loff_t *pos,
> > > > +			       struct task_struct *tsk, int write)
> > > > +{
> > > > +	int ret;
> > > > +	char *buffer;
> > > > +	u64 *out;
> > > > +	unsigned long start_addr, end_addr, start_frame, end_frame;
> > > > +	struct mm_struct *mm = file->private_data;
> > > > +	struct mm_walk walk = { .pmd_entry = pte_page_idle_proc_range, };
> > > > +	struct page_node *cur;
> > > > +	struct page_idle_proc_priv priv;
> > > > +	bool walk_error = false;
> > > > +	LIST_HEAD(idle_page_list);
> > > > +
> > > > +	if (!mm || !mmget_not_zero(mm))
> > > > +		return -EINVAL;
> > > > +
> > > > +	if (count > PAGE_SIZE)
> > > > +		count = PAGE_SIZE;
> > > > +
> > > > +	buffer = kzalloc(PAGE_SIZE, GFP_KERNEL);
> > > > +	if (!buffer) {
> > > > +		ret = -ENOMEM;
> > > > +		goto out_mmput;
> > > > +	}
> > > > +	out = (u64 *)buffer;
> > > > +
> > > > +	if (write && copy_from_user(buffer, ubuff, count)) {
> > > > +		ret = -EFAULT;
> > > > +		goto out;
> > > > +	}
> > > > +
> > > > +	ret = page_idle_get_frames(*pos, count, mm, &start_frame, &end_frame);
> > > > +	if (ret)
> > > > +		goto out;
> > > > +
> > > > +	start_addr = (start_frame << PAGE_SHIFT);
> > > > +	end_addr = (end_frame << PAGE_SHIFT);
> > > > +	priv.buffer = buffer;
> > > > +	priv.start_addr = start_addr;
> > > > +	priv.write = write;
> > > > +
> > > > +	priv.idle_page_list = &idle_page_list;
> > > > +	priv.cur_page_node = 0;
> > > > +	priv.page_nodes = kzalloc(sizeof(struct page_node) *
> > > > +				  (end_frame - start_frame), GFP_KERNEL);
> > > > +	if (!priv.page_nodes) {
> > > > +		ret = -ENOMEM;
> > > > +		goto out;
> > > > +	}
> > > > +
> > > > +	walk.private = &priv;
> > > > +	walk.mm = mm;
> > > > +
> > > > +	down_read(&mm->mmap_sem);
> > > > +
> > > > +	/*
> > > > +	 * idle_page_list is needed because walk_page_vma() holds ptlock which
> > > > +	 * deadlocks with page_idle_clear_pte_refs(). So we have to collect all
> > > > +	 * pages first, and then call page_idle_clear_pte_refs().
> > > > +	 */
> > > 
> > > Thanks for the comment, I was curious why you want to have
> > > idle_page_list and the reason is here.
> > > 
> > > How about making this /proc/<pid>/page_idle per-process granuariy,
> > > unlike system level /sys/xxx/page_idle? What I meant is not to check
> > > rmap to see any reference from random process but just check only
> > > access from the target process. It would be more proper as /proc/
> > > <pid>/ interface and good for per-process tracking as well as
> > > fast.
> > 
> > 
> > I prefer not to do this for the following reasons:
> > (1) It makes a feature lost, now accesses to shared pages will not be
> > accounted properly. 
> 
> Do you really want to check global attribute by per-process interface?

Pages are inherrently not per-process, they are global. A page does not
necessarily belong to a process. An anonymous page can be shared. We are
operating on pages in the end of the day.

I think you are confusing the per-process file interface with the core
mechanism. The core mechanism always operations on physical PAGES.


> That would be doable with existing idle page tracking feature and that's
> the one of reasons page idle tracking was born(e.g. even, page cache
> for non-mapped) unlike clear_refs.

I think you are misunderstanding the patch, the patch does not want to change
the core mechanism. That is a bit out of scope for the patch. Page
idle-tracking at the core of it looks at PTE of all processes. We are just
using the VFN (virtual frame) interface to skip the need for separate pagemap
look up -- that's it.


> Once we create a new interface by per-process, just checking the process
> -granuariy access check sounds more reasonable to me.

It sounds reasonable but there is no reason to not do the full and proper
page tracking for now, including shared pages. Otherwise it makes it
inconsistent with the existing mechanism and can confuse the user about what
to expect (especially for shared pages).


> With that, we could catch only idle pages of the target process even though
> the page was touched by several other processes.
> If the user want to know global level access point, they could use
> exisint interface(If there is a concern(e.g., security) to use existing
> idle page tracking, let's discuss it as other topic how we could make
> existing feature more useful).
> 
> IOW, my point is that we already have global access check(1. from ptes
> among several processes, 2. from page flag for non-mapped pages) feature
> from from existing idle page tracking interface and now we are about to create
> new interface for per-process wise so I wanted to create a particular
> feature which cannot be covered by existing iterface.

Yes, it sounds like you want to create a different feature. Then that can be
a follow-up different patch, and that is out of scope for this patch.


> > (2) It makes it inconsistent with other idle page tracking mechanism. I
> 
> That's the my comment to create different idle page tracking we couldn't
> do with existing interface.

Yes, sure. But that can be a different patch and we can weigh the benefits of
it at that time. I don't want to introduce a new page tracking mechanism, I
am just trying to reuse the existing one.


> > prefer if post per-process. At the heart of it, the tracking is always at the
> 
> What does it mean "post per-process"?

Sorry it was a typo, I meant "the core mechanism should not be a per-process
one, but a global one". We are just changing the interface in this patch, we
are not changing the existing core mechanism. That gives us all the benefits
of the existing code such as non-interference with page reclaim code, without
introducing any new bugs. By the way I did fix a bug in the existing original
code as well!


> > physical page level -- I feel that is how it should be. Other drawback, is
> > also we have to document this subtlety.
> 
> Sorry, Could you elaborate it a bit?

I meant, with a new mechanism as the one you are proposing, we have to
document that now shared pages will not be tracked properly. That is a
'subtle difference' and will have to be documented appropriated in the
'internals' section of the idle page tracking document.

thanks,

 - Joel

