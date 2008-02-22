Date: Fri, 22 Feb 2008 10:25:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080222190742.e8c03763.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802221018210.25455@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp>
 <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802220916290.18145@blonde.site>
 <20080222190742.e8c03763.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Fri, 22 Feb 2008 09:24:36 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > It seemed to me that mem_cgroup_uncharge should be doing its css_put
> > after its __mem_cgroup_remove_list: doesn't doing it before leave open
> > a slight danger that the struct mem_cgroup could be freed before the
> > remove_list?  Perhaps there's some other refcounting that makes that
> > impossible, but I've felt safer shifting those around.
> > 
> Sigh, it's very complicated. An idea which comes to me now is disallowing
> uncharge while force_empty is running and use Takahashi-san's method.
> It will be not so complicated.

Really?  I'd expect disallowing something to add to the complication.
I agree it's all rather subtle, but I'd rather it worked naturally
with itself than we bolt on extra prohibitions.  (I was frustrated
by the EBUSY failure of force_empty, so doing my testing with that
commented out, forcing empty with concurrent activity.)

And I'm not clear whether you're saying I'm wrong to move down that
css_put, for complicated reasons that you've not explained; or that
I'm right, and this is another example of how easy it is to get it
slightly wrong.  Please clarify!

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
