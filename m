Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D781D6B027F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:04:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p10so1715218pfl.22
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:04:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m1-v6si3828543pls.673.2018.03.28.10.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Mar 2018 10:04:08 -0700 (PDT)
Date: Wed, 28 Mar 2018 10:04:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: do_mmap Function Issue Report
Message-ID: <20180328170407.GB639@bombadil.infradead.org>
References: <CAD5U=y8Q-9G+6n9bRs1BbirwhAJ5z0-CS7sG1q8ypqLaDyyHgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD5U=y8Q-9G+6n9bRs1BbirwhAJ5z0-CS7sG1q8ypqLaDyyHgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Po-Hao Su <supohaosu@gmail.com>
Cc: linux-mm@kvack.org

On Wed, Mar 28, 2018 at 11:19:30PM +0800, Po-Hao Su wrote:
> I am writing in reference to report a bug in *do_mmap(...)* function.
> Recently, I found that there seems a bug after *get_unmapped_area(...)
> *function
> is return.
> *do_mmap(...) *function will check the *addr *parameter is aligned on a
> page boundary or not after *get_unmapped_area(...)* function is return.
> But it will return *addr *parameter, not an error(probably to *-EINVAL*)
> while address not aligned on a page boundary.
> Therefore, I think address not aligned on a page boundary should be an
> error(*-EINVAL*).

Hi Po-Hao,

I'm afraid you've misunderstood the intent of this code.  The 'addr'
returned from get_unmapped_area() may be an errno, in which case we
want to return it.  Successful invocations of get_unmapped_area do,
of course, return an aligned address.  Your patch would make us return
-EINVAL for all errors, covering up the actual cause of the error (eg
-ENOMEM or -ENODEV)
