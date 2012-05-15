Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 084B16B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 00:47:44 -0400 (EDT)
Message-ID: <4FB1E00F.2000903@kernel.org>
Date: Tue, 15 May 2012 13:48:15 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] documentation: update how page-cluster affects swap
 I/O
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1336996709-8304-3-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1336996709-8304-3-git-send-email-ehrhardt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, axboe@kernel.dk, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/14/2012 08:58 PM, ehrhardt@linux.vnet.ibm.com wrote:

> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> 
> Fix of the documentation of /proc/sys/vm/page-cluster to match the behavior of
> the code and add some comments about what the tunable will change in that
> behavior.
> 
> Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> ---
>  Documentation/sysctl/vm.txt |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 96f0ee8..4d87dc0 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -574,16 +574,24 @@ of physical RAM.  See above.
>  
>  page-cluster
>  
> -page-cluster controls the number of pages which are written to swap in
> -a single attempt.  The swap I/O size.
> +page-cluster controls the number of pages up to which consecutive pages (if
> +available) are read in from swap in a single attempt. This is the swap


"If available" would be wrong in next kernel because recently Rik submit following patch,

mm: make swapin readahead skip over holes
http://marc.info/?l=linux-mm&m=132743264912987&w=4


> +counterpart to page cache readahead.
> +The mentioned consecutivity is not in terms of virtual/physical addresses,
> +but consecutive on swap space - that means they were swapped out together.
>  
>  It is a logarithmic value - setting it to zero means "1 page", setting
>  it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
> +Zero disables swap readahead completely.
>  
>  The default value is three (eight pages at a time).  There may be some
>  small benefits in tuning this to a different value if your workload is
>  swap-intensive.
>  
> +Lower values mean lower latencies for initial faults, but at the same time
> +extra faults and I/O delays for following faults if they would have been part of
> +that consecutive pages readahead would have brought in.
> +
>  =============================================================
>  
>  panic_on_oom


Otherwise, Looks good to me.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
