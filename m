Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2AE2C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:13:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74159208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bHsPjAAR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74159208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1BD6B0005; Fri,  7 Jun 2019 15:13:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E29C26B0006; Fri,  7 Jun 2019 15:13:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA3EF6B000A; Fri,  7 Jun 2019 15:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A44246B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:13:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z16so2689944qto.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:13:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=L5u/Ewjt5chLxfL8rJhTxjnnE9xyDskU5p/CRtJxiWk=;
        b=DdiI99i/Wh5IWbEy5qN78rWPlfbyxqfauTkciAfU4EmM74xFSOA9fZKL4JLOFL/gq5
         8hne1nwK2P8se3QPwxbVwlCCzEoalxHRXLktN/5c7q2w5Cw8iEdzqVJ4I+JlMQYch893
         bLjDB03oEAmrc4lGR/UDSPVd/s+PMGzz3AuJHQzsRRzfSleGj0azAaSlnZXhANj+rnQ/
         pK+LR1DGdE/tmOnC13xhZMdwfits1YINiMJ6ab4toYOdImADf78OE+0q13Mf3ivuY4za
         87oMgkqxuMyWLQbUbeUSB61HENPNQPpNZkB1fa0GQlttKIFu3pA2zY+umaAyKJvszX8g
         JeJg==
X-Gm-Message-State: APjAAAU7iYcW+eCwJdcokSDidXfzFFCVF/zWy+TDhvGP0ROZZc3vnrB/
	ggGP+Tkg37ZSWPQfsTcZsD6B61z49Jyh0I6GLqReDMfZ3k3TkxqKDiH81KHsZ+eRZVgIKtsu3Vc
	88ohVkkvBywLBiC0niZMsWCX3lgJotfiFQCzZRtezrKevTdw7EiubK46radgouw4mDQ==
X-Received: by 2002:aed:3e1d:: with SMTP id l29mr34747254qtf.175.1559934784379;
        Fri, 07 Jun 2019 12:13:04 -0700 (PDT)
X-Received: by 2002:aed:3e1d:: with SMTP id l29mr34747218qtf.175.1559934783849;
        Fri, 07 Jun 2019 12:13:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559934783; cv=none;
        d=google.com; s=arc-20160816;
        b=pgklJJSubWgP4E/gE1jsRaTBSVA5mTHivhCo3v2HZ4UXOoSCsKx59hoKf/OkalkBIA
         SYbAtEr2ShfdSoJ84ONhzcQZFVF+lHlYYDoGZxsTY70P58Si277dA/1SxhWmnpHVfeI9
         Uhlqp/lmpN0mJH9za+giau0pEiVNQFl6rvNyxp8XG/7cFkXlcSJwQUh7c7ysf7fKRase
         I9fVVgXxlsEgF6BkjTywvJVZHdZl0zwERSUW3lLSPMp38/qCu5obhcY1F/mtwQ3PsTBV
         MDEwiiXMLMw11FYfakFuUuGQ6ZtsOlqKEsLQ4IQy1ttfEq2PKkPgCEghrpvdtK/5QA8p
         EH6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=L5u/Ewjt5chLxfL8rJhTxjnnE9xyDskU5p/CRtJxiWk=;
        b=fy+mmeia5L3SvtysAhMFAfJfTk1o/p5Q7DZCrAIGPTbdR+tQH+vyOuDynrBUkA6468
         EWpXYJK9PjoIz9ACipc7zAiIAZAbbNXa4kU6Pqrr6dfaeSitbKm/ixR4xgFdOQxMQdCQ
         mxekGmxtxG3BEeVxVNIwflUgx+PI6L9aP2cJpq/qL09Ft2UMQD+bUrVRhzKF3IntIdfJ
         z61pBcLJNnqZj0NkGrnNRmKja5HykXuG7sCr6jsVA0G/++t4VMIgwkmxmrFVkE0HbleC
         lxpGEr21L42F8UT4EXIR+a2Ybjog10kMOEM1LET1kteOwqDbGYJkbwPyFIQAFd19P1Qv
         2dQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bHsPjAAR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor2497653qvj.32.2019.06.07.12.13.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:13:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=bHsPjAAR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=L5u/Ewjt5chLxfL8rJhTxjnnE9xyDskU5p/CRtJxiWk=;
        b=bHsPjAAReITKwgXncrDQTUnXH5Uijp2yxwi54oFK0Oz03jgNQyFhk7SQWR25Vf57lG
         5J6WB8BhgQr2brS9p/HxVjcz/IKspC8ZZGgXxTb89hyDw6XGOwJRJa3HYjZxUQMfLrqP
         uVoeOGU1e0jF8iYlcy/d4lLIPcQqPtxjbX9ZItpPRa/lHVfSdg9gmJmTyxiQtHKaPV1U
         J1ylkbGKkx6WHJknF7MIDM9blwCpIDf4aCW/jrUX4cc6/SZAxImLy9wuCFni5MukTp9f
         vwPYJF+o6d56Yg60VxHr2pAlIWg0aH5DsbA7nYwEO21TQ5DiUxGjo1TsMsh9ne7w/s2v
         6l3w==
X-Google-Smtp-Source: APXvYqypnlbRh0P3THtdFA6tT1uB3/DaS37Mw0g1zWi372Eeo4eJbdLfgNtonmEZ+OErUzAT0EDkAg==
X-Received: by 2002:a0c:88c3:: with SMTP id 3mr26437457qvo.21.1559934783538;
        Fri, 07 Jun 2019 12:13:03 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id k40sm2014808qta.50.2019.06.07.12.13.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 12:13:03 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZKIQ-0000kC-MD; Fri, 07 Jun 2019 16:13:02 -0300
Date: Fri, 7 Jun 2019 16:13:02 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190607191302.GR14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 12:01:45PM -0700, Ralph Campbell wrote:
> 
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > The wait_event_timeout macro already tests the condition as its first
> > action, so there is no reason to open code another version of this, all
> > that does is skip the might_sleep() debugging in common cases, which is
> > not helpful.
> > 
> > Further, based on prior patches, we can no simplify the required condition
> > test:
> >   - If range is valid memory then so is range->hmm
> >   - If hmm_release() has run then range->valid is set to false
> >     at the same time as dead, so no reason to check both.
> >   - A valid hmm has a valid hmm->mm.
> > 
> > Also, add the READ_ONCE for range->valid as there is no lock held here.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> >   include/linux/hmm.h | 12 ++----------
> >   1 file changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 4ee3acabe5ed22..2ab35b40992b24 100644
> > +++ b/include/linux/hmm.h
> > @@ -218,17 +218,9 @@ static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
> >   static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
> >   					      unsigned long timeout)
> >   {
> > -	/* Check if mm is dead ? */
> > -	if (range->hmm == NULL || range->hmm->dead || range->hmm->mm == NULL) {
> > -		range->valid = false;
> > -		return false;
> > -	}
> > -	if (range->valid)
> > -		return true;
> > -	wait_event_timeout(range->hmm->wq, range->valid || range->hmm->dead,
> > +	wait_event_timeout(range->hmm->wq, range->valid,
> >   			   msecs_to_jiffies(timeout));
> > -	/* Return current valid status just in case we get lucky */
> > -	return range->valid;
> > +	return READ_ONCE(range->valid);
> >   }
> >   /*
> > 
> 
> Since we are simplifying things, perhaps we should consider merging
> hmm_range_wait_until_valid() info hmm_range_register() and
> removing hmm_range_wait_until_valid() since the pattern
> is to always call the two together.

? the hmm.rst shows the hmm_range_wait_until_valid being called in the
(ret == -EAGAIN) path. It is confusing because it should really just
have the again label moved up above hmm_range_wait_until_valid() as
even if we get the driver lock it could still be a long wait for the
colliding invalidation to clear.

What I want to get to is a pattern like this:

pagefault():

   hmm_range_register(&range);
again:
   /* On the slow path, if we appear to be live locked then we get
      the write side of mmap_sem which will break the live lock,
      otherwise this gets the read lock */
   if (hmm_range_start_and_lock(&range))
         goto err;

   lockdep_assert_held(range->mm->mmap_sem);

   // Optional: Avoid useless expensive work
   if (hmm_range_needs_retry(&range))
      goto again;
   hmm_range_(touch vmas)

   take_lock(driver->update);
   if (hmm_range_end(&range) {
       release_lock(driver->update);
       goto again;
   }
   // Finish driver updates
   release_lock(driver->update);

   // Releases mmap_sem
   hmm_range_unregister_and_unlock(&range);

What do you think? 

Is it clear?

Jason

