Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94BD7C46460
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:00:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64E5224D40
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 08:00:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64E5224D40
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEB4E6B0269; Tue,  4 Jun 2019 04:00:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC2166B026B; Tue,  4 Jun 2019 04:00:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD74B6B026E; Tue,  4 Jun 2019 04:00:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE996B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 04:00:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d13so19828054edo.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 01:00:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Fyo8267+bPLrlK7ZQG7q+38wvZ2Ccg1SE20pkIFms7Y=;
        b=sCcxkQC9G4wnWairy2YKkbgav0FNx/Ory2KLqozkP8GI44K/yQ2GNR0OfIIwU7jwQU
         ZFmvKINWuNQs9JIpkKKqVRdBl3xcKIb/lpyYW7zfUSFMXU4vXDpOCb6TXkpta1K37NPo
         DpkbC91rYgFYIpkf74cddCr451yxoyvRoANhHK7snhn4ELjr4bahKUTKuSbMmACvAslO
         Iqblj9VSa4/8YB2S8E4q569L0e89yQuN+DcK0esXSEgxKKV+DktNjTXytRJMqpNT3qLz
         d9fi8DjFnlgNn8LDXgwk4EstpuRaEi2GgeK4YoaHF/5zNkfCt3qzsiR1rbR8vCbbYNQC
         6Qug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVfX+Z5ULkjNMZL8nVv4p5HTAgxjAvcG0reJjLdXVrBkQ8tP0wE
	Af7FrexdkL98PLOEBHOK37qekN7Ze8xNBT9ucN4sLhhGgj5+CKJKLFEC/MIHwkkjPm3p5IOZ3tq
	jAo5VUtFzB+1SCyPuiDJhP523DbDpv2gg6bd35QJ5XC49MVs2UNMci9Tgq3JUW/vAyw==
X-Received: by 2002:a50:b7f8:: with SMTP id i53mr34774107ede.196.1559635245122;
        Tue, 04 Jun 2019 01:00:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRVabJtIe38fxlnHMQMZBBnW1UM5fQA10s6eQreHPQUElmY4lpIfbObVj3u99ywYJsglDn
X-Received: by 2002:a50:b7f8:: with SMTP id i53mr34774022ede.196.1559635244321;
        Tue, 04 Jun 2019 01:00:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559635244; cv=none;
        d=google.com; s=arc-20160816;
        b=oRrIbk7y2VJSGCu9RVfrc1ylNU792+dvDq0wkUGyOaClZ3CIx3qDWJWsTnumS1oSPk
         joBR3Zn0W1w3tPhWPresLThynSnxNJDe2MSdsLpB5rbin/CZPk8qmHJINYYT0StAH88x
         XI66n5/C9NXcvenI0zg0kY2o/iNLCmSpczySfTwB1R/uejky5z6XIO5C3a/iL8zG+zqF
         EylA+lTRP0fdoP+Oa9t05K9UhnDB9Ml769078zEkM2XWteJkiG4aF/06WS+KvD/vffpT
         wY2ieHTHLsk85MbzU63Sgbz8I7IbXqYTljhLr0aUgo6ynAGoUj05onbgarqa6ainj2wi
         RHtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Fyo8267+bPLrlK7ZQG7q+38wvZ2Ccg1SE20pkIFms7Y=;
        b=tgpGNbbH0FP4HWtq+JTQBVKkprsXTH3HlGdn63umrBwM7FyyqZTEqak1TNiV0yHU2g
         8rOYEIqn5/slPvh68sqz8toz6LDsC6sPHPbSqBl83uH7O2wDs/mOpX6Mq6qWdeVt7j+G
         GdXOCBTN7GUrqxbWXQAFMomyvfL2hBXax7xB7nvCbs4lfVyFMVFf0Utp/9ejb64XDx++
         riUgUzKwFQzdviByg9YtUri3/Twrl/RGwKYerWeJXaCa6FRuMSc32qX9+wxDIGzVSaOC
         TvREgZyEaScyEkwDpMW1yaEckhkvAjOaHc2ZO7WlIk0T7gdpVIuTVBr0CQ13+ShglseG
         sH9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f58si800816edf.135.2019.06.04.01.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 01:00:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D685AAEB5;
	Tue,  4 Jun 2019 08:00:43 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 76BD51E3C24; Tue,  4 Jun 2019 10:00:43 +0200 (CEST)
Date: Tue, 4 Jun 2019 10:00:43 +0200
From: Jan Kara <jack@suse.cz>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Ext4 <linux-ext4@vger.kernel.org>,
	Ted Tso <tytso@mit.edu>, Linux MM <linux-mm@kvack.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	stable <stable@vger.kernel.org>, Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 1/2] mm: Add readahead file operation
Message-ID: <20190604080043.GL27933@quack2.suse.cz>
References: <20190603132155.20600-1-jack@suse.cz>
 <20190603132155.20600-2-jack@suse.cz>
 <CAOQ4uxibr6_k2T_0BeC7XAOnuX1PHmEmBjFwfzkVJVh17YAqrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxibr6_k2T_0BeC7XAOnuX1PHmEmBjFwfzkVJVh17YAqrw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 03-06-19 19:16:59, Amir Goldstein wrote:
> On Mon, Jun 3, 2019 at 4:22 PM Jan Kara <jack@suse.cz> wrote:
> >
> > Some filesystems need to acquire locks before pages are read into page
> > cache to protect from races with hole punching. The lock generally
> > cannot be acquired within readpage as it ranks above page lock so we are
> > left with acquiring the lock within filesystem's ->read_iter
> > implementation for normal reads and ->fault implementation during page
> > faults. That however does not cover all paths how pages can be
> > instantiated within page cache - namely explicitely requested readahead.
> > Add new ->readahead file operation which filesystem can use for this.
> >
> > CC: stable@vger.kernel.org # Needed by following ext4 fix
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/fs.h |  5 +++++
> >  include/linux/mm.h |  3 ---
> >  mm/fadvise.c       | 12 +-----------
> >  mm/madvise.c       |  3 ++-
> >  mm/readahead.c     | 26 ++++++++++++++++++++++++--
> >  5 files changed, 32 insertions(+), 17 deletions(-)
> >
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index f7fdfe93e25d..9968abcd06ea 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1828,6 +1828,7 @@ struct file_operations {
> >                                    struct file *file_out, loff_t pos_out,
> >                                    loff_t len, unsigned int remap_flags);
> >         int (*fadvise)(struct file *, loff_t, loff_t, int);
> > +       int (*readahead)(struct file *, loff_t, loff_t);
> 
> The new method is redundant, because it is a subset of fadvise.
> When overlayfs needed to implement both methods, Miklos
> suggested that we unite them into one, hence:
> 3d8f7615319b vfs: implement readahead(2) using POSIX_FADV_WILLNEED

Yes, I've noticed this.

> So you can accomplish the ext4 fix without the new method.
> All you need extra is implementing madvise_willneed() with vfs_fadvise().

Ah, that's an interesting idea. I'll try that out. It will require some
dance in madvise() to drop mmap_sem but we already do that for
madvise_free() so I can just duplicate that.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

