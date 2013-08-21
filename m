Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4B0166B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 22:29:17 -0400 (EDT)
Message-ID: <521425BC.1090006@asianux.com>
Date: Wed, 21 Aug 2013 10:28:12 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/backing-dev.c: check user buffer length before copy
 data to the related user buffer.
References: <5212E12C.5010005@asianux.com> <20130820152809.GB2862@quack.suse.cz>
In-Reply-To: <20130820152809.GB2862@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/20/2013 11:28 PM, Jan Kara wrote:
> On Tue 20-08-13 11:23:24, Chen Gang wrote:
>> '*lenp' may be less than "sizeof(kbuf)", need check it before the next
>> copy_to_user().
>>
>> pdflush_proc_obsolete() is called by sysctl which 'procname' is
>> "nr_pdflush_threads", if the user passes buffer length less than
>> "sizeof(kbuf)", it will cause issue.
>>
>   Good catch. The patch looks good. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>
> 

Thanks.

> 								Honza
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  mm/backing-dev.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> index e04454c..2674671 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -649,7 +649,7 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
>>  {
>>  	char kbuf[] = "0\n";
>>  
>> -	if (*ppos) {
>> +	if (*ppos || *lenp < sizeof(kbuf)) {
>>  		*lenp = 0;
>>  		return 0;
>>  	}
>> -- 
>> 1.7.7.6


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
