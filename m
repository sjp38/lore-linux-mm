Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7032E6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 02:07:12 -0400 (EDT)
Message-ID: <51CD27F3.30104@infradead.org>
Date: Thu, 27 Jun 2013 23:06:43 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2013-06-27-16-36 uploaded (wait event common)
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com> <51CD1F81.4040202@infradead.org> <20130627225139.798e7b00.akpm@linux-foundation.org>
In-Reply-To: <20130627225139.798e7b00.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

On 06/27/13 22:51, Andrew Morton wrote:
> On Thu, 27 Jun 2013 22:30:41 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 06/27/13 16:37, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2013-06-27-16-36 has been uploaded to
>>>
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> mmotm-readme.txt says
>>>
>>> README for mm-of-the-moment:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>
>> My builds are littered with hundreds of warnings like this one:
>>
>> drivers/tty/tty_ioctl.c:220:6: warning: the omitted middle operand in ?: will always be 'true', suggest explicit middle operand [-Wparentheses]
>>
>> I guess due to this line from wait_event_common():
>>
>> +		__ret = __wait_no_timeout(tout) ?: (tout) ?: 1;
>>
> 
> Ah, sorry, I missed that.  Had I noticed it, I would have spat it back
> on taste grounds alone, it being unfit for human consumption.
> 
> Something like this?
> 
> --- a/include/linux/wait.h~wait-introduce-wait_event_commonwq-condition-state-timeout-fix
> +++ a/include/linux/wait.h
> @@ -196,7 +196,11 @@ wait_queue_head_t *bit_waitqueue(void *,
>  	for (;;) {							\
>  		prepare_to_wait(&wq, &__wait, state);			\
>  		if (condition) {					\
> -			__ret = __wait_no_timeout(tout) ?: __tout ?: 1;	\
> +			__ret = __wait_no_timeout(tout);		\
> +			if (!__ret)					\
> +				__ret = __tout;				\
> +				if (!__ret)				\
> +					__ret = 1;			\
>  			break;						\
>  		}							\
>  									\
> 
> 

That does reduce the number of warnings, but the wait_event_common() macro
needs similar treatment.  I.e., I am still getting those warnings, just not
quite as many. (down from 2 per source code line to 1 per source code line
which contains some kind of wait...)

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
