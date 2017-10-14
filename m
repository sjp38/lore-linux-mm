Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 227F46B0033
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 16:19:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so3459882pgo.20
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 13:19:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d25sor963412pfb.125.2017.10.14.13.19.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Oct 2017 13:19:38 -0700 (PDT)
Subject: Re: [PATCH for linux-next] mm/page-writeback.c: make changes of
 dirty_writeback_centisecs take effect immediately
References: <1507970307-16431-1-git-send-email-laoar.shao@gmail.com>
 <20171014175906.GA1825@zrhn9910b>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <b088d7e7-bda9-186d-9334-12f16aa92463@kernel.dk>
Date: Sat, 14 Oct 2017 14:19:34 -0600
MIME-Version: 1.0
In-Reply-To: <20171014175906.GA1825@zrhn9910b>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Damian Tometzki <damian.tometzki@icloud.com>, Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, yamada.masahiro@socionext.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/14/2017 11:59 AM, Damian Tometzki wrote:
> On Sat, 14. Oct 16:38, Yafang Shao wrote:
>> This patch is the followup of the prvious patch:
>> [writeback: schedule periodic writeback with sysctl].
>>
>> There's another issue to fix.
>> For example,
>> - When the tunable was set to one hour and is reset to one second, the
>>   new setting will not take effect for up to one hour.
>>
>> Kicking the flusher threads immediately fixes it.
>>
>> Cc: Jens Axboe <axboe@kernel.dk>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>> ---
>>  mm/page-writeback.c | 11 ++++++++++-
>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 3969e69..768fe4e 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1978,7 +1978,16 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
>>  	int ret;
>>  
>>  	ret = proc_dointvec(table, write, buffer, length, ppos);
>> -	if (!ret && !old_interval && dirty_writeback_interval)
>> +
>> +	/*
>> +	 * Writing 0 to dirty_writeback_interval will disable periodic writeback
>> +	 * and a different non-zero value will wakeup the writeback threads.
>> +	 * wb_wakeup_delayed() would be more appropriate, but it's a pain to
>> +	 * iterate over all bdis and wbs.
>> +	 * The reason we do this is to make the change take effect immediately.
>> +	 */
>> +	if (!ret && write && dirty_writeback_interval &&
>> +		dirty_writeback_interval != old_interval)
>>  		wakeup_flusher_threads(WB_REASON_PERIODIC);
> Is that call right ? The call need two arguments ?
> --> wakeup_flusher_threads(0,WB_REASON_PERIODIC);

It's right, the nr_pages argument was killed.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
