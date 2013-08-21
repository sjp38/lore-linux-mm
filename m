Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 407166B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 23:58:01 -0400 (EDT)
Message-ID: <52143A8B.90400@asianux.com>
Date: Wed, 21 Aug 2013 11:56:59 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/backing-dev.c: check user buffer length before copy
 data to the related user buffer.
References: <5212E12C.5010005@asianux.com> <20130820162903.d5caeda1a6f119a5967a13a2@linux-foundation.org> <52143568.30708@asianux.com> <20130820204550.356e13b5.akpm@linux-foundation.org>
In-Reply-To: <20130820204550.356e13b5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, jmoyer@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org

On 08/21/2013 11:45 AM, Andrew Morton wrote:
> On Wed, 21 Aug 2013 11:35:04 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> 
>> On 08/21/2013 07:29 AM, Andrew Morton wrote:
>>> On Tue, 20 Aug 2013 11:23:24 +0800 Chen Gang <gang.chen@asianux.com> wrote:
>>>
>>>> '*lenp' may be less than "sizeof(kbuf)", need check it before the next
>>>> copy_to_user().
>>>>
>>>> pdflush_proc_obsolete() is called by sysctl which 'procname' is
>>>> "nr_pdflush_threads", if the user passes buffer length less than
>>>> "sizeof(kbuf)", it will cause issue.
>>>>
>>>> ...
>>>>
>>>> --- a/mm/backing-dev.c
>>>> +++ b/mm/backing-dev.c
>>>> @@ -649,7 +649,7 @@ int pdflush_proc_obsolete(struct ctl_table *table, int write,
>>>>  {
>>>>  	char kbuf[] = "0\n";
>>>>  
>>>> -	if (*ppos) {
>>>> +	if (*ppos || *lenp < sizeof(kbuf)) {
>>>>  		*lenp = 0;
>>>>  		return 0;
>>>>  	}
>>>
>>> Well sort-of.  If userspace opens /proc/sys/vm/nr_pdflush_threads and
>>> then does a series of one-byte reads, the kernel should return "0" on the
>>> first read, "\n" on the second and then EOF.
>>>
>>
>> Excuse me for my English, I guess your meaning is
>>
>>   "this patch is OK, but can be improvement"
>>
>> Is it correct ?
> 
> Not really.  I was pointing out that the patched code doesn't correctly
> implement read(1) behavior.  But that is true of many other procfs
> files, so I suggest we not attempt to address the problem for this
> procfs file.
> 
> 
> 
> 

Hmm... does the fix below correctly implement read(1) behavior ?

----------------------------diff begin----------------------------------

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e04454c..d3be432 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -647,19 +647,19 @@ EXPORT_SYMBOL(wait_iff_congested);
 int pdflush_proc_obsolete(struct ctl_table *table, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	char kbuf[] = "0\n";
+	char kbuf[2] = {'0', '\n'};
 
 	if (*ppos) {
 		*lenp = 0;
 		return 0;
 	}
 
-	if (copy_to_user(buffer, kbuf, sizeof(kbuf)))
+	if (copy_to_user(buffer, kbuf, min(*lenp, sizeof(kbuf))))
 		return -EFAULT;
 	printk_once(KERN_WARNING "%s exported in /proc is scheduled for removal\n",
 			table->procname);
 
-	*lenp = 2;
+	*lenp = min(*lenp, sizeof(kbuf));
 	*ppos += *lenp;
 	return 2;
 }

----------------------------diff end------------------------------------


The diff above is not tested, if OK, I will send related patch after
finish the related test.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
