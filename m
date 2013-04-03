From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 6/8] staging: zcache: fix static variables defined in
 debug.h but used in mutiple C files
Date: Wed, 3 Apr 2013 08:04:32 +0800
Message-ID: <40325.5774909214$1364947514@news.gmane.org>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1364870780-16296-7-git-send-email-liwanp@linux.vnet.ibm.com>
 <CAPbh3rs8tXsZBYHrbXvyeASX1PUO+D0fez_fWK9pX-xUT-GuUQ@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UNBCR-0003C4-2f
	for glkm-linux-mm-2@m.gmane.org; Wed, 03 Apr 2013 02:05:11 +0200
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 950AB6B005C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 20:04:43 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 05:30:29 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 5E551125804E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:35:54 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3304VYJ5767652
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 05:34:32 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3304X1W005654
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 11:04:33 +1100
Content-Disposition: inline
In-Reply-To: <CAPbh3rs8tXsZBYHrbXvyeASX1PUO+D0fez_fWK9pX-xUT-GuUQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, Apr 02, 2013 at 11:17:37AM -0400, Konrad Rzeszutek Wilk wrote:
>On Mon, Apr 1, 2013 at 10:46 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> After commit 95bdaee214 ("zcache: Move debugfs code out of zcache-main.c file")
>> be merged, most of knods in zcache debugfs just export zero since these variables
>> are defined in debug.h but use in multiple C files zcache-main.c and debug.c, in
>
>I think you meant: "are in use in multiple.."

Thanks. ;-)

>> this case variables can't be treated as shared variables.
>
>You could also shove them in debug.c right? That way if you compile
>without CONFIG_DEBUGFS
>then you won't get warnings from unused variables?

Good point! 

Regards,
Wanpeng Li 

>
>>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/debug.h       |   62 +++++++++++++++++-----------------
>>  drivers/staging/zcache/zcache-main.c |   31 +++++++++++++++++
>>  2 files changed, 62 insertions(+), 31 deletions(-)
>>
>> diff --git a/drivers/staging/zcache/debug.h b/drivers/staging/zcache/debug.h
>> index 4bbe49b..8ec82d4 100644
>> --- a/drivers/staging/zcache/debug.h
>> +++ b/drivers/staging/zcache/debug.h
>> @@ -3,9 +3,9 @@
>>  #ifdef CONFIG_ZCACHE_DEBUG
>>
>>  /* we try to keep these statistics SMP-consistent */
>> -static ssize_t zcache_obj_count;
>> +extern ssize_t zcache_obj_count;
>>  static atomic_t zcache_obj_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_obj_count_max;
>> +extern ssize_t zcache_obj_count_max;
>>  static inline void inc_zcache_obj_count(void)
>>  {
>>         zcache_obj_count = atomic_inc_return(&zcache_obj_atomic);
>> @@ -17,9 +17,9 @@ static inline void dec_zcache_obj_count(void)
>>         zcache_obj_count = atomic_dec_return(&zcache_obj_atomic);
>>         BUG_ON(zcache_obj_count < 0);
>>  };
>> -static ssize_t zcache_objnode_count;
>> +extern ssize_t zcache_objnode_count;
>>  static atomic_t zcache_objnode_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_objnode_count_max;
>> +extern ssize_t zcache_objnode_count_max;
>>  static inline void inc_zcache_objnode_count(void)
>>  {
>>         zcache_objnode_count = atomic_inc_return(&zcache_objnode_atomic);
>> @@ -31,9 +31,9 @@ static inline void dec_zcache_objnode_count(void)
>>         zcache_objnode_count = atomic_dec_return(&zcache_objnode_atomic);
>>         BUG_ON(zcache_objnode_count < 0);
>>  };
>> -static u64 zcache_eph_zbytes;
>> +extern u64 zcache_eph_zbytes;
>>  static atomic_long_t zcache_eph_zbytes_atomic = ATOMIC_INIT(0);
>> -static u64 zcache_eph_zbytes_max;
>> +extern u64 zcache_eph_zbytes_max;
>>  static inline void inc_zcache_eph_zbytes(unsigned clen)
>>  {
>>         zcache_eph_zbytes = atomic_long_add_return(clen, &zcache_eph_zbytes_atomic);
>> @@ -46,7 +46,7 @@ static inline void dec_zcache_eph_zbytes(unsigned zsize)
>>  };
>>  extern  u64 zcache_pers_zbytes;
>>  static atomic_long_t zcache_pers_zbytes_atomic = ATOMIC_INIT(0);
>> -static u64 zcache_pers_zbytes_max;
>> +extern u64 zcache_pers_zbytes_max;
>>  static inline void inc_zcache_pers_zbytes(unsigned clen)
>>  {
>>         zcache_pers_zbytes = atomic_long_add_return(clen, &zcache_pers_zbytes_atomic);
>> @@ -59,7 +59,7 @@ static inline void dec_zcache_pers_zbytes(unsigned zsize)
>>  }
>>  extern ssize_t zcache_eph_pageframes;
>>  static atomic_t zcache_eph_pageframes_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_eph_pageframes_max;
>> +extern ssize_t zcache_eph_pageframes_max;
>>  static inline void inc_zcache_eph_pageframes(void)
>>  {
>>         zcache_eph_pageframes = atomic_inc_return(&zcache_eph_pageframes_atomic);
>> @@ -72,7 +72,7 @@ static inline void dec_zcache_eph_pageframes(void)
>>  };
>>  extern ssize_t zcache_pers_pageframes;
>>  static atomic_t zcache_pers_pageframes_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_pers_pageframes_max;
>> +extern ssize_t zcache_pers_pageframes_max;
>>  static inline void inc_zcache_pers_pageframes(void)
>>  {
>>         zcache_pers_pageframes = atomic_inc_return(&zcache_pers_pageframes_atomic);
>> @@ -83,21 +83,21 @@ static inline void dec_zcache_pers_pageframes(void)
>>  {
>>         zcache_pers_pageframes = atomic_dec_return(&zcache_pers_pageframes_atomic);
>>  }
>> -static ssize_t zcache_pageframes_alloced;
>> +extern ssize_t zcache_pageframes_alloced;
>>  static atomic_t zcache_pageframes_alloced_atomic = ATOMIC_INIT(0);
>>  static inline void inc_zcache_pageframes_alloced(void)
>>  {
>>         zcache_pageframes_alloced = atomic_inc_return(&zcache_pageframes_alloced_atomic);
>>  };
>> -static ssize_t zcache_pageframes_freed;
>> +extern ssize_t zcache_pageframes_freed;
>>  static atomic_t zcache_pageframes_freed_atomic = ATOMIC_INIT(0);
>>  static inline void inc_zcache_pageframes_freed(void)
>>  {
>>         zcache_pageframes_freed = atomic_inc_return(&zcache_pageframes_freed_atomic);
>>  }
>> -static ssize_t zcache_eph_zpages;
>> +extern ssize_t zcache_eph_zpages;
>>  static atomic_t zcache_eph_zpages_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_eph_zpages_max;
>> +extern ssize_t zcache_eph_zpages_max;
>>  static inline void inc_zcache_eph_zpages(void)
>>  {
>>         zcache_eph_zpages = atomic_inc_return(&zcache_eph_zpages_atomic);
>> @@ -110,7 +110,7 @@ static inline void dec_zcache_eph_zpages(unsigned zpages)
>>  }
>>  extern ssize_t zcache_pers_zpages;
>>  static atomic_t zcache_pers_zpages_atomic = ATOMIC_INIT(0);
>> -static ssize_t zcache_pers_zpages_max;
>> +extern ssize_t zcache_pers_zpages_max;
>>  static inline void inc_zcache_pers_zpages(void)
>>  {
>>         zcache_pers_zpages = atomic_inc_return(&zcache_pers_zpages_atomic);
>> @@ -130,23 +130,23 @@ static inline unsigned long curr_pageframes_count(void)
>>                 atomic_read(&zcache_pers_pageframes_atomic);
>>  };
>>  /* but for the rest of these, counting races are ok */
>> -static ssize_t zcache_flush_total;
>> -static ssize_t zcache_flush_found;
>> -static ssize_t zcache_flobj_total;
>> -static ssize_t zcache_flobj_found;
>> -static ssize_t zcache_failed_eph_puts;
>> -static ssize_t zcache_failed_pers_puts;
>> -static ssize_t zcache_failed_getfreepages;
>> -static ssize_t zcache_failed_alloc;
>> -static ssize_t zcache_put_to_flush;
>> -static ssize_t zcache_compress_poor;
>> -static ssize_t zcache_mean_compress_poor;
>> -static ssize_t zcache_eph_ate_tail;
>> -static ssize_t zcache_eph_ate_tail_failed;
>> -static ssize_t zcache_pers_ate_eph;
>> -static ssize_t zcache_pers_ate_eph_failed;
>> -static ssize_t zcache_evicted_eph_zpages;
>> -static ssize_t zcache_evicted_eph_pageframes;
>> +extern ssize_t zcache_flush_total;
>> +extern ssize_t zcache_flush_found;
>> +extern ssize_t zcache_flobj_total;
>> +extern ssize_t zcache_flobj_found;
>> +extern ssize_t zcache_failed_eph_puts;
>> +extern ssize_t zcache_failed_pers_puts;
>> +extern ssize_t zcache_failed_getfreepages;
>> +extern ssize_t zcache_failed_alloc;
>> +extern ssize_t zcache_put_to_flush;
>> +extern ssize_t zcache_compress_poor;
>> +extern ssize_t zcache_mean_compress_poor;
>> +extern ssize_t zcache_eph_ate_tail;
>> +extern ssize_t zcache_eph_ate_tail_failed;
>> +extern ssize_t zcache_pers_ate_eph;
>> +extern ssize_t zcache_pers_ate_eph_failed;
>> +extern ssize_t zcache_evicted_eph_zpages;
>> +extern ssize_t zcache_evicted_eph_pageframes;
>>
>>  extern ssize_t zcache_last_active_file_pageframes;
>>  extern ssize_t zcache_last_inactive_file_pageframes;
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index 14dcf8a..e112c1e 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -145,6 +145,37 @@ ssize_t zcache_pers_zpages;
>>  u64 zcache_pers_zbytes;
>>  ssize_t zcache_eph_pageframes;
>>  ssize_t zcache_pers_pageframes;
>> +ssize_t zcache_obj_count;
>> +ssize_t zcache_obj_count_max;
>> +ssize_t zcache_objnode_count;
>> +ssize_t zcache_objnode_count_max;
>> +u64 zcache_eph_zbytes;
>> +u64 zcache_eph_zbytes_max;
>> +u64 zcache_pers_zbytes_max;
>> +ssize_t zcache_eph_pageframes_max;
>> +ssize_t zcache_pers_pageframes_max;
>> +ssize_t zcache_pageframes_alloced;
>> +ssize_t zcache_pageframes_freed;
>> +ssize_t zcache_eph_zpages;
>> +ssize_t zcache_eph_zpages_max;
>> +ssize_t zcache_pers_zpages_max;
>> +ssize_t zcache_flush_total;
>> +ssize_t zcache_flush_found;
>> +ssize_t zcache_flobj_total;
>> +ssize_t zcache_flobj_found;
>> +ssize_t zcache_failed_eph_puts;
>> +ssize_t zcache_failed_pers_puts;
>> +ssize_t zcache_failed_getfreepages;
>> +ssize_t zcache_failed_alloc;
>> +ssize_t zcache_put_to_flush;
>> +ssize_t zcache_compress_poor;
>> +ssize_t zcache_mean_compress_poor;
>> +ssize_t zcache_eph_ate_tail;
>> +ssize_t zcache_eph_ate_tail_failed;
>> +ssize_t zcache_pers_ate_eph;
>> +ssize_t zcache_pers_ate_eph_failed;
>> +ssize_t zcache_evicted_eph_zpages;
>> +ssize_t zcache_evicted_eph_pageframes;
>>
>>  /* Used by this code. */
>>  ssize_t zcache_last_active_file_pageframes;
>> --
>> 1.7.7.6
>>
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
