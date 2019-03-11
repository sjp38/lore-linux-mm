Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18988C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C809F206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:48:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C809F206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 519BA8E0003; Mon, 11 Mar 2019 08:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A2F48E0002; Mon, 11 Mar 2019 08:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344478E0003; Mon, 11 Mar 2019 08:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06F6F8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:48:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id i3so5060137qtc.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:48:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=PGJ8zbf+GI7ZC/qAnsaCLtDgJXBhsk00TKBeRn8gflg=;
        b=VqMTLkeumgIrxH+fRm9A2SzZVBkk9qX/+ehP91yQZ4y+wi5xvV55BiBvksnUdLW+1L
         nDb/qkqSbMDAkcLPvdGe2EVoZxRcM+2sDvLC2AEp67eutZ3I5GA5aWu+RQzxAoKdFGl8
         kZaPtO5BvIqkbv7l2ic6d6ql0LqbS0ak6oeYtqA8GQQLYMVFQ3/mou06JJKdBdHI+nCI
         DmAESCpXpOwljZofW1m9O2mQrvsrWysZQYt+7LSaFtsNSlMoWV4kJXjLgSFfUtvoUFxr
         Xk1qbb1viDFl5QIQGlV5VTf1ttD+UkO/Prl72FF41unLvQFhn+y34+c/jzcN5onV4FJi
         G11A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQ/DoI5OS8/K5yzcEn3kqpd5RODedrad0Exmojcl+EUbp672hg
	ygZ11UYrNbl/wIEMHTL4ySWo9mulHeuw443Ut2R8VB1g7jnJx+xykO+L4O6+GDsPicdF5ecNKpi
	ziQtcvb9MaEtvqHzIYAmn0X+MvagpbiMpj5atKYSDq/6foUXrca94hAoWxcc+uQLm6x5+7E8BQy
	kXt0tZGy2/XQqv7qsdv63ZysXuvumwg8nCG5XTdnrj98g1PBE4GH6deBoyazHRC1BvRV1PwXSNE
	gvz///IuImHrjP8wKlhUP5i32yTnfel+KB4kyhHjBfq0rAc43m9dTD7S7Gb2hjTDtOg/6k9KUxr
	IAmrtWgkq5vQSFfTNrhBFx6f5dXMIeXQ5KHULnezv8eLXKlGwluRHkYxXzR8f0NfBSludEsGtdb
	5
X-Received: by 2002:a37:b105:: with SMTP id a5mr23751321qkf.298.1552308522755;
        Mon, 11 Mar 2019 05:48:42 -0700 (PDT)
X-Received: by 2002:a37:b105:: with SMTP id a5mr23751270qkf.298.1552308521768;
        Mon, 11 Mar 2019 05:48:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552308521; cv=none;
        d=google.com; s=arc-20160816;
        b=Btidj2e3w1RalybhFgRpaGe9QRaEMG1/bl7o8JufSry70425d00qnBiUgQM0EX7bmA
         bhg/mVVjhZp4HZbh3SNhjmAg4hKRwnCMSRc5isBnO9ti2Sb0IuYhEt6wt7FLSfQCWjGE
         ddd/EFc9r1vPcDTu8tgOamftw5aDzP/zXANAN9RGyaEkj8x28f4+bftceQxX4Je10sKJ
         AsGZF9EIxJPr9657ILLVrlj/b+K5BBLxS/P96CSAy3k5yNqSa8nMMskEBq7qyRSOgxb6
         7fMOwvpUe7WScamQRsm8za9LqRVRCfxkEGfYjqh8uvmUI0Ob34KCqdmyWEeER35LvvVh
         c/Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=PGJ8zbf+GI7ZC/qAnsaCLtDgJXBhsk00TKBeRn8gflg=;
        b=qEzPwh9Z0Scv79GcYtJiO9FpMqelGi1Ygdqv7yLX1t9dy8qwNqLLXZ6s3ak8eHnJU/
         zS3dDmzRrep3HNTvdXAwYU45AH1ZWkEmTMul7aq9uOL/tO27VZ8BFMZRppK/aiiAnDbc
         O4ddFuS8YlhBKYuInydyUSNcLvRdTqLYi3i3xVOfob6WU/3zet/HAvtTA3Vto5PBBlcd
         9BmLBH50wfrB3n70v2hruUSQdHiDjkXHqhS5uI28K6nqSKIBMoq4j9ZXseYre0j6eVM1
         6Zka2PYk+jYBJ4A5diKuoNmTOBa44HcTZQQtgJpVXaN+Km4/3JZPMUmQrs3lWfx/eHvw
         VgYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor5906130qvc.35.2019.03.11.05.48.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 05:48:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxitHgoNrrmoC1MNnHg0e8hERINGOglRw7Z0VJ/zXaiPKexOixiLmMkua/cdJCvwC/0bEHapg==
X-Received: by 2002:a0c:d849:: with SMTP id i9mr1325157qvj.207.1552308520546;
        Mon, 11 Mar 2019 05:48:40 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id l6sm3005169qkc.36.2019.03.11.05.48.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 05:48:39 -0700 (PDT)
Date: Mon, 11 Mar 2019 08:48:37 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190311084525-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
 <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8b68a2a0-907a-15f5-a07f-fc5b53d7ea19@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 03:40:31PM +0800, Jason Wang wrote:
> 
> On 2019/3/9 上午3:48, Andrea Arcangeli wrote:
> > Hello Jeson,
> > 
> > On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
> > > Just to make sure I understand here. For boosting through huge TLB, do
> > > you mean we can do that in the future (e.g by mapping more userspace
> > > pages to kenrel) or it can be done by this series (only about three 4K
> > > pages were vmapped per virtqueue)?
> > When I answered about the advantages of mmu notifier and I mentioned
> > guaranteed 2m/gigapages where available, I overlooked the detail you
> > were using vmap instead of kmap. So with vmap you're actually doing
> > the opposite, it slows down the access because it will always use a 4k
> > TLB even if QEMU runs on THP or gigapages hugetlbfs.
> > 
> > If there's just one page (or a few pages) in each vmap there's no need
> > of vmap, the linearity vmap provides doesn't pay off in such
> > case.
> > 
> > So likely there's further room for improvement here that you can
> > achieve in the current series by just dropping vmap/vunmap.
> > 
> > You can just use kmap (or kmap_atomic if you're in preemptible
> > section, should work from bh/irq).
> > 
> > In short the mmu notifier to invalidate only sets a "struct page *
> > userringpage" pointer to NULL without calls to vunmap.
> > 
> > In all cases immediately after gup_fast returns you can always call
> > put_page immediately (which explains why I'd like an option to drop
> > FOLL_GET from gup_fast to speed it up).
> > 
> > Then you can check the sequence_counter and inc/dec counter increased
> > by _start/_end. That will tell you if the page you got and you called
> > put_page to immediately unpin it or even to free it, cannot go away
> > under you until the invalidate is called.
> > 
> > If sequence counters and counter tells that gup_fast raced with anyt
> > mmu notifier invalidate you can just repeat gup_fast. Otherwise you're
> > done, the page cannot go away under you, the host virtual to host
> > physical mapping cannot change either. And the page is not pinned
> > either. So you can just set the "struct page * userringpage = page"
> > where "page" was the one setup by gup_fast.
> > 
> > When later the invalidate runs, you can just call set_page_dirty if
> > gup_fast was called with "write = 1" and then you clear the pointer
> > "userringpage = NULL".
> > 
> > When you need to read/write to the memory
> > kmap/kmap_atomic(userringpage) should work.
> 
> 
> Yes, I've considered kmap() from the start. The reason I don't do that is
> large virtqueue may need more than one page so VA might not be contiguous.
> But this is probably not a big issue which just need more tricks in the
> vhost memory accessors.
> 
> 
> > 
> > In short because there's no hardware involvement here, the established
> > mapping is just the pointer to the page, there is no need of setting
> > up any pagetables or to do any TLB flushes (except on 32bit archs if
> > the page is above the direct mapping but it never happens on 64bit
> > archs).
> 
> 
> I see, I believe we don't care much about the performance of 32bit archs (or
> we can just fallback to copy_to_user() friends).

Using copyXuser is better I guess.

> Using direct mapping (I
> guess kernel will always try hugepage for that?) should be better and we can
> even use it for the data transfer not only for the metadata.
> 
> Thanks

We can't really. The big issue is get user pages. Doing that on data
path will be slower than copyXuser. Or maybe it won't with the
amount of mitigations spread around. Go ahead and try.


> 
> > 
> > Thanks,
> > Andrea

