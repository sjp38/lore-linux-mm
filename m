Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 39FF46B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 14:38:00 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so7063694pbc.6
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 11:37:59 -0700 (PDT)
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
        by mx.google.com with ESMTPS id b4si8779388pbl.130.2014.04.07.11.37.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 11:37:59 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so7154282pbc.10
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 11:37:58 -0700 (PDT)
Message-ID: <5342F083.5020509@linaro.org>
Date: Mon, 07 Apr 2014 11:37:55 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory
 non-volatile
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-3-git-send-email-john.stultz@linaro.org> <CAHGf_=pBUW1Za862NGeN2u2D8B9hjTk5DgP4SYqoM34KUnMMhQ@mail.gmail.com>
In-Reply-To: <CAHGf_=pBUW1Za862NGeN2u2D8B9hjTk5DgP4SYqoM34KUnMMhQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/23/2014 10:42 AM, KOSAKI Motohiro wrote:
> On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
>> Users of volatile ranges will need to know if memory was discarded.
>> This patch adds the purged state tracking required to inform userland
>> when it marks memory as non-volatile that some memory in that range
>> was purged and needs to be regenerated.
>>
>> This simplified implementation which uses some of the logic from
>> Minchan's earlier efforts, so credit to Minchan for his work.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Android Kernel Team <kernel-team@android.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Robert Love <rlove@google.com>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Dave Hansen <dave@sr71.net>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
>> Cc: Neil Brown <neilb@suse.de>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Mike Hommey <mh@glandium.org>
>> Cc: Taras Glek <tglek@mozilla.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>> Cc: Michel Lespinasse <walken@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
>> Signed-off-by: John Stultz <john.stultz@linaro.org>
>> ---
>>  include/linux/swap.h    | 15 ++++++++--
>>  include/linux/swapops.h | 10 +++++++
>>  include/linux/vrange.h  |  3 ++
>>  mm/vrange.c             | 75 +++++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 101 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 46ba0c6..18c12f9 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -70,8 +70,19 @@ static inline int current_is_kswapd(void)
>>  #define SWP_HWPOISON_NUM 0
>>  #endif
>>
>> -#define MAX_SWAPFILES \
>> -       ((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
>> +
>> +/*
>> + * Purged volatile range pages
>> + */
>> +#define SWP_VRANGE_PURGED_NUM 1
>> +#define SWP_VRANGE_PURGED (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
>> +
>> +
>> +#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)      \
>> +                               - SWP_MIGRATION_NUM     \
>> +                               - SWP_HWPOISON_NUM      \
>> +                               - SWP_VRANGE_PURGED_NUM \
>> +                       )
> This change hwpoison and migration tag number. maybe ok, maybe not.

Though depending on config can't these tag numbers change anyway?


> I'd suggest to use younger number than hwpoison.
> (That's why hwpoison uses younger number than migration)

So I can, but the way these are defined makes the results seem pretty
terrible:

#define SWP_MIGRATION_WRITE    (MAX_SWAPFILES + SWP_HWPOISON_NUM \
                    + SWP_MVOLATILE_PURGED_NUM + 1)

Particularly when:
#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)        \
                - SWP_MIGRATION_NUM        \
                - SWP_HWPOISON_NUM        \
                - SWP_MVOLATILE_PURGED_NUM    \
            )

Its a lot of unnecessary mental gymnastics. Yuck.

Would a general cleanup like the following be ok to try to make this
more extensible?

thanks
-john

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..21387df 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -49,29 +49,38 @@ static inline int current_is_kswapd(void)
  * actions on faults.
  */
 
+enum {
+	/*
+	 * NOTE: We use the high bits here (subtracting from
+	 * 1<<MAX_SWPFILES_SHIFT), so to preserve the values insert
+	 * new entries here at the top of the enum, not at the bottom
+	 */
+#ifdef CONFIG_MEMORY_FAILURE
+	SWP_HWPOISON_NR,
+#endif
+#ifdef CONFIG_MIGRATION
+	SWP_MIGRATION_READ_NR,
+	SWP_MIGRATION_WRITE_NR,
+#endif
+	SWP_MAX_NR,
+};
+#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT) - SWP_MAX_NR)
+
 /*
  * NUMA node memory migration support
  */
 #ifdef CONFIG_MIGRATION
-#define SWP_MIGRATION_NUM 2
-#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM)
-#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
-#else
-#define SWP_MIGRATION_NUM 0
+#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_MIGRATION_READ_NR)
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_MIGRATION_WRITE_NR)
 #endif
 
 /*
  * Handling of hardware poisoned pages with memory corruption.
  */
 #ifdef CONFIG_MEMORY_FAILURE
-#define SWP_HWPOISON_NUM 1
-#define SWP_HWPOISON		MAX_SWAPFILES
-#else
-#define SWP_HWPOISON_NUM 0
+#define SWP_HWPOISON		(MAX_SWAPFILES + SWP_HWPOISON_NR)
 #endif
 
-#define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
