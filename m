Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 70C2E6B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 05:16:01 -0400 (EDT)
Message-ID: <4FBDFC43.6040707@redhat.com>
Date: Thu, 24 May 2012 11:15:47 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] avoid swapping out with swappiness==0
References: <65795E11DBF1E645A09CEC7EAEE94B9C015A48DF62@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C015A48DF62@USINDEVS02.corp.hds.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Richard Davies <richard.davies@elastichosts.com>, Seiji Aguchi <seiji.aguchi@hds.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

On 05/23/2012 10:41 PM, Satoru Moriya wrote:
> Hi Andrew,
> 
> This patch has been reviewed for couple of months.
> 
> This patch *only* improves the behavior when the kernel has
> enough filebacked pages. It means that it does not change
> the behavior when kernel has small number of filebacked pages.
> 
> Kosaki-san pointed out that the threshold which we use
> to decide whether filebacked page is enough or not is not
> appropriate(*).
> 
> (*) http://www.spinics.net/lists/linux-mm/msg32380.html
> 
> As I described in (**), I believe that threshold discussion
> should be done in other thread because it affects not only
> swappiness=0 case and the kernel behave the same way with
> or without this patch below the threshold.
> 
> (**) http://www.spinics.net/lists/linux-mm/msg34317.html
> 
> The patch may not be perfect but, at least, we can improve
> the kernel behavior in the enough filebacked memory case
> with this patch. I believe it's better than nothing.
> 
> Do you have any comments about it?
> 
> NOTE: I updated the patch with Acked-by tags
> 
> ---
> Sometimes we'd like to avoid swapping out anonymous memory
> in particular, avoid swapping out pages of important process or
> process groups while there is a reasonable amount of pagecache
> on RAM so that we can satisfy our customers' requirements.
> 
> OTOH, we can control how aggressive the kernel will swap memory pages
> with /proc/sys/vm/swappiness for global and
> /sys/fs/cgroup/memory/memory.swappiness for each memcg.
> 
> But with current reclaim implementation, the kernel may swap out
> even if we set swappiness==0 and there is pagecache on RAM.
> 
> This patch changes the behavior with swappiness==0. If we set
> swappiness==0, the kernel does not swap out completely
> (for global reclaim until the amount of free pages and filebacked
> pages in a zone has been reduced to something very very small
> (nr_free + nr_filebacked < high watermark)).
> 
> Any comments are welcome.
> 
> Regards,
> Satoru Moriya
> 
> Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> 

Acked-by: Jerome Marchand <jmarchan@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
