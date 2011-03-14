Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB538D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:06:48 -0400 (EDT)
Subject: Re: [PATCH R4 4/7] xen/balloon: Protect against CPU exhaust by
 event/x process
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
In-Reply-To: <20110308214824.GE27331@router-fw-old.local.net-space.pl>
References: <20110308214824.GE27331@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Mar 2011 15:04:49 +0000
Message-ID: <1300115089.17339.2183.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "v.tolstov@selfip.ru" <v.tolstov@selfip.ru>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2011-03-08 at 21:48 +0000, Daniel Kiper wrote:
> Protect against CPU exhaust by event/x process during
> errors by adding some delays in scheduling next event
> and retry count limit.

The addition of a default retry count limit reverses the change made in
bc2c0303226ec716854d3c208c7f84fe7aa35cd7. That change was made to allow
system wide ballooning daemons to work as expected and I don't think a
strong argument has been made for undoing it here.

I think the exponential back-off element of this patch is probably all
that is needed to avoid using too much CPU.

We are talking about polling at most once a second (backing off pretty
quickly to once every 32s with this patch) -- is that really enough to
"exhaust" the CPU running event/x?

Also this patch seems to make the driver quite chatty:

> +	pr_info("xen_balloon: Retry count: %lu/%lu\n", balloon_stats.retry_count,
> +			balloon_stats.max_retry_count);

Not needed. The balloon driver is a best effort background thing, it
doesn't need to be spamming the system logs each time something doesn't
go quite right first time, it should just continue on silently in the
background. It should only be logging if something goes catastrophically
wrong (in which case pr_info isn't really sufficient).

> +	if (rc <= 0) {
> +		pr_info("xen_balloon: %s: Cannot allocate memory\n", __func__);

Likewise.

> +			pr_info("xen_balloon: %s: Cannot allocate memory\n", __func__);

And again.

Ian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
