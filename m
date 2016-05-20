Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2A536B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 06:33:26 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c67so230538321vkh.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 03:33:26 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id i1si10308426vkf.195.2016.05.20.03.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 03:33:25 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id v68so15986483vka.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 03:33:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160520040836.GA573@swordfish>
References: <CADAEsF-kaCQnNN_9gySw3J0UT4mGh8KFp75tGSJtaDAuN1T10A@mail.gmail.com>
 <1463671123-5479-1-git-send-email-ddstreet@ieee.org> <20160520040836.GA573@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 20 May 2016 06:32:46 -0400
Message-ID: <CALZtONCq-V-r7xYLmkJNsqYf3CbR=mPjRP7Fjp=n-9TaKvHqZw@mail.gmail.com>
Subject: Re: [PATCHv2] mm/zsmalloc: don't fail if can't create debugfs info
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Fri, May 20, 2016 at 12:08 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (05/19/16 11:18), Dan Streetman wrote:
> [..]
>>       zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
>>       if (!zs_stat_root)
>> -             return -ENOMEM;
>> -
>> -     return 0;
>> +             pr_warn("debugfs 'zsmalloc' stat dir creation failed\n");
>>  }
>>
>>  static void __exit zs_stat_exit(void)
>> @@ -573,17 +575,19 @@ static const struct file_operations zs_stat_size_ops = {
>>       .release        = single_release,
>>  };
>>
>> -static int zs_pool_stat_create(struct zs_pool *pool, const char *name)
>> +static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
>>  {
>>       struct dentry *entry;
>>
>> -     if (!zs_stat_root)
>> -             return -ENODEV;
>> +     if (!zs_stat_root) {
>> +             pr_warn("no root stat dir, not creating <%s> stat dir\n", name);
>> +             return;
>> +     }
>
> just a small nit, there are basically two warn messages now for
> `!zs_stat_root':
>
>         debugfs 'zsmalloc' stat dir creation failed
>         no root stat dir, not creating <%s> stat dir

They're logged at different times though, the first at module load
time, the second at every pool creation time.  So while they may be
logged together if the module is loaded because a pool is being
created, any later pools created will only log the second message.

>
> may be we need only one of them; but no strong opinions.

If we drop either, I'd drop the first, but I think it could be useful
also in case zsmalloc is built-in or manually loaded without creating
a pool.

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
