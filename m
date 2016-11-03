Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69F576B02BF
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 01:40:38 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w63so7806589oiw.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 22:40:38 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id e68si4152737oib.253.2016.11.02.22.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 22:40:37 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id 128so4789366oih.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 22:40:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161102234755.4381f528@jkicinski-Precision-T1700>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
 <20161101172840.6d7d6278@jkicinski-Precision-T1700> <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
 <20161101185630.3c7d326f@jkicinski-Precision-T1700> <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
 <20161102234755.4381f528@jkicinski-Precision-T1700>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 2 Nov 2016 22:40:17 -0700
Message-ID: <CAM_iQpWHU_M3wYusHk6+4nY0kqGbqspLjvb6=YDVBdZCrUkdNg@mail.gmail.com>
Subject: Re: [RFC] make kmemleak scan __ro_after_init section (was: Re: [PATCH
 0/5] genetlink improvements)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jakub Kicinski <kubakici@wp.pl>
Cc: Johannes Berg <johannes@sipsolutions.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

On Wed, Nov 2, 2016 at 4:47 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
>
> Thanks for looking into this!  Bisect led me to the following commit:
>
> commit 56989f6d8568c21257dcec0f5e644d5570ba3281
> Author: Johannes Berg <johannes.berg@intel.com>
> Date:   Mon Oct 24 14:40:05 2016 +0200
>
>     genetlink: mark families as __ro_after_init
>
>     Now genl_register_family() is the only thing (other than the
>     users themselves, perhaps, but I didn't find any doing that)
>     writing to the family struct.
>
>     In all families that I found, genl_register_family() is only
>     called from __init functions (some indirectly, in which case
>     I've add __init annotations to clarifly things), so all can
>     actually be marked __ro_after_init.
>
>     This protects the data structure from accidental corruption.
>
>     Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
> I realized that kmemleak is not scanning the __ro_after_init section...
> Following patch solves the false positives but I wonder if it's the
> right/acceptable solution.

Nice work! Looks reasonable to me, but I am definitely not familiar
with kmemleak. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
