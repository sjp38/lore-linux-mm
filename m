Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 08DF96B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 01:41:28 -0400 (EDT)
Message-ID: <4A825601.60000@redhat.com>
Date: Wed, 12 Aug 2009 08:41:21 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Page allocation failures in guest
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <4A811545.5090209@redhat.com> <200908121249.51973.rusty@rustcorp.com.au> <200908121501.53167.rusty@rustcorp.com.au>
In-Reply-To: <200908121501.53167.rusty@rustcorp.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 08/12/2009 08:31 AM, Rusty Russell wrote:
> +static void refill_work(struct work_struct *work)
> +{
> +	struct virtnet_info *vi;
> +	bool still_empty;
> +
> +	vi = container_of(work, struct virtnet_info, refill);
> +	napi_disable(&vi->napi);
> +	try_fill_recv(vi, GFP_KERNEL);
> +	still_empty = (vi->num == 0);
> +	napi_enable(&vi->napi);
> +
> +	/* In theory, this can happen: if we don't get any buffers in
> +	 * we will*never*  try to fill again.  Sleeping in keventd if
> +	 * bad, but that is worse. */
> +	if (still_empty) {
> +		msleep(100);
> +		schedule_work(&vi->refill);
> +	}
> +}
> +
>    

schedule_delayed_work()?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
