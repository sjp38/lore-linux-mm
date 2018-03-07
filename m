Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB9E6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 09:08:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p13so1199647wmc.6
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 06:08:25 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id c33si5086648edf.167.2018.03.07.06.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 06:08:23 -0800 (PST)
Subject: Re: [PATCH 4/7] Protectable Memory
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-5-igor.stoppa@huawei.com>
 <1b0aff92-bc6c-c815-f129-95720ec80778@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <a21118be-a066-6ad7-4188-f50585a6f06d@huawei.com>
Date: Wed, 7 Mar 2018 16:07:42 +0200
MIME-Version: 1.0
In-Reply-To: <1b0aff92-bc6c-c815-f129-95720ec80778@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 06/03/18 05:59, J Freyensee wrote:

[...]

>> +config PROTECTABLE_MEMORY
>> +    bool
>> +    depends on MMU
> 
> 
> Curious, would you also want to depend on "SECURITY" as well, as this is 
> being advertised as a compliment to __read_only_after_init, per the file 
> header comments, as I'm assuming ro_after_init would be disabled if the 
> SECURITY Kconfig selection is *NOT* selected?

__ro_after_init is configured like this:

#if defined(CONFIG_STRICT_KERNEL_RWX) || defined(CONFIG_STRICT_MODULE_RWX)
bool rodata_enabled __ro_after_init = true;

But even if __ro_after_init and pmalloc are conceptually similar, in
practice they have - potentially - different constraints.

1) the __ro_after_init segment belongs to linear kernel memory
2) the pmalloc pools belong to vmalloc memory

There is one extra layer of indirection in pmalloc.
I am not an expert of MMUs but I suppose there might be types where it
is possible to mark pages as RO but it's not possible to have virtual
memory.

If (and this is a big "if") such MMUs exist and are supported by linux,
then __ro_after_init would be possible, while pmalloc would not be.

So it seemed more correct to focus specifically on hte enablers required
by pmalloc to perform correctly.

Open Question:

Is it ok that the API disappears in case the enablers are missing?
Or should it fall back to something else?

Dealing with lack of ReadOnly support would be pretty simple, it would
be enough to make the write-Protection conditional.

But what to do if virtual mapping is not supported?

kmalloc might not have the ability to support large requests made toward
pmalloc and this would possibly cause runtime failures.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
