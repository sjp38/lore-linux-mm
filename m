Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAA18D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:53:17 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p1SNrEQw032639
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:53:14 -0800
Received: from iyj8 (iyj8.prod.google.com [10.241.51.72])
	by wpaz13.hot.corp.google.com with ESMTP id p1SNqabP032163
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:53:13 -0800
Received: by iyj8 with SMTP id 8so3237799iyj.3
        for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:53:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110227160721.GB3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-4-git-send-email-gthelen@google.com> <20110227160721.GB3226@barrios-desktop>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 28 Feb 2011 15:52:53 -0800
Message-ID: <AANLkTik7LfGfYpteufr68AqEe3wUriJKgAMkmT8pJSzZ@mail.gmail.com>
Subject: Re: [PATCH v5 3/9] writeback: convert variables to unsigned
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Sun, Feb 27, 2011 at 8:07 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Feb 25, 2011 at 01:35:54PM -0800, Greg Thelen wrote:
>> Convert two balance_dirty_pages() page counter variables (nr_reclaimable
>> and nr_writeback) from 'long' to 'unsigned long'.
>>
>> These two variables are used to store results from global_page_state().
>> global_page_state() returns unsigned long and carefully sums per-cpu
>> counters explicitly avoiding returning a negative value.
>>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
>> ---
>> Changelog since v4:
>> - Created this patch for clarity. =A0Previously this patch was integrate=
d within
>> =A0 the "writeback: create dirty_info structure" patch.
>>
>> =A0mm/page-writeback.c | =A0 =A06 ++++--
>> =A01 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 2cb01f6..4408e54 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -478,8 +478,10 @@ unsigned long bdi_dirty_limit(struct backing_dev_in=
fo *bdi, unsigned long dirty)
>> =A0static void balance_dirty_pages(struct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g write_chunk)
>> =A0{
>> - =A0 =A0 long nr_reclaimable, bdi_nr_reclaimable;
>> - =A0 =A0 long nr_writeback, bdi_nr_writeback;
>> + =A0 =A0 unsigned long nr_reclaimable;
>> + =A0 =A0 long bdi_nr_reclaimable;
>> + =A0 =A0 unsigned long nr_writeback;
>> + =A0 =A0 long bdi_nr_writeback;
>> =A0 =A0 =A0 unsigned long background_thresh;
>> =A0 =A0 =A0 unsigned long dirty_thresh;
>> =A0 =A0 =A0 unsigned long bdi_thresh;
>> --
>> 1.7.3.1
>>
> bdi_nr_[reclaimable|writeback] can return negative value?
> When I just look through bdi_stat_sum, it uses *percpu_counter_sum_positi=
ve*.
> So I guess it always returns positive value.
> If it is right, could you change it, too?

Yes, I think we can also change bdi_nr_[reclaimable|writeback] to unsigned =
long.

bdi_stat_sum() and bdi_stat() both call percpu_counter_sum_positive(),
which return a positive number.  bdi_stat[_sum]() return s64.  Should
we also change bdi_stat[_sum]() to return unsigned long rather than
s64?  I would like the return value type to match the type of the
corresponding local variables in balance_dirty_pages().  All current
callers appear to expect bdi_stat[_sum]() to return unsigned long.

> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
