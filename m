Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0C3DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:26:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 711ED21872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:26:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711ED21872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8EE96B0003; Thu, 14 Mar 2019 22:26:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3FA06B0006; Thu, 14 Mar 2019 22:26:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0A846B0007; Thu, 14 Mar 2019 22:26:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC596B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:26:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p127so8440509pga.20
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 19:26:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YS382tGniaGcjmaQdqN3HKhX1MB59AhnY2x7pzaOUT4=;
        b=MfEQyXGjjsmUzssC6jPONIehCC4cUusETw9qPch8IXC4wWD9epKAF+VfJRbqLv1iU7
         ktfMf8y8BxNzYNeCkTvGYw0ZQ2AqSoWVNvMSRiH3ub8IOxsgbNFG8urBOYYNN0lAKy3h
         p9cl25PMr8bIP/JFKRmmdQB4fuWmUjyw6xiZd+mKX7CaAt9o945On6zLqOpIuOQdSfMX
         KIjcbgY5il7Xg7sKpWIi8sfqRpsvrpAmIevABKo+kn4NjQLAODc3CiFmhJMJUyoU29jk
         isA4NGvlrJFusejMt3T+RtyYzbhF+Qb1Klc8idqwkWms+VZnkFf3JswLi0AtY80D9uv6
         ASkA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.133 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVG/xm41N4MZtc0lOIMdphBIlyJMBR+LfdHYHp/dOAoFGIgAJCd
	QrcwyGytMAa/U1AOgGzahcK+t8Cp5IyRae8sPZJaq92FkzAMFe+9BHWZxuBQIjD2VmRMjco7Buc
	YsAPxXWJwiqN/kkAnpLF6Zzw2dedImCSrC9pqmPhDmyMCg+PF/0F4BS1hEYymFIU=
X-Received: by 2002:a63:43:: with SMTP id 64mr1100709pga.64.1552616769041;
        Thu, 14 Mar 2019 19:26:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM8fSmOJG4ihTTTatflAQEtgPkivangY5naqBAD0IIoVusbtM65euDy3MfVey0tbpOF7IO
X-Received: by 2002:a63:43:: with SMTP id 64mr1100630pga.64.1552616767529;
        Thu, 14 Mar 2019 19:26:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552616767; cv=none;
        d=google.com; s=arc-20160816;
        b=ypzNbvTc6z9PvJWsxH57KUYliEraAvUF1OdXCUgVX7AzLDkJqcLrd/y6FVj75sKBCF
         nmLSPEeUFAx5MwjfYYV2iG0GLsXLaNBg6gKS9qKJAikDmplCssnnxb7sM0XL9nA70EZl
         qC6J+9fQ6K5MwBjc0pSz27CRXcAs22rXwPgWmzm4KwcavCYKkasB0W3f+qYDvwjs+UD9
         VSk4jrJ3xpmitQtCYDhysIOUrx+/zuxbXZCE7RPfttpXt/+9UXl7pRNZxxTdXYsaZ271
         i5ZJ42oUAoxUvNDBsRQZ5f9H0yJtoJov7VMatjVyR6hZpyQbvzzBb2yunCNV7Qvd2OQG
         mlGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YS382tGniaGcjmaQdqN3HKhX1MB59AhnY2x7pzaOUT4=;
        b=yCQZt/Lw08mTL/iaks+S4PI8XZyiFyzisy6md7i/SBEuyk2uHaCarHCqg80TvLxtaB
         JkQ8f88J5XIeTPoPASmYV9Oq74CV7gdpSSpgrbZkaniQQIqfStSnwBis9ojfsOQjNIQu
         HT0uegFi9MS6UM5Eb7XKGUw5TCjF1Bv4QlfrcUX0dS9jK2wVHE66gGrFHHHDs2VOEuxM
         4h+Ik7YyotiWOFS3y/h8ZmBlrGhsMJFnzTPsHbPtOxO/YTSkAm8yBlQ1cbDoLp6/TddO
         8E56KThvjWRrVdeDxN/ZbqO/FVxyrb/WhNxyNNixnUwJ0vJT7DfzS7HxE+Conzx9H8fZ
         0FJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.133 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id o14si653657pgv.310.2019.03.14.19.26.06
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 19:26:07 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.133 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.133;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.133 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail01.adl2.internode.on.net with ESMTP; 15 Mar 2019 12:56:05 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h4cXs-0004x7-6R; Fri, 15 Mar 2019 13:26:04 +1100
Date: Fri, 15 Mar 2019 13:26:04 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	"Barror, Robert" <robert.barror@intel.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion
 (bisected)
Message-ID: <20190315022604.GO26298@dastard>
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org>
 <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
 <20190312043754.GD23020@dastard>
 <CAPcyv4i+z0RT7rTw+4w-h8dOyscVk1g3F+cu2pKHqqJjTgU++A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i+z0RT7rTw+4w-h8dOyscVk1g3F+cu2pKHqqJjTgU++A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 12:34:51AM -0700, Dan Williams wrote:
> On Mon, Mar 11, 2019 at 9:38 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> > > On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > > > Hi Willy,
> > > > >
> > > > > We're seeing a case where RocksDB hangs and becomes defunct when
> > > > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > > > > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > > > > handlers to XArray".
> > > > >
> > > > > I see some direct usage of xa_index and wonder if there are some more
> > > > > pmd fixups to do?
> > > > >
> > > > > Other thoughts?
> > > >
> > > > I don't see why killing a process would have much to do with PMD
> > > > misalignment.  The symptoms (hanging on a signal) smell much more like
> > > > leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> > > > get /proc/$pid/stack for a hung task?
> > >
> > > It's fairly easy to reproduce, I'll see if I can package up all the
> > > dependencies into something that fails in a VM.
> > >
> > > It's limited to xfs, no failure on ext4 to date.
> > >
> > > The hung process appears to be:
> > >
> > >      kworker/53:1-xfs-sync/pmem0
> >
> > That's completely internal to XFS. Every 30s the work is triggered
> > and it either does a log flush (if the fs is active) or it syncs the
> > superblock to clean the log and idle the filesystem. It has nothing
> > to do with user processes, and I don't see why killing a process has
> > any effect on what it does...
> >
> > > ...and then the rest of the database processes grind to a halt from there.
> > >
> > > Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:
> > >
> > > [<0>] worker_thread+0xb2/0x380
> > > [<0>] kthread+0x112/0x130
> > > [<0>] ret_from_fork+0x1f/0x40
> > > [<0>] 0xffffffffffffffff
> >
> > Much more useful would be:
> >
> > # echo w > /proc/sysrq-trigger
> >
> > And post the entire output of dmesg.
> 
> Here it is:
> 
> https://gist.github.com/djbw/ca7117023305f325aca6f8ef30e11556

Which tells us nothing. :(

I think a bisect is in order...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

