Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3C086B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 18:39:20 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so37884666wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 15:39:20 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id l1si5734870wmg.22.2016.12.16.15.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 15:39:19 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id kp2so16251993wjc.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 15:39:19 -0800 (PST)
Date: Sat, 17 Dec 2016 00:39:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] bpf: do not use KMALLOC_SHIFT_MAX
Message-ID: <20161216233917.GB23392@dhcp22.suse.cz>
References: <20161215164722.21586-1-mhocko@kernel.org>
 <20161215164722.21586-2-mhocko@kernel.org>
 <20161216180209.GA77597@ast-mbp.thefacebook.com>
 <20161216220235.GD7645@dhcp22.suse.cz>
 <20161216232340.GA99159@ast-mbp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216232340.GA99159@ast-mbp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-mm@kvack.org, Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>

On Fri 16-12-16 15:23:42, Alexei Starovoitov wrote:
> On Fri, Dec 16, 2016 at 11:02:35PM +0100, Michal Hocko wrote:
> > On Fri 16-12-16 10:02:10, Alexei Starovoitov wrote:
> > > On Thu, Dec 15, 2016 at 05:47:21PM +0100, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > 01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
> > > > overflow") has added checks for the maximum allocateable size. It
> > > > (ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
> > > > it is not very clean because we already have KMALLOC_MAX_SIZE for this
> > > > very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.
> > > > 
> > > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > Nack until the patches 1 and 2 are reversed.
> > 
> > I do not insist on ordering. The thing is that it shouldn't matter all
> > that much. Or are you worried about bisectability?
> 
> This patch 1 strongly depends on patch 2 !
> Therefore order matters.
> The patch 1 by itself is broken.
> The commit log is saying
> '(ab)used KMALLOC_SHIFT_MAX for that purpose .. use KMALLOC_MAX_SIZE instead'
> that is also incorrect. We cannot do that until KMALLOC_MAX_SIZE is fixed.
> So please change the order

Yes, I agree that using KMALLOC_MAX_SIZE could lead to a warning with
the current ordering. Why that matters all that much is less clear to
me. The allocation would simply fail and you would return ENOMEM rather
than E2BIG. Does this really matter?

Anyway, as I've said, I do not really insist on the current ordering and
the will ask Andrew to reorder them. I am just really wondering about
such a strong pushback about something that barely matters. Or maybe I
am just missing your point and checking KMALLOC_MAX_SIZE without an
update would lead to a wrong behavior, user space breakage, crash or
anything similar.

> and fix the commit log to say that KMALLOC_MAX_SIZE
> is actually valid limit now.

KMALLOC_MAX_SIZE has always been the right limit. It's value has been
incorrect but that is to be fixed now. Using KMALLOC_SHIFT_MAX is simply
abusing an internal constant. So I am not sure what should be fixed in
the changelog.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
