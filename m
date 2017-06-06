Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1A716B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 11:17:11 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n13so194652901ita.7
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 08:17:11 -0700 (PDT)
Received: from nm23-vm5.bullet.mail.ne1.yahoo.com (nm23-vm5.bullet.mail.ne1.yahoo.com. [98.138.91.245])
        by mx.google.com with ESMTPS id t26si34374916ioi.151.2017.06.06.08.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 08:17:10 -0700 (PDT)
Subject: Re: [PATCH 4/5] Make LSM Writable Hooks a command line option
References: <ff5714b2-bbb0-726d-2fe6-13d4f1a30a38@huawei.com>
 <201706061954.GBH56755.QSOOFMFLtJFVOH@I-love.SAKURA.ne.jp>
 <6c807793-6a39-82ef-93d9-29ad2546fc4c@huawei.com>
 <201706062042.GAC86916.FMtHOOFJOSVLFQ@I-love.SAKURA.ne.jp>
 <4c3e3b8b-6507-7da5-1537-1e0ce04fcba5@huawei.com>
 <201706062336.CFE35913.OFFLQOHMtSJFVO@I-love.SAKURA.ne.jp>
 <bff5442e-9ecd-9493-7397-7030ade63e81@huawei.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <61106c92-ab4c-4bc3-1cb9-d01b1845f670@schaufler-ca.com>
Date: Tue, 6 Jun 2017 08:17:01 -0700
MIME-Version: 1.0
In-Reply-To: <bff5442e-9ecd-9493-7397-7030ade63e81@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 6/6/2017 7:51 AM, Igor Stoppa wrote:
> On 06/06/17 17:36, Tetsuo Handa wrote:
>> Igor Stoppa wrote:
>>> For the case at hand, would it work if there was a non-API call that you
>>> could use until the API is properly expanded?
>> Kernel command line switching (i.e. this patch) is fine for my use cases.
>>
>> SELinux folks might want
>>
>> -static int security_debug;
>> +static int security_debug = IS_ENABLED(CONFIG_SECURITY_SELINUX_DISABLE);
> ok, thanks, I will add this
>
>> so that those who are using SELINUX=disabled in /etc/selinux/config won't
>> get oops upon boot by default. If "unlock the pool" were available,
>> SELINUX=enforcing users would be happy. Maybe two modes for rw/ro transition helps.
>>
>>   oneway rw -> ro transition mode: can't be made rw again by calling "unlock the pool" API
>>   twoway rw <-> ro transition mode: can be made rw again by calling "unlock the pool" API
> This was in the first cut of the API, but I was told that it would
> require further rework, to make it ok for upstream, so we agreed to do
> first the lockdown/destroy only part and the the rewrite.
>
> Is there really a valid use case for unloading SE Linux?

It's used today in the Redhat distros. There is talk of removing it.
You can only unload SELinux before policy is loaded, which is sort of
saying that you have your system misconfigured but can't figure out
how to fix it. You might be able to convince Paul Moore to accelerate
the removal of this feature for this worthy cause.

> Or any other security module.

I suppose that you could argue that if a security module had
been in place for 2 years on a system and had never once denied
anyone access it should be removed. That's a reasonable use case
description, but I doubt you'd encounter it in the real world.
Another possibility is a security module that is used during
container setup and once the system goes into full operation
is no longer needed. Personally, I don't see either of these
cases as compelling. "systemctl restart xyzzyd".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
