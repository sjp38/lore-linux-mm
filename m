Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B205E6B00F8
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 20:03:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAH13huZ020179
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Nov 2010 10:03:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E83E345DE62
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:03:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2C145DE55
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:03:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FBC6E18001
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:03:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44DA41DB803C
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:03:42 +0900 (JST)
Date: Wed, 17 Nov 2010 09:57:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make swap accounting default behavior configurable
Message-Id: <20101117095759.738de832.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
References: <20101116101726.GA21296@tiehlicka.suse.cz>
	<20101116124615.978ed940.akpm@linux-foundation.org>
	<20101117092339.1b7c2d6d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 09:23:39 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 16 Nov 2010 12:46:15 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 16 Nov 2010 11:17:26 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Hi Andrew,
> > > could you consider the following patch for the Linus tree, please?
> > > The discussion took place in this email thread 
> > > http://lkml.org/lkml/2010/11/10/114.
> > > The patch is based on top of 151f52f09c572 commit in the Linus tree.
> > > 
> > > Please let me know if there I should route this patch through somebody
> > > else.
> > > 
> > > Thanks!
> > > 
> > > ---
> > > >From 30238aaec758988493af793939f14b0ba83dc4b3 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Wed, 10 Nov 2010 13:30:04 +0100
> > > Subject: [PATCH] Make swap accounting default behavior configurable
> > > 
> > > Swap accounting can be configured by CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > > configuration option and then it is turned on by default. There is
> > > a boot option (noswapaccount) which can disable this feature.
> > > 
> > > This makes it hard for distributors to enable the configuration option
> > > as this feature leads to a bigger memory consumption and this is a no-go
> > > for general purpose distribution kernel. On the other hand swap
> > > accounting may be very usuful for some workloads.
> > 
> > This patch is needed by distros, and distros use the -stable tree, I
> > assume.  Do you see reasons why this patch should be backported into
> > -stable, so distros don't need to patch it themselves?  If so, any
> > particular kernel versions?  2.6.37?
> > 
> > > This patch adds a new configuration option which controls the default
> > > behavior (CGROUP_MEM_RES_CTLR_SWAP_ENABLED). If the option is selected
> > > then the feature is turned on by default.
> > > 
> > > It also adds a new boot parameter swapaccount which (contrary to
> > > noswapaccount) enables the feature. (I would consider swapaccount=yes|no
> > > semantic with removed noswapaccount parameter much better but this
> > > parameter is kind of API which might be in use and unexpected breakage
> > > is no-go.)
> > > 
> > > The default behavior is unchanged (if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is
> > > enabled then CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED is enabled as well)
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > >  Documentation/kernel-parameters.txt |    3 +++
> > >  init/Kconfig                        |   13 +++++++++++++
> > >  mm/memcontrol.c                     |   15 ++++++++++++++-
> > >  3 files changed, 30 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > > index ed45e98..14eafa5 100644
> > > --- a/Documentation/kernel-parameters.txt
> > > +++ b/Documentation/kernel-parameters.txt
> > > @@ -2385,6 +2385,9 @@ and is between 256 and 4096 characters. It is defined in the file
> > >  			improve throughput, but will also increase the
> > >  			amount of memory reserved for use by the client.
> > >  
> > > +	swapaccount	[KNL] Enable accounting of swap in memory resource
> > > +			controller. (See Documentation/cgroups/memory.txt)
> > 
> > So we have swapaccount and noswapaccount.  Ho hum, "swapaccount=[1|0]"
> > would have been better.
> > 
> I suggested to keep "noswapaccount" for compatibility.
> If you and other guys don't like having two parameters, I don't stick to
> the old parameter.
> 

I don't think "noswapaccount" is important if "enable is default" when 
proper configuration is used ....because it's rarelly used.
 
BTW, memory usage of swap_cgroup is really important ? It consumes 
1 Mbytes per 2G of swap.

Off topic.
I wonder I'll be happy if we can have default config template for all
others as recent "Add Kconfig option for default swappiness" discuss.

Thanks,
-Kame


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
