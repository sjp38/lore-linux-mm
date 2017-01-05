Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19B1D6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:14:26 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id dh1so60173486wjb.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:14:26 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y6si372111wmy.55.2017.01.05.14.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 14:14:25 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id u144so771441wmu.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:14:24 -0800 (PST)
Date: Fri, 6 Jan 2017 01:14:22 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: A use case for MAP_COPY
Message-ID: <20170105221422.GB27928@node.shutemov.name>
References: <CA+55aFyNFb7Ns7O2yjWsKZHOEzgGkyVznp=kLRE9an-mEUC0BQ@mail.gmail.com>
 <20170105211056.18340.qmail@ns.sciencehorizons.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105211056.18340.qmail@ns.sciencehorizons.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, riel@surriel.com

On Thu, Jan 05, 2017 at 04:10:56PM -0500, George Spelvin wrote:
> It just has to be less of a DoS attack than MAP_DENYWRITE.

It's easy to turn MAP_COPY into DoS:

  - in endless loop: mmap(MAP_COPY|MAP_FIXED) a victim file 1000 times (by
    distinct addresses) into your address space;

  - any attempt to write to the file would require to go through all
    mapping and put new page in every one;

  - by the time you've done with all 1000 VMAs, attacker created new bunch
    for you.

There's no way to guarantee it would ever complete (nasty hacks into
scheduler don't count).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
