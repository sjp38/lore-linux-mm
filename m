Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2176B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:35:25 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so12140193wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 04:35:24 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id c4si2748946wiy.27.2015.08.25.04.35.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 04:35:23 -0700 (PDT)
Received: by wijp15 with SMTP id p15so12792591wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 04:35:22 -0700 (PDT)
Date: Tue, 25 Aug 2015 13:35:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Message-ID: <20150825113521.GA6285@dhcp22.suse.cz>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
 <20150824113212.GL17078@dhcp22.suse.cz>
 <55DB1D94.3050404@hotmail.com>
 <COL130-W527FEAA0BEC780957B6B18B9620@phx.gbl>
 <20150824135716.GO17078@dhcp22.suse.cz>
 <55DB9278.2020603@qq.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55DB9278.2020603@qq.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@qq.com>
Cc: Chen Gang <xili_gchen_5257@hotmail.com>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On Tue 25-08-15 05:54:00, Chen Gang wrote:
> On 8/24/15 21:57, Michal Hocko wrote:
> > On Mon 24-08-15 21:34:25, Chen Gang wrote:
> 
> [...]
> 
> 
> >> It is always a little better to let the external function suppose fewer
> >> callers' behalf.
> > 
> > I am sorry but I do not understand what you are saying here.
> > 
> 
> Execuse me, my English maybe be still not quite well, my meaning is:
> 
>  - For the external functions (e.g. insert_vm_struct in our case), as a
>    callee, it may have to supose something from the caller.
> 
>  - If we can keep callee's functional contents no touch, a little fewer
>    supposing will let callee a little more independent from caller.
> 
>  - If can keep functional contens no touch, the lower dependency between
>    caller and callee is always better.

OK, I guess I understand what you mean. You are certainly right that a
partial initialization for the failure case is not nice in general. I
was just objecting that the callers are supposed to free the vma in
the failure case so any partial initialization doesn't matter in this
particular case.

Your patch would be more sensible if the failure case was more
likely. But this function is used for special mappings (vdso, temporary
vdso stack) which are created early in the process life time so both
failure paths are highly unlikely. If this was a part of a larger
changes where the function would be used elsewhere I wouldn't object at
all.

The reason I am skeptical about such changes in general is that
the effect is very marginal while it increases chances of the code
conflicts.

But as I've said, if others feel this is worthwhile I will not object.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
