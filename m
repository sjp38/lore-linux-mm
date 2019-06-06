Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D7CFC28D1E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:58:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E2AC206E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:58:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E2AC206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF8986B026B; Thu,  6 Jun 2019 06:58:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA98C6B026F; Thu,  6 Jun 2019 06:58:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97956B0270; Thu,  6 Jun 2019 06:58:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69B7D6B026B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:58:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s7so2080800edb.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:58:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fpgy2lN5a/yE57jAoHvcoQ5aUnLsxR1PYtwc2sGpdM4=;
        b=jixQlfSXJwEKxpyq8Be4PzTVbM0q7FwMs/cKfKSKZkiBc+smhk0Ue5rT73QS5Aoe3o
         uI+SsN8fqBn0Em/9x1NvbdHz1x4XO2tpfrUK1pI/dLv1mYuCMuhkllSeYMXjpFhRFGOG
         g5QVq6OfifeT9jBPmSPjEke/aXJgoKt0xNLFkHsjd+jWQr0NhLqdwyqX8g3qL8WWrIIc
         QhAE3xFlOhzyFF0nlG8e7AaydD6flKiY9TmQycrmklaNPUeoZv6fOmDEOAdKbLwUjg4/
         9qnPgZyEszYxoTm9+uY9sK6CGq4JzT1C5mxa1A4WA2m1O4LQ3qj9cKDUdh26HvhxqJoE
         evcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXVNi/MGSWYRZtroflK+WuQ1wGEhjxxWcdKsMcygypACJXP74IK
	6pr7baSa5McqSSwdie+MBA/VkGHse51Im8qhLd4vfadrAydKVNbSz1HRjbAO32q6nCyQQ3H8a0U
	y3OfUg44T2DXVQ6Gqqp6vfT3unBIiE1ceLnBwNFtITB/K4O4EcrgvFwfzn0eI/uEw3Q==
X-Received: by 2002:a50:a485:: with SMTP id w5mr49326629edb.78.1559818738023;
        Thu, 06 Jun 2019 03:58:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxahTBJPUjbKBH2eg5dRx0VtJ1aYt+6WWdvhVT+NnImgDUoWBBEmXbV5pCcHTGeZjYsC+gZ
X-Received: by 2002:a50:a485:: with SMTP id w5mr49326587edb.78.1559818737299;
        Thu, 06 Jun 2019 03:58:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559818737; cv=none;
        d=google.com; s=arc-20160816;
        b=NVFVhOPlFV0tRVQYhXyXefVfdHFFFR3Aqu2VluML2JyRaLfDNA0KXR8G78fdh6HHGz
         pdsS9+1sIzYmXfVgwgeEorGue4fqjE+VzCZSlr3U/juoc2RL/PeDPkAEPlfWyms8BN6u
         OJoVzZ5e4k7v1JIkyUVZMC6BLdB5c/cS0GkrDH1FS6yJtJmpOlTJw7DFz37VQRehNz3u
         go+8ehqzqm/k/3Oqarpb/kYWpQdrQP9sly0fHS0+4nMQngXFS4Z8hYOJQH1/YY6qM1Dv
         Iv7lRboRSqAmfk7FN+e2U+dqATRild6GObKyK5rbNon8PO6aphgji+Z4YWlx7yhdPy3L
         QSlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fpgy2lN5a/yE57jAoHvcoQ5aUnLsxR1PYtwc2sGpdM4=;
        b=Nt9Ga3oGc9l0HqrRdkOkw7e8n7zbOYzzzujAy8yQwLEabur48By79sh9fQUo7ZAXKn
         Mv1h9vgrma8TwZvsTxdZzW7nm6Ma3sCHeppQ1AVE9S/bDY5EtOWBpkkp8DmpgnIOZe2l
         FIbILJyt9/XDOWHai+PVTs8g2OK419CjtOjXd9BoKT8HrNj8Fa+FcmAOuaDamX5q6WZI
         ijyjl0YoQscUnNP+iUIaDFcd7mlqyTqYUxdvcxJvElyIj3+iwiUiRKuHD540uF5AXqKW
         3cn+4yTRoq3s17aZuSIbOmydsSDkOMWI6vvxEOWTD7Z3FalyTz4w2VPwFNIGpBd+2n2m
         p9Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si360573eda.46.2019.06.06.03.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 03:58:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7F9F6AF21;
	Thu,  6 Jun 2019 10:58:56 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id ED0EC1E3F51; Thu,  6 Jun 2019 12:58:55 +0200 (CEST)
Date: Thu, 6 Jun 2019 12:58:55 +0200
From: Jan Kara <jack@suse.cz>
To: ira.weiny@intel.com
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 07/10] fs/ext4: Fail truncate if pages are GUP pinned
Message-ID: <20190606105855.GG7433@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-8-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606014544.8339-8-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 18:45:40, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> If pages are actively gup pinned fail the truncate operation.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  fs/ext4/inode.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 75f543f384e4..1ded83ec08c0 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4250,6 +4250,9 @@ int ext4_break_layouts(struct inode *inode, loff_t offset, loff_t len)
>  		if (!page)
>  			return 0;
>  
> +		if (page_gup_pinned(page))
> +			return -ETXTBSY;
> +
>  		error = ___wait_var_event(&page->_refcount,
>  				atomic_read(&page->_refcount) == 1,
>  				TASK_INTERRUPTIBLE, 0, 0,

This caught my eye. Does this mean that now truncate for a file which has
temporary gup users (such buffers for DIO) can fail with ETXTBUSY? That
doesn't look desirable. If we would mandate layout lease while pages are
pinned as I suggested, this could be dealt with by checking for leases with
pins (breaking such lease would return error and not break it) and if
breaking leases succeeds (i.e., there are no long-term pinned pages), we'd
just wait for the remaining references as we do now.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

