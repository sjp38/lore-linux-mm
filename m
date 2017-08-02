Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB3C6B0637
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 17:45:58 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v68so5051887oia.14
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 14:45:58 -0700 (PDT)
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com. [209.85.218.47])
        by mx.google.com with ESMTPS id t17si21386402oij.476.2017.08.02.14.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 14:45:57 -0700 (PDT)
Received: by mail-oi0-f47.google.com with SMTP id x3so57277170oia.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 14:45:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170802105018.GA2529@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz>
From: Paul Moore <pmoore@redhat.com>
Date: Wed, 2 Aug 2017 17:45:56 -0400
Message-ID: <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jeff Vander Stoep <jeffv@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, selinux@tycho.nsa.gov

On Wed, Aug 2, 2017 at 6:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Hi,
> while doing something completely unrelated to selinux I've noticed a
> really strange __GFP_NOMEMALLOC usage pattern in selinux, especially
> GFP_ATOMIC | __GFP_NOMEMALLOC doesn't make much sense to me. GFP_ATOMIC
> on its own allows to access memory reserves while the later flag tells
> we cannot use memory reserves at all. The primary usecase for
> __GFP_NOMEMALLOC is to override a global PF_MEMALLOC should there be a
> need.
>
> It all leads to fa1aa143ac4a ("selinux: extended permissions for
> ioctls") which doesn't explain this aspect so let me ask. Why is the
> flag used at all? Moreover shouldn't GFP_ATOMIC be actually GFP_NOWAIT.
> What makes this path important to access memory reserves?

[NOTE: added the SELinux list to the CC line, please include that list
when asking SELinux questions]

The GFP_ATOMIC|__GFP_NOMEMALLOC use in SELinux appears to be limited
to security/selinux/avc.c, and digging a bit, I'm guessing commit
fa1aa143ac4a copied the combination from 6290c2c43973 ("selinux: tag
avc cache alloc as non-critical") and the avc_alloc_node() function.

I can't say that I'm an expert at the vm subsystem and the variety of
different GFP_* flags, but your suggestion of moving to GFP_NOWAIT in
security/selinux/avc.c seems reasonable and in keeping with the idea
behind commit 6290c2c43973.

-- 
paul moore
security @ redhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
