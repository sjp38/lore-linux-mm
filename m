Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B16046B006E
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 02:58:03 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so2136252pad.13
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 23:58:03 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id qq9si26170038pbb.102.2015.01.12.23.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 23:58:02 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI300INNVNDKL70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 13 Jan 2015 08:02:01 +0000 (GMT)
Message-id: <54B4CFF3.5060100@samsung.com>
Date: Tue, 13 Jan 2015 08:57:39 +0100
From: Andrzej Hajda <a.hajda@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 3/5] clk: convert clock name allocations to kstrdup_const
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
 <1421054323-14430-4-git-send-email-a.hajda@samsung.com>
 <20150112231104.20842.5239@quantum>
In-reply-to: <20150112231104.20842.5239@quantum>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Turquette <mturquette@linaro.org>, linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, sboyd@codeaurora.org

On 01/13/2015 12:11 AM, Mike Turquette wrote:
> Quoting Andrzej Hajda (2015-01-12 01:18:41)
>> Clock subsystem frequently performs duplication of strings located
>> in read-only memory section. Replacing kstrdup by kstrdup_const
>> allows to avoid such operations.
>>
>> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> Looks OK to me. Is there an easy trick to measuring the number of string
> duplications saved short of instrumenting your code with a counter?

I have just added pr_err in kstrdup_const:

diff --git a/mm/util.c b/mm/util.c
index c96fc4b..32a97b2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -56,8 +56,10 @@ EXPORT_SYMBOL(kstrdup);
 
 const char *kstrdup_const(const char *s, gfp_t gfp)
 {
-       if (is_kernel_rodata((unsigned long)s))
+       if (is_kernel_rodata((unsigned long)s)) {
+               pr_err("%s: %pS:%s\n", __func__,
__builtin_return_address(0), s);
                return s;
+       }
 
        return kstrdup(s, gfp);
 }

Probably printk buffer size should be increased:
CONFIG_LOG_BUF_SHIFT=17

Regards
Andrzej

>
> Regards,
> Mike
>
>> ---
>>  drivers/clk/clk.c | 12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/clk/clk.c b/drivers/clk/clk.c
>> index f4963b7..27e644a 100644
>> --- a/drivers/clk/clk.c
>> +++ b/drivers/clk/clk.c
>> @@ -2048,7 +2048,7 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
>>                 goto fail_out;
>>         }
>>  
>> -       clk->name = kstrdup(hw->init->name, GFP_KERNEL);
>> +       clk->name = kstrdup_const(hw->init->name, GFP_KERNEL);
>>         if (!clk->name) {
>>                 pr_err("%s: could not allocate clk->name\n", __func__);
>>                 ret = -ENOMEM;
>> @@ -2075,7 +2075,7 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
>>  
>>         /* copy each string name in case parent_names is __initdata */
>>         for (i = 0; i < clk->num_parents; i++) {
>> -               clk->parent_names[i] = kstrdup(hw->init->parent_names[i],
>> +               clk->parent_names[i] = kstrdup_const(hw->init->parent_names[i],
>>                                                 GFP_KERNEL);
>>                 if (!clk->parent_names[i]) {
>>                         pr_err("%s: could not copy parent_names\n", __func__);
>> @@ -2090,10 +2090,10 @@ struct clk *clk_register(struct device *dev, struct clk_hw *hw)
>>  
>>  fail_parent_names_copy:
>>         while (--i >= 0)
>> -               kfree(clk->parent_names[i]);
>> +               kfree_const(clk->parent_names[i]);
>>         kfree(clk->parent_names);
>>  fail_parent_names:
>> -       kfree(clk->name);
>> +       kfree_const(clk->name);
>>  fail_name:
>>         kfree(clk);
>>  fail_out:
>> @@ -2112,10 +2112,10 @@ static void __clk_release(struct kref *ref)
>>  
>>         kfree(clk->parents);
>>         while (--i >= 0)
>> -               kfree(clk->parent_names[i]);
>> +               kfree_const(clk->parent_names[i]);
>>  
>>         kfree(clk->parent_names);
>> -       kfree(clk->name);
>> +       kfree_const(clk->name);
>>         kfree(clk);
>>  }
>>  
>> -- 
>> 1.9.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
