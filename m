Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: Re: [PATCH v2] ksm: React on changing "sleep_millisecs" parameter
 faster
References: <20181211100346.GE2342@uranus.lan>
 <154452399396.4921.3418365102240528000.stgit@localhost.localdomain>
 <20181211111300.GF2342@uranus.lan>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <26fb047f-9164-96ae-a6cd-7a7efa41d43b@virtuozzo.com>
Date: Tue, 11 Dec 2018 15:22:42 +0300
MIME-Version: 1.0
In-Reply-To: <20181211111300.GF2342@uranus.lan>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com
List-ID: <linux-mm.kvack.org>

On 11.12.2018 14:13, Cyrill Gorcunov wrote:
> On Tue, Dec 11, 2018 at 01:26:59PM +0300, Kirill Tkhai wrote:
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
>>
>> v2: Use wait_event_interruptible_timeout() instead of unconditional
>>     schedule_timeout().
> ...
>> @@ -2844,7 +2849,10 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
>>  	if (err || msecs > UINT_MAX)
>>  		return -EINVAL;
>>  
>> +	mutex_lock(&ksm_thread_mutex);
>>  	ksm_thread_sleep_millisecs = msecs;
>> +	mutex_unlock(&ksm_thread_mutex);
>> +	wake_up_interruptible(&ksm_iter_wait);
> 
> Btw, just thought -- if we start using this mutex here don't we
> open a window for force attack on the thread self execution,
> iow if there gonna be a million of writers do we have a guarantee
> thread ksm_scan_thread will grab the mutex earlier than writers
> (or somewhere inbetween)?

This file is permitted for global root only. I don't think there is
a problem.

If someone wants to make ksm helpless, a person may just write a big
"sleep_millisecs" value. KSM thread won't be executed almost all the time
in this case.

Kirill
