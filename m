Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 23F1F6B0034
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 06:09:00 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id d49so1063000eek.20
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 03:08:58 -0700 (PDT)
Date: Sun, 4 Aug 2013 12:08:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V5 5/8] memcg: add per cgroup writeback pages accounting
Message-ID: <20130804100855.GD24005@dhcp22.suse.cz>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
 <1375358051-10306-1-git-send-email-handai.szj@taobao.com>
 <20130801145302.GJ5198@dhcp22.suse.cz>
 <CAFj3OHV-VCKJfe6bv4UMvv+uj4LELDXsieRZFJD06Yrdyy=XxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHV-VCKJfe6bv4UMvv+uj4LELDXsieRZFJD06Yrdyy=XxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>

On Sat 03-08-13 17:25:01, Sha Zhengju wrote:
> On Thu, Aug 1, 2013 at 10:53 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 01-08-13 19:54:11, Sha Zhengju wrote:
> >> From: Sha Zhengju <handai.szj@taobao.com>
> >>
> >> Similar to dirty page, we add per cgroup writeback pages accounting. The lock
> >> rule still is:
> >>         mem_cgroup_begin_update_page_stat()
> >>         modify page WRITEBACK stat
> >>         mem_cgroup_update_page_stat()
> >>         mem_cgroup_end_update_page_stat()
> >>
> >> There're two writeback interfaces to modify: test_{clear/set}_page_writeback().
> >> Lock order:
> >>       --> memcg->move_lock
> >>         --> mapping->tree_lock
> >>
> >> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> >
> > Looks good to me. Maybe I would suggest moving this patch up the stack
> > so that it might get merged earlier as it is simpler than dirty pages
> > accounting. Unless you insist on having the full series merged at once.
> 
> I think the following three patches can be merged earlier:
>       1/8 memcg: remove MEMCG_NR_FILE_MAPPED
>       3/8 memcg: check for proper lock held in mem_cgroup_update_page_stat
>       5/8 memcg: add per cgroup writeback pages accounting
> 
> Do I need to resent them again for you or they're enough?

This is a question for Andrew. I would go with them as they are.
 
> One more word, since dirty accounting is essential to future memcg
> dirty page throttling and it is not an optional feature now, I suspect
> whether we can merge the following two as well and leave the overhead
> optimization a separate series.  :p

I wouldn't hurry it. We need numbers for serious testing to see the
overhead. It is still just a small step towards dirty throttling.

>       4/5 memcg: add per cgroup dirty pages accounting
>       8/8 memcg: Document cgroup dirty/writeback memory statistics
> 
> The 2/8 ceph one still need more improvement, I'll separate it next version.
> 
> >
> > Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thank you.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
