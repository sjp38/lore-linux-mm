Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7E7CC6B007D
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 12:56:33 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id jk13so3499821bkc.29
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 09:56:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130711144003.GJ21667@dhcp22.suse.cz>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
	<1373045577-27671-1-git-send-email-handai.szj@taobao.com>
	<20130711144003.GJ21667@dhcp22.suse.cz>
Date: Fri, 12 Jul 2013 00:56:31 +0800
Message-ID: <CAFj3OHXSFWW2oXRu2t+oiKWo2Nw8eLyxsPi0MprrEzJSMcefaQ@mail.gmail.com>
Subject: Re: [PATCH V4 4/6] memcg: add per cgroup writeback pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, Sha Zhengju <handai.szj@taobao.com>

On Thu, Jul 11, 2013 at 10:40 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sat 06-07-13 01:32:57, Sha Zhengju wrote:
>> From: Sha Zhengju <handai.szj@taobao.com>
>>
>> Similar to dirty page, we add per cgroup writeback pages accounting. The lock
>> rule still is:
>>         mem_cgroup_begin_update_page_stat()
>>         modify page WRITEBACK stat
>>         mem_cgroup_update_page_stat()
>>         mem_cgroup_end_update_page_stat()
>>
>> There're two writeback interfaces to modify: test_{clear/set}_page_writeback().
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> Acked-by: Michal Hocko <mhocko@suse.cz>
>> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> cc: Greg Thelen <gthelen@google.com>
>> cc: Andrew Morton <akpm@linux-foundation.org>
>> cc: Fengguang Wu <fengguang.wu@intel.com>
>> cc: Mel Gorman <mgorman@suse.de>
>> ---
>>  include/linux/memcontrol.h |    1 +
>>  mm/memcontrol.c            |    5 +++++
>>  mm/page-writeback.c        |   15 +++++++++++++++
>>  3 files changed, 21 insertions(+)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index f952be6..ccd35d8 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -43,6 +43,7 @@ enum mem_cgroup_stat_index {
>>       MEM_CGROUP_STAT_RSS_HUGE,       /* # of pages charged as anon huge */
>>       MEM_CGROUP_STAT_FILE_MAPPED,    /* # of pages charged as file rss */
>>       MEM_CGROUP_STAT_FILE_DIRTY,     /* # of dirty pages in page cache */
>> +     MEM_CGROUP_STAT_WRITEBACK,      /* # of pages under writeback */
>>       MEM_CGROUP_STAT_SWAP,           /* # of pages, swapped out */
>>       MEM_CGROUP_STAT_NSTATS,
>>  };
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 1d31851..9126abc 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -92,6 +92,7 @@ static const char * const mem_cgroup_stat_names[] = {
>>       "mapped_file",
>>       "swap",
>>       "dirty",
>> +     "writeback",
>
> Ordering issue again (see mem_cgroup_stat_index)

Yes, you're right.

>
>>  };
>>
>>  enum mem_cgroup_events_index {
> [...]
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 3900e62..85de9a0 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -2008,11 +2008,17 @@ EXPORT_SYMBOL(account_page_dirtied);
>>
>>  /*
>>   * Helper function for set_page_writeback family.
>> + *
>> + * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
>> + * while modifying struct page state and accounting writeback pages.
>
> I guess "while calling this function" would be sufficient

Thanks for the advice.

>
>> + * See test_set_page_writeback for example.
>> + *
>>   * NOTE: Unlike account_page_dirtied this does not rely on being atomic
>>   * wrt interrupts.
>>   */
>>  void account_page_writeback(struct page *page)
>>  {
>> +     mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
>>       inc_zone_page_state(page, NR_WRITEBACK);
>>  }
>>  EXPORT_SYMBOL(account_page_writeback);
> [...]
> --
> Michal Hocko
> SUSE Labs



--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
