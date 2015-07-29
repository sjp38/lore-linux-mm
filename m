Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0E93C9003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:56:41 -0400 (EDT)
Received: by oibn4 with SMTP id n4so7355122oib.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:56:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bb9si19885767obb.16.2015.07.29.08.56.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:56:40 -0700 (PDT)
Date: Wed, 29 Jul 2015 17:55:35 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv2 06/10] xen/balloon: only hotplug additional memory if
 required
Message-ID: <20150729155535.GL3492@olila.local.net-space.pl>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-7-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-7-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 12:47:44PM +0100, David Vrabel wrote:
> Now that we track the total number of pages (included hotplugged
> regions), it is easy to determine if more memory needs to be
> hotplugged.
>
> Add a new BP_WAIT state to signal that the balloon process needs to
> wait until kicked by the memory add notifier (when the new section is
> onlined by userspace).
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
> v2:
> - New BP_WAIT status after adding new memory sections.
> ---
>  drivers/xen/balloon.c | 23 +++++++++++++++++++----
>  1 file changed, 19 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index b5037b1..ced34cd 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -75,12 +75,14 @@
>   * balloon_process() state:
>   *
>   * BP_DONE: done or nothing to do,
> + * BP_WAIT: wait to be rescheduled,

BP_SLEEP? BP_WAIT suggests that balloon process waits for something in a loop.

>   * BP_EAGAIN: error, go to sleep,
>   * BP_ECANCELED: error, balloon operation canceled.
>   */
>
>  enum bp_state {
>  	BP_DONE,
> +	BP_WAIT,
>  	BP_EAGAIN,
>  	BP_ECANCELED
>  };
> @@ -167,6 +169,9 @@ static struct page *balloon_next_page(struct page *page)
>
>  static enum bp_state update_schedule(enum bp_state state)
>  {
> +	if (state == BP_WAIT)
> +		return BP_WAIT;
> +
>  	if (state == BP_ECANCELED)
>  		return BP_ECANCELED;
>
> @@ -242,12 +247,22 @@ static void release_memory_resource(struct resource *resource)
>   * bit set). Real size of added memory is established at page onlining stage.
>   */

Please align above, partially visible, comment to current reality.

> -static enum bp_state reserve_additional_memory(long credit)
> +static enum bp_state reserve_additional_memory(void)
>  {
> +	long credit;
>  	struct resource *resource;
>  	int nid, rc;
>  	unsigned long balloon_hotplug;
>
> +	credit = balloon_stats.target_pages - balloon_stats.total_pages;
> +
> +	/*
> +	 * Already hotplugged enough pages?  Wait for them to be
> +	 * onlined.
> +	 */

Please change this comment for something like that:

Already hotplugged enough pages? If yes then go to sleep.

> +	if (credit <= 0)
> +		return BP_EAGAIN;

No, this should be BP_WAIT (BP_SLEEP). Otherwise when somebody
touches balloon_stats.target_pages balloon process will be
rescheduled unnecessarily until pages are onlined up to
balloon_stats.total_pages. We do not want that.

> +
>  	balloon_hotplug = round_up(credit, PAGES_PER_SECTION);
>
>  	resource = additional_memory_resource(balloon_hotplug * PAGE_SIZE);
> @@ -287,7 +302,7 @@ static enum bp_state reserve_additional_memory(long credit)
>
>  	balloon_stats.total_pages += balloon_hotplug;
>
> -	return BP_DONE;
> +	return BP_WAIT;
>    err:

Please add one empty line before err label.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
