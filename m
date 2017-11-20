Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 489596B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 03:55:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 11so3222337wrb.18
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 00:55:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a21si8029852edm.378.2017.11.20.00.55.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 00:55:26 -0800 (PST)
Date: Mon, 20 Nov 2017 09:55:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171120085524.y4onsl5dpd3qbh7y@dhcp22.suse.cz>
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116101900.13621-2-mhocko@kernel.org>
 <a3f7aed9-0df2-2fd6-cebb-ba569ad66781@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3f7aed9-0df2-2fd6-cebb-ba569ad66781@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org

On Fri 17-11-17 08:30:48, Florian Weimer wrote:
> On 11/16/2017 11:18 AM, Michal Hocko wrote:
> > +	if (flags & MAP_FIXED_SAFE) {
> > +		struct vm_area_struct *vma = find_vma(mm, addr);
> > +
> > +		if (vma && vma->vm_start <= addr)
> > +			return -ENOMEM;
> > +	}
> 
> Could you pick a different error code which cannot also be caused by a an
> unrelated, possibly temporary condition?  Maybe EBUSY or EEXIST?

Hmm, none of those are described in the man page. I am usually very
careful to not add new and potentially unexpected error codes but it is
true that a new flag should warrant a new error code. I am not sure
which one is more appropriate though. EBUSY suggests that retrying might
help which is true only if some other party unmaps the range. So EEXIST
would sound more natural.

> This would definitely help with application-based randomization of mappings,
> and there, actual ENOMEM and this error would have to be handled
> differently.

I see. Could you be more specific about the usecase you have in mind? I
would incorporate it into the patch description.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
