Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DDE9C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 11:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2BA1206E0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 11:16:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2BA1206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FA2B6B0003; Thu, 20 Jun 2019 07:16:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A9518E0002; Thu, 20 Jun 2019 07:16:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 373F28E0001; Thu, 20 Jun 2019 07:16:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF6D16B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:15:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so3793589edx.12
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 04:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bpk+jQCb/cMd+RIcKgYwFS2w/m1JeMMx8Hi6+LqzYbo=;
        b=bXGCdaTaEClkwnVp4k9HYwJLDZlGjaqrASeedpWON+METfeDbi2SQEU2sr5+pU4O8d
         utO6xt9mjIXyLcKMCPA82nOji9UkUJx1fvnMcGT75U9zyBVVhKxChf7MLzgQcCXUo4mr
         xrCoRmJ8RRKF+bCLOYCAS3BtQLpbEBSJdy+BpFt5KDVa6lLAdt59ZMiBCf4BBQFxZmhh
         viDes2hUFMr15dBmATIg3sq49LKYDAIPKgPFgKv5tILVZlcsVSTTAaiHdwty4udIcfOs
         JijmM+6eY019UUsajat5DNgQL91yah3IXfbN4r9fx4oFRpdw0oVeQ+Lxx/AzypRNx0xf
         4gjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUtG4pugMeEBd4Aulu3K8l3gQ0DE2Yss5DBNB9qwUTBR99icIra
	UbElL01VwbsBJAZ95f4KFe2fVd7M9fLaV+HnQxJK/wkvCs5IYgHTh0iaMBvCHq4FyGowsWIrlaf
	vLDRk0XRXYMAsYmXw1V+6ov7tpEPmkBZHIbU2YEMIBmlaAwenK3iBRecHJOteR21ltA==
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr67643955ejf.28.1561029359413;
        Thu, 20 Jun 2019 04:15:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG4o4gu7OwhQHhdu0dgDaaGC//VkItwbY6vWJg4AFNDei6ftArjHtky45jkTUJ6MgZ7RQI
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr67643896ejf.28.1561029358615;
        Thu, 20 Jun 2019 04:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561029358; cv=none;
        d=google.com; s=arc-20160816;
        b=Q6w9V4gaGMsUMEpOIf8kiFudVC43nOolIQhGE0Dr5wTKqBJJqHD6pStw+i6idky2jk
         9cUa1VrKH37r3qEvkpocQMSqHQ9+fzzdLDK8IIJLtffsp6EopcVuFRJOQuGZ4l1/Up8E
         I6uH2G8zrGvUI/6dWaay/T5M3dZWRoYdlT+//VhnhtH89ZMqZr2LgX5h5i1KePo4YQ1Y
         M9b2FCNwKS7H1u0BicixDs6eBtbm3PzZhRk0+mmwUgmcYugLpAEpvpDOIWtKBjJEnxcD
         G7FCkT/6STpT/dTaUVhpwsPDuFK1jiNUCmuC4LWfl8RUssphC9Zsho/NHvRPj1TBqeqn
         C5Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bpk+jQCb/cMd+RIcKgYwFS2w/m1JeMMx8Hi6+LqzYbo=;
        b=e80vLO3W+Na+WUcIfdRFJBkopvuQf0TlMDXXIWKxc1tmSTTGoE06kVr57890jSGhru
         6c8+rQej8wnvUaNY/SsDBcUuk2QA0gzWX+PctCdZ+Qwh7Zm1mS4Q9x/qVzflPGNDr67k
         tPessLhaf/BlwgDqK6MSqMjQ0CD6KznjYwpvHt1S9fmSZvMuiW0uHx8lgFUDAOuOutf3
         0k/JKHgpssYojenGMzijXFCxeQdMneXg1qXkTqKgxPrxNrVQYoYhsMzYdYj3kfDiCcxP
         kMu5vR+H/LkngQkIOFUfQ7liW17trc6orhORjA3k5dMY7pjiRx9xo64j3tSUjbMM0XMf
         PcCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x12si12909750ejb.342.2019.06.20.04.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 04:15:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 17F02AE82;
	Thu, 20 Jun 2019 11:15:58 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C461F1E4241; Thu, 20 Jun 2019 13:15:57 +0200 (CEST)
Date: Thu, 20 Jun 2019 13:15:57 +0200
From: Jan Kara <jack@suse.cz>
To: Ross Zwisler <zwisler@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <zwisler@google.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: Re: [PATCH 3/3] ext4: use jbd2_inode dirty range scoping
Message-ID: <20190620111557.GM13630@quack2.suse.cz>
References: <20190619172156.105508-1-zwisler@google.com>
 <20190619172156.105508-4-zwisler@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619172156.105508-4-zwisler@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 11:21:56, Ross Zwisler wrote:
> Use the newly introduced jbd2_inode dirty range scoping to prevent us
> from waiting forever when trying to complete a journal transaction.
> 
> Signed-off-by: Ross Zwisler <zwisler@google.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext4/ext4_jbd2.h   | 12 ++++++------
>  fs/ext4/inode.c       | 13 ++++++++++---
>  fs/ext4/move_extent.c |  3 ++-
>  3 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
> index 75a5309f22315..ef8fcf7d0d3b3 100644
> --- a/fs/ext4/ext4_jbd2.h
> +++ b/fs/ext4/ext4_jbd2.h
> @@ -361,20 +361,20 @@ static inline int ext4_journal_force_commit(journal_t *journal)
>  }
>  
>  static inline int ext4_jbd2_inode_add_write(handle_t *handle,
> -					    struct inode *inode)
> +		struct inode *inode, loff_t start_byte, loff_t length)
>  {
>  	if (ext4_handle_valid(handle))
> -		return jbd2_journal_inode_add_write(handle,
> -						    EXT4_I(inode)->jinode);
> +		return jbd2_journal_inode_ranged_write(handle,
> +				EXT4_I(inode)->jinode, start_byte, length);
>  	return 0;
>  }
>  
>  static inline int ext4_jbd2_inode_add_wait(handle_t *handle,
> -					   struct inode *inode)
> +		struct inode *inode, loff_t start_byte, loff_t length)
>  {
>  	if (ext4_handle_valid(handle))
> -		return jbd2_journal_inode_add_wait(handle,
> -						   EXT4_I(inode)->jinode);
> +		return jbd2_journal_inode_ranged_wait(handle,
> +				EXT4_I(inode)->jinode, start_byte, length);
>  	return 0;
>  }
>  
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index c7f77c6430085..27fec5c594459 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -731,10 +731,16 @@ int ext4_map_blocks(handle_t *handle, struct inode *inode,
>  		    !(flags & EXT4_GET_BLOCKS_ZERO) &&
>  		    !ext4_is_quota_file(inode) &&
>  		    ext4_should_order_data(inode)) {
> +			loff_t start_byte =
> +				(loff_t)map->m_lblk << inode->i_blkbits;
> +			loff_t length = (loff_t)map->m_len << inode->i_blkbits;
> +
>  			if (flags & EXT4_GET_BLOCKS_IO_SUBMIT)
> -				ret = ext4_jbd2_inode_add_wait(handle, inode);
> +				ret = ext4_jbd2_inode_add_wait(handle, inode,
> +						start_byte, length);
>  			else
> -				ret = ext4_jbd2_inode_add_write(handle, inode);
> +				ret = ext4_jbd2_inode_add_write(handle, inode,
> +						start_byte, length);
>  			if (ret)
>  				return ret;
>  		}
> @@ -4085,7 +4091,8 @@ static int __ext4_block_zero_page_range(handle_t *handle,
>  		err = 0;
>  		mark_buffer_dirty(bh);
>  		if (ext4_should_order_data(inode))
> -			err = ext4_jbd2_inode_add_write(handle, inode);
> +			err = ext4_jbd2_inode_add_write(handle, inode, from,
> +					length);
>  	}
>  
>  unlock:
> diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
> index 1083a9f3f16a1..c7ded4e2adff5 100644
> --- a/fs/ext4/move_extent.c
> +++ b/fs/ext4/move_extent.c
> @@ -390,7 +390,8 @@ move_extent_per_page(struct file *o_filp, struct inode *donor_inode,
>  
>  	/* Even in case of data=writeback it is reasonable to pin
>  	 * inode to transaction, to prevent unexpected data loss */
> -	*err = ext4_jbd2_inode_add_write(handle, orig_inode);
> +	*err = ext4_jbd2_inode_add_write(handle, orig_inode,
> +			(loff_t)orig_page_offset << PAGE_SHIFT, replaced_size);
>  
>  unlock_pages:
>  	unlock_page(pagep[0]);
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

