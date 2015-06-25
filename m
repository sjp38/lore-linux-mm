Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 328C16B006E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:18:51 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so60926551pdj.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:18:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gp1si44919302pbd.238.2015.06.25.14.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 14:18:50 -0700 (PDT)
Date: Thu, 25 Jun 2015 23:18:34 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 6/8] xen/balloon: only hotplug additional memory if
 required
Message-ID: <20150625211834.GO14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:11:01PM +0100, David Vrabel wrote:
> Now that we track the total number of pages (included hotplugged
> regions), it is easy to determine if more memory needs to be
> hotplugged.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/xen/balloon.c |   16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 960ac79..dd41da8 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -241,12 +241,22 @@ static void release_memory_resource(struct resource *resource)
>   * bit set). Real size of added memory is established at page onlining stage.
>   */
>
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

Comment is wrong or at least misleading. Both values does not depend on onlining.

> +	if (credit <= 0)
> +		return BP_EAGAIN;

Not BP_EAGAIN for sure. It should be BP_DONE but then balloon_process() will go
into loop until memory is onlined at least up to balloon_stats.target_pages.
BP_ECANCELED does work but it is misleading because it is not an error. So, maybe
we should introduce BP_STOP (or something like that) which works like BP_ECANCELED
and is not BP_ECANCELED.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
