Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2A44F6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:35:05 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id to4so16954980igc.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:35:05 -0800 (PST)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com. [209.85.223.180])
        by mx.google.com with ESMTPS id y79si39055460ioi.7.2016.01.05.07.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:35:04 -0800 (PST)
Received: by mail-io0-f180.google.com with SMTP id q21so189680091iod.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:35:04 -0800 (PST)
Date: Tue, 5 Jan 2016 16:35:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: __vmalloc() vs. GFP_NOIO/GFP_NOFS
Message-ID: <20160105153501.GB15594@dhcp22.suse.cz>
References: <20160103071246.GK9938@ZenIV.linux.org.uk>
 <20160103201233.GC6682@dastard>
 <20160103203514.GN9938@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160103203514.GN9938@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>

On Sun 03-01-16 20:35:14, Al Viro wrote:
[...]
> BTW, far scarier one is not GFP_NOFS or GFP_IO - there's a weird
> caller passing GFP_ATOMIC to __vmalloc(), for no reason I can guess.
> 
> _That_ really couldn't be handled without passing gfp_t to page allocation
> primitives, but I very much doubt that it's needed there at all; it's in
> alloc_large_system_hash() and I really cannot imagine a situation when
> it would be used in e.g. a nonblocking context.

Yeah, this is an __init context. The original commit which has added it
doesn't explain GFP_ATOMIC at all. It just converted alloc_bootmem to
__vmalloc resp. __get_free_pages based on the size. So we can only guess
it wanted to (ab)use memory reserves.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
