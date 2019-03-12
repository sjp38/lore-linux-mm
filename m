Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 207D8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:11:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9781214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:11:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9781214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 752D08E0004; Tue, 12 Mar 2019 17:11:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 702868E0002; Tue, 12 Mar 2019 17:11:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F2F48E0004; Tue, 12 Mar 2019 17:11:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33C3A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:11:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k5so3628472qte.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:11:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6D85umQO+3uCuVnh3eG7mrlbQDpMKyiC7PlzHjAJQLM=;
        b=qjJHdyj5RDH41uj2vPM244jFspHUi3Z5EN5xPJsYhM+GR2c0kTG07mw2gpCcvmGId3
         l1IME5ZqCwI5aH8fidCHQV0C6/bReT2kJntAuqw3I7056qOxRaYQNvoVQtqDEP/fjoGO
         AIh5IbU9h7LQr/vpMaBd0PWF88xvs/HelHGKNhcKXtZhLegKQMTPbwMOFqx63Gxm/1pa
         PiKveSCo8b1e7VNhcsDh5YISLFCibtRnHz/uPe2uP6uVWGSwXGko+AaCMzMnK0cQYUCp
         VI+heFAAywMYGLMGAYgVuG6F7AXKaL5mRIySh36vDH21jfhXRjRqN/qp/MAapABy8oqq
         BQPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTPT0UOTc0sM/YLDFM8n9qIgrhombhb0DG3/Gee5RZwpl3PyLS
	OOTFN44RwXxmk3bos+RGMm8pftY+2kveuznnCEnITbNIpjEr3EMOvpzOpz5QfsTnhKCt7yaF0mg
	E8U716pVNAB+p9HjUmryRAxlEuyG4OhjJZl2jtEoXqagF0imLlR2n8jhYV0UAJhOOAQ==
X-Received: by 2002:ac8:3032:: with SMTP id f47mr2834367qte.105.1552425084984;
        Tue, 12 Mar 2019 14:11:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNASPL+BYySwfm8FcukuHitleHAdko2miLlOHj2qmt5JxkSOKC/DHC/WT5NW0CllBAo6bS
X-Received: by 2002:ac8:3032:: with SMTP id f47mr2834329qte.105.1552425084126;
        Tue, 12 Mar 2019 14:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552425084; cv=none;
        d=google.com; s=arc-20160816;
        b=1EICU4bxye2Nyr3DKofp7iMEP3ypCX1HU2X8qQNq6NaV+fCTEkYANK3MsmseS+y8G6
         yV++vfCOtuZVDR8Jay4pJD6i2AGnC/sWL64Ufu+mD6unxZ+cMs84HtJrWKIwSsFpq+Uv
         nw9JdlWzjD6ScQ4/q+F/ISuAKUPLn5u+C5tGnqUDhkgKXMOKLXKNYvJVjAPACwPK88+W
         dEtQxvj+G4Jj9vnkMlI7KseIQgOPUkQ7/RHxFEXlIY5FQqzIbxKpfVrm0QBBQjNoC4DD
         BcXEfAi7ItkadzNs0wdtY3qoCg3vjc4SnYk8LulcOz6FGpW/ySoZf+OT63GvA0VShOWz
         jHtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6D85umQO+3uCuVnh3eG7mrlbQDpMKyiC7PlzHjAJQLM=;
        b=pPrvsyt7YXF0USH+5L6QqCrQyzLVt6fZ6M5r+9A/wPPEoV86fuJoQH6S835ry9i635
         O93pD/rxreHH7lGZp7yWkxYaJHnpwP2vApe33FuNi0yGsIRHfBVLYIkhmCFd7rSzFt7T
         95jeNI/l1ceyFOS/D78L+dFtG2bRigGbg8R1QWSbxGEv66FJTYFDdWRZmqknt/P+DJQv
         8Xlr0K6GfNd/EJBwu0q33kCUWzUaTMPA6XEH0EHVgq/ZlfUt6FwVId3EcME1NkulLTD9
         tdHybYdWntbKC7gD9Evx1+TeYJLXXoPBUGnsVjr8zNemU5SjKdosf9GjQUik72jAPjvN
         dEcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si2723878qvz.176.2019.03.12.14.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3EB26307D844;
	Tue, 12 Mar 2019 21:11:23 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EA5474C3;
	Tue, 12 Mar 2019 21:11:17 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:11:17 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190312211117.GB25147@redhat.com>
References: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552424017.14432.11.camel@HansenPartnership.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 12 Mar 2019 21:11:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 01:53:37PM -0700, James Bottomley wrote:
> I've got to say: optimize what?  What code do we ever have in the
> kernel that kmap's a page and then doesn't do anything with it? You can
> guarantee that on kunmap the page is either referenced (needs
> invalidating) or updated (needs flushing). The in-kernel use of kmap is
> always
> 
> kmap
> do something with the mapped page
> kunmap
> 
> In a very short interval.  It seems just a simplification to make
> kunmap do the flush if needed rather than try to have the users
> remember.  The thing which makes this really simple is that on most
> architectures flush and invalidate is the same operation.  If you
> really want to optimize you can use the referenced and dirty bits on
> the kmapped pte to tell you what operation to do, but if your flush is
> your invalidate, you simply assume the data needs flushing on kunmap
> without checking anything.

Except other archs like arm64 and sparc do the cache flushing on
copy_to_user_page and copy_user_page, not on kunmap.

#define copy_user_page(to,from,vaddr,pg) __cpu_copy_user_page(to, from, vaddr)
void __cpu_copy_user_page(void *kto, const void *kfrom, unsigned long vaddr)
{
	struct page *page = virt_to_page(kto);
	copy_page(kto, kfrom);
	flush_dcache_page(page);
}
#define copy_user_page(to, from, vaddr, page)	\
	do {	copy_page(to, from);		\
		sparc_flush_page_to_ram(page);	\
	} while (0)

And they do nothing on kunmap:

static inline void kunmap(struct page *page)
{
	BUG_ON(in_interrupt());
	if (!PageHighMem(page))
		return;
	kunmap_high(page);
}
void kunmap_high(struct page *page)
{
	unsigned long vaddr;
	unsigned long nr;
	unsigned long flags;
	int need_wakeup;
	unsigned int color = get_pkmap_color(page);
	wait_queue_head_t *pkmap_map_wait;

	lock_kmap_any(flags);
	vaddr = (unsigned long)page_address(page);
	BUG_ON(!vaddr);
	nr = PKMAP_NR(vaddr);

	/*
	 * A count must never go down to zero
	 * without a TLB flush!
	 */
	need_wakeup = 0;
	switch (--pkmap_count[nr]) {
	case 0:
		BUG();
	case 1:
		/*
		 * Avoid an unnecessary wake_up() function call.
		 * The common case is pkmap_count[] == 1, but
		 * no waiters.
		 * The tasks queued in the wait-queue are guarded
		 * by both the lock in the wait-queue-head and by
		 * the kmap_lock.  As the kmap_lock is held here,
		 * no need for the wait-queue-head's lock.  Simply
		 * test if the queue is empty.
		 */
		pkmap_map_wait = get_pkmap_wait_queue_head(color);
		need_wakeup = waitqueue_active(pkmap_map_wait);
	}
	unlock_kmap_any(flags);

	/* do wake-up, if needed, race-free outside of the spin lock */
	if (need_wakeup)
		wake_up(pkmap_map_wait);
}
static inline void kunmap(struct page *page)
{
}

because they already did it just above.


> > Which means after we fix vhost to add the flush_dcache_page after
> > kunmap, Parisc will get a double hit (but it also means Parisc was
> > the only one of those archs needed explicit cache flushes, where
> > vhost worked correctly so far.. so it kinds of proofs your point of
> > giving up being the safe choice).
> 
> What double hit?  If there's no cache to flush then cache flush is a
> no-op.  It's also a highly piplineable no-op because the CPU has the L1
> cache within easy reach.  The only event when flush takes a large
> amount time is if we actually have dirty data to write back to main
> memory.

The double hit is in parisc copy_to_user_page:

#define copy_to_user_page(vma, page, vaddr, dst, src, len) \
do { \
	flush_cache_page(vma, vaddr, page_to_pfn(page)); \
	memcpy(dst, src, len); \
	flush_kernel_dcache_range_asm((unsigned long)dst, (unsigned long)dst + len); \
} while (0)

That is executed just before kunmap:

static inline void kunmap(struct page *page)
{
	flush_kernel_dcache_page_addr(page_address(page));
}

Can't argue about the fact your "safer" kunmap is safer, but we cannot
rely on common code unless we remove some optimization from the common
code abstractions and we make all archs do kunmap like parisc.

Thanks,
Andrea

