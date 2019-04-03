Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F785C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:19:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 277D2205C9
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:19:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 277D2205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CB3E6B0008; Wed,  3 Apr 2019 13:19:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97BCD6B000C; Wed,  3 Apr 2019 13:19:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89DF06B0008; Wed,  3 Apr 2019 13:19:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C22B6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:19:41 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id y7so13569733wrq.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:19:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=Nrovqt/E3sLIY0UINWIZm4LZjlIUz46vFJMaX0OPy6U=;
        b=rY+KQ4sLnAIGNBrjCelkvxmdWJOnhI7HPdo4sFbKqHdL5Y9fWRv1xZfEPHXSZT+C/C
         C445qBDwT3jJZqXaoAhFAdkB2h6O7HDHS8pSdXtUc4Yhdr1jBC9So5JZLv1LnCFP/YXQ
         N5BCmudtfUh2kz1YEfOZj7bd4cRuci7oNLe+jIvKFdIjT5rRs+H8gidC/VdR0RkcHzSj
         sWYhpvSqhdDxe+KyFhZm44v4DdlfYLqCAHr8IyVdtlZ2qDWoaceVY2DePdVGtXjl3xKC
         G1lv1BS/pVx5mV3lwJxNTIXAvF6ivcM6R+yzutIZZgIh+SZG04/y20O8/Kp2mG1OwAem
         9fcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAX4nfPTEamLdbJMRFwHVTICm8yL68+YIVVwNq8uQc3QeuVM+nvY
	JiV8DlFdxLFbOnpuXFVtAbmFqO7cE4fwQ3BEdjmSnFphym8S9A4gCJDnYsajN8YOt5mpd3/sptp
	YoH5ArGH3I12r7+JVeWKTpxqkW/wu3WusnRAzSMDtKzT8hNDutSf0u0Rgll+XOADaQQ==
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr768577wmc.117.1554311980819;
        Wed, 03 Apr 2019 10:19:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzvdGXDKOvYDn11Chb3nzFbtuDTPacLWdj0ALM2FzqeYXUa6mdAxyGhxNX5N6unq2tSXTC
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr768532wmc.117.1554311979928;
        Wed, 03 Apr 2019 10:19:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554311979; cv=none;
        d=google.com; s=arc-20160816;
        b=ooBVdA9oasEqRNoC5L7nHyfgmFoNtbfzhUeSoZGbgZ+6Zi6qHb8RYuC1YTjwkxhUtd
         pH15SyhWDhTCt2OpxgFt9ey/Ij2DYguu86YXQjY5CHE2KXLPAjKoGRFwfBTAxuN65NZ9
         3NTp5mJU/8R07AJHdNenyEkkMVFCtXvp7IiTxElHHIUOGJOkZv00pC4rjZPFyK/SFZr9
         WCKC79WtnfyRWetaJUcvLLBKk5KrieTqiXpiy6LrV43ZePRBbZ4hflLt1qpXLCxUoBKz
         Yr5G4ycWhz+D+FpTlRhBMFXDKgC3WQPBvPcOiFsSDk4uvM7b0c/MNf30ngFxEdKNTjM0
         j5rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=Nrovqt/E3sLIY0UINWIZm4LZjlIUz46vFJMaX0OPy6U=;
        b=SbLEru+5PbpKe0Z59CpZfuCc138S6JMtDMVO6lULMGHleXc8mAHmjtfgah05N/xdZ7
         0NyhHWnXzTvQcnVeYs4jvhgCLvc/3uenbYuZgsYvuHAcGWHpvdZh/mOZ1sXG5BDyFfIk
         ZrBYbxcIu2DZ80Yv7n39iari3xcaVhkxX4y1gFAB34qja1rv5JUNmiZHoLD9BRWct8ik
         cdDdUzDBEMyVT1hEVkY8MRErY1fYD0iGOq5DuNBYPLvEjEFF0IRlcanZwshplVF+KnAy
         0b3acDSx8XIcxtrMDmoxgVN1yoOk7yMt6sEjZhtImeSmIwX51lotb07OCPvI+nUYbhSe
         79dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id c4si10576958wrv.79.2019.04.03.10.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:19:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hBjXl-000498-1C; Wed, 03 Apr 2019 17:19:21 +0000
Date: Wed, 3 Apr 2019 18:19:21 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
Message-ID: <20190403171920.GS2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403170811.GR2217@ZenIV.linux.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:08:11PM +0100, Al Viro wrote:

> Oh, *brilliant*
> 
> Let's do d_invalidate() on random dentries and hope they go away.
> With convoluted and brittle logics for deciding which ones to
> spare, which is actually wrong.  This will pick mountpoints
> and tear them out, to start with.
> 
> NAKed-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> And this is a NAK for the entire approach; if it has a positive refcount,
> LEAVE IT ALONE.  Period.  Don't play this kind of games, they are wrong.
> d_invalidate() is not something that can be done to an arbitrary dentry.

PS: "try to evict what can be evicted out of this set" can be done, but
you want something like
	start with empty list
	go through your array of references
		grab dentry->d_lock
		if dentry->d_lockref.count is not zero
			unlock and continue
		if dentry->d_flags & DCACHE_SHRINK_LIST
			ditto, it's not for us to play with
                if (dentry->d_flags & DCACHE_LRU_LIST)
                        d_lru_del(dentry);
		d_shrink_add(dentry, &list);
		unlock

on the collection phase and
	if the list is not empty by the end of that loop
		shrink_dentry_list(&list);
on the disposal.

