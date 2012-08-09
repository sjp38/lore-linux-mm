Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 993206B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:46:38 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so292078ggn.14
        for <linux-mm@kvack.org>; Thu, 09 Aug 2012 02:46:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343447832-7182-2-git-send-email-john.stultz@linaro.org>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
	<1343447832-7182-2-git-send-email-john.stultz@linaro.org>
Date: Thu, 9 Aug 2012 02:46:37 -0700
Message-ID: <CANN689HWYO5DD_p7yY39ethcFu_JO9hudMcDHd=K8FUfhpHZOg@mail.gmail.com>
Subject: Re: [PATCH 1/5] [RFC] Add volatile range management code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jul 27, 2012 at 8:57 PM, John Stultz <john.stultz@linaro.org> wrote:
> v5:
> * Drop intervaltree for prio_tree usage per Michel &
>   Dmitry's suggestions.

Actually, I believe the ranges you need to track are non-overlapping, correct ?

If that is the case, a simple rbtree, sorted by start-of-range
address, would work best.
(I am trying to remove prio_tree users... :)

> +       /* First, find any existing intervals that overlap */
> +       prio_tree_iter_init(&iter, root, start, end);

Note that prio tree iterations take intervals as [start; last] not [start; end[
So if you want to stick with prio trees, you would have to use end-1 here.

> +       /* Coalesce left-adjacent ranges */
> +       prio_tree_iter_init(&iter, root, start-1, start);

Same here; you probably want to use start-1 on both ends

> +       node = prio_tree_next(&iter);
> +       while (node) {

I'm confused, I don't think you ever expect more than one range to
match, do you ???

> +       /* Coalesce right-adjacent ranges */
> +       prio_tree_iter_init(&iter, root, end, end+1);

Same again, here you probably want end on both ends

This is far from a complete code review, but I just wanted to point
out a couple details that jumped to me first. I am afraid I am missing
some of the background about how the feature is to be used to really
dig into the rest of the changes at this point :/

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
