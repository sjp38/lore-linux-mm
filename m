Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 31E846B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:33:39 -0500 (EST)
Date: Tue, 14 Feb 2012 13:33:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
Message-Id: <20120214133337.9de7835b.akpm@linux-foundation.org>
In-Reply-To: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sun, 12 Feb 2012 01:21:35 +0100
Andrea Righi <andrea@betterlinux.com> wrote:

> The new proposal is to implement POSIX_FADV_NOREUSE as a way to perform a real
> drop-behind policy where applications can mark certain intervals of a file as
> FADV_NOREUSE before accessing the data.

I think you and John need to talk to each other, please.  The amount of
duplication here is extraordinary.

Both patchsets add fields to the address_space (and hence inode), which
is significant - we should convince ourselves that we're getting really
good returns from a feature which does this.



Regarding the use of fadvise(): I suppose it's a reasonable thing to do
in the long term - if the feature works well, popular data streaming
applications will eventually switch over.  But I do think we should
explore interfaces which don't require modification of userspace source
code.  Because there will always be unconverted applications, and the
feature becomes available immediately.

One such interface would be to toss the offending application into a
container which has a modified drop-behind policy.  And here we need to
drag out the crystal ball: what *is* the best way of tuning application
pagecache behaviour?  Will we gravitate towards containerization, or
will we gravitate towards finer-tuned fadvise/sync_page_range/etc
behaviour?  Thus far it has been the latter, and I don't think that has
been a great success.

Finally, are the problems which prompted these patchsets already
solved?  What happens if you take the offending streaming application
and toss it into a 16MB memcg?  That *should* avoid perturbing other
things running on that machine.

And yes, a container-based approach is pretty crude, and one can
envision applications which only want modified reclaim policy for one
particualr file.  But I suspect an application-wide reclaim policy
solves 90% of the problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
