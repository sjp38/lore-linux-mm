Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABB93C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:57:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EE0B24D3D
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:57:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EE0B24D3D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17FA56B0269; Tue,  4 Jun 2019 03:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12EE46B026B; Tue,  4 Jun 2019 03:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F39236B026E; Tue,  4 Jun 2019 03:57:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A50406B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:57:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i3so31383893edr.12
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:57:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=esA+Tgy54AjV+cnjV75+qNIV/bV7nflnGaR0loBTcFc=;
        b=CK7ymEW83OJpSXW/cKT0TfGZwUhrXOUGGRM53X7EaPhORnjRnZS5lDfZdyzypaVoG7
         nSh1LxqS/tXGoGLicIb31ZAtAgOBnSKd2F02zqOGaOTY1iZrX1lLAKhP++tVhL/Y9pEs
         qylRsPNrNjqGnubJ+V25DvuqesqHvc+PQ/FvfgqQe/FNdBIAyxKOyYqD4k/9FYKlgsfY
         Vd8huxfzO9n/6TI4QT8uJLsLSgFQzRaeslEF7b2l5YGbxdAM0l6WASjqlgFtWuSn++eK
         Xg4crWM58Gcy3f9e/DGXwmOcKFHSv0eNRjJbyPHDIijqwexQizXuPAPas0dJ5+YJYzQT
         norw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWi2oViBHXJMKWcVTLjLI/1a9czya8FHX0rWRLYVefF6LevLtqt
	EjgdAqYUAALDE/DjPzPNkwPGx92C5PqKkKDXB+rbrvH4/Pb1fOQkxZXj7O1oUjkB5lJiERb/2cd
	Y3WeMe7+jBp1qqdjgnzdfFdQaAm4aMu97hmESByvDPY5ZB2WTyAjmfdcbd0tApncLqg==
X-Received: by 2002:a50:be48:: with SMTP id b8mr5748996edi.284.1559635073240;
        Tue, 04 Jun 2019 00:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHFpZWJyZ2C1Pevfa5t+0QPrg95EYBjIxbKa3YsfYisoSBv1wtv1NRG+IFE+QwRo5jDSxG
X-Received: by 2002:a50:be48:: with SMTP id b8mr5748921edi.284.1559635072382;
        Tue, 04 Jun 2019 00:57:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559635072; cv=none;
        d=google.com; s=arc-20160816;
        b=Qzbv0yhGI8dI/XC9yg7WbuhPzxBFwcqNDWo9T6PfcCQ047gG8ecRMzrGLkgl+QPpEr
         VsZ3FgdDnLbaRmhPbBsyyGmk8xkmqTu9V7jadh6gIgltGi3ViXbM4Dzsk+8QMEJbHsoI
         MjkpRaH3uEA4pN879+1RdzZL2EUICFjbc17clRQhVv7aH6rEk+hzC6+VsRlCzVtsRsT9
         y3QOIWdTNAeqQKFqqam6X40LZrLXYO2SceSDXOHV+2X+KIWWP7JHD09ZPhFUs6oUfNJR
         woDINVbzugCVfbSiKIl05Ga0W4EmONhBg3GIQ0XGDQVzn+Kgq6228tReW/4kNizmqbU5
         XfMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=esA+Tgy54AjV+cnjV75+qNIV/bV7nflnGaR0loBTcFc=;
        b=eLQM0ZCtXJ0jzefHc5/M5Gk9xcvdi0Ls5oXup/K2mOe/QRokCn95oXW+Ut3G2NPByK
         VLSihGtAC+rkTBqsebQMb1dpDnr8ajW688lB7P3vb8yiouQvVSxRlVmwJVcEgfvAwgiE
         WcrSiaVtEg5GiGsXBiZkMQ6jVRvD9XnJA5Bkri3wmBM5+/VWOIUM52+RU/QqCHjoWqh5
         P+PoCH3d27SwpAE5PhCz7PdX3BBptDWbmqEswxcYsfT5KI8H4TjVGEl8E6AMK1uFvSEt
         1CNevKfMpnsbRa/ncFo6hxnPfMbWfaz/z6uCMSy4xi1QPRqOgDI7QXxKjqr3H/LDt73n
         fctg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s27si2452715ejb.385.2019.06.04.00.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:57:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 651CDAE21;
	Tue,  4 Jun 2019 07:57:51 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 0F6A11E3C24; Tue,  4 Jun 2019 09:57:51 +0200 (CEST)
Date: Tue, 4 Jun 2019 09:57:51 +0200
From: Jan Kara <jack@suse.cz>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Ext4 <linux-ext4@vger.kernel.org>,
	Ted Tso <tytso@mit.edu>, Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	stable <stable@vger.kernel.org>
Subject: Re: [PATCH 2/2] ext4: Fix stale data exposure when read races with
 hole punch
Message-ID: <20190604075751.GK27933@quack2.suse.cz>
References: <20190603132155.20600-1-jack@suse.cz>
 <20190603132155.20600-3-jack@suse.cz>
 <CAOQ4uxgn7_tY35KVE6c-na2skXtxXhrM8-2wRNUe2CtmYACZrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxgn7_tY35KVE6c-na2skXtxXhrM8-2wRNUe2CtmYACZrg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 03-06-19 19:33:50, Amir Goldstein wrote:
> On Mon, Jun 3, 2019 at 4:22 PM Jan Kara <jack@suse.cz> wrote:
> >
> > Hole puching currently evicts pages from page cache and then goes on to
> > remove blocks from the inode. This happens under both i_mmap_sem and
> > i_rwsem held exclusively which provides appropriate serialization with
> > racing page faults. However there is currently nothing that prevents
> > ordinary read(2) from racing with the hole punch and instantiating page
> > cache page after hole punching has evicted page cache but before it has
> > removed blocks from the inode. This page cache page will be mapping soon
> > to be freed block and that can lead to returning stale data to userspace
> > or even filesystem corruption.
> >
> > Fix the problem by protecting reads as well as readahead requests with
> > i_mmap_sem.
> >
> 
> So ->write_iter() does not take  i_mmap_sem right?
> and therefore mixed randrw workload is not expected to regress heavily
> because of this change?

Yes. i_mmap_sem is taken in exclusive mode only for truncate, punch hole,
and similar operations removing blocks from file. So reads will now be more
serialized with such operations. But not with writes. There may be some
regression still visible due to the fact that although readers won't block
one another or with writers, they'll still contend on updating the cacheline
with i_mmap_sem and that's going to be visible for cache hot readers
running from multiple NUMA nodes.

> Did you test performance diff?

No, not really. But I'll queue up some test to see the difference.

> Here [1] I posted results of fio test that did x5 worse in xfs vs.
> ext4, but I've seen much worse cases.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

