Message-ID: <47D9BA19.8000504@cn.fujitsu.com>
Date: Fri, 14 Mar 2008 08:34:49 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] res_counter: introduce res_counter_write_u64()
References: <47D65A27.80605@cn.fujitsu.com> <20080311192117.f7e23636.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080311192117.f7e23636.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 11 Mar 2008 19:08:39 +0900
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> This function can be used to assign the value of a resource counter member.
>>
> Why don't you make this function to do the same work as res_counter_write() ?
> 

You mean to deal with write strategy? We don't need that complexity. If it does
the same work as res_counter_write(), it's just a redundant function. ;)

But I forgot to take res_counter->lock ...

> Thanks,
> -Kame
> 
> 
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
>> ---
>>  include/linux/res_counter.h |    9 ++++++---
>>  kernel/res_counter.c        |    9 +++++++++
>>  2 files changed, 15 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index 8cb1ecd..8c23f7f 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -41,9 +41,10 @@ struct res_counter {
>>  
>>  /**
>>   * Helpers to interact with userspace
>> - * res_counter_read_u64() - returns the value of the specified member.
>> - * res_counter_read/_write - put/get the specified fields from the
>> - * res_counter struct to/from the user
>> + * res_counter_read_64/_write_u64 - returns/assigns the value of the
>> + *	specified member
>> + * res_counter_read/_write - puts/gets the specified fields from the
>> + *	res_counter struct to/from the user
>>   *
>>   * @counter:     the counter in question
>>   * @member:  the field to work with (see RES_xxx below)
>> @@ -53,6 +54,8 @@ struct res_counter {
>>   */
>>  
>>  u64 res_counter_read_u64(struct res_counter *counter, int member);
>> +void res_counter_write_u64(struct res_counter *counter, int member,
>> +			   unsigned long long val);
>>  
>>  ssize_t res_counter_read(struct res_counter *counter, int member,
>>  		const char __user *buf, size_t nbytes, loff_t *pos,
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index 791ff2b..a16b727 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -97,6 +97,15 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
>>  	return *res_counter_member(counter, member);
>>  }
>>  
>> +void res_counter_write_u64(struct res_counter *counter, int member,
>> +			   unsigned long long val)
>> +{
>> +	unsigned long long *tmp;
>> +
>> +	tmp = res_counter_member(counter, member);
>> +	*tmp = val;
>> +}
>> +
>>  ssize_t res_counter_write(struct res_counter *counter, int member,
>>  		const char __user *userbuf, size_t nbytes, loff_t *pos,
>>  		int (*write_strategy)(char *st_buf, unsigned long long *val))
>> -- 
>> 1.5.4.rc3
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
