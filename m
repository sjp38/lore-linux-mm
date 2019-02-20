Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2911FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D956320C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:56:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="flhp8ZHC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D956320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6330C8E000C; Wed, 20 Feb 2019 00:56:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E3708E0007; Wed, 20 Feb 2019 00:56:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC168E000C; Wed, 20 Feb 2019 00:56:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0995C8E0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:56:20 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h26so18029235pfn.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:56:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0BrDNTphJm/+rhmZn1YBz8NK1lKq/LyVvy5Bdga9dw0=;
        b=exCjh9XXm2QIJUJ+yA6CEsI/YGgnAkBlSSUGOlT8QyPY24ylgdXff6uaKGt9yGfuoE
         XxdFX1VWgx4Ef9HiYAeMEoMjc+XYM16oyUHCNmcJn2URh7kcDvSAhf9z5PYxAGX6P6cl
         vuYdouKt6CPEGmTudl3S2M+rqoe7r+VK+RglZftCmD3XpQXtwkcz6Q5kTISWHD9t4AIn
         +jtco/ASXdxLkikHVnNAB1pWvp28STDAoVZZCdw2s+r6Dk8Uu7dOrsrrqYyV8L3UA/xa
         C5AK9Fltxb8O/Up6Ihu3iSLXJ3kTxLc3Qd7b7yKk65wicFsWxxV/qHG11vKJEV7D/qxC
         00ew==
X-Gm-Message-State: AHQUAuauqHmrRf7m/r+pDanXudGkMDBYWnUXFPyVOJsClbAQvlItVtS0
	E5F1Z2jiffaT63iVFvDymFAYxCcl0BRcqSl9cUUP93mDho2KCUdPJOSXeGsBNu2vAwl5VCVNiMQ
	G42ZTc2NXHSdZ1+zkgT+fgc41h4WhT/q93V6Z2zOcwWg+6YsOIx95qR+0yigAgyqujw==
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr22324766plx.186.1550642179645;
        Tue, 19 Feb 2019 21:56:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8FnaBQIiuIlpxymlKThG91k1x9I6PDmvSSe7zvSbf0T6clEAD9iSLuz6kAvTorBsfMnkV
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr22324714plx.186.1550642178866;
        Tue, 19 Feb 2019 21:56:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550642178; cv=none;
        d=google.com; s=arc-20160816;
        b=YCXeaO6FL0Vgp7Noj2cjSj50QsxvugHTeE6ab1XqTM1yy4WiLH2s6Mh0o6s2aguBf7
         ewUyOUFlXmyXbhib4fSXOFIb8SsHzi+zXt1L3snaMDE4o3BsaqL5jyMcrRhXUNMB8mW4
         l5oDT5Q/8C1ikBJA6WD7kn8Q+9GYuFHB9PKLU3u41QCSWDmAPiy2oMor/89ggsWYbyK1
         kfJqyI7etmEzMR5A3/j0uGM92PkPKP4emfD/qHYsa4gMJBs5/AIzfuvLh5TuP8iYimhW
         z+UkjwiTC+TgM3LARuj8zyFcmahr5rWID+ya5Dpk7+/ok5FOlmZvsSHkx302YsXCfBMU
         T/ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0BrDNTphJm/+rhmZn1YBz8NK1lKq/LyVvy5Bdga9dw0=;
        b=yhcF5WidkYVj7HGWvHAOKUxydUDdVqTk5hlqe5qzExCrzCazioDfjxwpI6J1DjUoAe
         5kiD2YyW36IxutGqGM9ILhVXPchfMMebSlvcjqxhXzE6ekcQZ6zCLHZeQz2xV8HwawQX
         M0kKugBzW0kiifrgVqDE8oTTK1RjL/Pr5H1bl3wfgeBWsPKoEoxDsG4I+M1s7nIL63Q6
         Ms4qEIA6aCA28k5Ic8iIsR+1jqz2T42FfH/ObKiMwQsYoEe0gd7gGzQM8nKgTXr7Eyf7
         UEc3PCUrwPXkgiTVU8rp5YovlPZ9Ta8QHTQsRU/15X0s/XT5X1R7tomQuNUc5+kzq1kr
         4tDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=flhp8ZHC;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w15si4664112pgt.332.2019.02.19.21.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 21:56:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=flhp8ZHC;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0BrDNTphJm/+rhmZn1YBz8NK1lKq/LyVvy5Bdga9dw0=; b=flhp8ZHCcRCgJ2ahH7KBkZ8P4
	IEoJOLgd8dC8YGgKhCvHThpY+BpUIRegYTfc5Knt1wcfS8UR0niu2pLSHsKvZd4nlzBP8AuJ1iG7O
	W6Zh+qidvXs49K7aF5YRxoy801f/xv3FAMb32MnhbB46zigXqpTRjtn6NUvcK7N65ubo6dLPuZDts
	7qoCWi03Vc5NRGMVn3kPX5kqYB/2PgDr9mE3CHiNHtpZ6/sTjmwkL82fP/2nd1rWkC42yX+BKG12f
	9X1HiV5thCVawpgrI/9/RzNd/lFuucWtYHdvoJ2sJHuB3SJxgGqG1PaAPbDboFyh/UZDo74F2EeXO
	jXc4FvK8Q==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwKrg-00084a-Ba; Wed, 20 Feb 2019 05:56:16 +0000
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
To: "Bujnak, Stepan" <stepan@pex.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, mcgrof@kernel.org,
 hannes@cmpxchg.org
References: <20190220032245.2413-1-stepan@pex.com>
 <bc5d4f0f-8cbb-581a-5af3-2f178d6396fb@infradead.org>
 <CAFZe2nThWxhwGAbDEPkT5nQdFR_kaRvDhhk1_1c-EvPdR7_xfw@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <001a2f9c-4d3e-0e92-101f-84f115c35f02@infradead.org>
Date: Tue, 19 Feb 2019 21:56:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <CAFZe2nThWxhwGAbDEPkT5nQdFR_kaRvDhhk1_1c-EvPdR7_xfw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/19/19 8:30 PM, Bujnak, Stepan wrote:
> On Wed, Feb 20, 2019 at 5:10 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> Hi,
>>
>> Spell it out correctly (2 places):
> This is not a typo. It actually refers to the oom_dump_tasks option,
> in a sense that when that option is enabled,
> this option (oom_dump_task_cmdline) additionally displays task
> cmdline instead of task name.
>>

OK, thanks for clarifying.

>>
>> On 2/19/19 7:22 PM, Stepan Bujnak wrote:
>>> When oom_dump_tasks is enabled, this option will try to display task
>>
>>   When oom_dump_task_cmdline is enabled,
>>
>>> cmdline instead of the command name in the system-wide task dump.
>>>
>>> This is useful in some cases e.g. on postgres server. If OOM killer is
>>> invoked it will show a bunch of tasks called 'postgres'. With this
>>> option enabled it will show additional information like the database
>>> user, database name and what it is currently doing.
>>>
>>> Other example is python. Instead of just 'python' it will also show the
>>> script name currently being executed.
>>>
>>> Signed-off-by: Stepan Bujnak <stepan@pex.com>
>>> ---
>>>  Documentation/sysctl/vm.txt | 10 ++++++++++
>>>  include/linux/oom.h         |  1 +
>>>  kernel/sysctl.c             |  7 +++++++
>>>  mm/oom_kill.c               | 20 ++++++++++++++++++--
>>>  4 files changed, 36 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>>> index 187ce4f599a2..74278c8c30d2 100644
>>> --- a/Documentation/sysctl/vm.txt
>>> +++ b/Documentation/sysctl/vm.txt
>>> @@ -50,6 +50,7 @@ Currently, these files are in /proc/sys/vm:
>>>  - nr_trim_pages         (only if CONFIG_MMU=n)
>>>  - numa_zonelist_order
>>>  - oom_dump_tasks
>>> +- oom_dump_task_cmdline
>>>  - oom_kill_allocating_task
>>>  - overcommit_kbytes
>>>  - overcommit_memory
>>> @@ -639,6 +640,15 @@ The default value is 1 (enabled).
>>>
>>>  ==============================================================
>>>
>>> +oom_dump_task_cmdline
>>> +
>>> +When oom_dump_tasks is enabled, this option will try to display task cmdline
>>
>>    When oom_dump_task_cmdline is enabled,
>>
>>> +instead of the command name in the system-wide task dump.
>>> +
>>> +The default value is 0 (disabled).
>>> +
>>> +==============================================================
>>> +
>>>  oom_kill_allocating_task
>>>
>>>  This enables or disables killing the OOM-triggering task in
>>> diff --git a/include/linux/oom.h b/include/linux/oom.h
>>> index d07992009265..461b15b3b695 100644
>>> --- a/include/linux/oom.h
>>> +++ b/include/linux/oom.h
>>> @@ -125,6 +125,7 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>>>
>>>  /* sysctls */
>>>  extern int sysctl_oom_dump_tasks;
>>> +extern int sysctl_oom_dump_task_cmdline;
>>>  extern int sysctl_oom_kill_allocating_task;
>>>  extern int sysctl_panic_on_oom;
>>>  #endif /* _INCLUDE_LINUX_OOM_H */
>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>> index ba4d9e85feb8..4edc5f8e6cf9 100644
>>> --- a/kernel/sysctl.c
>>> +++ b/kernel/sysctl.c
>>> @@ -1288,6 +1288,13 @@ static struct ctl_table vm_table[] = {
>>>               .mode           = 0644,
>>>               .proc_handler   = proc_dointvec,
>>>       },
>>> +     {
>>> +             .procname       = "oom_dump_task_cmdline",
>>> +             .data           = &sysctl_oom_dump_task_cmdline,
>>> +             .maxlen         = sizeof(sysctl_oom_dump_task_cmdline),
>>> +             .mode           = 0644,
>>> +             .proc_handler   = proc_dointvec,
>>> +     },
>>>       {
>>>               .procname       = "overcommit_ratio",
>>>               .data           = &sysctl_overcommit_ratio,
>>
>>
>> thanks.
>> --
>> ~Randy


-- 
~Randy

