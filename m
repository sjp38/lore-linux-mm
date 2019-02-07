Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89144C169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:26:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21BD62175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:26:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21BD62175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F9F78E000D; Wed,  6 Feb 2019 20:26:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A98B8E0002; Wed,  6 Feb 2019 20:26:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 671E18E000D; Wed,  6 Feb 2019 20:26:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39D8A8E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 20:26:47 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z126so8152844qka.10
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 17:26:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=GV7jRzryx4h4elQUlhKrt3qkVD48To0IwEujXST8aHo=;
        b=AIePp6u4peJ/uZ/sTEl9ve0tDDXittdt7rxJqYgba+ZPR4cCzdSYC3kLrGD3HduZ2x
         Ct0qKXxN87B6lZi2Uh8SSBKLWdk8JKaY0RtaYO251cdibXW8s3u8UWf5KM6o4rwUh8iT
         nSPal1FuagA2afD/CYaJjLsCjevZRO8a2Fapviyg937gAJfNjV0vbvlDHwbzXawAwDKf
         nnanvfN4ewulUxCmf8/W0NoNsQmMzY/crvOVxzSGyJdJD37YgMSZOBgQs0+BZvDY0JC3
         XsAP2J5RPcUmQy14noM3Vbmchn5zsnkCG36e82/qr+pEI1mDdzRopCtQnXrgQAFVxuAp
         IUrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaYOTCtPFTdBzr7zDOm5ARvDqO7k5k0aZt0Uv+cRAu3CUeLsGih
	OQSFQbbAAH6uuBYdBOK/oF4RCA7RpBe74ouRFiPWLTMjZK5L1SZY3xxdAROWQJX6es/RYAsDiXk
	yLx1p5ipilJJ9lZR0gA9ubsTt77yzPVXv4l5ha1+fkXYOxKmv+D60wl3YyUsf+MRH8Q==
X-Received: by 2002:a37:2f44:: with SMTP id v65mr9941143qkh.191.1549502806919;
        Wed, 06 Feb 2019 17:26:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZXhtRrJQcRLIKmxC1rYSWOzK/0xYcuFXZZcgEdWVHTtVdCBTNA2x/+WQWW56D6p6RNjxBM
X-Received: by 2002:a37:2f44:: with SMTP id v65mr9941100qkh.191.1549502806050;
        Wed, 06 Feb 2019 17:26:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549502806; cv=none;
        d=google.com; s=arc-20160816;
        b=FnHxzxnz8fmxaNbcAUw7KtaKD7edLYYDceFOP7AZU5t1BX4bDvpmxsxeLQgbhpNc9g
         LO+B+AGCKE9gRfww5oJmFVUOb99/0eP0o7VCmjmpDfaSFmr6pSb3FAb0w3bUb/7mBtEt
         0xae2hLOA077n2Cn5f+Bw9flpqL3B3oRRZtvqSy9fHXY5O6gGJtJNi50pMLgpNhhejuq
         EAQ/tHtE9sZxKbN+/tB5I8D135YY9oVE7WpzKswohVGWu5fdU3o05+LzKaUykEi69JnQ
         AkjR12PzZp4Bp+LzoXROa2u+Q70D30/vEDbFpI4AJZrOZHpG+z6wI5MXtnD2ki9+T5gH
         7C8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=GV7jRzryx4h4elQUlhKrt3qkVD48To0IwEujXST8aHo=;
        b=G3sNs9FzvO6krny5wZ1AXvenW7dBIXdvaCq56+wTtNKNee4VN3yI4iIBoTZrJxgOj0
         MTl+xdfijb+E+EfpYgivrx12rxg6A8gAfLCMUgqr2j6KJ80bIIH7Qeoht3bBTSql03Yz
         WxQ3OpVstD10nbNey9f83AfLkgbRmtMqoenEg//bSG9fZgl233ap9hL7q6NO1BHhjaDE
         CUdN318Y08PlJivpENT2wVDzQ74E0YkH3XijWCdYqUODpcKT8WgYTLmrP6utGQKImO5t
         +xn0n06/kB5xxkP4VzzV8CuSQuUVSu6bkqJn7XjXxs9VEbhGJNdnbSiLXfm2rLN0Qreg
         n2Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l12si2684014qtj.387.2019.02.06.17.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 17:26:46 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C663C002970;
	Thu,  7 Feb 2019 01:26:44 +0000 (UTC)
Received: from redhat.com (ovpn-120-253.rdu2.redhat.com [10.10.120.253])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4008E6A526;
	Thu,  7 Feb 2019 01:26:43 +0000 (UTC)
Date: Wed, 6 Feb 2019 20:26:42 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Julien Freche <jfreche@vmware.com>,
	Jason Wang <jasowang@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH 3/6] mm/balloon_compaction: list interfaces
Message-ID: <20190206202628-mutt-send-email-mst@kernel.org>
References: <20190206235706.4851-1-namit@vmware.com>
 <20190206235706.4851-4-namit@vmware.com>
 <20190206191936-mutt-send-email-mst@kernel.org>
 <0DFA5F3F-8358-4268-83C7-9937C5F0CFFF@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0DFA5F3F-8358-4268-83C7-9937C5F0CFFF@vmware.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 07 Feb 2019 01:26:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 12:43:51AM +0000, Nadav Amit wrote:
> > On Feb 6, 2019, at 4:32 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > 
> > On Wed, Feb 06, 2019 at 03:57:03PM -0800, Nadav Amit wrote:
> >> Introduce interfaces for ballooning enqueueing and dequeueing of a list
> >> of pages. These interfaces reduce the overhead of storing and restoring
> >> IRQs by batching the operations. In addition they do not panic if the
> >> list of pages is empty.
> >> 
> 
> [Snip]
> 
> First, thanks for the quick feedback.
> 
> >> +
> >> +/**
> >> + * balloon_page_list_enqueue() - inserts a list of pages into the balloon page
> >> + *				 list.
> >> + * @b_dev_info: balloon device descriptor where we will insert a new page to
> >> + * @pages: pages to enqueue - allocated using balloon_page_alloc.
> >> + *
> >> + * Driver must call it to properly enqueue a balloon pages before definitively
> >> + * removing it from the guest system.
> >> + */
> >> +void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> >> +			       struct list_head *pages)
> >> +{
> >> +	struct page *page, *tmp;
> >> +	unsigned long flags;
> >> +
> >> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> >> +	list_for_each_entry_safe(page, tmp, pages, lru)
> >> +		balloon_page_enqueue_one(b_dev_info, page);
> >> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> > 
> > As this is scanning pages one by one anyway, it will be useful
> > to have this return the # of pages enqueued.
> 
> Sure.
> 
> > 
> >> +}
> >> +EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
> >> +
> >> +/**
> >> + * balloon_page_list_dequeue() - removes pages from balloon's page list and
> >> + *				 returns a list of the pages.
> >> + * @b_dev_info: balloon device decriptor where we will grab a page from.
> >> + * @pages: pointer to the list of pages that would be returned to the caller.
> >> + * @n_req_pages: number of requested pages.
> >> + *
> >> + * Driver must call it to properly de-allocate a previous enlisted balloon pages
> >> + * before definetively releasing it back to the guest system. This function
> >> + * tries to remove @n_req_pages from the ballooned pages and return it to the
> >> + * caller in the @pages list.
> >> + *
> >> + * Note that this function may fail to dequeue some pages temporarily empty due
> >> + * to compaction isolated pages.
> >> + *
> >> + * Return: number of pages that were added to the @pages list.
> >> + */
> >> +int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> >> +			       struct list_head *pages, int n_req_pages)
> > 
> > Are we sure this int never overflows? Why not just use u64
> > or size_t straight away?
> 
> size_t it is.
> 
> > 
> >> +{
> >> +	struct page *page, *tmp;
> >> +	unsigned long flags;
> >> +	int n_pages = 0;
> >> +
> >> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> >> +	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> >> +		/*
> >> +		 * Block others from accessing the 'page' while we get around
> >> +		 * establishing additional references and preparing the 'page'
> >> +		 * to be released by the balloon driver.
> >> +		 */
> >> +		if (!trylock_page(page))
> >> +			continue;
> >> +
> >> +		if (IS_ENABLED(CONFIG_BALLOON_COMPACTION) &&
> >> +		    PageIsolated(page)) {
> >> +			/* raced with isolation */
> >> +			unlock_page(page);
> >> +			continue;
> >> +		}
> >> +		balloon_page_delete(page);
> >> +		__count_vm_event(BALLOON_DEFLATE);
> >> +		unlock_page(page);
> >> +		list_add(&page->lru, pages);
> >> +		if (++n_pages >= n_req_pages)
> >> +			break;
> >> +	}
> >> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> >> +
> >> +	return n_pages;
> >> +}
> >> +EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
> >> +
> > 
> > This looks quite reasonable. In fact virtio can be reworked to use
> > this too and then the original one can be dropped.
> > 
> > Have the time?
> 
> Obviously not, but I am willing to make the time. What I cannot “make" is an
> approval to send patches for other hypervisors. Let me run a quick check
> with our FOSS people here.
> 
> Anyhow, I hope it would not prevent the patches from getting to the next
> release.
> 

No, that's not a blocker.

-- 
MST

