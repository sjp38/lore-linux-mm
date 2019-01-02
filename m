Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2D08E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:47:54 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id c33so14860221otb.18
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:47:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z89sor138199otb.62.2019.01.02.09.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 09:47:53 -0800 (PST)
MIME-Version: 1.0
References: <20181203170934.16512-1-vpillai@digitalocean.com>
 <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
 <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com> <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Wed, 2 Jan 2019 12:47:43 -0500
Message-ID: <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Tue, Jan 1, 2019 at 11:16 PM Hugh Dickins <hughd@google.com> wrote:
> One more fix on top of what I sent yesterday: once I delved into
> the retries, I found that the major cause of exceeding MAX_RETRIES
> was the way the retry code neatly avoided retrying the last part of
> its work.  With this fix in, I have not yet seen retries go above 1:
> no doubt it could, but at present I have no actual evidence that
> the MAX_RETRIES-or-livelock issue needs to be dealt with urgently.
> Fix sent for completeness, but it reinforces the point that the
> structure of try_to_unuse() should be reworked, and oldi gone.
>

Thanks for the fix and suggestions Hugh!

After reading the code again, I feel like we can make the retry logic
simpler and avoid the use of oldi. If my understanding is correct,
except for frontswap case, we reach try_to_unuse() only after we
disable the swap device. So I think, we would not be seeing any more
swap usage on the disabled swap device, after we loop through all the
process and swapin the pages on that device. In that case, we would
not need the retry logic right?
For frontswap case, the patch was missing a check for pages_to_unuse.
We would still need the retry logic, but as you mentioned, I can
easily remove the oldi logic and make it simpler. Or probably,
refactor the frontswap code out as a special case if pages_to_unuse is
still not zero after the initial loop.

Thanks,
Vineeth
