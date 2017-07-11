Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C71A6B04B5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:04:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so29196861wrc.15
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:04:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si9216724wrb.265.2017.07.10.23.03.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:03:59 -0700 (PDT)
Date: Tue, 11 Jul 2017 08:03:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/mremap: Remove redundant checks inside vma_expandable()
Message-ID: <20170711060354.GA24852@dhcp22.suse.cz>
References: <20170710111059.30795-1-khandual@linux.vnet.ibm.com>
 <20170710134917.GB19645@dhcp22.suse.cz>
 <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6f9ec12-4518-8f97-eca9-6592808b839d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Tue 11-07-17 09:58:42, Anshuman Khandual wrote:
> On 07/10/2017 07:19 PM, Michal Hocko wrote:
> > On Mon 10-07-17 16:40:59, Anshuman Khandual wrote:
> >> As 'delta' is an unsigned long, 'end' (vma->vm_end + delta) cannot
> >> be less than 'vma->vm_end'.
> > 
> > This just doesn't make any sense. This is exactly what the overflow
> > check is for. Maybe vm_end + delta can never overflow because of
> > (old_len == vma->vm_end - addr) and guarantee old_len < new_len
> > in mremap but I haven't checked that too deeply.
> 
> Irrespective of that, just looking at the variables inside this
> particular function where delta is an 'unsigned long', 'end' cannot
> be less than vma->vm_end. Is not that true ?

no. What happens when end is too large?

[...]

> > here. This is hardly something that would save many cycles in a
> > relatively cold path.
> 
> Though I have not done any detailed instruction level measurement,
> there is a reduction in real and system amount of time to execute
> the test with and without the patch.
> 
> Without the patch
> 
> real	0m2.100s
> user	0m0.162s
> sys	0m1.937s
> 
> With this patch
> 
> real	0m0.928s
> user	0m0.161s
> sys	0m0.756s

Are you telling me that two if conditions cause more than a second
difference? That sounds suspicious.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
