Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E93EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F83220675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:09:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JdvJwEXr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F83220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CBD26B0005; Thu, 20 Jun 2019 11:09:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77D5C8E0002; Thu, 20 Jun 2019 11:09:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61D5D8E0001; Thu, 20 Jun 2019 11:09:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 424C56B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:09:16 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so5598865ioh.22
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:09:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ewdhs5LHMjOeAYyn48UrmEBDkixoi9wUic5LA0EV24E=;
        b=njGheCUrY/xhHyCmNZWBS1B6BGfqDgf5LSdJeyzVHv+wQTNEMglZnWantEhdeLAARZ
         cpXY/BOaVl5ExAUpRAaqmwDx72CkepUNs43UnlrxT9EqObh8kdBIdvO4Qx+a8vxZaDfK
         q/INoVbZDK6FcSQnIyeQ6IvuYwDYHbMslB8tTENQjHBDOZUae8T0nbYN5Y3CaSsST4H/
         DorPbRdjzNnj9IMtaIyjt08xKrJugzEXkNZItBeML91+LDc4WfEZxCDnwf1hJ92QqV0Q
         DHzHsp2wnYM3yeIrQygGs3QL72nl40oDZXMFyKJaaH09FhG28fqlf9XSmuZxxbm6YxFc
         20OA==
X-Gm-Message-State: APjAAAVVaURVXyNiDAR3rj/98DMXNQMOaTVc4fmjZBrxT6sCCzyxxuW/
	LbcFbNoGodUsf5fmdGPvmTPHAY9sMFYW0Ngy9+fI2WTbcRichT+ez7icvzqZ45jBsib6DsAgUPf
	P2maZIm8x9STiZvJm3jTraAceiQV+Z0ALi9zEL637h9J9JNpk4rcQ7nD3QujYWnNIew==
X-Received: by 2002:a5d:96d8:: with SMTP id r24mr31129633iol.269.1561043355921;
        Thu, 20 Jun 2019 08:09:15 -0700 (PDT)
X-Received: by 2002:a5d:96d8:: with SMTP id r24mr31129551iol.269.1561043355007;
        Thu, 20 Jun 2019 08:09:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561043355; cv=none;
        d=google.com; s=arc-20160816;
        b=RnAAHW2oUY5raHSGJ/VY1kvleZ6NQ+6Dm1DRCGPOtqSsjUngiSt1ilPqEHs0Kc86iU
         jNJHnsRWNrQido889qEI80VNYnGNyxYOc6gyfwaI0lR6bu8m0rYXExa7cKD3/4fMP8Ah
         cpJj1PBvnVV8wvqlNh8+TrVq0ALyovwUC/f76a69SWCxz5523rIUoJl/QZBzy0tMpab4
         vGCXmbIZtrpLygBIOowR6wPTqZcmLi+Zz2r1tn12Xpci3I8jpzff4jfbERiAHDC7hOqC
         Ris/xZGJmf92xtC1Dj7xjE+uNDRZFN2BTyjeGPHz//2Rz8LAkWaLNm/SbbT7MnaPr9t6
         kEgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ewdhs5LHMjOeAYyn48UrmEBDkixoi9wUic5LA0EV24E=;
        b=Y1ViAEs5hk5sR8OeJbj2DcSkzNA65SRyXDzw0jeLp0Viw/CAMmBFM7D2JSf4ERjXeG
         UsDi+GDYHVeKrrpgnaa5FfMJ0jolIhVdM6IwS7q++yjaCOx4J0DcL0v1Oa+uXfdLOPBz
         UG8NmPfWo3Mkt1u5YBfxstxUctfZmfkg/luyVcfp8wKuyysUgTSJFqEu2cB/RTv1IqYb
         SxBRPOmfdZGVqWIrBlHg7z2tK5391iwXJkXuCCbV6SnpNuhfaickMvzSREWhDJdQ82a+
         zlx8vTS0UN3EKmK8sxkMgAzAWwA6oqa6gHwcld/tjIDBxj685rhU2/KkV6yEHOF3cPzs
         3cQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JdvJwEXr;
       spf=pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k21sor17584913ios.74.2019.06.20.08.09.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 08:09:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JdvJwEXr;
       spf=pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ewdhs5LHMjOeAYyn48UrmEBDkixoi9wUic5LA0EV24E=;
        b=JdvJwEXrYAnx5AAC+XXXCNKVU113R27SbHcmaFh10XoeJ19jse9UlgQHUgP9Dbs/Ly
         L5gsnLoUu69tMP0wH9tzzv14tw9rZx8tP97CUVrh25VbPy/chgSW/u87CuNuhB99D0ob
         Jzxea/k/UXe+JdQrG5HCVGXJ7MwB+foaI17QqOx5S+HDW8qAMFIwEImkYuYp4+F+/pbb
         ps+qGPCzBctzDiyTzmyWhPDKhpeBzqb9KiXlkgIFz/GzkJZl5P6q2rcOg5mf0hdnnvbK
         xq4nHwF21difWFt9jzn8/KwkphqxT7Rj2JbfX2TwfWZhWPUsPMs6hx/0kOrsaq+6o/GK
         O02Q==
X-Google-Smtp-Source: APXvYqx5OhNQGc/cowc4jUU7ZK9aKOWQfczrnZebKrjxu3Ng1Qb+wjCWeQXoL4sJ7gt1IrioslXb3g==
X-Received: by 2002:a6b:3883:: with SMTP id f125mr89642441ioa.109.1561043354165;
        Thu, 20 Jun 2019 08:09:14 -0700 (PDT)
Received: from google.com ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id w23sm52147ioa.51.2019.06.20.08.09.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 20 Jun 2019 08:09:13 -0700 (PDT)
Date: Thu, 20 Jun 2019 09:09:11 -0600
From: Ross Zwisler <zwisler@google.com>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <zwisler@chromium.org>, linux-kernel@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: Re: [PATCH 2/3] jbd2: introduce jbd2_inode dirty range scoping
Message-ID: <20190620150911.GA4488@google.com>
References: <20190619172156.105508-1-zwisler@google.com>
 <20190619172156.105508-3-zwisler@google.com>
 <20190620110454.GL13630@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620110454.GL13630@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 01:04:54PM +0200, Jan Kara wrote:
> On Wed 19-06-19 11:21:55, Ross Zwisler wrote:
> > Currently both journal_submit_inode_data_buffers() and
> > journal_finish_inode_data_buffers() operate on the entire address space
> > of each of the inodes associated with a given journal entry.  The
> > consequence of this is that if we have an inode where we are constantly
> > appending dirty pages we can end up waiting for an indefinite amount of
> > time in journal_finish_inode_data_buffers() while we wait for all the
> > pages under writeback to be written out.
> > 
> > The easiest way to cause this type of workload is do just dd from
> > /dev/zero to a file until it fills the entire filesystem.  This can
> > cause journal_finish_inode_data_buffers() to wait for the duration of
> > the entire dd operation.
> > 
> > We can improve this situation by scoping each of the inode dirty ranges
> > associated with a given transaction.  We do this via the jbd2_inode
> > structure so that the scoping is contained within jbd2 and so that it
> > follows the lifetime and locking rules for that structure.
> > 
> > This allows us to limit the writeback & wait in
> > journal_submit_inode_data_buffers() and
> > journal_finish_inode_data_buffers() respectively to the dirty range for
> > a given struct jdb2_inode, keeping us from waiting forever if the inode
> > in question is still being appended to.
> > 
> > Signed-off-by: Ross Zwisler <zwisler@google.com>
> 
> The patch looks good to me. I was thinking whether we should not have
> separate ranges for current and the next transaction but I guess it is not
> worth it at least for now. So just one nit below. With that applied feel free
> to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

We could definitely keep separate dirty ranges for each of the current and
next transaction.  I think the case where you would see a difference would be
if you had multiple transactions in a row which grew the dirty range for a
given jbd2_inode, and then had a random I/O workload which kept dirtying pages
inside that enlarged dirty range.

I'm not sure how often this type of workload would be a problem.  For the
workloads I've been testing which purely append to the inode, having a single
dirty range per jbd2_inode is sufficient.

I guess for now this single range seems simpler, but if later we find that
someone would benefit from separate tracking for each of the current and next
transactions, I'll take a shot at adding it.

Thank you for the review!

> > @@ -257,15 +262,24 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
> >  	/* For locking, see the comment in journal_submit_data_buffers() */
> >  	spin_lock(&journal->j_list_lock);
> >  	list_for_each_entry(jinode, &commit_transaction->t_inode_list, i_list) {
> > +		loff_t dirty_start = jinode->i_dirty_start;
> > +		loff_t dirty_end = jinode->i_dirty_end;
> > +
> >  		if (!(jinode->i_flags & JI_WAIT_DATA))
> >  			continue;
> >  		jinode->i_flags |= JI_COMMIT_RUNNING;
> >  		spin_unlock(&journal->j_list_lock);
> > -		err = filemap_fdatawait_keep_errors(
> > -				jinode->i_vfs_inode->i_mapping);
> > +		err = filemap_fdatawait_range_keep_errors(
> > +				jinode->i_vfs_inode->i_mapping, dirty_start,
> > +				dirty_end);
> >  		if (!ret)
> >  			ret = err;
> >  		spin_lock(&journal->j_list_lock);
> > +
> > +		if (!jinode->i_next_transaction) {
> > +			jinode->i_dirty_start = 0;
> > +			jinode->i_dirty_end = 0;
> > +		}
> 
> This would be more logical in the next loop that moves jinode into the next
> transaction.

Yep, agreed, this is much better.  Fixed in v2.

