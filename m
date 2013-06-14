Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 364566B0036
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:41:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 15:06:51 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id A7A0C125805B
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:10:06 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5E9fCMr23658678
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:11:13 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5E9f6CY021278
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 09:41:08 GMT
Date: Fri, 14 Jun 2013 17:41:05 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] mm/writeback: fix wb_do_writeback exported unsafely
Message-ID: <20130614094105.GA10412@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130614093121.GB28555@hli22-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130614093121.GB28555@hli22-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

On Fri, Jun 14, 2013 at 05:31:21PM +0800, Haicheng Li wrote:
>
>On Fri, Jun 14, 2013 at 03:30:34PM +0800, Wanpeng Li wrote:
>> There is just one caller in fs-writeback.c call wb_do_writeback and
>> current codes unnecessary export it in header file, this patch fix
>> it by changing wb_do_writeback to static function.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Hi Wanpeng,
>
>A simliar patch has been merged in -next tree with commit#: 836f29bbb0f7a08dbdf1ed3ee704ef8aea81e56f
>
>BTW, actually this should have nothing to do with safety, just unnecessary to export it globally.

Oh, I miss your commit, anyway, good to see your work. ;-)

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
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
