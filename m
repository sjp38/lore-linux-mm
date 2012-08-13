Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 60B456B005A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 06:11:35 -0400 (EDT)
Message-ID: <5028D2B0.4010800@ce.jp.nec.com>
Date: Mon, 13 Aug 2012 19:10:56 +0900
From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] HWPOISON: undo memory error handling for dirty pagecache
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1344634913-13681-3-git-send-email-n-horiguchi@ah.jp.nec.com> <m2a9y2cpj7.fsf@firstfloor.org>
In-Reply-To: <m2a9y2cpj7.fsf@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 08/11/12 08:09, Andi Kleen wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
>> Current memory error handling on dirty pagecache has a bug that user
>> processes who use corrupted pages via read() or write() can't be aware
>> of the memory error and result in discarding dirty data silently.
>>
>> The following patch is to improve handling/reporting memory errors on
>> this case, but as a short term solution I suggest that we should undo
>> the present error handling code and just leave errors for such cases
>> (which expect the 2nd MCE to panic the system) to ensure data consistency.
> 
> Not sure that's the right approach. It's not worse than any other IO 
> errors isn't it? 

IMO, it's worse in certain cases.  For example, producer-consumer type
program which uses file as a temporary storage.
Current memory-failure.c drops produced data from dirty pagecache
and allows reader to consume old or empty data from disk (silently!),
that's what I think HWPOISON should prevent.

Similar thing could happen theoretically with disk I/O errors,
though, practically those errors are often persistent and reader will
likely get errors again instead of bad data.
Also, ext3/ext4 has an option to panic when an error is detected,
for people who want to avoid corruption on intermittent errors.

-- 
Jun'ichi Nomura, NEC Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
