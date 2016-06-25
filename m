Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id C76446B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 21:28:11 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id v6so79044345vkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 18:28:11 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id q10si7135607qke.40.2016.06.24.18.28.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 18:28:11 -0700 (PDT)
Subject: Re: [PATCH] memory:bugxfix panic on cat or write /dev/kmem
References: <1466703010-32242-1-git-send-email-chenjie6@huawei.com>
 <20160623124257.GB30082@dhcp22.suse.cz>
From: "Chenjie (K)" <chenjie6@huawei.com>
Message-ID: <576DDC46.6050607@huawei.com>
Date: Sat, 25 Jun 2016 09:20:06 +0800
MIME-Version: 1.0
In-Reply-To: <20160623124257.GB30082@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, panxuesong@huawei.comakpm@linux-foundation.org



On 2016/6/23 20:42, Michal Hocko wrote:
> On Fri 24-06-16 01:30:10, chenjie6@huawei.com wrote:
>> From: chenjie <chenjie6@huawei.com>
>>
>> cat /dev/kmem and echo > /dev/kmem will lead panic
>
> Writing to /dev/kmem without being extremely careful is a disaster AFAIK
> and even reading from the file can lead to unexpected results. Anyway
> I am trying to understand what exactly you are trying to fix here. Why
> writing to/reading from zero pfn should be any special wrt. any other
> potentially dangerous addresses
>

cat /dev/mem not panic. cat /dev/kmem, just the user's operation for 
nothing.

>>
>> Signed-off-by: chenjie <chenjie6@huawei.com>
>> ---
>>   drivers/char/mem.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
>> index 71025c2..4bdde28 100644
>> --- a/drivers/char/mem.c
>> +++ b/drivers/char/mem.c
>> @@ -412,6 +412,8 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
>>   			 * by the kernel or data corruption may occur
>>   			 */
>>   			kbuf = xlate_dev_kmem_ptr((void *)p);
>> +			if (!kbuf)
>> +				return -EFAULT;
>>
>>   			if (copy_to_user(buf, kbuf, sz))
>>   				return -EFAULT;
>> @@ -482,6 +484,11 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
>>   		 * corruption may occur.
>>   		 */
>>   		ptr = xlate_dev_kmem_ptr((void *)p);
>> +		if (!ptr) {
>> +			if (written)
>> +				break;
>> +			return -EFAULT;
>> +		}
>>
>>   		copied = copy_from_user(ptr, buf, sz);
>>   		if (copied) {
>> --
>> 1.8.0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
