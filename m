Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48935C28EBD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 01:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00EFB206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 01:51:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00EFB206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83AA06B0266; Sun,  9 Jun 2019 21:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EA9B6B0269; Sun,  9 Jun 2019 21:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 701586B026A; Sun,  9 Jun 2019 21:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C89D6B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 21:51:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n126so7041612qkc.18
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 18:51:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tb+JzOwVOTLv433ezXVmPOE0ZFocomL8gQwNfPZ6/cY=;
        b=Aa9cqJ9JwqR/oOPFmOmiHwgTiuqzuv3Px8QJI2MhSJNuzR6SVRKGnISB0BPdXSNsxN
         ekF9aGrRVwN/GXS134KOtXzYu+2IwR46ID8F3b5oap62ox2ITHqWafAPTkOlfVGD+ERd
         OtcFjgq+PvfhrVbONA1sJZ9K5XVvQpD6wuuupDuM8sLVcb9EnY9eyje/Fto9TOfY8JFB
         2XicDuTDPIhoyDIgZFm5UnwYNwraN5LWhEtvRvhh3uXx+EH7cRi1IzP4ifFcHML5IxWr
         lGx1wPXlwJ6aB0rTIjNEttC0lTpFErDMYKkrhzyot40ZqOdOeUbzU4Oi6f0X2sZjgjZv
         +Okg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAWcYE8CvgYa+PF9X3wA5tQNd/SLCL84cD6YEjJhqWthVofeNGdV
	fi0sqcjxdQFURwtYC/6V7e56HqcQ/6x7TF+kwv3g9AkD6NVJg3z7/quGfoaIZ/AeBIPfOETyDgm
	HGWI35rvaiKaViQwLDxZhipmexReUwD17leyK4N8IOLXMBCmCtmY4oKf8AnbMYsz/Jw==
X-Received: by 2002:ac8:2646:: with SMTP id v6mr37766303qtv.205.1560131508178;
        Sun, 09 Jun 2019 18:51:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlxzFJpOH+8cZg3I8AD79Y7OeqmIF8Ti2/XHPe4EnnBNsN2wP5iS7T4N1wGWh0DpVwTBCA
X-Received: by 2002:ac8:2646:: with SMTP id v6mr37766286qtv.205.1560131507712;
        Sun, 09 Jun 2019 18:51:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560131507; cv=none;
        d=google.com; s=arc-20160816;
        b=dJ3x0WVSRORTU0FP0lo9HvcF9DCscTD56+vcGcBfFltROMri9rMdAEjkyNfrKxNztI
         V/7Y+hcGY+x+xNQD7Lpv4oP0B3k+s8EnCYL4PfKVE17H8SN6u7a5XnGHAoWHUiKRO9fO
         jYLvKUiESHFgAPkNb8fGSBUZSnrjgMG2rBPNXoLFgc2eOJVY456JXexqx7jA+rX+uKR2
         W6BzMgrXtSiBMwtmlbQqCOH9/TcYjMb7LTjOVFMToVpSrHHQLWlYFzhXqe7syCCFc06I
         S7u3mjiNFjV7IhOXa38OwyglKRpEsjAk3/C9HS1yoZ3blW/VH7hhRWHlnuNUSqlQlL7V
         J07g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tb+JzOwVOTLv433ezXVmPOE0ZFocomL8gQwNfPZ6/cY=;
        b=sFA4bOM+eFRzOsubzsySy/7gTc6wzcxp8KZ1INl+qDPi5lnyBKg1OzFcdrQiy0PD7E
         XRSSZ5OWcGh+V26MkCM8cqSmf6Y5fm90NoWGzTOe4GoS7hwRS+USjxzWnVtDeO/LmiAA
         W9eEeGhsBBdziAAJQ4nU0ek7/fUFNLhHrR4sPjFs9ynRWbVRAk1ZzrqRxDopC09sz+Ep
         uUvLW2w3UYCw2tVQYzjK47ESNBbyDSgk/MKdE7zMAQtufAARAOkSpZhe40v7KqwIQbQA
         fHk2cc7hMxV4xgYFhjD3Fov9C4TAi0x5+0fJnSUIPtFFrLWlpRIaLomBmKue9Xgi871d
         Ms3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id g187si92161qkc.5.2019.06.09.18.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 18:51:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5A1pjIR002876
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Sun, 9 Jun 2019 21:51:46 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id C99A2420481; Sun,  9 Jun 2019 21:51:45 -0400 (EDT)
Date: Sun, 9 Jun 2019 21:51:45 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610015145.GB3266@mit.edu>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552787330.20411.11893581890744963309.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:04:33PM -0700, Darrick J. Wong wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index ab650c21bccd..dfd5eba278d6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2149,6 +2149,9 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
>  
>  	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>  
> +	if (vmf->vma->vm_file && IS_IMMUTABLE(file_inode(vmf->vma->vm_file)))
> +		return VM_FAULT_SIGBUS;
> +
>  	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
>  	/* Restore original flags so that caller is not surprised */
>  	vmf->flags = old_flags;

Shouldn't this check be moved before the modification of vmf->flags?
It looks like do_page_mkwrite() isn't supposed to be returning with
vmf->flags modified, lest "the caller gets surprised".

	   	     	       	      	   - Ted

