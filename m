Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f44.google.com (mail-vn0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDCC6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:41:52 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so1353748vnb.12
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:41:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id xg5si36103483vdb.106.2015.04.28.15.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:41:51 -0700 (PDT)
Message-ID: <55400CA7.3050902@redhat.com>
Date: Tue, 28 Apr 2015 18:41:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
References: <20150428221553.GA5770@node.dhcp.inet.fi>
In-Reply-To: <20150428221553.GA5770@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On 04/28/2015 06:15 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 28, 2015 at 01:42:10PM -0700, Andy Lutomirski wrote:
>> At some point, I'd like to implement PCID on x86 (if no one beats me
>> to it, and this is a low priority for me), which will allow us to skip
>> expensive TLB flushes while context switching.  I have no idea whether
>> ARM can do something similar.
> 
> I talked with Dave about implementing PCID and he thinks that it will be
> net loss. TLB entries will live longer and it means we would need to trigger
> more IPIs to flash them out when we have to. Cost of IPIs will be higher
> than benifit from hot TLB after context switch.

I suspect that may depend on how you do the shootdown.

If, when receiving a TLB shootdown for a non-current PCID, we just flush
all the entries for that PCID and remove the CPU from the mm's
cpu_vm_mask_var, we will never receive more than one shootdown IPI for
a non-current mm, but we will still get the benefits of TLB longevity
when dealing with eg. pipe workloads where tasks take turns running on
the same CPU.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
