Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 485256B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 03:07:54 -0500 (EST)
Received: by obbww6 with SMTP id ww6so149066113obb.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:07:54 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id d199si1747075oih.12.2015.12.01.00.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 00:07:53 -0800 (PST)
Received: by oixx65 with SMTP id x65so111502302oix.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:07:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151130143915.50010329146ee04d92a26e49@linux-foundation.org>
References: <201511261619.Q4kX5Hst%fengguang.wu@intel.com>
	<20151130143915.50010329146ee04d92a26e49@linux-foundation.org>
Date: Tue, 1 Dec 2015 09:07:53 +0100
Message-ID: <CAMuHMdUU9VR7QzF_eVKke0RD5nzjYjssNRrhcsXSN86uYUrYcA@mail.gmail.com>
Subject: Re: [linux-next:master 3174/3442] fs/ocfs2/file.c:2297:3: note: in
 expansion of macro 'xchg'
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Ryan Ding <ryan.ding@oracle.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

On Mon, Nov 30, 2015 at 11:39 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 26 Nov 2015 16:45:21 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>> head:   7dd2ecb6facfd1ac1a1cccc908e88e20e65e5801
>> commit: 5d974dfe80b2322a6b0afc85beb15fe9bc233804 [3174/3442] ocfs2: fix ip_unaligned_aio deadlock with dio work queue
>> config: m68k-sun3_defconfig (attached as .config)
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout 5d974dfe80b2322a6b0afc85beb15fe9bc233804
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=m68k
>>
>> All warnings (new ones prefixed by >>):
>>
>>    In file included from arch/m68k/include/asm/atomic.h:6:0,
>>                     from include/linux/atomic.h:4,
>>                     from include/linux/spinlock.h:406,
>>                     from include/linux/wait.h:8,
>>                     from include/linux/fs.h:5,
>>                     from fs/ocfs2/file.c:27:
>>    fs/ocfs2/file.c: In function 'ocfs2_file_write_iter':
>>    arch/m68k/include/asm/cmpxchg.h:78:22: warning: value computed is not used [-Wunused-value]
>>     #define xchg(ptr,x) ((__typeof__(*(ptr)))__xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
>>                          ^
>> >> fs/ocfs2/file.c:2297:3: note: in expansion of macro 'xchg'
>>       xchg(&iocb->ki_complete, saved_ki_complete);
>>       ^
>>
>> vim +/xchg +2297 fs/ocfs2/file.c
>>
>>   2281                                written = ret;
>>   2282
>>   2283                        if (!ret) {
>>   2284                                ret = jbd2_journal_force_commit(osb->journal->j_journal);
>>   2285                                if (ret < 0)
>>   2286                                        written = ret;
>>   2287                        }
>>   2288
>>   2289                        if (!ret)
>>   2290                                ret = filemap_fdatawait_range(file->f_mapping,
>>   2291                                                              iocb->ki_pos - written,
>>   2292                                                              iocb->ki_pos - 1);
>>   2293                }
>>   2294
>>   2295        out:
>>   2296                if (saved_ki_complete)
>> > 2297                        xchg(&iocb->ki_complete, saved_ki_complete);
>>   2298
>>   2299                if (rw_level != -1)
>>   2300                        ocfs2_rw_unlock(inode, rw_level);
>>   2301
>>   2302        out_mutex:
>>   2303                mutex_unlock(&inode->i_mutex);
>>   2304
>>   2305                if (written)
>
> Beats me.  Maybe a glitch in the m68k compiler?

Known "issue" with the m68k  xchg() macro implementation.
Should fix that, one day...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
