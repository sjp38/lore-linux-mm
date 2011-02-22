Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3CF8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:42:51 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p1MIghYI022258
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:42:43 -0800
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe13.cbf.corp.google.com with ESMTP id p1MIgfPe018970
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:42:42 -0800
Received: by pvg12 with SMTP id 12so398176pvg.33
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:42:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1298394776-9957-5-git-send-email-arighi@develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-5-git-send-email-arighi@develer.com>
Date: Tue, 22 Feb 2011 10:42:41 -0800
Message-ID: <AANLkTinD2ZH3hw_iqVpvMjMRbUkXMBgttjd2NevvYq9x@mail.gmail.com>
Subject: Re: [PATCH 4/5] blk-throttle: track buffered and anonymous pages
From: Chad Talbott <ctalbott@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 22, 2011 at 9:12 AM, Andrea Righi <arighi@develer.com> wrote:
> Add the tracking of buffered (writeback) and anonymous pages.
...
> ---
> =A0block/blk-throttle.c =A0 | =A0 87 ++++++++++++++++++++++++++++++++++++=
+++++++++++-
> =A0include/linux/blkdev.h | =A0 26 ++++++++++++++-
> =A02 files changed, 111 insertions(+), 2 deletions(-)
>
> diff --git a/block/blk-throttle.c b/block/blk-throttle.c
> index 9ad3d1e..a50ee04 100644
> --- a/block/blk-throttle.c
> +++ b/block/blk-throttle.c
...
> +int blk_throtl_set_anonpage_owner(struct page *page, struct mm_struct *m=
m)
> +int blk_throtl_set_filepage_owner(struct page *page, struct mm_struct *m=
m)
> +int blk_throtl_copy_page_owner(struct page *npage, struct page *opage)

It would be nice if these were named blk_cgroup_*.  This is arguably
more correct as the id comes from the blkio subsystem, and isn't
specific to blk-throttle.  This will be more important very shortly,
as CFQ will be using this same cgroup id for async IO tracking soon.

is_kernel_io() is a good idea, it avoids a bug that we've run into
with CFQ async IO tracking.  Why isn't PF_KTHREAD sufficient to cover
all kernel threads, including kswapd and those marked PF_MEMALLOC?

Thanks,
Chad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
