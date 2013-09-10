Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 1B78D6B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 20:48:21 -0400 (EDT)
Message-ID: <522E6C14.7060006@asianux.com>
Date: Tue, 10 Sep 2013 08:47:16 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/10/2013 04:30 AM, David Rientjes wrote:
> On Thu, 5 Sep 2013, Chen Gang wrote:
> 
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index f00c1c1..b4d44db 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -883,16 +883,20 @@ redirty:
>>  
>>  #ifdef CONFIG_NUMA
>>  #ifdef CONFIG_TMPFS
>> -static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>> +static int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>  {
>>  	char buffer[64];
>> +	int ret;
>>  
>>  	if (!mpol || mpol->mode == MPOL_DEFAULT)
>> -		return;		/* show nothing */
>> +		return 0;		/* show nothing */
>>  
>> -	mpol_to_str(buffer, sizeof(buffer), mpol);
>> +	ret = mpol_to_str(buffer, sizeof(buffer), mpol);
> 
> I was wondering how mpol_to_str() could fail given a pointer to a stack 
> allocated buffer, so I checked and it happens if the mempolicy mode isn't 
> known or the buffer isn't long enough.
> 

Yeah.

> I think it would be better to keep mpol_to_str() returning void, and hence 
> avoiding the need for this patch, and make it so it cannot fail.  If the 
> mode is invalid, just store a 0 to the buffer (or "unknown"); and if 
> maxlen isn't large enough, make it a compile-time error (let's avoid 
> trying to be fancy and allocating less than 64 bytes on the stack if a 
> given context is known to have short mempolicy strings).
> 

Hmm... at least, like most of print functions, it need return a value
to tell the length it writes, so in my opinion, I still suggest it can
return a value.

For common printing functions, caller knows about the string format and
all parameters, and also can control them,  so for callee, it is not
'quite polite' to return any failures to caller.  :-)

But for our function, caller may not know about the string format and
parameters' details, so callee has duty to check and process them:

  e.g. "if related parameter is invalid, it is neccessary to notifiy to caller".


Thanks.

>> +	if (ret < 0)
>> +		return ret;
>>  
>>  	seq_printf(seq, ",mpol=%s", buffer);
>> +	return 0;
>>  }
>>  
>>  static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
>> @@ -951,8 +955,9 @@ static struct page *shmem_alloc_page(gfp_t gfp,
>>  }
>>  #else /* !CONFIG_NUMA */
>>  #ifdef CONFIG_TMPFS
>> -static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>> +static inline int shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
>>  {
>> +	return 0;
>>  }
>>  #endif /* CONFIG_TMPFS */
>>  
>> @@ -2555,8 +2560,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
>>  	if (!gid_eq(sbinfo->gid, GLOBAL_ROOT_GID))
>>  		seq_printf(seq, ",gid=%u",
>>  				from_kgid_munged(&init_user_ns, sbinfo->gid));
>> -	shmem_show_mpol(seq, sbinfo->mpol);
>> -	return 0;
>> +	return shmem_show_mpol(seq, sbinfo->mpol);
>>  }
>>  #endif /* CONFIG_TMPFS */
>>  
> 
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
