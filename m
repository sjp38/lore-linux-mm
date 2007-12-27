Date: Thu, 27 Dec 2007 13:49:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][patch] mem_notify more faster reduce load average
In-Reply-To: <20071225192625.D273.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071225192625.D273.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071227134854.7F0E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Marcelo-san

this patch is a bit improvement against my mem notifications large system patch.
original my patch is too slower reduce load average at after free memory increased.
this patch fixed it.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Index: linux-2.6.23-mem_notify_v3/mm/mem_notify.c
===================================================================
--- linux-2.6.23-mem_notify_v3.orig/mm/mem_notify.c
+++ linux-2.6.23-mem_notify_v3/mm/mem_notify.c
@@ -20,7 +20,8 @@ struct mem_notify_file_info {
         long          last_event;
 };

-atomic_t mem_notify_event = ATOMIC_INIT(0);
+static atomic_t mem_notify_event = ATOMIC_INIT(0);
+static atomic_t mem_notify_event_end = ATOMIC_INIT(0);

 static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
 static atomic_long_t last_mem_notify = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
@@ -76,13 +77,18 @@ static unsigned int mem_notify_poll(stru
        unsigned long bonus;
        unsigned long now;
        unsigned long last;
+       unsigned long event;

        poll_wait(file, &mem_wait, wait);

-        if (file_info->last_event == atomic_read(&mem_notify_event))
+retry:
+       event = atomic_read(&mem_notify_event);
+       if (event == file_info->last_event)
                 goto out;

-retry:
+       if (event == atomic_read(&mem_notify_event_end))
+               goto out;
+
        /* Ugly trick:
           when too many task wakeup,
           control function exit rate for prevent too much freed.
@@ -114,6 +120,8 @@ retry:

        if (pages_free < (pages_high+pages_reserve)*2)
                val = POLLIN;
+       else
+               atomic_set(&mem_notify_event_end, event);

 out:



- kosaki




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
