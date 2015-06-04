Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A0116900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 05:00:51 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so26738269pdb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 02:00:51 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id z16si4915136pbt.136.2015.06.04.02.00.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 02:00:50 -0700 (PDT)
Received: by padjw17 with SMTP id jw17so25536206pad.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 02:00:49 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Subject: Re: Rules for calling ->releasepage()
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20150604083953.GB5923@quack.suse.cz>
Date: Thu, 4 Jun 2015 03:00:44 -0600
Content-Transfer-Encoding: 7bit
Message-Id: <75C1F36D-E42F-4897-A1CB-232EA0938F83@dilger.ca>
References: <20150604083953.GB5923@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, mfasheh@suse.de, mgorman@suse.de, linux-ext4@vger.kernel.org

On Jun 4, 2015, at 2:39 AM, Jan Kara <jack@suse.cz> wrote:
> 
>  Hello,
> 
> we were recently debugging an issue where customer was hitting
> warnings in xfs_vm_releasepage() which was complaining that the
> page it was called for has delay-allocated buffers. After some
> debugging we realized that indeed try_to_release_page() call from
> shrink_active_list() can happen for a page in arbitrary state (that
> call happens only if buffer_heads_over_limit is set so that is
> the reason why we normally don't see that).
> 
> Hence comes my question: What are the rules for when releasepage()
> can be called? And what is the expected outcome? We are certainly
> guaranteed to hold page lock. try_to_release_page() also makes
> sure the page isn't under writeback.  But what is ->releasepage()
> supposed to do with a dirty page?
> Generally IFAIU we aren't supposed to discard dirty data but I
> wouldn't bet on all filesystems getting it right because the
> common call paths make sure page is clean. I would almost say we
> should enforce !PageDirty in try_to_release_page() if it was not
> for that ext3 nastyness of cleaning buffers under a dirty page -
> hum, but maybe the right answer for that is ripping ext3 out of
> tree (which would also allow us to get rid of some code in the
> blocklayer for bouncing journaled data buffers when stable writes
> are required).
> 
> Thoughts?

I've been an advocate of removing ext3 from the tree for a few years
already.  It doesn't do anything better than ext4, but it does a lot
of things worse.  Distros have been using CONFIG_EXT4_USE_FOR_EXT23
for several years now without problems AFAIK so this is safe even
if users don't want to upgrade their on-disk features in case they
want to be able to downgrade to an older kernel.

Cheers, Andreas





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
