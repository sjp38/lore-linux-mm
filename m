Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D36CC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 647C5222A1
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 647C5222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7D778E0146; Mon, 11 Feb 2019 14:28:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E354B8E0134; Mon, 11 Feb 2019 14:28:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D42748E0146; Mon, 11 Feb 2019 14:28:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90CD88E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:28:02 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so51773pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:28:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NCH24E5W1G3TBmUaU6lY6Ca2qnNKvPyFZAcuoX7ZFCo=;
        b=JYSOz0k5V+DQoDmyxvG4AhUHBuulwDkbVA7ttyu/h1w/DHhEI7F6YF9zkA+qbQBB+n
         bDcW1hOYix7d73df4NJ52pR8MXzypYsDdGx5K8jY1fSfVX/FBywx47EKFh6IY46EZ3fO
         6m0F3GUmo71/95q9hotMhrWK56H0NY3xsBrVWzFxlazPvdTyUTVCN43nPA3gheeH4MPH
         rmqW+gQa9IoHgo1hZLwwDuKcfs7v5UohcYUv9JzaIN/23QaRMj48qQaVdaO8VzQY4Njr
         DH3ToBwdgHEVHtDy7P9y7E2rz7GNS/t92bz4x0TFfVIeZUbGjwDiub82Dx6Lr4K2PAJX
         mDRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAubjjrcVjFDzReGcavlA1IcVOT1UfpRqqXt8Idwq1R2O2nP41Fh8
	B4TSXtRA6c//mil6/IKYbel4M1UzQLpCkXNUU4//ESwYROJclm1wt1tqv5Pvxq4wHxv3pcN7BP4
	+eGgCq80+WTJCupuGyTIhSWnT4U3CDBQ9KsX5CuorQRT+v8djw76BGYovOV5MSmpUrg==
X-Received: by 2002:a17:902:128c:: with SMTP id g12mr37705563pla.146.1549913282259;
        Mon, 11 Feb 2019 11:28:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaTJMBI0OJpjvSeUlq9hlMoBmwzJD7MZMUFKhp0hLiT15DldYfcKl7SqImmKVZcooEZlbAu
X-Received: by 2002:a17:902:128c:: with SMTP id g12mr37705510pla.146.1549913281506;
        Mon, 11 Feb 2019 11:28:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913281; cv=none;
        d=google.com; s=arc-20160816;
        b=F5k/NuBsL6qKf2nErbDmATSK8daxOLwg2W6OEdEsUFoJh5DgVmuRYgIvvK6HuS613R
         xFDMXbVhCmhEsmueJWUFdJV7cJGOEcZIemmJIR7iKY98Ho1rGhshgPny0Ebv6ToQjTji
         DlL1SEViEyiaL7V6X6uu/UM4QaEbwG1guXZpjLle3NFRSWYDyaR9vyUoOyclmf2ntED8
         aqdti4p+7Fl3LWrT8x511IC03rIQsU30pOU7duOL3padNLXD6L0pxzSo8IAMHOi2XAxD
         O53TkKx3oQaePS6REQg5rQYxUX8/y/xG1joLJ+TvED2VUVGCdC3fiFZn4GvE2QDJPzJ+
         +CTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=NCH24E5W1G3TBmUaU6lY6Ca2qnNKvPyFZAcuoX7ZFCo=;
        b=PuRu0Dy1b86EOSK5rFCMOGQJ9fK/tG5ap9HQvaQonXwiesK33TwxRWTeA19P4Mh5R/
         pfGXcxwIw2asklTMH4TOmlnlF9Ys47L/SNmo5ne3b4qJS7HYLYzyqzYYx90xGcoq1R61
         PIFRbrIfNNOzt7PUtKhJh7YK4aKQi4ZQ9IcxWZESsOrRqQZa7SZHABrHLCp8E+BzU29v
         L3xDadSO+K5r1ZzTZPlOuY0LegQaMeHymzQeHchP6+va0iWfsslYufaXvGhZHeeb4dCN
         n4DjW6aJPnrfd8e3HJ1fTr95SvutVn+uMRG3akei45c+n3AqdbFBxPHF2WdDN3/I3MGz
         HtrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b8si9784963pgw.561.2019.02.11.11.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:28:01 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 1F7BFD72F;
	Mon, 11 Feb 2019 19:28:01 +0000 (UTC)
Date: Mon, 11 Feb 2019 11:27:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: <rcampbell@nvidia.com>
Cc: <linux-mm@kvack.org>, Waiman Long <longman@redhat.com>
Subject: Re: [PATCH] numa: Change get_mempolicy() to use nr_node_ids instead
 of MAX_NUMNODES
Message-Id: <20190211112759.a7441b3486ea0b26dec40786@linux-foundation.org>
In-Reply-To: <20190211180245.22295-1-rcampbell@nvidia.com>
References: <20190211180245.22295-1-rcampbell@nvidia.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 10:02:45 -0800 <rcampbell@nvidia.com> wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The system call, get_mempolicy() [1], passes an unsigned long *nodemask
> pointer and an unsigned long maxnode argument which specifies the
> length of the user's nodemask array in bits (which is rounded up).
> The manual page says that if the maxnode value is too small,
> get_mempolicy will return EINVAL but there is no system call to return
> this minimum value. To determine this value, some programs search
> /proc/<pid>/status for a line starting with "Mems_allowed:" and use
> the number of digits in the mask to determine the minimum value.
> A recent change to the way this line is formatted [2] causes these
> programs to compute a value less than MAX_NUMNODES so get_mempolicy()
> returns EINVAL.
> 
> Change get_mempolicy(), the older compat version of get_mempolicy(), and
> the copy_nodes_to_user() function to use nr_node_ids instead of
> MAX_NUMNODES, thus preserving the defacto method of computing the
> minimum size for the nodemask array and the maxnode argument.
> 
> [1] http://man7.org/linux/man-pages/man2/get_mempolicy.2.html
> [2] https://lore.kernel.org/lkml/1545405631-6808-1-git-send-email-longman@redhat.com
> 

Ugh, what a mess.

For a start, that's a crazy interface.  I wish that had been brought to
our attention so we could have provided a sane way for userspace to
determine MAX_NUMNODES.

Secondly, 4fb8e5b89bcbbb ("include/linux/nodemask.h: use nr_node_ids
(not MAX_NUMNODES) in __nodemask_pr_numnodes()") introduced a
regession.  The proposed get_mempolicy() change appears to be a good
one, but is a strange way of addressing the regression.  I suppose it's
acceptable, as long as this change is backported into kernels which
have 4fb8e5b89bcbbb.

