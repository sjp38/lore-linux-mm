Date: Tue, 27 May 2008 18:42:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 2/4] memcg: high-low watermark
Message-Id: <20080527184215.dfc1bf37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <483BBD8C.3040803@cn.fujitsu.com>
References: <20080527140116.fb04b06b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080527140703.97b69ed3.kamezawa.hiroyu@jp.fujitsu.com>
	<483BBD8C.3040803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008 15:51:40 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Add high/low watermarks to res_counter.
> > *This patch itself has no behavior changes to memory resource controller.
> > 
> > Changelog: very old one -> this one (v1)
> >  - watarmark_state is removed and all state check is done under lock.
> >  - changed res_counter_charge() interface. The only user is memory
> >    resource controller. Anyway, returning -ENOMEM here is a bit starnge.
> >  - Added watermark enable/disable flag for someone don't want watermarks.
> >  - Restarted against 2.6.25-mm1.
> >  - some subsystem which doesn't want high-low watermark can work withou it.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> > 
> > ---
> >  include/linux/res_counter.h |   41 ++++++++++++++++++++++++---
> >  kernel/res_counter.c        |   66 ++++++++++++++++++++++++++++++++++++++++----
> >  mm/memcontrol.c             |    2 -
> >  3 files changed, 99 insertions(+), 10 deletions(-)
> > 
> > Index: mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> > ===================================================================
> > --- mm-2.6.26-rc2-mm1.orig/include/linux/res_counter.h
> > +++ mm-2.6.26-rc2-mm1/include/linux/res_counter.h
> > @@ -16,6 +16,16 @@
> >  #include <linux/cgroup.h>
> >  
> >  /*
> > + * status of resource coutner's usage.
> > + */
> > +enum res_state {
> > +	RES_BELOW_LOW,	/* usage < lwmark */
> 
> It seems it's 'usage <= lwmark'
> 
> > +	RES_BELOW_HIGH,	/* lwmark < usage < hwmark */
> 
> and 'lwmark < usage <= hwmark'
> 
> > +	RES_BELOW_LIMIT,	/* hwmark < usage < limit. */
> 
> and 'hwmark < usage <= limit'
> 

Thank you. I'll fix.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
