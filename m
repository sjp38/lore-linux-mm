Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C01456B005C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 00:54:25 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5089243pbb.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 21:54:25 -0700 (PDT)
Date: Sun, 10 Jun 2012 12:54:03 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] page-writeback.c: fix update bandwidth time judgment
 error
Message-ID: <20120610045300.GA29336@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1339302005-366-1-git-send-email-liwp.linux@gmail.com>
 <20120610043641.GA10355@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120610043641.GA10355@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, PeterZijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp@linux.vnet.ibm.com>

On Sun, Jun 10, 2012 at 12:36:41PM +0800, Fengguang Wu wrote:
>Wanpeng,
>
>Sorry this I won't take this: it don't really improve anything.  Even
>with the changed test, the real intervals are still some random values
>above (and not far away from) 200ms.. We are saying about 200ms
>intervals just for convenience.
>
But some parts like:

__bdi_update_bandwidth which bdi_update_bandwidth will call:

if(elapsed < BANDWIDTH_INTERVAL)
	return;

or

global_update_bandwidth:

if(time_before(now, update_time + BANDWIDTH_INTERVAL))
	return;

You me just ignore this disunion ?

Regards,
Wanpeng Li

>
>On Sun, Jun 10, 2012 at 12:20:05PM +0800, Wanpeng Li wrote:
>> From: Wanpneg Li <liwp@linux.vnet.ibm.com>
>> 
>> Since bdi_update_bandwidth function  should estimate write bandwidth at 200ms intervals,
>> so the time is bdi->bw_time_stamp + BANDWIDTH_INTERVAL == jiffies, but
>> if use time_is_after_eq_jiffies intervals will be bdi->bw_time_stamp +
>> BANDWIDTH_INTERVAL + 1.
>> 
>> Signed-off-by: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> ---
>>  mm/page-writeback.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index c833bf0..099e225 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1032,7 +1032,7 @@ static void bdi_update_bandwidth(struct backing_dev_info *bdi,
>>  				 unsigned long bdi_dirty,
>>  				 unsigned long start_time)
>>  {
>> -	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
>> +	if (time_is_after_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
>>  		return;
>>  	spin_lock(&bdi->wb.list_lock);
>>  	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
>> -- 
>> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
