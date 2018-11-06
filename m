Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 267BB6B02CA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:22:24 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h24-v6so3182442ede.9
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:22:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b55-v6si3612956edb.252.2018.11.06.00.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 00:22:22 -0800 (PST)
Date: Tue, 6 Nov 2018 09:22:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kstrdup_quotable_cmdline and gfp flags
Message-ID: <20181106082221.GB27423@dhcp22.suse.cz>
References: <84197642-f414-81dc-ee68-1a4c1cdea5ae@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84197642-f414-81dc-ee68-1a4c1cdea5ae@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Kees Cook <keescook@chromium.org>, Jordan Crouse <jcrouse@codeaurora.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon 05-11-18 22:32:07, Rasmus Villemoes wrote:
> kstrdup_quotable_cmdline takes gfp flags and passes those on to
> kstrdup_quotable, but before that it has done a kmalloc(PAGE_SIZE) with
> a hard-coded GFP_KERNEL. There is one caller of kstrdup_quotable_cmdline
> which passes GFP_ATOMIC, and the commit introducing that (65a3c2748e)
> conveniently has this piece of history:
> 
>     v2: Use GFP_ATOMIC while holding the rcu lock per Chris Wilson
> 
> So, should the GFP_KERNEL in kstrdup_quotable_cmdline simply be changed
> to use the passed-in gfp, or is there some deeper reason for the
> GFP_KERNEL (in which case it doesn't really make sense to take gfp at
> all...)?

I would just drop the gfp argument and move comm = kstrdup(task->comm, GFP_ATOMIC);
before rcu read lock

The code in its current form is buggy.
-- 
Michal Hocko
SUSE Labs
