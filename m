Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 235926B0062
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 06:14:00 -0500 (EST)
Message-ID: <50AE08D4.7040602@redhat.com>
Date: Thu, 22 Nov 2012 12:13:24 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: Lockdep complain for zram
References: <20121121083737.GB5121@bbox>
In-Reply-To: <20121121083737.GB5121@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 11/21/2012 09:37 AM, Minchan Kim wrote:
> Hi alls,
> 
> Today, I saw below complain of lockdep.
> As a matter of fact, I knew it long time ago but forgot that.
> The reason lockdep complains is that now zram uses GFP_KERNEL
> in reclaim path(ex, __zram_make_request) :(
> I can fix it via replacing GFP_KERNEL with GFP_NOIO.
> But more big problem is vzalloc in zram_init_device which calls GFP_KERNEL.
> Of course, I can change it with __vmalloc which can receive gfp_t.
> But still we have a problem. Althoug __vmalloc can handle gfp_t, it calls
> allocation of GFP_KERNEL. That's why I sent the patch.
> https://lkml.org/lkml/2012/4/23/77
> Since then, I forgot it, saw the bug today and poped the question again.
> 
> Yes. Fundamental problem is utter crap API vmalloc.
> If we can fix it, everyone would be happy. But life isn't simple like seeing
> my thread of the patch.
> 
> So next option is to move zram_init_device into setting disksize time.
> But it makes unnecessary metadata waste until zram is used really(That's why
> Nitin move zram_init_device from disksize setting time to make_request) and
> it makes user should set the disksize before using, which are behavior change.
> 
> I would like to clean up this issue before promoting because it might change
> usage behavior.
> 
> Do you have any idea?

This is a false positive due to the memory allocation in
zram_init_device() called from zram_make_request(). It appears to
lockdep that the allocation might trigger a request on the device that
would try to take init_lock again, but in fact it doesn't. The device
is not initialized yet, even less swapped on.

The following (quickly tested) patch should prevent lockdep complain.  

Jerome

---
