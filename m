Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9FAE76B003B
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 14:47:16 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id t12so5561920pdi.21
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 11:47:15 -0700 (PDT)
Message-ID: <51B8C230.6000902@linaro.org>
Date: Wed, 12 Jun 2013 11:47:12 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] vrange: Add new vrange(2) system call
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org> <1371010971-15647-6-git-send-email-john.stultz@linaro.org> <20130612164848.10b93db2@notabene.brown>
In-Reply-To: <20130612164848.10b93db2@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/11/2013 11:48 PM, NeilBrown wrote:
> On Tue, 11 Jun 2013 21:22:48 -0700 John Stultz <john.stultz@linaro.org> wrote:
>
>> From: Minchan Kim <minchan@kernel.org>
>>
>> This patch adds new system call sys_vrange.
>>
>> NAME
>> 	vrange - Mark or unmark range of memory as volatile
>>
>> SYNOPSIS
>> 	int vrange(unsigned_long start, size_t length, int mode,
>> 			 int *purged);
>>
> ...
>> 	purged: Pointer to an integer which will return 1 if
>> 	mode == VRANGE_NONVOLATILE and any page in the affected range
>> 	was purged. If purged returns zero during a mode ==
>> 	VRANGE_NONVOLATILE call, it means all of the pages in the range
>> 	are intact.
> This seems a bit ambiguous.
> It is clear that the pointed-to location will be set to '1' if any part of
> the range was purged, but it is not clear what will happen if it wasn't
> purged.
> The mention of 'returns zero' seems to suggest that it might set the location
> to '0' in that case, but that isn't obvious to me.  The code appear to always
> set it - that should be explicit.
>
> Also, should the location be a fixed number of bytes to reduce possible
> issues with N-bit userspace on M-bit kernels?
>
> May I suggest:
>
>          purge:  If not NULL, a pointer to a 32bit location which will be set
>          to 1 if mode == VRANGE_NONVOLATILE and any page in the affected range
>          was purged, and will be set to 0 in all other cases (including
>          if mode == VRANGE_VOLATILE).
>
>
> I don't think any further explanation is needed.

I'll use this! Thanks for the suggestion!


>> +	if (purged) {
>> +		/* Test pointer is valid before making any changes */
>> +		if (put_user(p, purged))
>> +			return -EFAULT;
>> +	}
>> +
>> +	ret = do_vrange(mm, start, end - 1, mode, &p);
>> +
>> +	if (purged) {
>> +		if (put_user(p, purged)) {
>> +			/*
>> +			 * This would be bad, since we've modified volatilty
>> +			 * and the change in purged state would be lost.
>> +			 */
>> +			BUG();
>> +		}
>> +	}
> I agree that would be bad, but I don't think a BUG() is called for.  Maybe a
> WARN, and certainly a "return -EFAULT;"

Yea, this was a late change before I sent out the patches. In reviewing 
the documentation I realized we still could return an error and the 
purge data was lost. Thus I added the earlier test to make sure the 
pointer is valid before we take any action.

The BUG() was mostly for my own testing, and I'll change it in the 
future, although I want to sort out exactly in what cases the second 
put_user() could fail if the first succeeded.

Thanks as always for the great feedback!
-john





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
