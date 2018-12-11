Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66F868E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:23:18 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id j24-v6so3620128lji.20
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:23:18 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id h8si10269143lfc.108.2018.12.11.01.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 01:23:16 -0800 (PST)
Subject: Re: [PATCH] ksm: React on changing "sleep_millisecs" parameter faster
References: <154445792450.3178.16241744401215933502.stgit@localhost.localdomain>
 <20181210201036.GC2342@uranus.lan>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <db19c148-b375-b6f2-dbf5-9e78f5e46c04@virtuozzo.com>
Date: Tue, 11 Dec 2018 12:23:11 +0300
MIME-Version: 1.0
In-Reply-To: <20181210201036.GC2342@uranus.lan>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com

Hi, Cyrill,

On 10.12.2018 23:10, Cyrill Gorcunov wrote:
> On Mon, Dec 10, 2018 at 07:06:18PM +0300, Kirill Tkhai wrote:
>> ksm thread unconditionally sleeps in ksm_scan_thread()
>> after each iteration:
>>
>> 	schedule_timeout_interruptible(
>> 		msecs_to_jiffies(ksm_thread_sleep_millisecs))
>>
>> The timeout is configured in /sys/kernel/mm/ksm/sleep_millisecs.
>>
>> In case of user writes a big value by a mistake, and the thread
>> enters into schedule_timeout_interruptible(), it's not possible
>> to cancel the sleep by writing a new smaler value; the thread
>> is just sleeping till timeout expires.
>>
>> The patch fixes the problem by waking the thread each time
>> after the value is updated.
>>
>> This also may be useful for debug purposes; and also for userspace
>> daemons, which change sleep_millisecs value in dependence of
>> system load.
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> Kirill, can we rather reuse @ksm_thread variable from ksm_init
> (by moving it to static file level variable).

I've considered using it, but this is not looks good for me.
The problem is ksm thread may be parked, or it even may fail
to start. But at the same time, parallel writes to "sleep_millisecs"
are possible. There is a place for races, so to use the local
variable in ksm_init() (like we have at the moment) looks better
for me. At the patch the mutex protects against any races.

> Also wakening up
> unconditionally on write looks somehow suspicious to me
> though I don't have a precise argument against.

The conditional wait requires one more wait_queue. This is
the thing I tried to avoid. But. I also had doubts about
this, so you are already the second person, who worries :)
It looks like we really need to change this.

How are you about something like the below?

diff --git a/mm/ksm.c b/mm/ksm.c
index 723bd32d4dd0..66d962a227e7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -296,6 +296,7 @@ static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
 
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
+static DECLARE_WAIT_QUEUE_HEAD(ksm_iter_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
 
@@ -2432,6 +2433,8 @@ static int ksmd_should_run(void)
 
 static int ksm_scan_thread(void *nothing)
 {
+	unsigned int sleep_ms;
+
 	set_freezable();
 	set_user_nice(current, 5);
 
@@ -2440,13 +2443,15 @@ static int ksm_scan_thread(void *nothing)
 		wait_while_offlining();
 		if (ksmd_should_run())
 			ksm_do_scan(ksm_thread_pages_to_scan);
+		sleep_ms = ksm_thread_sleep_millisecs;
 		mutex_unlock(&ksm_thread_mutex);
 
 		try_to_freeze();
 
 		if (ksmd_should_run()) {
-			schedule_timeout_interruptible(
-				msecs_to_jiffies(ksm_thread_sleep_millisecs));
+			wait_event_interruptible_timeout(ksm_iter_wait,
+					sleep_ms != ksm_thread_sleep_millisecs,
+					msecs_to_jiffies(sleep_ms));
 		} else {
 			wait_event_freezable(ksm_thread_wait,
 				ksmd_should_run() || kthread_should_stop());
@@ -2864,7 +2869,10 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
 	if (err || msecs > UINT_MAX)
 		return -EINVAL;
 
+	mutex_lock(&ksm_thread_mutex);
 	ksm_thread_sleep_millisecs = msecs;
+	mutex_unlock(&ksm_thread_mutex);
+	wake_up_interruptible(&ksm_iter_wait);
 
 	return count;
 }
