Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B29306B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 08:19:01 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u36so1247882wrf.21
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 05:19:01 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id p2si6575951edb.312.2018.03.07.05.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 05:19:00 -0800 (PST)
Subject: Re: [PATCH 6/7] lkdtm: crash on overwriting protected pmalloc var
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-7-igor.stoppa@huawei.com>
 <1723ee8d-c89e-0704-c2c3-254eda39dc8b@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <6378e63e-174f-642e-d319-1d121b74d3d7@huawei.com>
Date: Wed, 7 Mar 2018 15:18:16 +0200
MIME-Version: 1.0
In-Reply-To: <1723ee8d-c89e-0704-c2c3-254eda39dc8b@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 06/03/18 19:20, J Freyensee wrote:

> On 2/28/18 12:06 PM, Igor Stoppa wrote:

[...]

>>   void __init lkdtm_perms_init(void);
>>   void lkdtm_WRITE_RO(void);
>>   void lkdtm_WRITE_RO_AFTER_INIT(void);
>> +void lkdtm_WRITE_RO_PMALLOC(void);
> 
> Does this need some sort of #ifdef too?

Not strictly. It's just a function declaration.
As long as it is not used, the linker will not complain.
The #ifdef placed around the use and definition is sufficient, from a
correctness perspective.

But it's a different question if there is any standard in linux about
hiding also the declaration.

I am not very fond of #ifdefs, so when I can I try to avoid them.

>> +	pr_info("attempting bad pmalloc write at %p\n", i);
>> +	*i = 0;
> 
> OK, now I'm on the right version of this patch series, same comment 
> applies.A  I don't get the local *i assignment at the end of the 
> function, but seems harmless.


Because that's the whole point of the function: prove that pmalloc
protection works (see the message in the pr_info one line above).

The function is supposed to do:

* create a pool
* allocate memory from it
* protect it
* try to alter it (and crash)

*i = 0; performs the last step

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
