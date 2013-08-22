Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A866C6B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:46:33 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id na10so587048bkb.14
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:46:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130804100855.GD24005@dhcp22.suse.cz>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
	<1375358051-10306-1-git-send-email-handai.szj@taobao.com>
	<20130801145302.GJ5198@dhcp22.suse.cz>
	<CAFj3OHV-VCKJfe6bv4UMvv+uj4LELDXsieRZFJD06Yrdyy=XxA@mail.gmail.com>
	<20130804100855.GD24005@dhcp22.suse.cz>
Date: Thu, 22 Aug 2013 17:46:31 +0800
Message-ID: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
Subject: Fwd: [PATCH V5 5/8] memcg: add per cgroup writeback pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Sha Zhengju <handai.szj@taobao.com>

Hi Andrew,

After several rounds of review, parts of the memcg page accounting
patchset is ready (leaving memcg dirty page accounting under more
review):

  1/8 memcg: remove MEMCG_NR_FILE_MAPPED
  2/8 ceph: vfs __set_page_dirty_nobuffers interface instead of doing
it inside filesystem
  3/8 memcg: check for proper lock held in mem_cgroup_update_page_stat
  5/8 memcg: add per cgroup writeback pages accounting
  8/8 memcg: Document cgroup dirty/writeback memory statistics

But the 2/8 ceph one has been improved again and will be merged in
ceph tree, so only the other 4 patches need to be added to -mm tree.
I've moved the 5/8 writeback one up the stack and updated the 8/8 to
only document writeback changes. Could you please merge them earlier?
I'll post these updated patches soon. :)

Thank you!


---------- Forwarded message ----------
From: Michal Hocko <mhocko@suse.cz>
Date: Sun, Aug 4, 2013 at 6:08 PM
Subject: Re: [PATCH V5 5/8] memcg: add per cgroup writeback pages accounting
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
"linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups
<cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>,
Greg Thelen <gthelen@google.com>, Wu Fengguang
<fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
Sha Zhengju <handai.szj@taobao.com>


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
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
