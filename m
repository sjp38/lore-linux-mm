Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 67F819000BD
	for <linux-mm@kvack.org>; Sun, 26 Jun 2011 18:47:59 -0400 (EDT)
Message-ID: <4E07B709.9010306@redhat.com>
Date: Sun, 26 Jun 2011 18:47:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] fadvise: implement POSIX_FADV_NOREUSE
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com> <1308923350-7932-3-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308923350-7932-3-git-send-email-andrea@betterlinux.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/24/2011 09:49 AM, Andrea Righi wrote:

> @@ -114,7 +114,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>   			ret = 0;
>   		break;
>   	case POSIX_FADV_NOREUSE:
> -		break;
> +		/* Reduce cache eligibility */
> +		force = false;
>   	case POSIX_FADV_DONTNEED:
>   		if (!bdi_write_congested(mapping->backing_dev_info))
>   			filemap_flush(mapping);

And the same is true here.  "force" is just not a very
descriptive name.

> @@ -124,8 +125,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>   		end_index = (endbyte>>  PAGE_CACHE_SHIFT);
>
>   		if (end_index>= start_index)
> -			invalidate_mapping_pages(mapping, start_index,
> -						end_index);
> +			__invalidate_mapping_pages(mapping, start_index,
> +						end_index, force);
>   		break;
>   	default:
>   		ret = -EINVAL;


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
