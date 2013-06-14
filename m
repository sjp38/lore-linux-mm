Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 188E56B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 06:33:15 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 19:12:20 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 029C22CE81FB
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 19:14:11 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5E8xY091311116
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 18:59:34 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5E9E9IO004503
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 19:14:10 +1000
Date: Fri, 14 Jun 2013 17:14:07 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
Message-ID: <20130614091407.GA2970@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130614090217.GA7574@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130614090217.GA7574@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 14, 2013 at 11:02:17AM +0200, Michal Hocko wrote:
>On Fri 14-06-13 15:30:34, Wanpeng Li wrote:
>> There is just one caller in fs-writeback.c call wb_do_writeback and
>> current codes unnecessary export it in header file, this patch fix
>> it by changing wb_do_writeback to static function.
>
>So what?
>
>Besides that git grep wb_do_writeback tells that 
>mm/backing-dev.c:                       wb_do_writeback(me, 0);
>

I don't think this can be found in 3.10-rc1 ~ 3.10-rc5. ;-) 
Since Tejun's patchset commit 839a8e86("writeback: replace 
custom worker pool implementation with unbound workqueue")
merged, just one caller in fs/fs-writeback.c now. 

>Have you tested this at all?
>

I test them all against 3.10-rc5. ;-)

>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  fs/fs-writeback.c         | 2 +-
>>  include/linux/writeback.h | 1 -
>>  2 files changed, 1 insertion(+), 2 deletions(-)
>> 
>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>> index 3be5718..f892dec 100644
>> --- a/fs/fs-writeback.c
>> +++ b/fs/fs-writeback.c
>> @@ -959,7 +959,7 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
>>  /*
>>   * Retrieve work items and do the writeback they describe
>>   */
>> -long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
>> +static long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
>>  {
>>  	struct backing_dev_info *bdi = wb->bdi;
>>  	struct wb_writeback_work *work;
>> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
>> index 579a500..e27468e 100644
>> --- a/include/linux/writeback.h
>> +++ b/include/linux/writeback.h
>> @@ -94,7 +94,6 @@ int try_to_writeback_inodes_sb_nr(struct super_block *, unsigned long nr,
>>  void sync_inodes_sb(struct super_block *);
>>  long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
>>  				enum wb_reason reason);
>> -long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
>>  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
>>  void inode_wait_for_writeback(struct inode *inode);
>>  
>> -- 
>> 1.8.1.2
>> 
>
>-- 
>Michal Hocko
>SUSE Labs
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
