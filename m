Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2A1236B0075
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 16:34:47 -0500 (EST)
Date: Fri, 15 Feb 2013 23:39:34 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] net: fix functions and variables related to
 netns_ipvs->sysctl_sync_qlen_max
In-Reply-To: <20130214142159.d0516a5f.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.1302152304010.1746@ja.ssi.bg>
References: <51131B88.6040809@cn.fujitsu.com> <51132A56.60906@cn.fujitsu.com> <alpine.LFD.2.00.1302070944480.1810@ja.ssi.bg> <20130214142159.d0516a5f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, davem@davemloft.net, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


	Hello,

On Thu, 14 Feb 2013, Andrew Morton wrote:

> On Thu, 7 Feb 2013 10:40:26 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
> 
> > > Another question about the sysctl_sync_qlen_max:
> > > This variable is assigned as:
> > > 
> > > ipvs->sysctl_sync_qlen_max = nr_free_buffer_pages() / 32;
> > > 
> > > The function nr_free_buffer_pages actually means: counts of pages
> > > which are beyond high watermark within ZONE_DMA and ZONE_NORMAL.
> > > 
> > > is it ok to be called here? Some people misused this function because
> > > the function name was misleading them. I am sorry I am totally not
> > > familiar with the ipvs code, so I am just asking you about
> > > this.
> > 
> > 	Using nr_free_buffer_pages should be fine here.
> > We are using it as rough estimation for the number of sync
> > buffers we can use in NORMAL zones. We are using dev->mtu
> > for such buffers, so it can take a PAGE_SIZE for a buffer.
> > We are not interested in HIGHMEM size. high watermarks
> > should have negliable effect. I'm even not sure whether
> > we need to clamp it for systems with TBs of memory.
> 
> Using nr_free_buffer_pages() is good-enough-for-now.  There are
> questions around the name of this thing and its exact functionality and
> whether callers are using it appropriately.  But if anything is changed
> there, it will be as part of kernel-wide sweep.
> 
> One thing to bear in mind is memory hot[un]plug.  Anything which was
> sized using nr_free_buffer_pages() (or similar) may become
> inappropriately sized if memory is added or removed.  So any site which
> uses nr_free_buffer_pages() really should be associated with a hotplug
> handler and a great pile of code to resize the structure at runtime. 
> It's pretty ugly stuff :(  I suspect it usually Just Doesn't Matter.

	I'll try to think on this hotplug problem
and also on the si_meminfo usage in net/netfilter/ipvs/ip_vs_ctl.c
which is quite wrong for systems with HIGHMEM, may be
we need there a free+reclaimable+file function for
NORMAL zone.

> Redarding this patch:
> net-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch and
> net-fix-functions-and-variables-related-to-netns_ipvs-sysctl_sync_qlen_max.patch
> are joined at the hip and should be redone as a single patch with a
> suitable changelog, please.  And with a cc:netdev@vger.kernel.org.

	Agreed, Zhang Yanfei and Simon? I'm just not sure,
may be this combined patch should hit only the
ipvs->nf->net trees? Or may be net-next, if we don't have
time for 3.8.

Regards

--
Julian Anastasov <ja@ssi.bg>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
