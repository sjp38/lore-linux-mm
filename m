Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] mm: Release a semaphore in 'get_vaddr_frames()'
Date: Mon, 11 Dec 2017 08:28:51 +0100
Message-ID: <p0lc3b$rh7$1@blaine.gmane.org>
References: <20171209070941.31828-1-christophe.jaillet@wanadoo.fr>
 <20171210094545.GW20234@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171210094545.GW20234@dhcp22.suse.cz>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Le 10/12/2017 à 10:45, Michal Hocko a écrit :
> On Sat 09-12-17 08:09:41, Christophe JAILLET wrote:
>> A semaphore is acquired before this check, so we must release it before
>> leaving.
>>
>> Fixes: b7f0554a56f2 ("mm: fail get_vaddr_frames() for filesystem-dax mappings")
>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
>> ---
>> -- Untested --
>>
>> The wording of the commit entry and log description could be improved
>> but I didn't find something better.
> The changelog is ok imo.
>
>> ---
>>   mm/frame_vector.c | 4 +++-
>>   1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
>> index 297c7238f7d4..e0c5e659fa82 100644
>> --- a/mm/frame_vector.c
>> +++ b/mm/frame_vector.c
>> @@ -62,8 +62,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
>>   	 * get_user_pages_longterm() and disallow it for filesystem-dax
>>   	 * mappings.
>>   	 */
>> -	if (vma_is_fsdax(vma))
>> +	if (vma_is_fsdax(vma)) {
>> +		up_read(&mm->mmap_sem);
>>   		return -EOPNOTSUPP;
>> +	}
> Is there any reason to do a different error handling than other error
> paths? Namely not going without goto out?

You are right, I misread the code after out:.
I thought it would override the returned value, but I was wrong.
'goto out' is definitively better, IMHO. I'll propose a v2.

CJ
